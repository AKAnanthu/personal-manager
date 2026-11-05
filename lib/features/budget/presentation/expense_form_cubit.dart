import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/utils/money.dart';
import 'package:personal_life_manager/features/budget/domain/budget_repository.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';

final class ExpenseFormState extends Equatable {
  const ExpenseFormState({
    this.loading = true,
    this.expenseId,
    this.amountText = '',
    this.description = '',
    this.spentOn,
    this.month,
    this.originalAmount = 0,
    this.dirty = false,
    this.busy = false,
    this.showErrors = false,
    this.failure,
    this.outcome = EditorOutcome.none,
  });

  final bool loading;
  final String? expenseId;
  final String amountText;
  final String description;
  final DateTime? spentOn;

  /// The chosen date's month, for "Leaves ₹X of ₹Y this month".
  final BudgetSummary? month;

  /// This expense's saved amount (already inside [month]'s total).
  final int originalAmount;
  final bool dirty;
  final bool busy;
  final bool showErrors;
  final Failure? failure;
  final EditorOutcome outcome;

  bool get isNew => expenseId == null;

  int? get amountPaise {
    final v = Money.parseRupees(amountText);
    return v != null && v > 0 ? v : null;
  }

  /// Remaining after this expense, or null without a budget.
  int? get leaves {
    final m = month;
    final budget = m?.budgetPaise;
    if (m == null || budget == null) return null;
    final sameMonth =
        !isNew &&
        originalAmount > 0 &&
        m.expenses.any((e) => e.id == expenseId);
    return budget -
        m.spentPaise +
        (sameMonth ? originalAmount : 0) -
        (amountPaise ?? 0);
  }

  ExpenseFormState copyWith({
    bool? loading,
    String? expenseId,
    String? amountText,
    String? description,
    DateTime? spentOn,
    BudgetSummary? month,
    int? originalAmount,
    bool? dirty,
    bool? busy,
    bool? showErrors,
    Failure? failure,
    bool clearFailure = false,
    EditorOutcome? outcome,
  }) => ExpenseFormState(
    loading: loading ?? this.loading,
    expenseId: expenseId ?? this.expenseId,
    amountText: amountText ?? this.amountText,
    description: description ?? this.description,
    spentOn: spentOn ?? this.spentOn,
    month: month ?? this.month,
    originalAmount: originalAmount ?? this.originalAmount,
    dirty: dirty ?? this.dirty,
    busy: busy ?? this.busy,
    showErrors: showErrors ?? this.showErrors,
    failure: clearFailure ? null : (failure ?? this.failure),
    outcome: outcome ?? this.outcome,
  );

  @override
  List<Object?> get props => [
    loading,
    expenseId,
    amountText,
    description,
    spentOn,
    month,
    originalAmount,
    dirty,
    busy,
    showErrors,
    failure,
    outcome,
  ];
}

/// Add or edit a manual expense.
class ExpenseFormCubit extends Cubit<ExpenseFormState> {
  ExpenseFormCubit({
    required this._repository,
    this.expenseId,
    this._clock = DateTime.now,
  }) : super(const ExpenseFormState());

  final BudgetRepository _repository;
  final String? expenseId;
  final DateTime Function() _clock;
  StreamSubscription<BudgetSummary>? _monthSub;

  Future<void> load() async {
    final now = _clock();
    final id = expenseId;
    final e = id == null ? null : await _repository.watchExpense(id).first;
    if (isClosed) return;
    if (id != null && (e == null || e.fromShopping)) {
      emit(state.copyWith(loading: false, failure: const NotFoundFailure()));
      return;
    }
    final date = e?.spentOn ?? DateTime(now.year, now.month, now.day);
    emit(
      state.copyWith(
        loading: false,
        expenseId: e?.id,
        amountText: e == null ? '' : Money.toInput(e.amountPaise),
        description: e?.description,
        spentOn: date,
        originalAmount: e?.amountPaise ?? 0,
      ),
    );
    _watchMonth(date);
  }

  void _watchMonth(DateTime d) {
    final month = BudgetMonth.of(d);
    if (_monthSub != null && state.month?.month == month) return;
    unawaited(_monthSub?.cancel());
    _monthSub = _repository.watchMonth(month).listen((m) {
      if (!isClosed) emit(state.copyWith(month: m));
    });
  }

  void amountChanged(String v) =>
      emit(state.copyWith(amountText: v, dirty: true));

  void descriptionChanged(String v) =>
      emit(state.copyWith(description: v, dirty: true));

  void dateChanged(DateTime d) {
    emit(state.copyWith(spentOn: d, dirty: true));
    _watchMonth(d);
  }

  Future<void> save() async {
    if (state.busy) return;
    final amount = state.amountPaise;
    final date = state.spentOn;
    if (amount == null || date == null) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(busy: true, clearFailure: true));
    final r = await _repository.saveExpense(
      ExpenseDraft(
        id: state.expenseId,
        amountPaise: amount,
        spentOn: date,
        description: state.description,
      ),
    );
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(busy: false, failure: f),
        (_) => state.copyWith(
          busy: false,
          dirty: false,
          outcome: EditorOutcome.saved,
        ),
      ),
    );
  }

  Future<void> delete() async {
    final id = state.expenseId;
    if (id == null) return;
    emit(state.copyWith(busy: true));
    final r = await _repository.deleteExpense(id);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(busy: false, failure: f),
        (_) => state.copyWith(busy: false, outcome: EditorOutcome.deleted),
      ),
    );
  }

  void clearFailure() => emit(state.copyWith(clearFailure: true));

  @override
  Future<void> close() async {
    await _monthSub?.cancel();
    await super.close();
  }
}

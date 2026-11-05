import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/budget/domain/budget_repository.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';

final class BudgetState extends Equatable {
  const BudgetState({
    required this.month,
    required this.currentMonth,
    this.summary,
    this.failure,
    this.deleted,
  });

  final BudgetMonth month;
  final BudgetMonth currentMonth;
  final BudgetSummary? summary;
  final Failure? failure;

  /// The expense just deleted, for undo.
  final Expense? deleted;

  bool get loading => summary?.month != month;
  bool get isCurrentMonth => month == currentMonth;

  BudgetState copyWith({
    BudgetMonth? month,
    BudgetSummary? summary,
    Failure? failure,
    Expense? deleted,
    bool clearTransient = false,
  }) => BudgetState(
    month: month ?? this.month,
    currentMonth: currentMonth,
    summary: summary ?? this.summary,
    failure: clearTransient ? null : (failure ?? this.failure),
    deleted: clearTransient ? null : (deleted ?? this.deleted),
  );

  @override
  List<Object?> get props => [month, currentMonth, summary, failure, deleted];
}

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit(this._repository, {DateTime Function() clock = DateTime.now})
    : super(
        BudgetState(
          month: BudgetMonth.of(clock()),
          currentMonth: BudgetMonth.of(clock()),
        ),
      );

  final BudgetRepository _repository;
  StreamSubscription<BudgetSummary>? _sub;

  void start() => _watch();

  void _watch() {
    unawaited(_sub?.cancel());
    _sub = _repository.watchMonth(state.month).listen(
      (s) {
        if (s.month == state.month) emit(state.copyWith(summary: s));
      },
      onError: (Object _) =>
          emit(state.copyWith(failure: const DatabaseFailure())),
    );
  }

  /// Earlier months stay browsable; future months are not shown.
  void previousMonth() {
    emit(state.copyWith(month: state.month.previous, clearTransient: true));
    _watch();
  }

  void nextMonth() {
    if (state.isCurrentMonth) return;
    emit(state.copyWith(month: state.month.next, clearTransient: true));
    _watch();
  }

  /// Sets the budget from the shown month onwards.
  Future<void> setBudget(int amountPaise) async {
    final r = await _repository.setBudget(state.month, amountPaise);
    if (isClosed) return;
    if (r case Err(:final failure)) emit(state.copyWith(failure: failure));
  }

  Future<void> deleteExpense(Expense e) async {
    emit(state.copyWith(clearTransient: true));
    final r = await _repository.deleteExpense(e.id);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(failure: f),
        (_) => state.copyWith(deleted: e),
      ),
    );
  }

  /// Puts a just-deleted manual expense back.
  Future<void> undoDelete() async {
    final e = state.deleted;
    if (e == null) return;
    emit(state.copyWith(clearTransient: true));
    await _repository.saveExpense(
      ExpenseDraft(
        amountPaise: e.amountPaise,
        spentOn: e.spentOn,
        description: e.description,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await super.close();
  }
}

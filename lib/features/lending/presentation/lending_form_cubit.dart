import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/utils/money.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';
import 'package:personal_life_manager/features/lending/domain/lending_repository.dart';

final class LendingFormState extends Equatable {
  const LendingFormState({
    this.loading = true,
    this.recordId,
    this.direction = LendingDirection.lent,
    this.person = '',
    this.amountText = '',
    this.givenOn,
    this.dueOn,
    this.notes = '',
    this.remind = true,
    this.status = LendingStatus.pending,
    this.dirty = false,
    this.busy = false,
    this.showErrors = false,
    this.failure,
    this.outcome = EditorOutcome.none,
    this.notificationsBlocked = false,
  });

  final bool loading;
  final String? recordId;
  final LendingDirection direction;
  final String person;
  final String amountText;
  final DateTime? givenOn;
  final DateTime? dueOn;
  final String notes;

  /// Only applies with a due date.
  final bool remind;
  final LendingStatus status;
  final bool dirty;
  final bool busy;
  final bool showErrors;
  final Failure? failure;
  final EditorOutcome outcome;
  final bool notificationsBlocked;

  bool get isNew => recordId == null;
  bool get personMissing => person.trim().isEmpty;

  int? get amountPaise {
    final v = Money.parseRupees(amountText);
    return v != null && v > 0 ? v : null;
  }

  /// A due date can't be before the date the money changed hands.
  bool get dueBeforeGiven {
    final g = givenOn;
    final d = dueOn;
    return g != null && d != null && d.isBefore(g);
  }

  bool get willRemind =>
      remind && dueOn != null && status == LendingStatus.pending;

  bool get hasErrors =>
      personMissing || amountPaise == null || givenOn == null || dueBeforeGiven;

  LendingFormState copyWith({
    bool? loading,
    String? recordId,
    LendingDirection? direction,
    String? person,
    String? amountText,
    DateTime? givenOn,
    DateTime? Function()? dueOn,
    String? notes,
    bool? remind,
    LendingStatus? status,
    bool? dirty,
    bool? busy,
    bool? showErrors,
    Failure? failure,
    bool clearFailure = false,
    EditorOutcome? outcome,
    bool? notificationsBlocked,
  }) => LendingFormState(
    loading: loading ?? this.loading,
    recordId: recordId ?? this.recordId,
    direction: direction ?? this.direction,
    person: person ?? this.person,
    amountText: amountText ?? this.amountText,
    givenOn: givenOn ?? this.givenOn,
    dueOn: dueOn != null ? dueOn() : this.dueOn,
    notes: notes ?? this.notes,
    remind: remind ?? this.remind,
    status: status ?? this.status,
    dirty: dirty ?? this.dirty,
    busy: busy ?? this.busy,
    showErrors: showErrors ?? this.showErrors,
    failure: clearFailure ? null : (failure ?? this.failure),
    outcome: outcome ?? this.outcome,
    notificationsBlocked: notificationsBlocked ?? this.notificationsBlocked,
  );

  @override
  List<Object?> get props => [
    loading,
    recordId,
    direction,
    person,
    amountText,
    givenOn,
    dueOn,
    notes,
    remind,
    status,
    dirty,
    busy,
    showErrors,
    failure,
    outcome,
    notificationsBlocked,
  ];
}

class LendingFormCubit extends Cubit<LendingFormState> {
  LendingFormCubit({
    required this._repository,
    required this._permissions,
    this.recordId,
    this.initialDirection = LendingDirection.lent,
    this._clock = DateTime.now,
  }) : super(const LendingFormState());

  final LendingRepository _repository;
  final NotificationPermissions _permissions;
  final String? recordId;
  final LendingDirection initialDirection;
  final DateTime Function() _clock;

  Future<void> load() async {
    final id = recordId;
    final now = _clock();
    if (id == null) {
      emit(
        state.copyWith(
          loading: false,
          direction: initialDirection,
          givenOn: DateTime(now.year, now.month, now.day),
        ),
      );
      return;
    }
    final r = await _repository.watchRecord(id).first;
    if (isClosed) return;
    if (r == null) {
      emit(state.copyWith(loading: false, failure: const NotFoundFailure()));
      return;
    }
    emit(
      state.copyWith(
        loading: false,
        recordId: r.id,
        direction: r.direction,
        person: r.person,
        amountText: Money.toInput(r.amountPaise),
        givenOn: r.givenOn,
        dueOn: () => r.dueOn,
        notes: r.notes,
        remind: r.remind,
        status: r.status,
      ),
    );
  }

  void directionChanged(LendingDirection d) =>
      emit(state.copyWith(direction: d, dirty: true));
  void personChanged(String v) => emit(state.copyWith(person: v, dirty: true));
  void amountChanged(String v) =>
      emit(state.copyWith(amountText: v, dirty: true));
  void givenOnChanged(DateTime d) =>
      emit(state.copyWith(givenOn: d, dirty: true));
  void dueOnChanged(DateTime? d) =>
      emit(state.copyWith(dueOn: () => d, dirty: true));
  void notesChanged(String v) => emit(state.copyWith(notes: v, dirty: true));
  void remindChanged({required bool value}) =>
      emit(state.copyWith(remind: value, dirty: true));
  void statusChanged(LendingStatus s) =>
      emit(state.copyWith(status: s, dirty: true));

  Future<void> save() async {
    if (state.busy) return;
    final amount = state.amountPaise;
    final given = state.givenOn;
    if (state.hasErrors || amount == null || given == null) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(busy: true, clearFailure: true));
    final r = await _repository.save(
      LendingDraft(
        id: state.recordId,
        direction: state.direction,
        person: state.person,
        amountPaise: amount,
        givenOn: given,
        dueOn: state.dueOn,
        status: state.status,
        notes: state.notes,
        remind: state.remind,
      ),
    );
    if (isClosed) return;
    if (r.fold((f) => f, (_) => null) case final f?) {
      emit(state.copyWith(busy: false, failure: f));
      return;
    }
    final blocked = state.willRemind && !await _permissions.ensurePermission();
    if (isClosed) return;
    emit(
      state.copyWith(
        busy: false,
        dirty: false,
        notificationsBlocked: blocked,
        outcome: EditorOutcome.saved,
      ),
    );
  }

  Future<void> delete() async {
    final id = state.recordId;
    if (id == null) return;
    emit(state.copyWith(busy: true));
    final r = await _repository.delete(id);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(busy: false, failure: f),
        (_) => state.copyWith(busy: false, outcome: EditorOutcome.deleted),
      ),
    );
  }

  void clearFailure() => emit(state.copyWith(clearFailure: true));
}

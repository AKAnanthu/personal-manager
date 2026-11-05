import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/reminders/domain/reminder.dart';
import 'package:personal_life_manager/features/reminders/domain/reminders_repository.dart';

enum ReminderAction { done, snoozed }

final class RemindersState extends Equatable {
  const RemindersState({
    required this.now,
    this.status = LoadStatus.loading,
    this.reminders = const [],
    this.failure,
    this.lastAction,
  });

  final LoadStatus status;
  final List<Reminder> reminders;
  final DateTime now;
  final Failure? failure;
  final ReminderAction? lastAction;

  List<Reminder> get overdue =>
      reminders.where((r) => r.isOverdue(now)).toList();
  List<Reminder> get upcoming =>
      reminders.where((r) => !r.isOverdue(now)).toList();

  RemindersState copyWith({
    LoadStatus? status,
    List<Reminder>? reminders,
    DateTime? now,
    Failure? failure,
    ReminderAction? lastAction,
    bool clearTransient = false,
  }) => RemindersState(
    status: status ?? this.status,
    reminders: reminders ?? this.reminders,
    now: now ?? this.now,
    failure: clearTransient ? null : (failure ?? this.failure),
    lastAction: clearTransient ? null : (lastAction ?? this.lastAction),
  );

  @override
  List<Object?> get props => [status, reminders, now, failure, lastAction];
}

class RemindersCubit extends Cubit<RemindersState> {
  RemindersCubit(this._repository, {this._clock = DateTime.now})
    : super(RemindersState(now: _clock()));

  final RemindersRepository _repository;
  final DateTime Function() _clock;
  StreamSubscription<List<Reminder>>? _sub;
  Timer? _tick;

  void start() {
    _sub ??= _repository.watchOpen().listen(
      (list) => emit(
        state.copyWith(
          reminders: list,
          status: LoadStatus.ready,
          now: _clock(),
        ),
      ),
      onError: (Object _) => emit(state.copyWith(status: LoadStatus.failure)),
    );
    // Re-classify overdue/upcoming as time passes.
    _tick ??= Timer.periodic(
      const Duration(minutes: 1),
      (_) => emit(state.copyWith(now: _clock())),
    );
  }

  Future<void> markDone(String id) =>
      _act(() => _repository.markDone(id), ReminderAction.done);

  Future<void> snoozeHour(String id) => _act(
    () => _repository.snooze(id, const Duration(hours: 1)),
    ReminderAction.snoozed,
  );

  Future<void> _act(
    Future<Result<void>> Function() run,
    ReminderAction action,
  ) async {
    emit(state.copyWith(clearTransient: true));
    final result = await run();
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(failure: f),
        (_) => state.copyWith(lastAction: action, now: _clock()),
      ),
    );
  }

  @override
  Future<void> close() async {
    _tick?.cancel();
    await _sub?.cancel();
    await super.close();
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/reminders/domain/reminder.dart';
import 'package:personal_life_manager/features/reminders/domain/reminders_repository.dart';

final class ReminderFormState extends Equatable {
  const ReminderFormState({
    this.loading = true,
    this.reminderId,
    this.title = '',
    this.description = '',
    this.date,
    this.hour,
    this.minute,
    this.repeat = RepeatFrequency.none,
    this.dirty = false,
    this.busy = false,
    this.showErrors = false,
    this.failure,
    this.outcome = EditorOutcome.none,
    this.notificationsBlocked = false,
  });

  final bool loading;
  final String? reminderId;
  final String title;
  final String description;
  final DateTime? date;
  final int? hour;
  final int? minute;
  final RepeatFrequency repeat;
  final bool dirty;
  final bool busy;
  final bool showErrors;
  final Failure? failure;
  final EditorOutcome outcome;
  final bool notificationsBlocked;

  bool get isNew => reminderId == null;
  bool get titleMissing => title.trim().isEmpty;
  bool get timeMissing => hour == null || minute == null;

  DateTime? get at {
    final d = date;
    final h = hour;
    final m = minute;
    if (d == null || h == null || m == null) return null;
    return DateTime(d.year, d.month, d.day, h, m);
  }

  /// A one-time reminder must be in the future; repeating ones roll forward.
  bool inPast(DateTime now) {
    final a = at;
    return repeat == RepeatFrequency.none && a != null && !a.isAfter(now);
  }

  ReminderFormState copyWith({
    bool? loading,
    String? reminderId,
    String? title,
    String? description,
    DateTime? date,
    int? hour,
    int? minute,
    RepeatFrequency? repeat,
    bool? dirty,
    bool? busy,
    bool? showErrors,
    Failure? failure,
    bool clearFailure = false,
    EditorOutcome? outcome,
    bool? notificationsBlocked,
  }) => ReminderFormState(
    loading: loading ?? this.loading,
    reminderId: reminderId ?? this.reminderId,
    title: title ?? this.title,
    description: description ?? this.description,
    date: date ?? this.date,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    repeat: repeat ?? this.repeat,
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
    reminderId,
    title,
    description,
    date,
    hour,
    minute,
    repeat,
    dirty,
    busy,
    showErrors,
    failure,
    outcome,
    notificationsBlocked,
  ];
}

class ReminderFormCubit extends Cubit<ReminderFormState> {
  ReminderFormCubit({
    required this._repository,
    required this._permissions,
    this.reminderId,
    this._clock = DateTime.now,
  }) : super(const ReminderFormState());

  final RemindersRepository _repository;
  final NotificationPermissions _permissions;
  final String? reminderId;
  final DateTime Function() _clock;
  DateTime? _originalAt;

  DateTime get now => _clock();

  /// Only a changed date/time must be in the future (an unchanged overdue
  /// reminder can still be edited).
  bool get timeInvalid => state.inPast(now) && state.at != _originalAt;

  Future<void> load() async {
    final id = reminderId;
    if (id == null) {
      // Default: the next full hour today (or tomorrow).
      final next = DateTime(now.year, now.month, now.day, now.hour + 1);
      emit(
        state.copyWith(
          loading: false,
          date: DateTime(next.year, next.month, next.day),
          hour: next.hour,
          minute: 0,
        ),
      );
      return;
    }
    final r = await _repository.watchReminder(id).first;
    if (isClosed) return;
    if (r == null) {
      emit(state.copyWith(loading: false, failure: const NotFoundFailure()));
      return;
    }
    // Editing shows the occurrence that's currently due.
    final at = r.repeat == RepeatFrequency.none ? r.dueAt : r.anchorAt;
    _originalAt = at;
    emit(
      state.copyWith(
        loading: false,
        reminderId: r.id,
        title: r.title,
        description: r.description,
        date: DateTime(at.year, at.month, at.day),
        hour: at.hour,
        minute: at.minute,
        repeat: r.repeat,
      ),
    );
  }

  void titleChanged(String v) => emit(state.copyWith(title: v, dirty: true));

  void descriptionChanged(String v) =>
      emit(state.copyWith(description: v, dirty: true));

  void dateChanged(DateTime d) =>
      emit(state.copyWith(date: DateTime(d.year, d.month, d.day), dirty: true));

  void timeChanged(int hour, int minute) =>
      emit(state.copyWith(hour: hour, minute: minute, dirty: true));

  void repeatChanged(RepeatFrequency r) =>
      emit(state.copyWith(repeat: r, dirty: true));

  Future<void> save() async {
    if (state.busy) return;
    final at = state.at;
    if (state.titleMissing || at == null || timeInvalid) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(busy: true, clearFailure: true));
    final r = await _repository.save(
      ReminderDraft(
        id: state.reminderId,
        title: state.title,
        description: state.description,
        at: at,
        repeat: state.repeat,
      ),
    );
    if (isClosed) return;
    if (!r.isSuccess) {
      emit(state.copyWith(busy: false, failure: r.fold((f) => f, (_) => null)));
      return;
    }
    final allowed = await _permissions.ensurePermission();
    if (isClosed) return;
    emit(
      state.copyWith(
        busy: false,
        dirty: false,
        notificationsBlocked: !allowed,
        outcome: EditorOutcome.saved,
      ),
    );
  }

  Future<void> delete() async {
    final id = state.reminderId;
    if (id == null) {
      emit(state.copyWith(outcome: EditorOutcome.discarded));
      return;
    }
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

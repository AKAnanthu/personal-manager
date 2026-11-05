import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine_repository.dart';

final class MedicineListState extends Equatable {
  const MedicineListState({
    this.status = LoadStatus.loading,
    this.medicines = const [],
    this.failure,
  });

  final LoadStatus status;
  final List<Medicine> medicines;
  final Failure? failure;

  MedicineListState copyWith({
    LoadStatus? status,
    List<Medicine>? medicines,
    Failure? failure,
    bool clearFailure = false,
  }) => MedicineListState(
    status: status ?? this.status,
    medicines: medicines ?? this.medicines,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [status, medicines, failure];
}

class MedicineListCubit extends Cubit<MedicineListState> {
  MedicineListCubit(this._repository) : super(const MedicineListState());

  final MedicineRepository _repository;
  StreamSubscription<List<Medicine>>? _sub;

  void start() {
    _sub ??= _repository.watchAll().listen(
      (m) => emit(state.copyWith(medicines: m, status: LoadStatus.ready)),
      onError: (Object _) => emit(state.copyWith(status: LoadStatus.failure)),
    );
  }

  Future<void> setEnabled(Medicine m, {required bool value}) async {
    emit(state.copyWith(clearFailure: true));
    final r = await _repository.setEnabled(m.id, value: value);
    if (isClosed) return;
    if (r case Err(:final failure)) emit(state.copyWith(failure: failure));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await super.close();
  }
}

final class MedicineFormState extends Equatable {
  const MedicineFormState({
    this.loading = true,
    this.medicineId,
    this.name = '',
    this.times = const [],
    this.everyDay = true,
    this.weekdays = const {},
    this.enabled = true,
    this.dirty = false,
    this.busy = false,
    this.showErrors = false,
    this.failure,
    this.outcome = EditorOutcome.none,
    this.notificationsBlocked = false,
  });

  final bool loading;
  final String? medicineId;
  final String name;

  /// Sorted, unique.
  final List<TimeOfDayMinutes> times;
  final bool everyDay;

  /// Used when not [everyDay].
  final Set<int> weekdays;
  final bool enabled;
  final bool dirty;
  final bool busy;
  final bool showErrors;
  final Failure? failure;
  final EditorOutcome outcome;
  final bool notificationsBlocked;

  bool get isNew => medicineId == null;
  bool get nameMissing => name.trim().isEmpty;
  bool get timesMissing => times.isEmpty;
  bool get daysMissing => !everyDay && weekdays.isEmpty;
  bool get hasErrors => nameMissing || timesMissing || daysMissing;

  MedicineFormState copyWith({
    bool? loading,
    String? medicineId,
    String? name,
    List<TimeOfDayMinutes>? times,
    bool? everyDay,
    Set<int>? weekdays,
    bool? enabled,
    bool? dirty,
    bool? busy,
    bool? showErrors,
    Failure? failure,
    bool clearFailure = false,
    EditorOutcome? outcome,
    bool? notificationsBlocked,
  }) => MedicineFormState(
    loading: loading ?? this.loading,
    medicineId: medicineId ?? this.medicineId,
    name: name ?? this.name,
    times: times ?? this.times,
    everyDay: everyDay ?? this.everyDay,
    weekdays: weekdays ?? this.weekdays,
    enabled: enabled ?? this.enabled,
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
    medicineId,
    name,
    times,
    everyDay,
    weekdays,
    enabled,
    dirty,
    busy,
    showErrors,
    failure,
    outcome,
    notificationsBlocked,
  ];
}

class MedicineFormCubit extends Cubit<MedicineFormState> {
  MedicineFormCubit({
    required this._repository,
    required this._permissions,
    this.medicineId,
  }) : super(const MedicineFormState());

  final MedicineRepository _repository;
  final NotificationPermissions _permissions;
  final String? medicineId;

  Future<void> load() async {
    final id = medicineId;
    if (id == null) {
      emit(state.copyWith(loading: false));
      return;
    }
    final m = await _repository.watchMedicine(id).first;
    if (isClosed) return;
    if (m == null) {
      emit(state.copyWith(loading: false, failure: const NotFoundFailure()));
      return;
    }
    emit(
      state.copyWith(
        loading: false,
        medicineId: m.id,
        name: m.name,
        times: m.times,
        everyDay: m.everyDay,
        weekdays: m.everyDay ? const {} : m.weekdays,
        enabled: m.enabled,
      ),
    );
  }

  void nameChanged(String v) => emit(state.copyWith(name: v, dirty: true));

  void addTime(TimeOfDayMinutes t) => emit(
    state.copyWith(times: ({...state.times, t}.toList()..sort()), dirty: true),
  );

  void removeTime(TimeOfDayMinutes t) => emit(
    state.copyWith(
      times: state.times.where((x) => x != t).toList(),
      dirty: true,
    ),
  );

  /// Switching to selected days starts from all seven ticked, so the
  /// natural next step is unticking the days to skip.
  void everyDayChanged({required bool value}) => emit(
    state.copyWith(
      everyDay: value,
      weekdays: value || state.weekdays.isNotEmpty
          ? null
          : {for (var d = 1; d <= 7; d++) d},
      dirty: true,
    ),
  );

  void weekdayToggled(int day) {
    final days = {...state.weekdays};
    if (!days.remove(day)) days.add(day);
    emit(state.copyWith(weekdays: days, dirty: true));
  }

  void enabledChanged({required bool value}) =>
      emit(state.copyWith(enabled: value, dirty: true));

  Future<void> save() async {
    if (state.busy) return;
    if (state.hasErrors) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(busy: true, clearFailure: true));
    final r = await _repository.save(
      MedicineDraft(
        id: state.medicineId,
        name: state.name,
        times: state.times,
        weekdays: state.everyDay ? const {} : state.weekdays,
        enabled: state.enabled,
      ),
    );
    if (isClosed) return;
    if (r case Err(:final failure)) {
      emit(state.copyWith(busy: false, failure: failure));
      return;
    }
    final blocked = state.enabled && !await _permissions.ensurePermission();
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
    final id = state.medicineId;
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

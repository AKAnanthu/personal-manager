import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/db/db_guard.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine_repository.dart';
import 'package:uuid/uuid.dart';

/// Notification text for one dose time, supplied by the app (l10n).
typedef DoseText = ({String title, String body}) Function(
  Medicine medicine,
  TimeOfDayMinutes time,
);

final class MedicineRepositoryImpl implements MedicineRepository {
  MedicineRepositoryImpl({
    required this._db,
    required this._onScheduleChanged,
    this._uuid = const Uuid(),
    this._clock = DateTime.now,
  });

  final AppDatabase _db;
  final void Function() _onScheduleChanged;
  final Uuid _uuid;
  final DateTime Function() _clock;

  $MedicinesTable get _t => _db.medicines;

  @override
  Stream<List<Medicine>> watchAll() =>
      (_db.select(_t)..orderBy([(m) => OrderingTerm.asc(m.name)])).watch().map(
        (rows) => rows.map(_map).toList(),
      );

  @override
  Stream<Medicine?> watchMedicine(String id) =>
      (_db.select(_t)..where((m) => m.id.equals(id))).watchSingleOrNull().map(
        (r) => r == null ? null : _map(r),
      );

  @override
  Future<Result<String>> save(MedicineDraft d) async {
    final times = (d.times.toSet().toList()..sort());
    if (d.name.trim().isEmpty || times.isEmpty) {
      return const Err(ValidationFailure('medicine'));
    }
    // All seven days is the same as every day.
    final days = d.weekdays.length == 7 ? <int>{} : d.weekdays;
    final r = await dbGuard(() async {
      final now = _clock();
      final companion = MedicinesCompanion(
        name: Value(d.name.trim()),
        times: Value(times),
        weekdays: Value(days),
        enabled: Value(d.enabled),
        updatedAt: Value(now),
      );
      final id = d.id;
      if (id == null) {
        final newId = _uuid.v4();
        await _db
            .into(_t)
            .insert(
              companion.copyWith(id: Value(newId), createdAt: Value(now)),
            );
        return newId;
      }
      final n = await (_db.update(
        _t,
      )..where((m) => m.id.equals(id))).write(companion);
      if (n == 0) throw const RecordNotFound();
      return id;
    });
    if (r.isSuccess) _onScheduleChanged();
    return r;
  }

  @override
  Future<Result<void>> setEnabled(String id, {required bool value}) async {
    final r = await dbGuard(() async {
      final n = await (_db.update(_t)..where((m) => m.id.equals(id))).write(
        MedicinesCompanion(enabled: Value(value), updatedAt: Value(_clock())),
      );
      if (n == 0) throw const RecordNotFound();
    });
    if (r.isSuccess) _onScheduleChanged();
    return r;
  }

  @override
  Future<Result<void>> delete(String id) async {
    final r = await dbGuard(
      () => (_db.delete(_t)..where((m) => m.id.equals(id))).go(),
    );
    if (r case Err(:final failure)) return Err(failure);
    _onScheduleChanged();
    return const Ok(null);
  }

  /// One source per dose time so each notification names its own time.
  /// Medicine has the highest priority in the iOS pending budget.
  Future<List<ScheduleSource>> notificationSources(DoseText text) async {
    final rows = await (_db.select(_t)..where((m) => m.enabled)).get();
    return [
      for (final m in rows.map(_map))
        for (final t in m.times) _source(m, t, text(m, t)),
    ];
  }

  static ScheduleSource _source(
    Medicine m,
    TimeOfDayMinutes t,
    ({String title, String body}) text,
  ) => ScheduleSource(
    kind: NotificationKind.medicine,
    entityId: '${m.id}@${t.hour}:${t.minute}',
    title: text.title,
    body: text.body,
    route: '/medicine/${m.id}',
    schedule: DailyTimesSchedule(times: [t], weekdays: m.weekdays),
  );

  static Medicine _map(MedicineRow r) => Medicine(
    id: r.id,
    name: r.name,
    times: r.times,
    weekdays: r.weekdays,
    enabled: r.enabled,
  );
}

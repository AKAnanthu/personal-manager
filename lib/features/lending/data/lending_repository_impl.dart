import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/db/db_guard.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';
import 'package:personal_life_manager/features/lending/domain/lending_repository.dart';
import 'package:uuid/uuid.dart';

/// Notification text, supplied by the app (l10n).
typedef LendingText = ({String title, String body}) Function(
  LendingRecord record,
);

final class LendingRepositoryImpl implements LendingRepository {
  LendingRepositoryImpl({
    required this._db,
    required this._onScheduleChanged,
    this._uuid = const Uuid(),
    this._clock = DateTime.now,
  });

  final AppDatabase _db;
  final void Function() _onScheduleChanged;
  final Uuid _uuid;
  final DateTime Function() _clock;

  $LendingRecordsTable get _t => _db.lendingRecords;

  @override
  Stream<LendingTab> watchTab(LendingDirection direction) =>
      (_db.select(
        _t,
      )..where((r) => r.direction.equalsValue(direction))).watch().map((rows) {
        final records = rows.map(_map).toList()..sort(_order);
        return LendingTab(records);
      });

  /// Pending first by due date (undated last), then completed, latest first.
  static int _order(LendingRecord a, LendingRecord b) {
    if (a.isPending != b.isPending) return a.isPending ? -1 : 1;
    if (a.isPending) {
      final x = a.dueOn;
      final y = b.dueOn;
      if (x != null && y != null && x != y) return x.compareTo(y);
      if ((x == null) != (y == null)) return x == null ? 1 : -1;
      return b.givenOn.compareTo(a.givenOn);
    }
    final x = a.completedOn ?? a.givenOn;
    final y = b.completedOn ?? b.givenOn;
    return y.compareTo(x);
  }

  @override
  Stream<LendingRecord?> watchRecord(String id) =>
      (_db.select(_t)..where((r) => r.id.equals(id))).watchSingleOrNull().map(
        (r) => r == null ? null : _map(r),
      );

  @override
  Stream<List<LendingRecord>> watchUpcomingDue() =>
      (_db.select(_t)
            ..where(
              (r) =>
                  r.status.equalsValue(LendingStatus.pending) &
                  r.dueOn.isNotNull(),
            )
            ..orderBy([(r) => OrderingTerm.asc(r.dueOn)]))
          .watch()
          .map((rows) => rows.map(_map).toList());

  @override
  Future<Result<String>> save(LendingDraft d) async {
    if (d.person.trim().isEmpty || d.amountPaise <= 0) {
      return const Err(ValidationFailure('lending'));
    }
    final r = await dbGuard(() async {
      final now = _clock();
      final today = DateTime(now.year, now.month, now.day);
      final id = d.id;
      final before = id == null
          ? null
          : await (_db.select(
              _t,
            )..where((r) => r.id.equals(id))).getSingleOrNull();
      if (id != null && before == null) throw const RecordNotFound();
      final completed = d.status == LendingStatus.completed;
      final companion = LendingRecordsCompanion(
        direction: Value(d.direction),
        person: Value(d.person.trim()),
        amountPaise: Value(d.amountPaise),
        givenOn: Value(d.givenOn),
        dueOn: Value(d.dueOn),
        status: Value(d.status),
        // Keep the original completion date when re-saving.
        completedOn: Value(completed ? (before?.completedOn ?? today) : null),
        notes: Value(d.notes.trim()),
        remind: Value(d.remind && d.dueOn != null),
        updatedAt: Value(now),
      );
      if (id == null) {
        final newId = _uuid.v4();
        await _db
            .into(_t)
            .insert(
              companion.copyWith(id: Value(newId), createdAt: Value(now)),
            );
        return newId;
      }
      await (_db.update(_t)..where((r) => r.id.equals(id))).write(companion);
      return id;
    });
    if (r.isSuccess) _onScheduleChanged();
    return r;
  }

  @override
  Future<Result<void>> setStatus(String id, LendingStatus status) async {
    final now = _clock();
    final r = await dbGuard(() async {
      final n = await (_db.update(_t)..where((r) => r.id.equals(id))).write(
        LendingRecordsCompanion(
          status: Value(status),
          completedOn: Value(
            status == LendingStatus.completed
                ? DateTime(now.year, now.month, now.day)
                : null,
          ),
          updatedAt: Value(now),
        ),
      );
      if (n == 0) throw const RecordNotFound();
    });
    if (r.isSuccess) _onScheduleChanged();
    return r;
  }

  @override
  Future<Result<void>> delete(String id) async {
    final r = await dbGuard(
      () => (_db.delete(_t)..where((r) => r.id.equals(id))).go(),
    );
    if (r case Err(:final failure)) return Err(failure);
    _onScheduleChanged();
    return const Ok(null);
  }

  /// Due-date reminders for pending records that asked for one.
  Future<List<ScheduleSource>> notificationSources(LendingText text) async {
    final rows =
        await (_db.select(_t)..where(
              (r) =>
                  r.status.equalsValue(LendingStatus.pending) &
                  r.remind &
                  r.dueOn.isNotNull(),
            ))
            .get();
    final sources = <ScheduleSource>[];
    for (final record in rows.map(_map)) {
      final at = record.reminderAt;
      if (at == null) continue;
      final t = text(record);
      sources.add(
        ScheduleSource(
          kind: NotificationKind.lending,
          entityId: record.id,
          title: t.title,
          body: t.body,
          route: '/lending/${record.id}',
          schedule: OneTimeSchedule(at),
        ),
      );
    }
    return sources;
  }

  static LendingRecord _map(LendingRow r) => LendingRecord(
    id: r.id,
    direction: r.direction,
    person: r.person,
    amountPaise: r.amountPaise,
    givenOn: r.givenOn,
    dueOn: r.dueOn,
    status: r.status,
    completedOn: r.completedOn,
    notes: r.notes,
    remind: r.remind,
  );
}

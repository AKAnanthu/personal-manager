import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/db/db_guard.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/features/reminders/domain/reminder.dart';
import 'package:personal_life_manager/features/reminders/domain/reminders_repository.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

final class RemindersRepositoryImpl implements RemindersRepository {
  RemindersRepositoryImpl({
    required this._db,
    required this._onScheduleChanged,
    this._uuid = const Uuid(),
    this._clock = DateTime.now,
  });

  final AppDatabase _db;
  final void Function() _onScheduleChanged;
  final Uuid _uuid;
  final DateTime Function() _clock;

  @override
  Stream<List<Reminder>> watchOpen() =>
      (_db.select(_db.reminders)
            ..where((r) => r.isCompleted.equals(false))
            ..orderBy([(r) => OrderingTerm.asc(r.dueAt)]))
          .watch()
          .map((rows) {
            final list = rows.map(_map).toList()
              ..sort((a, b) => a.effectiveAt.compareTo(b.effectiveAt));
            return list;
          });

  @override
  Stream<Reminder?> watchReminder(String id) =>
      (_db.select(_db.reminders)..where((r) => r.id.equals(id)))
          .watchSingleOrNull()
          .map((r) => r == null ? null : _map(r));

  @override
  Future<Result<String>> save(ReminderDraft draft) => _changing(() async {
    final now = _clock();
    final id = draft.id ?? _uuid.v4();
    final at = _minute(draft.at);
    final companion = RemindersCompanion(
      id: Value(id),
      title: Value(draft.title.trim()),
      description: Value(draft.description.trim()),
      anchorAt: Value(at),
      dueAt: Value(at),
      repeat: Value(draft.repeat),
      snoozedUntil: const Value(null),
      isCompleted: const Value(false),
      completedAt: const Value(null),
      updatedAt: Value(now),
    );
    if (draft.id == null) {
      await _db
          .into(_db.reminders)
          .insert(companion.copyWith(createdAt: Value(now)));
    } else {
      final n = await (_db.update(
        _db.reminders,
      )..where((r) => r.id.equals(id))).write(companion);
      if (n == 0) throw const RecordNotFound();
    }
    return id;
  });

  @override
  Future<Result<void>> markDone(String id) => _changing(() async {
    final row = await _get(id);
    final now = _clock();
    final RemindersCompanion patch;
    if (row.repeat == RepeatFrequency.none) {
      patch = RemindersCompanion(
        isCompleted: const Value(true),
        completedAt: Value(now),
        snoozedUntil: const Value(null),
        updatedAt: Value(now),
      );
    } else {
      // Next occurrence after both now and the one being completed.
      final after = row.dueAt.isAfter(now) ? row.dueAt : now;
      final next = Recurrence.upcoming(
        RepeatingSchedule(row.anchorAt, row.repeat),
        after: tz.TZDateTime(
          tz.local,
          after.year,
          after.month,
          after.day,
          after.hour,
          after.minute,
        ),
        limit: 1,
      ).first;
      patch = RemindersCompanion(
        dueAt: Value(
          DateTime(next.year, next.month, next.day, next.hour, next.minute),
        ),
        snoozedUntil: const Value(null),
        updatedAt: Value(now),
      );
    }
    await (_db.update(
      _db.reminders,
    )..where((r) => r.id.equals(id))).write(patch);
  });

  @override
  Future<Result<void>> snooze(String id, Duration duration) =>
      _changing(() async {
        final row = await _get(id);
        final until = _minute(_clock().add(duration));
        // One-time: just move it. Repeating: keep the series, add a snooze.
        final patch = row.repeat == RepeatFrequency.none
            ? RemindersCompanion(dueAt: Value(until))
            : RemindersCompanion(snoozedUntil: Value(until));
        await (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
          patch.copyWith(updatedAt: Value(_clock())),
        );
      });

  @override
  Future<Result<void>> delete(String id) => _changing(() async {
    await (_db.delete(_db.reminders)..where((r) => r.id.equals(id))).go();
  });

  /// Open reminders as notification sources.
  Future<List<ScheduleSource>> notificationSources() async {
    final rows = await (_db.select(
      _db.reminders,
    )..where((r) => r.isCompleted.equals(false))).get();
    return [
      for (final r in rows) ...[
        ScheduleSource(
          kind: NotificationKind.reminder,
          entityId: r.id,
          title: r.title,
          body: r.description,
          route: '/reminders/${r.id}',
          schedule: r.repeat == RepeatFrequency.none
              ? OneTimeSchedule(r.dueAt)
              : RepeatingSchedule(r.anchorAt, r.repeat),
        ),
        if (r.repeat != RepeatFrequency.none && r.snoozedUntil != null)
          ScheduleSource(
            kind: NotificationKind.reminder,
            entityId: '${r.id}:snoozed',
            title: r.title,
            body: r.description,
            route: '/reminders/${r.id}',
            schedule: OneTimeSchedule(r.snoozedUntil ?? r.dueAt),
          ),
      ],
    ];
  }

  Future<ReminderRow> _get(String id) async {
    final row = await (_db.select(
      _db.reminders,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    if (row == null) throw const RecordNotFound();
    return row;
  }

  Future<Result<T>> _changing<T>(Future<T> Function() body) async {
    final result = await dbGuard(body);
    if (result.isSuccess) _onScheduleChanged();
    return result;
  }

  static DateTime _minute(DateTime d) =>
      DateTime(d.year, d.month, d.day, d.hour, d.minute);

  static Reminder _map(ReminderRow r) => Reminder(
    id: r.id,
    title: r.title,
    description: r.description,
    anchorAt: r.anchorAt,
    dueAt: r.dueAt,
    repeat: r.repeat,
    snoozedUntil: r.snoozedUntil,
    isCompleted: r.isCompleted,
  );
}

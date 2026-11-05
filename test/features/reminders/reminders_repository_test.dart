import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/features/reminders/data/reminders_repository_impl.dart';
import 'package:personal_life_manager/features/reminders/domain/reminder.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../helpers/fakes.dart';

T ok<T>(Result<T> r) => r.fold((f) => fail('unexpected $f'), (v) => v);

void main() {
  late AppDatabase db;
  late RemindersRepositoryImpl repo;
  late TestClock clock;
  late int replans;

  setUpAll(() {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = TestClock(DateTime(2026, 11, 3, 18));
    replans = 0;
    repo = RemindersRepositoryImpl(
      db: db,
      onScheduleChanged: () => replans++,
      clock: clock.call,
    );
  });
  tearDown(() => db.close());

  Future<Reminder> get(String id) async =>
      (await repo.watchReminder(id).first) ?? fail('missing');

  test('saves at minute precision and re-plans', () async {
    final id = ok(
      await repo.save(
        ReminderDraft(
          title: 'Pay bill',
          at: DateTime(2026, 11, 4, 10, 0, 42),
          repeat: RepeatFrequency.monthly,
        ),
      ),
    );
    final r = await get(id);
    expect(r.dueAt, DateTime(2026, 11, 4, 10));
    expect(r.anchorAt, r.dueAt);
    expect(replans, 1);
  });

  test(
    'one-time: mark done completes it and drops it from open list',
    () async {
      final id = ok(
        await repo.save(
          ReminderDraft(
            title: 'x',
            at: DateTime(2026, 11, 2, 9),
            repeat: RepeatFrequency.none,
          ),
        ),
      );
      expect((await get(id)).isOverdue(clock.now), isTrue);

      ok(await repo.markDone(id));

      expect(await repo.watchOpen().first, isEmpty);
      expect(await repo.notificationSources(), isEmpty);
    },
  );

  test(
    'repeating: mark done advances to the next occurrence after now',
    () async {
      // Monthly on the 31st, last due 31 Oct, now 3 Nov → next 30 Nov.
      final id = ok(
        await repo.save(
          ReminderDraft(
            title: 'Recharge',
            at: DateTime(2026, 8, 31, 19),
            repeat: RepeatFrequency.monthly,
          ),
        ),
      );
      ok(await repo.markDone(id));

      final r = await get(id);
      expect(r.dueAt, DateTime(2026, 11, 30, 19));
      expect(r.isCompleted, isFalse);
      expect(r.isOverdue(clock.now), isFalse);
    },
  );

  test('repeating mark done before due skips to the following one', () async {
    final id = ok(
      await repo.save(
        ReminderDraft(
          title: 'Plants',
          at: DateTime(2026, 11, 7, 8),
          repeat: RepeatFrequency.weekly,
        ),
      ),
    );
    ok(await repo.markDone(id));
    expect((await get(id)).dueAt, DateTime(2026, 11, 14, 8));
  });

  test('snooze: one-time moves, repeating adds a one-off', () async {
    final once = ok(
      await repo.save(
        ReminderDraft(
          title: 'a',
          at: DateTime(2026, 11, 3, 17),
          repeat: RepeatFrequency.none,
        ),
      ),
    );
    final monthly = ok(
      await repo.save(
        ReminderDraft(
          title: 'b',
          at: DateTime(2026, 10, 3, 17),
          repeat: RepeatFrequency.monthly,
        ),
      ),
    );

    ok(await repo.snooze(once, const Duration(hours: 1)));
    ok(await repo.snooze(monthly, const Duration(hours: 1)));

    expect((await get(once)).dueAt, DateTime(2026, 11, 3, 19));
    final m = await get(monthly);
    expect(m.snoozedUntil, DateTime(2026, 11, 3, 19));
    expect(m.isOverdue(clock.now), isFalse);

    final sources = await repo.notificationSources();
    expect(
      sources.map((s) => s.entityId),
      containsAll([once, monthly, '$monthly:snoozed']),
    );
    expect(
      sources.firstWhere((s) => s.entityId == monthly).schedule,
      RepeatingSchedule(DateTime(2026, 10, 3, 17), RepeatFrequency.monthly),
    );
  });

  test('editing resets snooze and completion', () async {
    final id = ok(
      await repo.save(
        ReminderDraft(
          title: 'a',
          at: DateTime(2026, 10, 3, 17),
          repeat: RepeatFrequency.monthly,
        ),
      ),
    );
    ok(await repo.snooze(id, const Duration(hours: 1)));
    ok(
      await repo.save(
        ReminderDraft(
          id: id,
          title: 'a2',
          at: DateTime(2026, 12, 1, 9),
          repeat: RepeatFrequency.yearly,
        ),
      ),
    );
    final r = await get(id);
    expect(r.snoozedUntil, isNull);
    expect(r.title, 'a2');
    expect(r.anchorAt, DateTime(2026, 12, 1, 9));
  });

  test('open list is ordered by when it needs attention', () async {
    ok(
      await repo.save(
        ReminderDraft(
          title: 'later',
          at: DateTime(2026, 11, 20, 9),
          repeat: RepeatFrequency.none,
        ),
      ),
    );
    ok(
      await repo.save(
        ReminderDraft(
          title: 'soon',
          at: DateTime(2026, 11, 4, 9),
          repeat: RepeatFrequency.none,
        ),
      ),
    );
    expect(
      [for (final r in await repo.watchOpen().first) r.title],
      ['soon', 'later'],
    );
  });

  test('unknown id → NotFoundFailure, no re-plan', () async {
    final r = await repo.markDone('nope');
    expect(r.fold((f) => f, (_) => null), isA<NotFoundFailure>());
    expect(replans, 0);
  });

  test('wall-clock times survive a timezone change', () async {
    final id = ok(
      await repo.save(
        ReminderDraft(
          title: 'a',
          at: DateTime(2026, 11, 4, 10),
          repeat: RepeatFrequency.none,
        ),
      ),
    );
    final raw = await db
        .customSelect('SELECT due_at FROM reminders')
        .getSingle();
    expect(raw.read<String>('due_at'), '2026-11-04T10:00');
    expect((await get(id)).dueAt.hour, 10);
  });
}

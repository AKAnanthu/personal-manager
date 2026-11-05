import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/notifications/notification_ids.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/notification_planner.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late tz.Location loc;
  late tz.TZDateTime now;

  setUpAll(() {
    tzdata.initializeTimeZones();
    loc = tz.getLocation('Asia/Kolkata');
  });
  setUp(() => now = tz.TZDateTime(loc, 2026, 11, 3, 18));

  ScheduleSource src(
    String id,
    NotificationSchedule schedule, {
    NotificationKind kind = NotificationKind.reminder,
    bool enabled = true,
  }) => ScheduleSource(
    kind: kind,
    entityId: id,
    title: 'T $id',
    body: 'B',
    route: '/reminders/$id',
    schedule: schedule,
    enabled: enabled,
  );

  const planner = NotificationPlanner(budget: 60);

  group('ids', () {
    test('deterministic, positive 31-bit, input-sensitive', () {
      final a = NotificationIds.forOccurrence('reminder', 'x', 'once');
      expect(NotificationIds.forOccurrence('reminder', 'x', 'once'), a);
      expect(a, inInclusiveRange(1, 0x7fffffff));
      expect(NotificationIds.forOccurrence('reminder', 'y', 'once'), isNot(a));
      expect(NotificationIds.forOccurrence('task', 'x', 'once'), isNot(a));
      expect(NotificationIds.snoozeOf(a), isNot(a));
      expect(NotificationIds.snoozeOf(a), NotificationIds.snoozeOf(a));
    });

    test('ids are unique within a large plan', () {
      final sources = [
        for (var i = 0; i < 300; i++)
          src('r$i', OneTimeSchedule(DateTime(2026, 11, 4, 9))),
      ];
      final plan = const NotificationPlanner(budget: 400)
          .plan(sources, now: now);
      expect(plan.map((n) => n.id).toSet(), hasLength(300));
    });
  });

  test('skips disabled and past schedules', () {
    final plan = planner.plan([
      src('a', OneTimeSchedule(DateTime(2026, 11, 4, 9)), enabled: false),
      src('b', OneTimeSchedule(DateTime(2026, 11, 2, 9))),
      src('c', OneTimeSchedule(DateTime(2026, 11, 4, 9))),
    ], now: now);

    expect(plan.map((n) => n.title), ['T c']);
    expect(plan.single.repeat, isNull);
    expect(plan.single.route, '/reminders/c');
  });

  test('daily/weekly/monthly(≤28)/yearly use one OS-repeating slot', () {
    final plan = planner.plan([
      src(
        'd',
        RepeatingSchedule(DateTime(2026, 1, 1, 8), RepeatFrequency.daily),
      ),
      src(
        'w',
        RepeatingSchedule(DateTime(2026, 1, 5, 8), RepeatFrequency.weekly),
      ),
      src(
        'm',
        RepeatingSchedule(DateTime(2026, 1, 15, 8), RepeatFrequency.monthly),
      ),
      src(
        'y',
        RepeatingSchedule(DateTime(2025, 3, 1, 8), RepeatFrequency.yearly),
      ),
    ], now: now);

    expect(
      {for (final n in plan) n.title: n.repeat},
      {
        'T d': RepeatMatch.time,
        'T w': RepeatMatch.dayOfWeekAndTime,
        'T m': RepeatMatch.dayOfMonthAndTime,
        'T y': RepeatMatch.dateAndTime,
      },
    );
  });

  test('month-end and 29 Feb are expanded instead of OS-repeated', () {
    final plan = planner.plan([
      src(
        'm',
        RepeatingSchedule(DateTime(2026, 1, 31, 9), RepeatFrequency.monthly),
      ),
      src(
        'y',
        RepeatingSchedule(DateTime(2024, 2, 29, 9), RepeatFrequency.yearly),
      ),
    ], now: now);

    final monthly = plan.where((n) => n.title == 'T m').toList();
    expect(monthly, hasLength(4));
    expect(monthly.every((n) => n.repeat == null), isTrue);
    expect(monthly.map((n) => n.at.day), [30, 31, 31, 28]);
    expect(plan.where((n) => n.title == 'T y'), hasLength(4));
  });

  test('a future start more than one period away is a one-off first', () {
    // iOS calendar triggers would otherwise fire tomorrow.
    final plan = planner.plan([
      src(
        'd',
        RepeatingSchedule(DateTime(2026, 11, 10, 8), RepeatFrequency.daily),
      ),
    ], now: now);

    expect(plan.single.repeat, isNull);
    expect(plan.single.at, tz.TZDateTime(loc, 2026, 11, 10, 8));

    // Once within a day of the start, it switches to the OS repeat.
    final later = planner.plan([
      src(
        'd',
        RepeatingSchedule(DateTime(2026, 11, 10, 8), RepeatFrequency.daily),
      ),
    ], now: tz.TZDateTime(loc, 2026, 11, 9, 9));
    expect(later.single.repeat, RepeatMatch.time);
  });

  test('medicine: one slot per time (and weekday)', () {
    final plan = planner.plan([
      src(
        'med',
        const DailyTimesSchedule(
          times: [TimeOfDayMinutes(8, 0), TimeOfDayMinutes(20, 0)],
        ),
        kind: NotificationKind.medicine,
      ),
      src(
        'med2',
        const DailyTimesSchedule(
          times: [TimeOfDayMinutes(9, 0)],
          weekdays: {DateTime.monday, DateTime.wednesday},
        ),
        kind: NotificationKind.medicine,
      ),
    ], now: now);

    expect(plan.where((n) => n.title == 'T med'), hasLength(2));
    expect(plan.where((n) => n.title == 'T med').map((n) => n.repeat).toSet(), {
      RepeatMatch.time,
    });
    expect(
      plan.where((n) => n.title == 'T med2').map((n) => n.repeat).toSet(),
      {RepeatMatch.dayOfWeekAndTime},
    );
    expect(plan.where((n) => n.title == 'T med2'), hasLength(2));
  });

  test('budget keeps medicine first, then reminders, then others', () {
    final sources = [
      for (var i = 0; i < 3; i++)
        src(
          'task$i',
          OneTimeSchedule(DateTime(2026, 11, 3, 19)),
          kind: NotificationKind.task,
        ),
      for (var i = 0; i < 3; i++)
        src('rem$i', OneTimeSchedule(DateTime(2026, 11, 20, 9))),
      for (var i = 0; i < 2; i++)
        src(
          'med$i',
          const DailyTimesSchedule(times: [TimeOfDayMinutes(21, 0)]),
          kind: NotificationKind.medicine,
        ),
    ];

    final plan = const NotificationPlanner(budget: 4).plan(sources, now: now);

    expect(plan, hasLength(4));
    expect(
      plan.where((n) => n.kind == NotificationKind.medicine),
      hasLength(2),
    );
    expect(
      plan.where((n) => n.kind == NotificationKind.reminder),
      hasLength(2),
    );
    expect(plan.where((n) => n.kind == NotificationKind.task), isEmpty);
  });

  test('result is sorted by fire time and never exceeds the iOS budget', () {
    final sources = [
      for (var i = 0; i < 100; i++)
        src(
          'r$i',
          OneTimeSchedule(DateTime(2026, 11, 4).add(Duration(hours: 100 - i))),
        ),
    ];
    final plan = const NotificationPlanner(
      budget: NotificationPlanner.iosBudget,
    ).plan(sources, now: now);

    expect(plan, hasLength(NotificationPlanner.iosBudget));
    for (var i = 1; i < plan.length; i++) {
      expect(plan[i].at.isBefore(plan[i - 1].at), isFalse);
    }
    // Soonest ones were kept.
    expect(plan.first.at, tz.TZDateTime(loc, 2026, 11, 4, 1));
  });

  group('payload', () {
    test('round-trips, including the snooze flag', () {
      const p = NotificationPayload(
        kind: NotificationKind.medicine,
        route: '/medicine/1',
        title: 'Vitamin D3',
        body: '8:00 PM',
      );
      expect(NotificationPayload.decode(p.encode()), p);
      expect(
        NotificationPayload.decode(p.asSnooze().encode())?.isSnooze,
        isTrue,
      );
    });

    test('rejects foreign or malformed payloads', () {
      for (final raw in [
        null,
        '',
        'not json',
        '[]',
        '{"k":"nope","r":"/","t":"x","b":"y"}',
        '{"k":"reminder","r":1,"t":"x","b":"y"}',
      ]) {
        expect(NotificationPayload.decode(raw), isNull, reason: raw);
      }
    });
  });
}

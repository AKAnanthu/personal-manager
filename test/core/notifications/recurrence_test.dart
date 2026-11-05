// Full dates (incl. month/day 1) read better in these cases.
// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late tz.Location kolkata;
  late tz.Location newYork;

  setUpAll(() {
    tzdata.initializeTimeZones();
    kolkata = tz.getLocation('Asia/Kolkata');
    newYork = tz.getLocation('America/New_York');
  });

  String two(int n) => n.toString().padLeft(2, '0');

  List<String> fmt(List<tz.TZDateTime> xs) => [
    for (final x in xs)
      '${x.year}-${two(x.month)}-${two(x.day)} ${two(x.hour)}:${two(x.minute)}',
  ];

  group('one-time', () {
    test('future time yields one occurrence, past yields none', () {
      final now = tz.TZDateTime(kolkata, 2026, 11, 3, 18);
      expect(
        fmt(
          Recurrence.upcoming(
            OneTimeSchedule(DateTime(2026, 11, 4, 10)),
            after: now,
            limit: 5,
          ),
        ),
        ['2026-11-04 10:00'],
      );
      expect(
        Recurrence.upcoming(
          OneTimeSchedule(DateTime(2026, 11, 3, 17, 59)),
          after: now,
          limit: 5,
        ),
        isEmpty,
      );
    });

    test('exactly now is not upcoming', () {
      final now = tz.TZDateTime(kolkata, 2026, 11, 3, 18);
      expect(
        Recurrence.upcoming(
          OneTimeSchedule(DateTime(2026, 11, 3, 18)),
          after: now,
          limit: 1,
        ),
        isEmpty,
      );
    });
  });

  group('repeating', () {
    test('monthly on the 31st clamps to each month end', () {
      final now = tz.TZDateTime(kolkata, 2026, 1, 1);
      final xs = Recurrence.upcoming(
        RepeatingSchedule(DateTime(2026, 1, 31, 9), RepeatFrequency.monthly),
        after: now,
        limit: 5,
      );
      expect(fmt(xs), [
        '2026-01-31 09:00',
        '2026-02-28 09:00',
        '2026-03-31 09:00',
        '2026-04-30 09:00',
        '2026-05-31 09:00',
      ]);
    });

    test('monthly clamping does not drift (31st → Feb 29 in a leap year)', () {
      final now = tz.TZDateTime(kolkata, 2028, 2, 1);
      final xs = Recurrence.upcoming(
        RepeatingSchedule(DateTime(2027, 12, 31, 9), RepeatFrequency.monthly),
        after: now,
        limit: 2,
      );
      expect(fmt(xs), ['2028-02-29 09:00', '2028-03-31 09:00']);
    });

    test('yearly on 29 Feb falls on 28 Feb in non-leap years', () {
      final now = tz.TZDateTime(kolkata, 2028, 3, 1);
      final xs = Recurrence.upcoming(
        RepeatingSchedule(DateTime(2024, 2, 29, 8), RepeatFrequency.yearly),
        after: now,
        limit: 5,
      );
      expect(fmt(xs), [
        '2029-02-28 08:00',
        '2030-02-28 08:00',
        '2031-02-28 08:00',
        '2032-02-29 08:00',
        '2033-02-28 08:00',
      ]);
    });

    test('daily keeps wall-clock time across a DST change', () {
      // US DST starts 8 Mar 2026; 08:00 local stays 08:00.
      final now = tz.TZDateTime(newYork, 2026, 3, 6, 12);
      final xs = Recurrence.upcoming(
        RepeatingSchedule(DateTime(2026, 1, 1, 8), RepeatFrequency.daily),
        after: now,
        limit: 3,
      );
      expect(fmt(xs), [
        '2026-03-07 08:00',
        '2026-03-08 08:00',
        '2026-03-09 08:00',
      ]);
      expect(
        xs[2].difference(xs[1]),
        const Duration(hours: 24),
        reason: 'after the switch, a full day',
      );
      expect(
        xs[1].difference(xs[0]),
        const Duration(hours: 23),
        reason: 'the DST night is an hour shorter',
      );
    });

    test('weekly from an old anchor jumps forward correctly', () {
      // 2020-01-06 was a Monday.
      final now = tz.TZDateTime(kolkata, 2026, 11, 3, 18); // Tuesday
      final xs = Recurrence.upcoming(
        RepeatingSchedule(DateTime(2020, 1, 6, 7, 30), RepeatFrequency.weekly),
        after: now,
        limit: 2,
      );
      expect(fmt(xs), ['2026-11-09 07:30', '2026-11-16 07:30']);
    });

    test('future anchor starts at the anchor', () {
      final now = tz.TZDateTime(kolkata, 2026, 11, 3);
      final xs = Recurrence.upcoming(
        RepeatingSchedule(DateTime(2026, 12, 25, 9), RepeatFrequency.yearly),
        after: now,
        limit: 2,
      );
      expect(fmt(xs), ['2026-12-25 09:00', '2027-12-25 09:00']);
    });

    test('later today is still today', () {
      final now = tz.TZDateTime(kolkata, 2026, 11, 3, 7, 59);
      final xs = Recurrence.upcoming(
        RepeatingSchedule(DateTime(2026, 1, 1, 8), RepeatFrequency.daily),
        after: now,
        limit: 1,
      );
      expect(fmt(xs), ['2026-11-03 08:00']);
    });

    test('frequency none behaves like one-time', () {
      final now = tz.TZDateTime(kolkata, 2026, 11, 3);
      expect(
        Recurrence.upcoming(
          RepeatingSchedule(DateTime(2026, 11, 5, 9), RepeatFrequency.none),
          after: now,
          limit: 5,
        ),
        hasLength(1),
      );
    });
  });

  group('daily times (medicine)', () {
    test('several times every day, in order', () {
      final now = tz.TZDateTime(kolkata, 2026, 11, 3, 12);
      final xs = Recurrence.upcoming(
        const DailyTimesSchedule(
          times: [TimeOfDayMinutes(20, 0), TimeOfDayMinutes(8, 0)],
        ),
        after: now,
        limit: 3,
      );
      expect(fmt(xs), [
        '2026-11-03 20:00',
        '2026-11-04 08:00',
        '2026-11-04 20:00',
      ]);
    });

    test('selected weekdays only', () {
      final now = tz.TZDateTime(kolkata, 2026, 11, 3, 12); // Tuesday
      final xs = Recurrence.upcoming(
        const DailyTimesSchedule(
          times: [TimeOfDayMinutes(9, 0)],
          weekdays: {DateTime.monday, DateTime.friday},
        ),
        after: now,
        limit: 3,
      );
      expect(fmt(xs), [
        '2026-11-06 09:00',
        '2026-11-09 09:00',
        '2026-11-13 09:00',
      ]);
    });

    test('no times means no occurrences', () {
      final now = tz.TZDateTime(kolkata, 2026, 11, 3);
      expect(
        Recurrence.upcoming(
          const DailyTimesSchedule(times: []),
          after: now,
          limit: 3,
        ),
        isEmpty,
      );
    });
  });
}

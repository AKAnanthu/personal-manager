import 'package:equatable/equatable.dart';
import 'package:timezone/timezone.dart' as tz;

enum RepeatFrequency { none, daily, weekly, monthly, yearly }

/// Wall-clock time of day (no date, no zone).
final class TimeOfDayMinutes extends Equatable
    implements Comparable<TimeOfDayMinutes> {
  const TimeOfDayMinutes(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24, 'hour'),
      assert(minute >= 0 && minute < 60, 'minute');

  final int hour;
  final int minute;

  int get totalMinutes => hour * 60 + minute;

  @override
  int compareTo(TimeOfDayMinutes other) =>
      totalMinutes.compareTo(other.totalMinutes);

  @override
  List<Object?> get props => [hour, minute];
}

/// When a notification fires. Dates/times are local wall-clock values: an
/// 8:00 reminder stays at 8:00 across DST changes and timezone moves.
sealed class NotificationSchedule extends Equatable {
  const NotificationSchedule();
}

final class OneTimeSchedule extends NotificationSchedule {
  const OneTimeSchedule(this.at);

  final DateTime at;

  @override
  List<Object?> get props => [at];
}

/// Repeats from [anchor] (the first occurrence) at [frequency].
/// Monthly on the 29th–31st falls back to the month's last day; yearly on
/// 29 February falls back to 28 February in non-leap years.
final class RepeatingSchedule extends NotificationSchedule {
  const RepeatingSchedule(this.anchor, this.frequency);

  final DateTime anchor;
  final RepeatFrequency frequency;

  @override
  List<Object?> get props => [anchor, frequency];
}

/// One or more times per day, every day or on selected weekdays
/// (`DateTime.monday`…`DateTime.sunday`; empty = every day). Used for
/// medicine schedules.
final class DailyTimesSchedule extends NotificationSchedule {
  const DailyTimesSchedule({required this.times, this.weekdays = const {}});

  final List<TimeOfDayMinutes> times;
  final Set<int> weekdays;

  @override
  List<Object?> get props => [times, weekdays];
}

/// Pure occurrence calculator.
abstract final class Recurrence {
  /// Up to [limit] occurrences strictly after [after], in time order.
  static List<tz.TZDateTime> upcoming(
    NotificationSchedule schedule, {
    required tz.TZDateTime after,
    required int limit,
  }) {
    if (limit <= 0) return const [];
    final loc = after.location;
    return switch (schedule) {
      OneTimeSchedule(:final at) => [
        if (_at(loc, at).isAfter(after)) _at(loc, at),
      ],
      RepeatingSchedule(frequency: RepeatFrequency.none, :final anchor) =>
        upcoming(OneTimeSchedule(anchor), after: after, limit: limit),
      RepeatingSchedule(:final anchor, :final frequency) => _repeating(
        anchor,
        frequency,
        after,
        limit,
      ),
      DailyTimesSchedule() => _dailyTimes(schedule, after, limit),
    };
  }

  /// Occurrence [k] (0 = anchor) as a wall-clock date in [loc].
  static tz.TZDateTime occurrence(
    tz.Location loc,
    DateTime anchor,
    RepeatFrequency frequency,
    int k,
  ) {
    final (y, m, d) = switch (frequency) {
      RepeatFrequency.none => (anchor.year, anchor.month, anchor.day),
      // Day arithmetic on a UTC date avoids DST shifting the calendar day.
      RepeatFrequency.daily => _addDays(anchor, k),
      RepeatFrequency.weekly => _addDays(anchor, 7 * k),
      RepeatFrequency.monthly => _addMonthsClamped(anchor, k),
      RepeatFrequency.yearly => _addMonthsClamped(anchor, 12 * k),
    };
    return tz.TZDateTime(loc, y, m, d, anchor.hour, anchor.minute);
  }

  static List<tz.TZDateTime> _repeating(
    DateTime anchor,
    RepeatFrequency frequency,
    tz.TZDateTime after,
    int limit,
  ) {
    final loc = after.location;
    // Jump close to `after` instead of iterating from an old anchor.
    var k = _estimateIndex(anchor, frequency, after);
    final out = <tz.TZDateTime>[];
    while (out.length < limit) {
      final at = occurrence(loc, anchor, frequency, k++);
      if (at.isAfter(after)) out.add(at);
    }
    return out;
  }

  static int _estimateIndex(
    DateTime anchor,
    RepeatFrequency frequency,
    tz.TZDateTime after,
  ) {
    final start = DateTime.utc(anchor.year, anchor.month, anchor.day);
    final end = DateTime.utc(after.year, after.month, after.day);
    final days = end.difference(start).inDays;
    final months = (after.year - anchor.year) * 12 + after.month - anchor.month;
    final k = switch (frequency) {
      RepeatFrequency.daily => days,
      RepeatFrequency.weekly => days ~/ 7,
      RepeatFrequency.monthly => months,
      RepeatFrequency.yearly => months ~/ 12,
      RepeatFrequency.none => 0,
    };
    // Step back one so the occurrence just after `after` isn't skipped.
    return k > 1 ? k - 1 : 0;
  }

  static List<tz.TZDateTime> _dailyTimes(
    DailyTimesSchedule s,
    tz.TZDateTime after,
    int limit,
  ) {
    if (s.times.isEmpty) return const [];
    final times = [...s.times]..sort();
    final out = <tz.TZDateTime>[];
    // At most 7 days pass before a selected weekday recurs.
    for (var day = 0; out.length < limit && day < 7 * (limit + 1); day++) {
      final (y, m, d) = _addDays(after, day);
      final weekday = DateTime.utc(y, m, d).weekday;
      if (s.weekdays.isNotEmpty && !s.weekdays.contains(weekday)) continue;
      for (final t in times) {
        final at = tz.TZDateTime(after.location, y, m, d, t.hour, t.minute);
        if (at.isAfter(after)) out.add(at);
        if (out.length == limit) break;
      }
    }
    return out;
  }

  static tz.TZDateTime _at(tz.Location loc, DateTime wall) => tz.TZDateTime(
    loc,
    wall.year,
    wall.month,
    wall.day,
    wall.hour,
    wall.minute,
  );

  static (int, int, int) _addDays(DateTime date, int days) {
    final d = DateTime.utc(date.year, date.month, date.day + days);
    return (d.year, d.month, d.day);
  }

  static (int, int, int) _addMonthsClamped(DateTime anchor, int months) {
    final total = anchor.month - 1 + months;
    final year = anchor.year + total ~/ 12;
    final month = total % 12 + 1;
    final last = DateTime.utc(year, month + 1, 0).day;
    return (year, month, anchor.day > last ? last : anchor.day);
  }
}

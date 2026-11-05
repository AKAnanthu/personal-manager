import 'package:personal_life_manager/core/notifications/notification_ids.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:timezone/timezone.dart' as tz;

/// Turns [ScheduleSource]s into the concrete set of OS notifications to keep
/// pending. Pure: same input, same output.
///
/// - Schedules the OS can repeat by itself use one pending slot each
///   (daily/weekly, monthly on days 1–28, yearly except 29 Feb, medicine
///   times).
/// - Others (monthly 29–31, yearly 29 Feb) are expanded into their next few
///   occurrences, rolled forward each time the app re-plans.
/// - Only [budget] notifications are kept, choosing by priority tier and
///   then by time. iOS allows 64 pending notifications per app.
final class NotificationPlanner {
  const NotificationPlanner({required this.budget, this.perSourceLimit = 4});

  /// iOS: 64 per app; keep headroom for snoozes and one-offs.
  static const iosBudget = 60;

  /// Android has no hard cap, but AlarmManager limits apps to ~500 alarms.
  static const androidBudget = 400;

  final int budget;

  /// Occurrences scheduled ahead for schedules the OS can't repeat.
  final int perSourceLimit;

  List<PlannedNotification> plan(
    Iterable<ScheduleSource> sources, {
    required tz.TZDateTime now,
  }) {
    final candidates = <PlannedNotification>[];
    final usedIds = <int>{};

    for (final source in sources) {
      if (!source.enabled) continue;
      for (final (key, at, repeat) in _slots(source.schedule, now)) {
        candidates.add(
          PlannedNotification(
            id: _uniqueId(source, key, usedIds),
            kind: source.kind,
            title: source.title,
            body: source.body,
            route: source.route,
            at: at,
            repeat: repeat,
          ),
        );
      }
    }

    candidates.sort((a, b) {
      final tier = a.kind.tier.compareTo(b.kind.tier);
      return tier != 0 ? tier : a.at.compareTo(b.at);
    });
    final kept = candidates.take(budget).toList()
      ..sort((a, b) => a.at.compareTo(b.at));
    return kept;
  }

  /// (stable occurrence key, first fire time, OS repeat) for each slot.
  List<(String, tz.TZDateTime, RepeatMatch?)> _slots(
    NotificationSchedule schedule,
    tz.TZDateTime now,
  ) {
    switch (schedule) {
      case OneTimeSchedule():
        return [
          for (final at in Recurrence.upcoming(schedule, after: now, limit: 1))
            ('once', at, null),
        ];
      case RepeatingSchedule(:final anchor, :final frequency):
        final match = _matchFor(anchor, frequency);
        if (match == null) {
          final limit = frequency == RepeatFrequency.none ? 1 : perSourceLimit;
          return [
            for (final at in Recurrence.upcoming(
              schedule,
              after: now,
              limit: limit,
            ))
              ('at-${_wallKey(at)}', at, null),
          ];
        }
        final next = Recurrence.upcoming(schedule, after: now, limit: 1);
        if (next.isEmpty) return const [];
        // iOS calendar triggers ignore the start date and fire at the next
        // match. If the anchor is more than one period away, schedule it as
        // a one-off; a later re-plan switches to the OS repeat.
        final first = next.first;
        final anchorAt = Recurrence.occurrence(
          now.location,
          anchor,
          frequency,
          0,
        );
        if (first == anchorAt &&
            _periodBefore(anchor, frequency, now).isAfter(now)) {
          return [('first-${_wallKey(first)}', first, null)];
        }
        return [('repeat', first, match)];
      case DailyTimesSchedule(:final times, :final weekdays):
        final slots = <(String, tz.TZDateTime, RepeatMatch?)>[];
        for (final t in {...times}) {
          final hhmm = '${t.hour}:${t.minute}';
          if (weekdays.isEmpty) {
            final next = Recurrence.upcoming(
              DailyTimesSchedule(times: [t]),
              after: now,
              limit: 1,
            );
            slots.addAll([
              for (final at in next) ('d-$hhmm', at, RepeatMatch.time),
            ]);
          } else {
            for (final day in weekdays) {
              final next = Recurrence.upcoming(
                DailyTimesSchedule(times: [t], weekdays: {day}),
                after: now,
                limit: 1,
              );
              slots.addAll([
                for (final at in next)
                  ('w$day-$hhmm', at, RepeatMatch.dayOfWeekAndTime),
              ]);
            }
          }
        }
        return slots;
    }
  }

  /// The OS repeat matching [frequency], or null if the OS would get it
  /// wrong (month-end and leap-day clamping).
  static RepeatMatch? _matchFor(DateTime anchor, RepeatFrequency frequency) =>
      switch (frequency) {
        RepeatFrequency.none => null,
        RepeatFrequency.daily => RepeatMatch.time,
        RepeatFrequency.weekly => RepeatMatch.dayOfWeekAndTime,
        RepeatFrequency.monthly =>
          anchor.day <= 28 ? RepeatMatch.dayOfMonthAndTime : null,
        RepeatFrequency.yearly =>
          anchor.month == 2 && anchor.day == 29
              ? null
              : RepeatMatch.dateAndTime,
      };

  /// The OS match one period before [anchor] (only for matchable schedules,
  /// so no month-end or leap-day clamping is needed).
  static tz.TZDateTime _periodBefore(
    DateTime anchor,
    RepeatFrequency frequency,
    tz.TZDateTime now,
  ) {
    final a = anchor;
    final (y, m, d) = switch (frequency) {
      RepeatFrequency.daily => _ymd(DateTime.utc(a.year, a.month, a.day - 1)),
      RepeatFrequency.weekly => _ymd(DateTime.utc(a.year, a.month, a.day - 7)),
      RepeatFrequency.monthly => _ymd(DateTime.utc(a.year, a.month - 1, a.day)),
      RepeatFrequency.yearly => (a.year - 1, a.month, a.day),
      RepeatFrequency.none => (a.year, a.month, a.day),
    };
    return tz.TZDateTime(now.location, y, m, d, a.hour, a.minute);
  }

  static (int, int, int) _ymd(DateTime d) => (d.year, d.month, d.day);

  static String _wallKey(tz.TZDateTime at) =>
      '${at.year}-${at.month}-${at.day}T${at.hour}:${at.minute}';

  /// Deterministic ID; on the (rare) hash collision, re-hash with a salt.
  static int _uniqueId(ScheduleSource s, String key, Set<int> used) {
    for (var salt = 0; ; salt++) {
      final id = NotificationIds.forOccurrence(
        s.kind.name,
        s.entityId,
        key,
        salt: salt,
      );
      if (used.add(id)) return id;
    }
  }
}

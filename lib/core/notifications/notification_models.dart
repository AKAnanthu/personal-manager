import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:timezone/timezone.dart' as tz;

/// Notification categories, ordered by priority when the iOS pending budget
/// is tight (medicine first, then reminders, then everything else).
enum NotificationKind {
  medicine(tier: 0, snoozable: true),
  reminder(tier: 1, snoozable: true),
  task(tier: 2, snoozable: true),
  lending(tier: 2, snoozable: false),
  documentExpiry(tier: 2, snoozable: false),
  shopping(tier: 2, snoozable: false);

  NotificationKind({required this.tier, required this.snoozable});

  final int tier;
  final bool snoozable;
}

/// Something a feature wants notifications for. Features supply these;
/// only the scheduler talks to the OS.
final class ScheduleSource extends Equatable {
  const ScheduleSource({
    required this.kind,
    required this.entityId,
    required this.title,
    required this.body,
    required this.route,
    required this.schedule,
    this.enabled = true,
  });

  final NotificationKind kind;
  final String entityId;
  final String title;
  final String body;

  /// In-app location opened when the notification is tapped.
  final String route;
  final NotificationSchedule schedule;
  final bool enabled;

  @override
  List<Object?> get props => [
    kind,
    entityId,
    title,
    body,
    route,
    schedule,
    enabled,
  ];
}

/// How a planned notification repeats at the OS level.
enum RepeatMatch { time, dayOfWeekAndTime, dayOfMonthAndTime, dateAndTime }

final class PlannedNotification extends Equatable {
  const PlannedNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.route,
    required this.at,
    this.repeat,
  });

  final int id;
  final NotificationKind kind;
  final String title;
  final String body;
  final String route;

  /// First (or only) fire time.
  final tz.TZDateTime at;

  /// Non-null when the OS repeats it by itself (one pending slot).
  final RepeatMatch? repeat;

  NotificationPayload get payload =>
      NotificationPayload(kind: kind, route: route, title: title, body: body);

  @override
  List<Object?> get props => [id, kind, title, body, route, at, repeat];
}

/// Carried with each OS notification so taps can deep-link and snooze can
/// re-create the notification from a background isolate.
final class NotificationPayload extends Equatable {
  const NotificationPayload({
    required this.kind,
    required this.route,
    required this.title,
    required this.body,
    this.isSnooze = false,
  });

  final NotificationKind kind;
  final String route;
  final String title;
  final String body;

  /// Snoozed copies are not owned by the planner and survive a re-plan.
  final bool isSnooze;

  NotificationPayload asSnooze() => NotificationPayload(
    kind: kind,
    route: route,
    title: title,
    body: body,
    isSnooze: true,
  );

  String encode() => jsonEncode({
    'k': kind.name,
    'r': route,
    't': title,
    'b': body,
    if (isSnooze) 's': true,
  });

  /// Null for anything that isn't a payload this app wrote.
  static NotificationPayload? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map<String, Object?>) return null;
      final kind = NotificationKind.values
          .where((k) => k.name == map['k'])
          .firstOrNull;
      final route = map['r'];
      final title = map['t'];
      final body = map['b'];
      if (kind == null || route is! String || title is! String) return null;
      if (body is! String) return null;
      return NotificationPayload(
        kind: kind,
        route: route,
        title: title,
        body: body,
        isSnooze: map['s'] == true,
      );
    } on FormatException {
      return null;
    }
  }

  @override
  List<Object?> get props => [kind, route, title, body, isSnooze];
}

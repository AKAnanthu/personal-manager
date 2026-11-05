import 'package:equatable/equatable.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';

final class PendingNotification extends Equatable {
  const PendingNotification(this.id, this.payload);

  final int id;
  final NotificationPayload? payload;

  @override
  List<Object?> get props => [id, payload];
}

/// A tap on a notification or one of its action buttons.
final class NotificationTap extends Equatable {
  const NotificationTap({this.id, this.actionId, this.payload});

  final int? id;

  /// Null for a tap on the notification body.
  final String? actionId;
  final NotificationPayload? payload;

  @override
  List<Object?> get props => [id, actionId, payload];
}

/// Snooze action IDs and their durations.
abstract final class SnoozeActions {
  static const minutes = [5, 10, 30];

  static String idFor(int minutes) => 'snooze:$minutes';

  /// Minutes for a snooze action ID, or null for anything else.
  static int? parse(String? actionId) {
    if (actionId == null || !actionId.startsWith('snooze:')) return null;
    final m = int.tryParse(actionId.substring(7));
    return m != null && minutes.contains(m) ? m : null;
  }
}

/// The OS notification API, behind an interface so the scheduler can be
/// tested and so nothing else touches the plugin.
abstract interface class NotificationPlatform {
  Future<void> initialize({required void Function(NotificationTap) onTap});

  /// The tap that launched the app from a terminated state, if any.
  Future<NotificationTap?> launchTap();

  Future<List<PendingNotification>> pending();

  /// Schedules (or replaces, same ID) a notification.
  Future<void> schedule(PlannedNotification n, {required bool exact});

  /// Shows a notification immediately (not scheduled).
  Future<void> show(int id, NotificationPayload payload);

  /// One-off copy of a notification [minutes] from now.
  Future<void> snooze(int originalId, NotificationPayload payload, int minutes);

  Future<void> cancel(int id);

  /// Removes every pending and shown notification of this app.
  Future<void> cancelAll();

  Future<bool> areEnabled();

  /// Shows the OS permission prompt (Android 13+, iOS). True if granted.
  Future<bool> requestPermission();

  /// Android 12+: whether exact alarms are allowed. Always true on iOS.
  Future<bool> canScheduleExact();

  /// Opens the system screen where the user can allow exact alarms.
  Future<void> requestExactAlarms();

  /// Opens this app's notification settings.
  Future<void> openSettings();
}

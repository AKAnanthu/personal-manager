import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:personal_life_manager/core/notifications/notification_ids.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/notification_platform.dart';
import 'package:personal_life_manager/core/notifications/time_zone_service.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;

/// Handles snooze buttons pressed while the app isn't running. Runs in a
/// separate background isolate, so it sets up its own plugin and zone.
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(NotificationResponse r) async {
  final minutes = SnoozeActions.parse(r.actionId);
  final payload = NotificationPayload.decode(r.payload);
  final id = r.id;
  if (minutes == null || payload == null || id == null) return;
  await TimeZoneService().init();
  final platform = LocalNotificationsPlatform();
  await platform.initialize(onTap: (_) {});
  await platform.snooze(id, payload, minutes);
}

final class LocalNotificationsPlatform implements NotificationPlatform {
  LocalNotificationsPlatform([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  static const _channel = MethodChannel('app.plm/platform');
  static const _snoozeCategory = 'snoozable';

  // Notification text is set up before any BuildContext exists (and in the
  // background isolate), so look up strings directly.
  AppLocalizations get _l10n {
    final locale = PlatformDispatcher.instance.locale;
    return lookupAppLocalizations(
      AppLocalizations.supportedLocales.any(
            (l) => l.languageCode == locale.languageCode,
          )
          ? Locale(locale.languageCode)
          : const Locale('en'),
    );
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> initialize({
    required void Function(NotificationTap) onTap,
  }) async {
    final l10n = _l10n;
    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Permission is requested later, when the first reminder is set.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: [
            DarwinNotificationCategory(
              _snoozeCategory,
              actions: [
                for (final m in SnoozeActions.minutes)
                  DarwinNotificationAction.plain(
                    SnoozeActions.idFor(m),
                    l10n.notificationSnoozeAction(m),
                  ),
              ],
            ),
          ],
        ),
      ),
      onDidReceiveNotificationResponse: (r) async {
        final tap = _toTap(r);
        final minutes = SnoozeActions.parse(r.actionId);
        final payload = tap.payload;
        final id = tap.id;
        if (minutes != null && payload != null && id != null) {
          await snooze(id, payload, minutes);
        } else {
          onTap(tap);
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );
  }

  @override
  Future<NotificationTap?> launchTap() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (details == null || !details.didNotificationLaunchApp) return null;
    return response == null ? null : _toTap(response);
  }

  @override
  Future<List<PendingNotification>> pending() async => [
    for (final p in await _plugin.pendingNotificationRequests())
      PendingNotification(p.id, NotificationPayload.decode(p.payload)),
  ];

  @override
  Future<void> schedule(PlannedNotification n, {required bool exact}) =>
      _plugin.zonedSchedule(
        id: n.id,
        title: n.title,
        body: n.body,
        scheduledDate: n.at,
        notificationDetails: _details(n.kind),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: switch (n.repeat) {
          null => null,
          RepeatMatch.time => DateTimeComponents.time,
          RepeatMatch.dayOfWeekAndTime => DateTimeComponents.dayOfWeekAndTime,
          RepeatMatch.dayOfMonthAndTime => DateTimeComponents.dayOfMonthAndTime,
          RepeatMatch.dateAndTime => DateTimeComponents.dateAndTime,
        },
        payload: n.payload.encode(),
      );

  @override
  Future<void> show(int id, NotificationPayload payload) => _plugin.show(
    id: id,
    title: payload.title,
    body: payload.body,
    notificationDetails: _details(payload.kind, bigText: payload.body),
    payload: payload.encode(),
  );

  @override
  Future<void> snooze(
    int originalId,
    NotificationPayload payload,
    int minutes,
  ) async {
    final exact = await canScheduleExact();
    await _plugin.zonedSchedule(
      id: NotificationIds.snoozeOf(originalId),
      title: payload.title,
      body: payload.body,
      scheduledDate: tz.TZDateTime.now(tz.local)
          .add(Duration(minutes: minutes)),
      notificationDetails: _details(payload.kind),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload.asSnooze().encode(),
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<bool> areEnabled() async {
    if (Platform.isAndroid) {
      return await _android?.areNotificationsEnabled() ?? false;
    }
    final options = await _ios?.checkPermissions();
    return options?.isEnabled ?? false;
  }

  @override
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      return await _android?.requestNotificationsPermission() ?? false;
    }
    return await _ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  @override
  Future<bool> canScheduleExact() async {
    if (!Platform.isAndroid) return true;
    return await _android?.canScheduleExactNotifications() ?? false;
  }

  @override
  Future<void> requestExactAlarms() async {
    await _android?.requestExactAlarmsPermission();
  }

  @override
  Future<void> openSettings() =>
      _channel.invokeMethod<void>('openNotificationSettings');

  /// [bigText] expands multi-line bodies (e.g. a list of items) on Android.
  NotificationDetails _details(NotificationKind kind, {String? bigText}) {
    final l10n = _l10n;
    final snoozable = kind.snoozable;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'plm.${kind.name}',
        l10n.notificationChannelName(kind.name),
        channelDescription: l10n.notificationChannelDescription(kind.name),
        importance: kind == NotificationKind.shopping
            ? Importance.defaultImportance
            : Importance.high,
        priority: kind == NotificationKind.shopping
            ? Priority.defaultPriority
            : Priority.high,
        category: AndroidNotificationCategory.reminder,
        styleInformation: bigText == null
            ? null
            : BigTextStyleInformation(bigText),
        // Hide content on the lock screen; the title alone may be personal.
        visibility: NotificationVisibility.private,
        actions: snoozable
            ? [
                for (final m in SnoozeActions.minutes)
                  AndroidNotificationAction(
                    SnoozeActions.idFor(m),
                    l10n.notificationSnoozeAction(m),
                  ),
              ]
            : null,
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: snoozable ? _snoozeCategory : null,
      ),
    );
  }

  static NotificationTap _toTap(NotificationResponse r) => NotificationTap(
    id: r.id,
    actionId: r.actionId,
    payload: NotificationPayload.decode(r.payload),
  );
}

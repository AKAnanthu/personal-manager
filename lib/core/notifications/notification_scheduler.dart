import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:personal_life_manager/core/notifications/notification_ids.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/notifications/notification_planner.dart';
import 'package:personal_life_manager/core/notifications/notification_platform.dart';
import 'package:personal_life_manager/core/notifications/time_zone_service.dart';
import 'package:personal_life_manager/core/utils/app_logger.dart';

/// Supplies a feature's current notification needs (e.g. all enabled
/// reminders). Called on every re-plan.
typedef ScheduleSourceProvider = Future<List<ScheduleSource>> Function();

/// The single owner of OS notifications. Features register providers and
/// call [replan] after any change; nothing else schedules or cancels.
class NotificationScheduler implements NotificationPermissions {
  NotificationScheduler({
    required this._platform,
    required this._planner,
    required this._timeZone,
    required this._logger,
  });

  final NotificationPlatform _platform;
  final NotificationPlanner _planner;
  final TimeZoneService _timeZone;
  final AppLogger _logger;
  final _providers = <String, ScheduleSourceProvider>{};
  final _taps = StreamController<String>.broadcast();
  AppLifecycleListener? _lifecycle;

  Future<void>? _running;
  bool _rerunRequested = false;
  bool _exactAlarms = true;

  /// In-app routes from notification taps (validated, always in-app).
  Stream<String> get tapRoutes => _taps.stream;

  /// False on Android 12+ when the user hasn't allowed exact alarms;
  /// notifications then fire within a few minutes of their time.
  @override
  bool get exactAlarmsAvailable => _exactAlarms;

  Future<void> initialize() =>
      _platform.initialize(onTap: (t) => _emitRoute(t.payload?.route));

  /// Route to open if a notification tap launched the app.
  Future<String?> launchRoute() async {
    final tap = await _platform.launchTap();
    final route = tap?.payload?.route;
    return isSafeRoute(route) ? route : null;
  }

  void registerSource(String key, ScheduleSourceProvider provider) =>
      _providers[key] = provider;

  /// Re-plans when the app returns to the foreground (also picks up a
  /// timezone change and rolls expanded occurrences forward).
  void attachLifecycle() {
    _lifecycle ??= AppLifecycleListener(onResume: () => unawaited(onResumed()));
  }

  @visibleForTesting
  Future<void> onResumed() async {
    await _timeZone.refresh();
    await replan();
  }

  /// Recomputes and applies the pending set. Calls during a run are
  /// coalesced into one follow-up run.
  Future<void> replan() {
    final running = _running;
    if (running != null) {
      _rerunRequested = true;
      return running;
    }
    return _running = _loop().whenComplete(() => _running = null);
  }

  Future<void> _loop() async {
    do {
      _rerunRequested = false;
      await _replanOnce();
    } while (_rerunRequested);
  }

  Future<void> _replanOnce() async {
    final sources = <ScheduleSource>[];
    for (final MapEntry(:key, value: provider) in _providers.entries) {
      try {
        sources.addAll(await provider());
      } on Exception catch (e, st) {
        // One broken feature must not stop medicine reminders.
        _logger.error('notification source failed: $key', e, st);
      }
    }
    final planned = _planner.plan(sources, now: _timeZone.now());
    final wanted = {for (final n in planned) n.id};

    try {
      _exactAlarms = await _platform.canScheduleExact();
      for (final p in await _platform.pending()) {
        // Snoozed copies aren't planner-owned; let them fire once.
        if (!wanted.contains(p.id) && p.payload?.isSnooze != true) {
          await _platform.cancel(p.id);
        }
      }
      for (final n in planned) {
        await _platform.schedule(n, exact: _exactAlarms);
      }
    } on PlatformException catch (e, st) {
      _logger.error('notification replan failed', e, st);
    }
  }

  /// Shows a one-off notification now, outside the plan (e.g. shopping
  /// "continue later"). Its ID is fixed per [kind] + [entityId], so showing
  /// again replaces it instead of adding a second one.
  Future<void> showNow({
    required NotificationKind kind,
    required String entityId,
    required String title,
    required String body,
    required String route,
  }) async {
    try {
      await _platform.show(
        oneOffId(kind, entityId),
        NotificationPayload(kind: kind, route: route, title: title, body: body),
      );
    } on PlatformException catch (e, st) {
      _logger.error('notification show failed', e, st);
    }
  }

  /// Removes a [showNow] notification, whether still in the shade or not.
  Future<void> cancelShown(NotificationKind kind, String entityId) async {
    try {
      await _platform.cancel(oneOffId(kind, entityId));
    } on PlatformException catch (e, st) {
      _logger.error('notification cancel failed', e, st);
    }
  }

  /// Erasing all data: nothing may ring afterwards.
  Future<void> cancelAll() async {
    try {
      await _platform.cancelAll();
    } on PlatformException catch (e, st) {
      _logger.error('notification cancelAll failed', e, st);
    }
  }

  @visibleForTesting
  static int oneOffId(NotificationKind kind, String entityId) =>
      NotificationIds.forOccurrence(kind.name, entityId, 'now');

  @override
  Future<bool> areEnabled() => _platform.areEnabled();

  /// Asks for permission if not already granted. True if enabled afterwards.
  @override
  Future<bool> ensurePermission() async =>
      await _platform.areEnabled() || await _platform.requestPermission();

  @override
  Future<void> requestExactAlarms() async {
    await _platform.requestExactAlarms();
    _exactAlarms = await _platform.canScheduleExact();
  }

  @override
  Future<void> openSettings() => _platform.openSettings();

  void _emitRoute(String? route) {
    if (isSafeRoute(route) && route != null) _taps.add(route);
  }

  static bool isSafeRoute(String? route) =>
      route != null && route.startsWith('/') && !route.startsWith('//');

  Future<void> dispose() async {
    _lifecycle?.dispose();
    await _taps.close();
  }
}

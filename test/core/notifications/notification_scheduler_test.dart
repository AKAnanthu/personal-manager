import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/notification_planner.dart';
import 'package:personal_life_manager/core/notifications/notification_platform.dart';
import 'package:personal_life_manager/core/notifications/notification_scheduler.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/notifications/time_zone_service.dart';
import 'package:personal_life_manager/core/utils/app_logger.dart';
import 'package:timezone/timezone.dart' as tz;

final class FakePlatform implements NotificationPlatform {
  final Map<int, (PlannedNotification?, NotificationPayload?)> pendingById = {};
  final List<int> cancelled = [];
  final List<bool> exactFlags = [];
  bool exact = true;
  bool enabled = false;
  bool grantOnRequest = true;
  int requests = 0;
  int scheduleCalls = 0;
  Completer<void>? gate;
  void Function(NotificationTap)? onTap;
  NotificationTap? launch;

  @override
  Future<void> initialize({
    required void Function(NotificationTap) onTap,
  }) async => this.onTap = onTap;

  @override
  Future<NotificationTap?> launchTap() async => launch;

  @override
  Future<List<PendingNotification>> pending() async {
    await gate?.future;
    return [
      for (final MapEntry(:key, :value) in pendingById.entries)
        PendingNotification(key, value.$2),
    ];
  }

  @override
  Future<void> schedule(PlannedNotification n, {required bool exact}) async {
    scheduleCalls++;
    exactFlags.add(exact);
    pendingById[n.id] = (n, n.payload);
  }

  final List<(int, NotificationPayload)> shown = [];
  bool cancelledAll = false;

  @override
  Future<void> cancelAll() async {
    cancelledAll = true;
    pendingById.clear();
  }

  @override
  Future<void> show(int id, NotificationPayload payload) async =>
      shown.add((id, payload));

  @override
  Future<void> snooze(int id, NotificationPayload p, int minutes) async {}

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    pendingById.remove(id);
  }

  @override
  Future<bool> areEnabled() async => enabled;

  @override
  Future<bool> requestPermission() async {
    requests++;
    return enabled = grantOnRequest;
  }

  @override
  Future<bool> canScheduleExact() async => exact;

  @override
  Future<void> requestExactAlarms() async => exact = true;

  @override
  Future<void> openSettings() async {}
}

void main() {
  late FakePlatform platform;
  late TimeZoneService tzService;
  late NotificationScheduler scheduler;
  late String zone;
  late List<ScheduleSource> reminders;

  setUp(() async {
    zone = 'Asia/Kolkata';
    tzService = TimeZoneService(
      deviceZone: () async => zone,
      clock: () => DateTime.utc(2026, 11, 3, 12),
    );
    await tzService.init();
    platform = FakePlatform();
    scheduler = NotificationScheduler(
      platform: platform,
      planner: const NotificationPlanner(budget: 60),
      timeZone: tzService,
      logger: AppLogger(verbose: false),
    );
    await scheduler.initialize();
    reminders = [
      ScheduleSource(
        kind: NotificationKind.reminder,
        entityId: 'r1',
        title: 'Pay bill',
        body: '',
        route: '/reminders/r1',
        schedule: OneTimeSchedule(DateTime(2026, 11, 4, 10)),
      ),
    ];
    scheduler.registerSource('reminders', () async => reminders);
  });
  tearDown(() => scheduler.dispose());

  test('schedules planned notifications', () async {
    await scheduler.replan();

    final planned = platform.pendingById.values.single.$1;
    expect(planned?.title, 'Pay bill');
    expect(planned?.at, tz.TZDateTime(tz.getLocation(zone), 2026, 11, 4, 10));
  });

  test('cancels stale ones but keeps snoozed copies', () async {
    const snoozed = NotificationPayload(
      kind: NotificationKind.reminder,
      route: '/x',
      title: 't',
      body: 'b',
      isSnooze: true,
    );
    platform.pendingById
      ..[111] =
          (null, null) // stale (e.g. deleted reminder)
      ..[222] = (null, snoozed);

    await scheduler.replan();

    expect(platform.cancelled, [111]);
    expect(platform.pendingById.keys, contains(222));
  });

  test('removing a source item cancels its notification', () async {
    await scheduler.replan();
    final id = platform.pendingById.keys.single;

    reminders = [];
    await scheduler.replan();

    expect(platform.cancelled, [id]);
    expect(platform.pendingById, isEmpty);
  });

  test('a failing source does not block the others', () async {
    scheduler.registerSource(
      'broken',
      () async => throw const FormatException('x'),
    );

    await scheduler.replan();

    expect(platform.pendingById, hasLength(1));
  });

  test('falls back to inexact alarms when exact are not allowed', () async {
    platform.exact = false;

    await scheduler.replan();

    expect(platform.exactFlags, [false]);
    expect(scheduler.exactAlarmsAvailable, isFalse);
  });

  test('platform errors are contained', () async {
    final failing = _ThrowingPlatform();
    final s = NotificationScheduler(
      platform: failing,
      planner: const NotificationPlanner(budget: 60),
      timeZone: tzService,
      logger: AppLogger(verbose: false),
    )..registerSource('reminders', () async => reminders);
    addTearDown(s.dispose);

    await expectLater(s.replan(), completes);
  });

  test('concurrent replans are coalesced into one follow-up run', () async {
    platform.gate = Completer<void>();
    final first = scheduler.replan();
    final second = scheduler.replan();
    final third = scheduler.replan();
    platform.gate?.complete();
    await Future.wait([first, second, third]);

    // One run plus one coalesced re-run.
    expect(platform.scheduleCalls, 2);
  });

  test('a timezone change on resume re-plans in the new zone', () async {
    await scheduler.replan();
    zone = 'Europe/London';

    await scheduler.onResumed();

    final at = platform.pendingById.values.single.$1?.at;
    expect(at?.location.name, 'Europe/London');
    expect(at?.hour, 10, reason: 'wall-clock time is kept');
  });

  test('permission is requested only when not already granted', () async {
    expect(await scheduler.ensurePermission(), isTrue);
    expect(platform.requests, 1);

    expect(await scheduler.ensurePermission(), isTrue);
    expect(platform.requests, 1);
  });

  test('denied permission is reported', () async {
    platform.grantOnRequest = false;
    expect(await scheduler.ensurePermission(), isFalse);
  });

  test('taps emit only in-app routes', () async {
    final routes = <String>[];
    final sub = scheduler.tapRoutes.listen(routes.add);
    addTearDown(sub.cancel);
    NotificationTap tap(String route) => NotificationTap(
      id: 1,
      payload: NotificationPayload(
        kind: NotificationKind.reminder,
        route: route,
        title: 't',
        body: 'b',
      ),
    );

    platform.onTap?.call(tap('/reminders/r1'));
    platform.onTap?.call(tap('https://evil.example'));
    platform.onTap?.call(tap('//evil.example'));
    platform.onTap?.call(const NotificationTap(id: 2));
    await Future<void>.delayed(Duration.zero);

    expect(routes, ['/reminders/r1']);
  });

  test('launch route comes from the launching notification', () async {
    platform.launch = const NotificationTap(
      id: 1,
      payload: NotificationPayload(
        kind: NotificationKind.medicine,
        route: '/medicine/m1',
        title: 't',
        body: 'b',
      ),
    );
    expect(await scheduler.launchRoute(), '/medicine/m1');
  });

  test('snooze action IDs parse only known durations', () {
    expect(SnoozeActions.parse('snooze:10'), 10);
    expect(SnoozeActions.parse('snooze:7'), isNull);
    expect(SnoozeActions.parse('open'), isNull);
    expect(SnoozeActions.parse(null), isNull);
  });

  test('showNow: one fixed ID per entity; a re-plan never cancels or '
      'repeats it; cancelShown removes it', () async {
    for (var i = 0; i < 2; i++) {
      await scheduler.showNow(
        kind: NotificationKind.shopping,
        entityId: 'list-1',
        title: '2 items left in Weekly',
        body: 'Milk · 2',
        route: '/shopping/session',
      );
    }
    final id = NotificationScheduler.oneOffId(
      NotificationKind.shopping,
      'list-1',
    );
    expect(platform.shown.map((s) => s.$1), [id, id]);
    expect(platform.shown.first.$2.route, '/shopping/session');

    await scheduler.replan();
    expect(platform.cancelled, isNot(contains(id)));
    expect(platform.pendingById, isNot(contains(id)));

    await scheduler.cancelShown(NotificationKind.shopping, 'list-1');
    expect(platform.cancelled, contains(id));
  });
}

final class _ThrowingPlatform extends FakePlatform {
  @override
  Future<List<PendingNotification>> pending() =>
      throw PlatformException(code: 'boom');
}

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';

import '../../helpers/fakes.dart';

void main() {
  late TestClock clock;

  AppLock unlocked({Duration timeout = Duration.zero}) => AppLock(
    initialStatus: LockStatus.unlocked,
    timeout: timeout,
    clock: clock.call,
  );

  setUp(() => clock = TestClock());

  test(
    'locks on return from background with the default immediate timeout',
    () {
      final lock = unlocked();
      addTearDown(lock.dispose);

      lock
        ..onBackgrounded()
        ..onForegrounded();

      expect(lock.status, LockStatus.locked);
    },
  );

  test('stays unlocked when back before the timeout, locks after', () {
    final lock = unlocked(timeout: const Duration(minutes: 1));
    addTearDown(lock.dispose);

    lock.onBackgrounded();
    clock.advance(const Duration(seconds: 59));
    lock.onForegrounded();
    expect(lock.status, LockStatus.unlocked);

    lock.onBackgrounded();
    clock.advance(const Duration(minutes: 1));
    lock.onForegrounded();
    expect(lock.status, LockStatus.locked);
  });

  test(
    'external activities (pickers, share sheet) do not trigger a lock',
    () async {
      final lock = unlocked();
      addTearDown(lock.dispose);

      final result = await lock.runExternal(() async {
        lock
          ..onBackgrounded()
          ..onForegrounded();
        return 42;
      });

      expect(result, 42);
      expect(lock.status, LockStatus.unlocked);
    },
  );

  test(
    'external activity counter is released even when the action throws',
    () async {
      final lock = unlocked();
      addTearDown(lock.dispose);

      await expectLater(
        lock.runExternal<void>(() async => throw StateError('x')),
        throwsStateError,
      );
      lock
        ..onBackgrounded()
        ..onForegrounded();

      expect(lock.status, LockStatus.locked);
    },
  );

  test('lock() is a no-op before setup and notifies only on change', () {
    final lock = AppLock(initialStatus: LockStatus.notSetUp);
    addTearDown(lock.dispose);
    var notified = 0;
    lock
      ..addListener(() => notified++)
      ..lock();
    expect(lock.status, LockStatus.notSetUp);
    expect(notified, 0);

    lock
      ..markUnlocked()
      ..markUnlocked()
      ..lock();
    expect(lock.status, LockStatus.locked);
    expect(notified, 2);
  });
}

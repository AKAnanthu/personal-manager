import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/security/password_hasher.dart';
import 'package:personal_life_manager/features/auth/data/auth_repository_impl.dart';
import 'package:personal_life_manager/features/auth/domain/auth_repository.dart';

import '../../helpers/fakes.dart';

T ok<T>(Result<T> r) => r.fold((f) => fail('unexpected $f'), (v) => v);

void main() {
  late InMemorySecureStore store;
  late TestClock clock;
  late AuthRepositoryImpl repo;

  setUp(() {
    store = InMemorySecureStore();
    clock = TestClock();
    repo = AuthRepositoryImpl(
      store: store,
      hasher: const PasswordHasher(iterations: 1000),
      clock: clock.call,
    );
  });

  Future<UnlockOutcome> attempt(String pw) async =>
      ok<UnlockOutcome>(await repo.unlockWithPassword(pw));

  test('is set up only after a password is created; stores a hash', () async {
    expect(ok(await repo.isSetUp()), isFalse);

    ok(await repo.createPassword('hunter22'));

    expect(ok(await repo.isSetUp()), isTrue);
    expect(store.values[AuthKeys.passwordHash], isNot(contains('hunter22')));
  });

  test('unlocks with the right password', () async {
    ok(await repo.createPassword('hunter22'));

    expect(await attempt('hunter22'), const UnlockSucceeded());
  });

  test('wrong passwords count down, then lock out with backoff', () async {
    ok(await repo.createPassword('hunter22'));

    expect(await attempt('x'), const WrongPassword(attemptsBeforeLockout: 4));
    for (var i = 0; i < 3; i++) {
      await attempt('x');
    }
    final fifth = await attempt('x');

    expect(
      fifth,
      WrongPassword(
        attemptsBeforeLockout: 0,
        lockedUntil: clock.now.add(const Duration(seconds: 30)),
      ),
    );
    // Even the right password is refused during the lockout.
    expect(await attempt('hunter22'), isA<LockedOut>());
    expect(ok(await repo.lockedUntil()), isNotNull);
  });

  test('lockout survives a new repository instance (app restart)', () async {
    ok(await repo.createPassword('hunter22'));
    for (var i = 0; i < 5; i++) {
      await attempt('x');
    }

    final restarted = AuthRepositoryImpl(
      store: store,
      hasher: const PasswordHasher(iterations: 1000),
      clock: clock.call,
    );

    expect(
      ok(await restarted.unlockWithPassword('hunter22')),
      isA<LockedOut>(),
    );
  });

  test(
    'after the wait, a failure doubles the lockout; success resets',
    () async {
      ok(await repo.createPassword('hunter22'));
      for (var i = 0; i < 5; i++) {
        await attempt('x');
      }
      clock.advance(const Duration(seconds: 30));
      expect(ok(await repo.lockedUntil()), isNull);

      final sixth = await attempt('x');
      expect(
        (sixth as WrongPassword).lockedUntil,
        clock.now.add(const Duration(minutes: 1)),
      );

      clock.advance(const Duration(minutes: 1));
      expect(await attempt('hunter22'), const UnlockSucceeded());
      expect(await attempt('x'), const WrongPassword(attemptsBeforeLockout: 4));
    },
  );

  test('biometric unlock clears the failure counter', () async {
    ok(await repo.createPassword('hunter22'));
    for (var i = 0; i < 3; i++) {
      await attempt('x');
    }

    ok(await repo.recordBiometricUnlock());

    expect(await attempt('x'), const WrongPassword(attemptsBeforeLockout: 4));
  });

  test('stores the biometric preference', () async {
    expect(ok(await repo.isBiometricEnabled()), isFalse);
    ok(await repo.setBiometricEnabled(enabled: true));
    expect(ok(await repo.isBiometricEnabled()), isTrue);
  });

  test('maps secure storage errors to StorageFailure', () async {
    final failing = MockSecureStore();
    when(() => failing.read(any()))
        .thenThrow(PlatformException(code: 'keystore'));

    final result = await AuthRepositoryImpl(store: failing).isSetUp();

    expect(result.fold((f) => f, (_) => null), isA<StorageFailure>());
  });
}

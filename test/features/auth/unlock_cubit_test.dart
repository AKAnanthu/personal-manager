import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/security/biometric_auth.dart';
import 'package:personal_life_manager/features/auth/domain/auth_repository.dart';
import 'package:personal_life_manager/features/auth/presentation/unlock/unlock_cubit.dart';

import '../../helpers/fakes.dart';

void main() {
  late MockAuthRepository repo;
  late MockBiometricAuth bio;
  late AppLock lock;
  late TestClock clock;

  setUp(() {
    repo = MockAuthRepository();
    bio = MockBiometricAuth();
    clock = TestClock();
    lock = AppLock(initialStatus: LockStatus.locked);
    when(repo.lockedUntil).thenAnswer((_) async => const Ok(null));
    when(repo.isBiometricEnabled).thenAnswer((_) async => const Ok(false));
    when(repo.recordBiometricUnlock).thenAnswer((_) async => const Ok(null));
  });
  tearDown(() => lock.dispose());

  UnlockCubit build() => UnlockCubit(
    repository: repo,
    biometrics: bio,
    lock: lock,
    clock: clock.call,
  );

  blocTest<UnlockCubit, UnlockState>(
    'correct password unlocks the app',
    setUp: () =>
        when(() => repo.unlockWithPassword('pw'))
            .thenAnswer((_) async => const Ok(UnlockSucceeded())),
    build: build,
    act: (c) => c.unlockWithPassword('pw'),
    verify: (_) => expect(lock.status, LockStatus.unlocked),
  );

  blocTest<UnlockCubit, UnlockState>(
    'wrong password shows attempts left and stays locked',
    setUp: () => when(() => repo.unlockWithPassword('bad')).thenAnswer(
      (_) async => const Ok(WrongPassword(attemptsBeforeLockout: 3)),
    ),
    build: build,
    act: (c) => c.unlockWithPassword('bad'),
    verify: (c) {
      expect(c.state.error, const WrongPasswordError(3));
      expect(c.state.busy, isFalse);
      expect(lock.status, LockStatus.locked);
    },
  );

  blocTest<UnlockCubit, UnlockState>(
    'a lockout blocks further attempts until it expires',
    setUp: () => when(() => repo.unlockWithPassword(any())).thenAnswer(
      (_) async => Ok(
        WrongPassword(
          attemptsBeforeLockout: 0,
          lockedUntil: clock.now.add(const Duration(seconds: 30)),
        ),
      ),
    ),
    build: build,
    act: (c) async {
      await c.unlockWithPassword('bad');
      await c.unlockWithPassword('again');
    },
    verify: (c) {
      expect(c.state.isLockedOut, isTrue);
      expect(c.state.lockoutRemaining, const Duration(seconds: 30));
      verify(() => repo.unlockWithPassword(any())).called(1);
    },
  );

  blocTest<UnlockCubit, UnlockState>(
    'storage failure surfaces an error',
    setUp: () =>
        when(() => repo.unlockWithPassword(any()))
            .thenAnswer((_) async => const Err(StorageFailure())),
    build: build,
    act: (c) => c.unlockWithPassword('pw'),
    verify: (c) => expect(c.state.error, const StorageError()),
  );

  blocTest<UnlockCubit, UnlockState>(
    'empty password is ignored',
    build: build,
    act: (c) => c.unlockWithPassword(''),
    expect: () => <UnlockState>[],
    verify: (_) => verifyNever(() => repo.unlockWithPassword(any())),
  );

  group('biometrics', () {
    setUp(() {
      when(repo.isBiometricEnabled).thenAnswer((_) async => const Ok(true));
      when(bio.availableKind)
          .thenAnswer((_) async => BiometricKind.fingerprint);
    });

    blocTest<UnlockCubit, UnlockState>(
      'init prompts once and unlocks on success',
      setUp: () =>
          when(() => bio.authenticate(reason: any(named: 'reason')))
              .thenAnswer((_) async => true),
      build: build,
      act: (c) => c.init(biometricReason: 'r'),
      verify: (_) {
        verify(() => bio.authenticate(reason: 'r')).called(1);
        verify(repo.recordBiometricUnlock).called(1);
        expect(lock.status, LockStatus.unlocked);
      },
    );

    blocTest<UnlockCubit, UnlockState>(
      'a cancelled prompt falls back to the password',
      setUp: () =>
          when(() => bio.authenticate(reason: any(named: 'reason')))
              .thenAnswer((_) async => false),
      build: build,
      act: (c) => c.init(biometricReason: 'r'),
      verify: (c) {
        expect(c.state.error, const BiometricFailedError());
        expect(c.state.biometricKind, BiometricKind.fingerprint);
        expect(c.state.busy, isFalse);
        expect(lock.status, LockStatus.locked);
      },
    );

    blocTest<UnlockCubit, UnlockState>(
      'not offered when the sensor is no longer available',
      setUp: () => when(bio.availableKind).thenAnswer((_) async => null),
      build: build,
      act: (c) => c.init(biometricReason: 'r'),
      verify: (c) {
        expect(c.state.biometricKind, isNull);
        verifyNever(() => bio.authenticate(reason: any(named: 'reason')));
      },
    );
  });
}

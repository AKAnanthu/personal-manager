import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/security/biometric_auth.dart';
import 'package:personal_life_manager/features/auth/presentation/setup/setup_cubit.dart';

import '../../helpers/fakes.dart';

void main() {
  late MockAuthRepository repo;
  late MockBiometricAuth bio;
  late AppLock lock;

  setUp(() {
    repo = MockAuthRepository();
    bio = MockBiometricAuth();
    lock = AppLock(initialStatus: LockStatus.notSetUp);
    when(() => repo.createPassword(any()))
        .thenAnswer((_) async => const Ok(null));
    when(() => repo.setBiometricEnabled(enabled: any(named: 'enabled')))
        .thenAnswer((_) async => const Ok(null));
  });
  tearDown(() => lock.dispose());

  SetupCubit build() =>
      SetupCubit(repository: repo, biometrics: bio, lock: lock);

  void fillValid(SetupCubit c) => c
    ..start()
    ..passwordChanged('Abcdefg1')
    ..confirmationChanged('Abcdefg1')
    ..acknowledgedChanged(value: true);

  test('cannot submit until valid, matching and acknowledged', () {
    final c = build()
      ..start()
      ..passwordChanged('short');
    expect(c.state.canSubmitPassword, isFalse);

    c
      ..passwordChanged('Abcdefg1')
      ..confirmationChanged('Abcdefg2');
    expect(c.state.confirmationMismatch, isTrue);
    expect(c.state.canSubmitPassword, isFalse);

    c.confirmationChanged('Abcdefg1');
    expect(c.state.canSubmitPassword, isFalse, reason: 'not acknowledged');

    c.acknowledgedChanged(value: true);
    expect(c.state.canSubmitPassword, isTrue);
    addTearDown(c.close);
  });

  test('submitPassword without valid input does nothing', () async {
    final c = build()..start();
    addTearDown(c.close);
    await c.submitPassword();
    verifyNever(() => repo.createPassword(any()));
  });

  blocTest<SetupCubit, SetupState>(
    'with biometrics available: hashes, drops the plaintext, shows step 3',
    setUp: () =>
        when(bio.availableKind)
            .thenAnswer((_) async => BiometricKind.fingerprint),
    build: build,
    act: (c) async {
      fillValid(c);
      await c.submitPassword();
    },
    verify: (c) {
      verify(() => repo.createPassword('Abcdefg1')).called(1);
      expect(c.state.step, SetupStep.biometric);
      expect(c.state.password, isEmpty);
      expect(c.state.biometricKind, BiometricKind.fingerprint);
      expect(lock.status, LockStatus.notSetUp);
    },
  );

  blocTest<SetupCubit, SetupState>(
    'without biometrics: finishes and unlocks',
    setUp: () => when(bio.availableKind).thenAnswer((_) async => null),
    build: build,
    act: (c) async {
      fillValid(c);
      await c.submitPassword();
    },
    verify: (_) => expect(lock.status, LockStatus.unlocked),
  );

  blocTest<SetupCubit, SetupState>(
    'storage failure keeps the user on the password step with an error',
    setUp: () =>
        when(() => repo.createPassword(any()))
            .thenAnswer((_) async => const Err(StorageFailure())),
    build: build,
    act: (c) async {
      fillValid(c);
      await c.submitPassword();
    },
    verify: (c) {
      expect(c.state.step, SetupStep.password);
      expect(c.state.error, SetupError.storage);
      expect(c.state.busy, isFalse);
      expect(lock.status, LockStatus.notSetUp);
    },
  );

  group('biometric step', () {
    setUp(
      () => when(bio.availableKind).thenAnswer((_) async => BiometricKind.face),
    );

    blocTest<SetupCubit, SetupState>(
      'enabling after a successful scan saves the flag and unlocks',
      setUp: () =>
          when(() => bio.authenticate(reason: any(named: 'reason')))
              .thenAnswer((_) async => true),
      build: build,
      act: (c) async {
        fillValid(c);
        await c.submitPassword();
        await c.enableBiometric(reason: 'r');
      },
      verify: (_) {
        verify(() => repo.setBiometricEnabled(enabled: true)).called(1);
        expect(lock.status, LockStatus.unlocked);
      },
    );

    blocTest<SetupCubit, SetupState>(
      'a failed scan shows an error and leaves biometrics off',
      setUp: () =>
          when(() => bio.authenticate(reason: any(named: 'reason')))
              .thenAnswer((_) async => false),
      build: build,
      act: (c) async {
        fillValid(c);
        await c.submitPassword();
        await c.enableBiometric(reason: 'r');
      },
      verify: (c) {
        expect(c.state.error, SetupError.biometricFailed);
        verifyNever(
          () => repo.setBiometricEnabled(enabled: any(named: 'enabled')),
        );
        expect(lock.status, LockStatus.notSetUp);
      },
    );

    blocTest<SetupCubit, SetupState>(
      'skipping unlocks without enabling',
      build: build,
      act: (c) async {
        fillValid(c);
        await c.submitPassword();
        c.skipBiometric();
      },
      verify: (_) {
        expect(lock.status, LockStatus.unlocked);
        verifyNever(
          () => repo.setBiometricEnabled(enabled: any(named: 'enabled')),
        );
      },
    );
  });
}

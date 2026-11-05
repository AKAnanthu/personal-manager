import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/app/app.dart';
import 'package:personal_life_manager/app/di.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/security/biometric_auth.dart';
import 'package:personal_life_manager/features/auth/domain/auth_repository.dart';
import 'package:personal_life_manager/features/auth/presentation/setup/setup_page.dart';
import 'package:personal_life_manager/features/auth/presentation/unlock/unlock_page.dart';
import 'package:personal_life_manager/features/dashboard/domain/upcoming_item.dart';

import '../helpers/fakes.dart';

void main() {
  late MockAuthRepository repo;
  late MockBiometricAuth bio;

  setUp(() {
    repo = MockAuthRepository();
    bio = MockBiometricAuth();
    when(() => repo.createPassword(any()))
        .thenAnswer((_) async => const Ok(null));
    when(repo.lockedUntil).thenAnswer((_) async => const Ok(null));
    when(repo.isBiometricEnabled).thenAnswer((_) async => const Ok(false));
    when(bio.availableKind).thenAnswer((_) async => null);
    sl
      ..registerSingleton<AuthRepository>(repo)
      ..registerSingleton<BiometricAuth>(bio)
      ..registerSingleton<List<UpcomingSource>>(const []);
  });
  tearDown(sl.reset);

  Future<void> enterField(WidgetTester tester, String label, String text) =>
      tester.enterText(
        find.descendant(
          of: find.bySemanticsLabel(label),
          matching: find.byType(EditableText),
        ),
        text,
      );

  void usePhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('first run: setup → home → lock → unlock → home', (tester) async {
    usePhoneSize(tester);
    final lock = AppLock(initialStatus: LockStatus.notSetUp);
    addTearDown(lock.dispose);
    await tester.pumpWidget(PlmApp(lock: lock));
    await tester.pumpAndSettle();

    // Step 1: welcome.
    expect(find.byType(SetupPage), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 2: password + acknowledgement.
    await tester.enterText(find.byType(EditableText).at(0), 'Abcdefg1');
    await tester.enterText(find.byType(EditableText).at(1), 'Abcdefg1');
    await tester.pump();
    final continueButton = find.widgetWithText(FilledButton, 'Continue');
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

    final acknowledge = find.text('I understand how my data is stored');
    await tester.scrollUntilVisible(
      acknowledge,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(acknowledge);
    await tester.pump();
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // No biometrics on this device → straight into the app.
    verify(() => repo.createPassword('Abcdefg1')).called(1);
    expect(find.byType(NavigationBar), findsOneWidget);

    // Lock now.
    await tester.tap(find.byTooltip('Lock app'));
    await tester.pumpAndSettle();
    expect(find.byType(UnlockPage), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    // Wrong, then right password.
    when(() => repo.unlockWithPassword('nope')).thenAnswer(
      (_) async => const Ok(WrongPassword(attemptsBeforeLockout: 4)),
    );
    when(() => repo.unlockWithPassword('Abcdefg1'))
        .thenAnswer((_) async => const Ok(UnlockSucceeded()));

    await enterField(tester, 'App password', 'nope');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(
      find.text('Wrong password. 4 attempts left before a short wait.'),
      findsOneWidget,
    );

    await enterField(tester, 'App password', 'Abcdefg1');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(lock.status, LockStatus.unlocked);
  });

  testWidgets('lockout disables unlocking and shows a countdown', (
    tester,
  ) async {
    when(repo.lockedUntil).thenAnswer(
      (_) async => Ok(DateTime.now().add(const Duration(minutes: 1))),
    );
    final lock = AppLock(initialStatus: LockStatus.locked);
    addTearDown(lock.dispose);
    await tester.pumpWidget(PlmApp(lock: lock));
    await tester.pumpAndSettle();

    expect(find.textContaining('Too many attempts'), findsOneWidget);
    final unlock = find.widgetWithText(FilledButton, 'Unlock');
    expect(tester.widget<FilledButton>(unlock).onPressed, isNull);
    verifyNever(() => repo.unlockWithPassword(any()));
  });

  testWidgets('offers biometrics only when enabled, falls back on cancel', (
    tester,
  ) async {
    when(repo.isBiometricEnabled).thenAnswer((_) async => const Ok(true));
    when(bio.availableKind).thenAnswer((_) async => BiometricKind.fingerprint);
    when(() => bio.authenticate(reason: any(named: 'reason')))
        .thenAnswer((_) async => false);
    final lock = AppLock(initialStatus: LockStatus.locked);
    addTearDown(lock.dispose);

    await tester.pumpWidget(PlmApp(lock: lock));
    await tester.pumpAndSettle();

    expect(find.text('Use fingerprint'), findsOneWidget);
    expect(
      find.text("Biometric check didn't work. Try again or use your password."),
      findsOneWidget,
    );
    expect(lock.status, LockStatus.locked);
  });

  for (final status in [LockStatus.notSetUp, LockStatus.locked]) {
    testWidgets('${status.name} screen fits a small phone at 200% text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      final lock = AppLock(initialStatus: status);
      addTearDown(lock.dispose);

      await tester.pumpWidget(PlmApp(lock: lock));
      await tester.pumpAndSettle();
      if (status == LockStatus.notSetUp) {
        final next = find.text('Continue');
        await tester.ensureVisible(next);
        await tester.pumpAndSettle();
        await tester.tap(next);
        await tester.pumpAndSettle();
        expect(find.text('Create your app password'), findsOneWidget);
      }

      expect(tester.takeException(), isNull);
    });
  }
}

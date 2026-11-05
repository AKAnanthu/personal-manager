import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/security/biometric_auth.dart';
import 'package:personal_life_manager/core/security/password_hasher.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/features/auth/data/auth_repository_impl.dart';
import 'package:personal_life_manager/features/auth/domain/auth_repository.dart';
import 'package:personal_life_manager/features/auth/presentation/unlock/unlock_cubit.dart';
import 'package:personal_life_manager/features/auth/presentation/unlock/unlock_page.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_platform.dart';
import 'package:personal_life_manager/features/notes/data/notes_repository_impl.dart';
import 'package:personal_life_manager/features/notes/domain/note.dart';
import 'package:personal_life_manager/features/settings/data/app_settings.dart';
import 'package:personal_life_manager/features/settings/data/data_eraser.dart';
import 'package:personal_life_manager/features/settings/presentation/settings_cubits.dart';
import 'package:personal_life_manager/features/settings/presentation/settings_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';
import 'package:personal_life_manager/l10n/locales.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../helpers/fakes.dart';

class _Auth extends Mock implements AuthRepository;

class _Biometrics extends Mock implements BiometricAuth;

class _Perms extends Mock implements NotificationPermissions;

class _Last extends Mock implements LastBackupStore;

class _Eraser extends Mock implements DataEraser;

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  localizationsDelegates: const [
    ...AppLocalizations.localizationsDelegates,
    GlobalMaterialLocalizations.delegate,
  ],
  supportedLocales: appSupportedLocales,
  locale: const Locale('en', 'IN'),
  home: child,
);

void main() {
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  group('AppSettings', () {
    test('auto-lock and theme apply at once and survive a restart', () async {
      final lock = AppLock(initialStatus: LockStatus.unlocked);
      addTearDown(lock.dispose);
      final settings = AppSettings(lock);
      await settings.load();
      expect(lock.timeout, Duration.zero);
      await settings.setAutoLock(AutoLock.after1min);
      await settings.setTheme(ThemeMode.dark);
      expect(lock.timeout, const Duration(minutes: 1));

      final again = AppSettings(lock);
      await again.load();
      expect(
        (again.autoLock, again.themeMode.value),
        (AutoLock.after1min, ThemeMode.dark),
      );
      expect(again.export(), {'theme': 'dark', 'autoLock': 'after1min'});

      await again.reset();
      expect(lock.timeout, Duration.zero);
      expect(await SharedPreferencesAsync().getKeys(), isEmpty);
    });
  });

  group('change password', () {
    test('needs the right current password; counts wrong attempts', () async {
      final repo = AuthRepositoryImpl(
        store: InMemorySecureStore(),
        // Fast hashing for tests.
        hasher: const PasswordHasher(iterations: 1000),
      );
      ok(await repo.createPassword('old-password'));
      final wrong = ok(
        await repo.changePassword(current: 'nope', replacement: 'new-password'),
      );
      expect(wrong, isA<WrongPassword>());
      expect(
        ok(await repo.unlockWithPassword('old-password')),
        const UnlockSucceeded(),
      );
      expect(
        ok(
          await repo.changePassword(
            current: 'old-password',
            replacement: 'new-password',
          ),
        ),
        const UnlockSucceeded(),
      );
      expect(
        ok(await repo.unlockWithPassword('new-password')),
        const UnlockSucceeded(),
      );
    });

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'validates before checking; wrong current shows attempts left',
      setUp: () {},
      build: () {
        final auth = _Auth();
        when(
          () => auth.changePassword(
            current: any(named: 'current'),
            replacement: any(named: 'replacement'),
          ),
        ).thenAnswer(
          (_) async => const Ok(WrongPassword(attemptsBeforeLockout: 3)),
        );
        return ChangePasswordCubit(auth);
      },
      act: (c) async {
        c
          ..currentChanged('old')
          ..replacementChanged('short')
          ..confirmChanged('short');
        await c.submit();
        expect(c.state.showErrors, isTrue);
        c
          ..replacementChanged('long-enough-1')
          ..confirmChanged('long-enough-1');
        await c.submit();
      },
      verify: (c) {
        expect(c.state.attemptsLeft, 3);
        expect(c.state.outcome, ChangePasswordOutcome.none);
      },
    );
  });

  test(
    'erase: every record, file and the password go; back to setup',
    () async {
      final dir = Directory.systemTemp.createTempSync('erase');
      addTearDown(() => dir.deleteSync(recursive: true));
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final files = Directory(p.join(dir.path, 'files'))..createSync();
      final temp = Directory(p.join(dir.path, 'tmp'))..createSync();
      File(p.join(temp.path, 'leftover')).writeAsStringSync('x');
      final notes = NotesRepositoryImpl(db: db, files: FileStore(files));
      final id = ok<String>(
        await notes.save(
          const NoteDraft(title: 'Secret', contentJson: '[]', plainText: 'x'),
        ),
      );
      final scan = File(p.join(dir.path, 'a.pdf'))
        ..writeAsBytesSync([0x25, 0x50, 0x44, 0x46]);
      ok(await notes.addAttachment(id, scan, originalName: 'a.pdf'));
      final secure = InMemorySecureStore();
      await secure.write('auth.passwordHash', 'h');
      final lock = AppLock(initialStatus: LockStatus.unlocked);
      addTearDown(lock.dispose);
      var cleared = false;

      await DataEraser(
        db: db,
        filesDir: files,
        tempDir: temp,
        secure: secure,
        settings: AppSettings(lock),
        clearNotifications: () async => cleared = true,
        lock: lock,
      ).eraseEverything();

      expect(await notes.watchNotes(const NotesFilter()).first, isEmpty);
      expect(
        await notes.watchNotes(const NotesFilter(query: 'secret')).first,
        isEmpty,
      );
      expect(files.listSync(), isEmpty);
      expect(temp.listSync(), isEmpty);
      expect(await secure.read('auth.passwordHash'), isNull);
      expect(cleared, isTrue);
      expect(lock.status, LockStatus.notSetUp);
    },
  );

  testWidgets('settings page: sections, fingerprint, theme', (tester) async {
    tester.view
      ..physicalSize = const Size(1170, 4200)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final auth = _Auth();
    final bio = _Biometrics();
    final perms = _Perms();
    final last = _Last();
    final lock = AppLock(initialStatus: LockStatus.unlocked);
    addTearDown(lock.dispose);
    final settings = AppSettings(lock);
    when(bio.availableKind).thenAnswer((_) async => BiometricKind.fingerprint);
    when(auth.isBiometricEnabled).thenAnswer((_) async => const Ok(true));
    when(perms.areEnabled).thenAnswer((_) async => true);
    when(() => perms.exactAlarmsAvailable).thenReturn(false);
    when(last.load).thenAnswer((_) async => null);

    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) {
            final c = SettingsCubit(
              auth: auth,
              biometrics: bio,
              permissions: perms,
              settings: settings,
              lastBackup: last,
              eraser: _Eraser(),
            );
            unawaited(c.load());
            return c;
          },
          child: const SettingsPage(appVersion: '1.0.0'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final t in [
      'SECURITY',
      'Change app password',
      'Fingerprint unlock',
      'As soon as you leave the app',
      'Not connected · coming in a later update',
      'No backup made on this phone yet.',
      'Monthly · starts on the 1st',
      'Version 1.0.0 · licences',
      'Erase all data',
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    expect(find.textContaining('may ring a few minutes late'), findsOneWidget);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(settings.themeMode.value, ThemeMode.dark);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('forgot password: erase only after typing ERASE', (tester) async {
    final auth = _Auth();
    final bio = _Biometrics();
    when(bio.availableKind).thenAnswer((_) async => null);
    when(auth.isBiometricEnabled).thenAnswer((_) async => const Ok(false));
    when(auth.lockedUntil).thenAnswer((_) async => const Ok(null));
    final lock = AppLock(initialStatus: LockStatus.locked);
    addTearDown(lock.dispose);
    var erased = 0;
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) =>
              UnlockCubit(repository: auth, biometrics: bio, lock: lock),
          child: UnlockPage(onErase: () async => erased++),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Forgot your password?'), findsOneWidget);
    final erase = find.widgetWithText(TextButton, 'Erase everything');
    expect(tester.widget<TextButton>(erase).onPressed, isNull);
    await tester.enterText(find.byType(TextField).last, 'erase');
    await tester.pump();
    await tester.tap(erase);
    await tester.pumpAndSettle();
    expect(erased, 1);
  });
}

T ok<T>(Result<T> r) => r.fold((f) => fail('unexpected $f'), (v) => v);

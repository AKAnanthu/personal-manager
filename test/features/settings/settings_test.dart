import 'dart:async';
import 'dart:io';

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
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_platform.dart';
import 'package:personal_life_manager/features/notes/data/notes_repository_impl.dart';
import 'package:personal_life_manager/features/notes/domain/note.dart';
import 'package:personal_life_manager/features/settings/data/app_settings.dart';
import 'package:personal_life_manager/features/settings/data/data_eraser.dart';
import 'package:personal_life_manager/features/settings/presentation/erase_dialog.dart';
import 'package:personal_life_manager/features/settings/presentation/settings_cubits.dart';
import 'package:personal_life_manager/features/settings/presentation/settings_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';
import 'package:personal_life_manager/l10n/locales.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../helpers/fakes.dart';

class _Perms extends Mock implements NotificationPermissions;

class _Last extends Mock implements LastBackupStore;

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

  test(
    'erase: every record, file and preference go; Drive is left alone',
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
      // Wiping this phone records no deletions to send to Drive.
      for (final t in ['sync_outbox', 'sync_remote', 'sync_mute']) {
        expect(await db.customSelect('SELECT * FROM $t').get(), isEmpty);
      }
    },
  );

  testWidgets('settings page: sections, account, theme', (tester) async {
    tester.view
      ..physicalSize = const Size(1170, 4200)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final perms = _Perms();
    final last = _Last();
    final lock = AppLock(initialStatus: LockStatus.unlocked);
    addTearDown(lock.dispose);
    final settings = AppSettings(lock);
    when(perms.areEnabled).thenAnswer((_) async => true);
    when(() => perms.exactAlarmsAvailable).thenReturn(false);
    when(last.load).thenAnswer((_) async => null);

    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) {
            final c = SettingsCubit(
              permissions: perms,
              settings: settings,
              lastBackup: last,
            );
            unawaited(c.load());
            return c;
          },
          child: SettingsPage(
            appVersion: '1.0.0',
            driveAccount: ValueNotifier<String?>('me@gmail.com'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final t in [
      'SECURITY',
      'As soon as you leave the app',
      'Account & sync',
      'me@gmail.com',
      'Google Drive files',
      'No backup made on this phone yet.',
      'Monthly · starts on the 1st',
      'Terms of use',
      'Version 1.0.0 · licences',
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

  testWidgets('delete all my data only after typing ERASE', (tester) async {
    bool? confirmed;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => confirmed = await confirmErase(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Delete all my data'), findsOneWidget);
    final erase = find.widgetWithText(TextButton, 'Erase everything');
    expect(tester.widget<TextButton>(erase).onPressed, isNull);
    await tester.enterText(find.byType(TextField).last, 'erase');
    await tester.pump();
    await tester.tap(erase);
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
  });
}

T ok<T>(Result<T> r) => r.fold((f) => fail('unexpected $f'), (v) => v);

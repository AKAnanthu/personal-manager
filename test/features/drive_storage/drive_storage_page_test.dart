import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/drive/drive_folders.dart';
import 'package:personal_life_manager/core/storage/file_access.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/features/drive_storage/presentation/drive_browser_cubit.dart';
import 'package:personal_life_manager/features/drive_storage/presentation/drive_storage_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';
import 'package:personal_life_manager/l10n/locales.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../helpers/fake_drive.dart';

class _Pickers extends Mock implements FilePickers;

class _Opener extends Mock implements FileOpener;

class _Saver extends Mock implements FileSaver;

/// The page with fake Drive pieces.
Future<void> pumpDrivePage(
  WidgetTester tester, {
  required FakeDriveAuth auth,
  required FakeDriveService drive,
  required Directory temp,
  FileSaver? saver,
  FilePickers? pickers,
}) async {
  final folders = DriveFolders(drive, SharedPreferencesAsync());
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: appSupportedLocales,
      locale: const Locale('en', 'IN'),
      home: BlocProvider(
        create: (_) {
          final c = DriveBrowserCubit(
            auth: auth,
            drive: drive,
            folders: folders,
            tempDir: temp,
          );
          unawaited(c.start());
          return c;
        },
        child: DriveStoragePage(
          pickers: pickers ?? _Pickers(),
          opener: _Opener(),
          saver: saver ?? _Saver(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late Directory dir;

  setUpAll(() => registerFallbackValue(File('x')));
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    dir = Directory.systemTemp.createTempSync('drive_page');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  testWidgets('not connected: explains, then connects and shows folders', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final auth = FakeDriveAuth();
    final drive = FakeDriveService();
    await pumpDrivePage(tester, auth: auth, drive: drive, temp: dir);

    expect(find.text('Not connected'), findsOneWidget);
    expect(find.textContaining('never the rest of your Drive'), findsOneWidget);
    expect(find.textContaining('not encrypted by this app'), findsOneWidget);
    expect(find.text('Upload'), findsNothing);

    await tester.tap(find.text('Connect Google Drive'));
    await tester.pumpAndSettle();
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('me@example.com'), findsOneWidget);
    for (final f in ['Backups', 'Documents', 'Receipts']) {
      expect(find.text(f), findsOneWidget);
    }
    expect(find.text('7 items'), findsOneWidget);
    expect(find.textContaining("Only this app's folder is shown"), findsOne);

    await tester.tap(find.text('Documents'));
    await tester.pumpAndSettle();
    expect(find.text('Property and Vehicle'), findsOneWidget);
    expect(find.text('Educational'), findsOneWidget);
    // Breadcrumb back to the top.
    await tester.tap(find.text('Personal Life Manager'));
    await tester.pumpAndSettle();
    expect(find.text('Receipts'), findsOneWidget);
  });

  testWidgets('files: details, save to phone, move to trash', (tester) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final auth = FakeDriveAuth(account: 'me@example.com');
    final drive = FakeDriveService();
    final saver = _Saver();
    when(() => saver.saveCopy(any(), name: any(named: 'name')))
        .thenAnswer((_) async => true);
    final folders = DriveFolders(drive, SharedPreferencesAsync());
    final receipts = (await folders.resolve(DriveLayout.receiptsFolder))
        .fold((f) => fail('$f'), (v) => v);
    drive.put(
      'passport.pdf',
      parent: receipts,
      bytes: List.filled(1200, 1),
      modifiedAt: DateTime(2026, 10, 28),
    );
    await pumpDrivePage(
      tester,
      auth: auth,
      drive: drive,
      temp: dir,
      saver: saver,
    );
    await tester.tap(find.text('Receipts'));
    await tester.pumpAndSettle();
    expect(find.text('FILES IN RECEIPTS'), findsOneWidget);
    expect(find.textContaining('PDF · '), findsOneWidget);

    await tester.tap(find.byTooltip('Download passport.pdf'));
    await tester.pump();
    // The download writes a real file: give it real time.
    for (
      var i = 0;
      i < 20 && find.text('Downloading…').evaluate().isNotEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    final saved =
        verify(() => saver.saveCopy(captureAny(), name: 'passport.pdf'))
                .captured
                .single
            as File;
    expect(p.isWithin(dir.path, saved.path), isTrue);
    expect(find.text('Saved to your phone'), findsOneWidget);

    await tester.tap(find.byTooltip('More options for passport.pdf'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to Drive trash').last);
    await tester.pumpAndSettle();
    expect(find.textContaining("Google Drive's trash"), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Move to Drive trash'));
    await tester.pumpAndSettle();
    expect(find.text('passport.pdf'), findsNothing);
    expect(find.text('No files in this folder yet.'), findsOneWidget);
  });

  testWidgets('disconnect asks first and keeps Drive files', (tester) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final auth = FakeDriveAuth(account: 'me@example.com');
    final drive = FakeDriveService();
    await pumpDrivePage(tester, auth: auth, drive: drive, temp: dir);
    final files = drive.entries.length;

    await tester.tap(find.text('Manage'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disconnect'));
    await tester.pumpAndSettle();
    expect(find.text('Disconnect Google Drive?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Disconnect'));
    await tester.pumpAndSettle();
    expect(find.text('Not connected'), findsOneWidget);
    expect(auth.disconnects, 1);
    expect(drive.entries.length, files);
  });
}

import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_platform.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_service.dart';
import 'package:personal_life_manager/features/backup_restore/domain/backup.dart';
import 'package:personal_life_manager/features/backup_restore/presentation/backup_cubits.dart';
import 'package:personal_life_manager/features/backup_restore/presentation/backup_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';
import 'package:personal_life_manager/l10n/locales.dart';

class _Service extends Mock implements BackupService;

class _Files extends Mock implements BackupFiles;

class _Last extends Mock implements LastBackupStore;

final _manifest = BackupManifest(
  formatVersion: 1,
  appVersion: '0.1.0',
  schemaVersion: 6,
  createdAt: DateTime.utc(2026, 10, 28, 13),
  platform: 'android',
  categories: const [BackupCategory.notes, BackupCategory.passwords],
  counts: const {BackupCategory.notes: 12, BackupCategory.passwords: 3},
  files: const [],
);

void main() {
  late _Service service;
  late _Files files;
  late _Last last;
  late Directory dir;
  late File built;

  setUpAll(() {
    registerFallbackValue(CancelToken());
    registerFallbackValue(File(''));
    registerFallbackValue(LastBackup(at: DateTime(0), size: 0));
    registerFallbackValue(RestoreStrategy.merge);
    registerFallbackValue(
      BackupPreview(manifest: _manifest, stagingPath: '', fileSize: 0),
    );
  });

  setUp(() {
    service = _Service();
    files = _Files();
    last = _Last();
    dir = Directory.systemTemp.createTempSync('backup_ui');
    built = File('${dir.path}/b.plmbackup')
      ..writeAsBytesSync(List.filled(2048, 1));
    when(last.load).thenAnswer((_) async => null);
    when(() => last.save(any())).thenAnswer((_) async {});
    when(() => service.discard(any())).thenAnswer((_) async {});
    when(() => service.estimate(any())).thenAnswer(
      (_) async => (counts: {BackupCategory.notes: 12}, bytes: 4096),
    );
    when(() => service.create(any(), token: any(named: 'token')))
        .thenAnswer((_) async => built);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  BackupCubit backupCubit() => BackupCubit(
    service: service,
    files: files,
    last: last,
    clock: () => DateTime(2026, 11, 3),
  );

  group('BackupCubit', () {
    blocTest<BackupCubit, BackupState>(
      'defaults → estimate → build → save to phone → remembered',
      setUp: () =>
          when(() => files.saveToDevice(any())).thenAnswer((_) async => true),
      build: backupCubit,
      act: (c) async {
        expect(c.state.selected, BackupCategory.defaults);
        expect(c.state.selected.contains(BackupCategory.passwords), isFalse);
        await c.prepare();
        expect(c.state.phase, BackupPhase.confirming);
        await c.build();
        expect((c.state.phase, c.state.size), (BackupPhase.built, 2048));
        await c.deliver(BackupDestination.device);
      },
      verify: (c) {
        expect(c.state.phase, BackupPhase.done);
        expect(
          c.state.lastBackup,
          LastBackup(at: DateTime(2026, 11, 3), size: 2048),
        );
        verify(() => service.discard(built.path)).called(1);
      },
    );

    blocTest<BackupCubit, BackupState>(
      'cancelling the save dialog keeps the file to choose again; '
      'cancel removes it',
      setUp: () =>
          when(() => files.saveToDevice(any())).thenAnswer((_) async => false),
      build: backupCubit,
      act: (c) async {
        await c.prepare();
        await c.build();
        await c.deliver(BackupDestination.device);
        expect(c.state.phase, BackupPhase.built);
        await c.cancel();
      },
      verify: (c) {
        expect(c.state.phase, BackupPhase.idle);
        expect(c.state.file, isNull);
        verify(() => service.discard(built.path)).called(1);
        verifyNever(() => last.save(any()));
      },
    );

    blocTest<BackupCubit, BackupState>(
      'password notes flag the stronger warning',
      build: backupCubit,
      act: (c) => c.toggle(BackupCategory.passwords),
      verify: (c) => expect(c.state.includesSensitive, isTrue),
    );
  });

  group('RestoreCubit', () {
    blocTest<RestoreCubit, RestoreState>(
      'an unusable file reports why',
      setUp: () {
        when(files.pickBackup).thenAnswer((_) async => built);
        when(() => service.inspect(any(), token: any(named: 'token')))
            .thenThrow(const BackupInvalid(BackupProblem.tooNew));
      },
      build: () => RestoreCubit(service: service, files: files),
      act: (c) => c.pick(),
      verify: (c) {
        expect(c.state.problem, BackupProblem.tooNew);
        expect(c.state.phase, RestorePhase.idle);
      },
    );

    blocTest<RestoreCubit, RestoreState>(
      'preview selects everything in the backup; restores only the chosen '
      'categories with the chosen strategy, then cleans up',
      setUp: () {
        when(files.pickBackup).thenAnswer((_) async => built);
        when(() => service.inspect(any(), token: any(named: 'token')))
            .thenAnswer(
              (_) async => BackupPreview(
                manifest: _manifest,
                stagingPath: 'staging',
                fileSize: 2048,
              ),
            );
        when(() => service.restore(any(), any(), any()))
            .thenAnswer((_) async => {BackupCategory.notes: 12});
      },
      build: () => RestoreCubit(service: service, files: files),
      act: (c) async {
        await c.pick();
        expect(c.state.selected, {
          BackupCategory.notes,
          BackupCategory.passwords,
        });
        c
          ..toggle(BackupCategory.passwords)
          ..strategyChanged(RestoreStrategy.replace);
        await c.restore();
      },
      verify: (c) {
        expect(c.state.phase, RestorePhase.done);
        verify(
          () => service.restore(any(), {
            BackupCategory.notes,
          }, RestoreStrategy.replace),
        ).called(1);
        verify(() => service.discard('staging')).called(1);
      },
    );
  });

  testWidgets('page: defaults ticked, password notes sensitive; Drive later', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1170, 4200)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: appSupportedLocales,
        locale: const Locale('en', 'IN'),
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) {
                final c = backupCubit();
                unawaited(c.load());
                return c;
              },
            ),
            BlocProvider(
              create: (_) => RestoreCubit(service: service, files: files),
            ),
          ],
          child: const BackupPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    CheckboxListTile box(String title) => tester.widget(
      find.ancestor(
        of: find.text(title),
        matching: find.byType(CheckboxListTile),
      ),
    );
    expect(box('Personal details').value, isTrue);
    expect(box('Password notes').value, isFalse);
    expect(find.text('Sensitive'), findsOneWidget);
    expect(find.text('Create backup · 5 categories'), findsOneWidget);
    expect(
      find.text('Available once Google Drive is connected'),
      findsOneWidget,
    );
    expect(find.textContaining('not encrypted. Anyone'), findsOneWidget);

    await tester.tap(find.text('Password notes'));
    await tester.pump();
    expect(find.textContaining('includes your password notes'), findsOneWidget);

    await tester.tap(find.text('Create backup · 6 categories'));
    await tester.pumpAndSettle();
    expect(find.text('Create this backup?'), findsOneWidget);
    expect(find.text('About 4 KB'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => service.create(any(), token: any(named: 'token')));

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
    expect(find.text('Choose backup file'), findsOneWidget);
  });
}

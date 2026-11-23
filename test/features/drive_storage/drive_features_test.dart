import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/drive/drive_copier.dart';
import 'package:personal_life_manager/core/drive/drive_folders.dart';
import 'package:personal_life_manager/core/drive/drive_models.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_platform.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_service.dart';
import 'package:personal_life_manager/features/backup_restore/domain/backup.dart';
import 'package:personal_life_manager/features/backup_restore/presentation/backup_cubits.dart';
import 'package:personal_life_manager/features/documents/data/document_uploader.dart';
import 'package:personal_life_manager/features/documents/data/documents_repository_impl.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/presentation/document_view_cubit.dart';
import 'package:personal_life_manager/features/drive_storage/presentation/drive_browser_cubit.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';
import 'package:personal_life_manager/features/shopping/presentation/history_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../helpers/fake_drive.dart';

class _BackupService extends Mock implements BackupService;

class _BackupFiles extends Mock implements BackupFiles;

class _Last extends Mock implements LastBackupStore;

class _Shopping extends Mock implements ShoppingRepository;

const _pdf = [0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x37, 1, 2, 3];

DriveProblem? _problem(Failure? f) => f is DriveFailure ? f.problem : null;

void main() {
  late Directory dir;
  late FakeDriveService drive;
  late FakeDriveAuth auth;
  late DriveFolders folders;

  setUpAll(() {
    registerFallbackValue(CancelToken());
    registerFallbackValue(<BackupCategory>{});
    registerFallbackValue(File('x'));
    registerFallbackValue(LastBackup(at: DateTime(2026), size: 0));
    registerFallbackValue(
      const Receipt(
        fileKey: 'k',
        originalName: 'r.pdf',
        fileType: SupportedFileType.pdf,
      ),
    );
  });

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    dir = Directory.systemTemp.createTempSync('drive_features');
    drive = FakeDriveService();
    auth = FakeDriveAuth(account: 'me@example.com');
    folders = DriveFolders(drive, SharedPreferencesAsync());
  });
  tearDown(() => dir.deleteSync(recursive: true));

  File source(String name, [List<int> bytes = _pdf]) =>
      File(p.join(dir.path, name))..writeAsBytesSync(bytes);

  group('document uploads', () {
    late AppDatabase db;
    late DocumentsRepositoryImpl docs;
    late DocumentUploader uploader;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      final store = Directory(p.join(dir.path, 'files'))..createSync();
      docs = DocumentsRepositoryImpl(
        db: db,
        files: FileStore(store),
        onScheduleChanged: () {},
      );
      uploader = DocumentUploader(
        documents: docs,
        drive: drive,
        folders: folders,
      );
    });
    tearDown(() => db.close());

    Future<String> addDoc(DocumentCategory c) async {
      final r = await docs.add(
        DocumentDraft(title: 'Car insurance', category: c),
        source: source('policy.pdf'),
        originalName: 'policy.pdf',
      );
      return r.fold<String>((f) => fail('$f'), (id) => id);
    }

    Future<AppDocument> doc(String id) async =>
        (await docs.watchDocument(id).first)!;

    test('goes to Documents/<category>; the local file stays', () async {
      final id = await addDoc(DocumentCategory.propertyVehicle);
      final progress = <double>[];
      void listen() {
        final v = uploader.progress.value[id];
        if (v != null) progress.add(v);
      }

      uploader.progress.addListener(listen);
      expect(await uploader.upload(id), isA<Ok<void>>());
      uploader.progress.removeListener(listen);

      final d = await doc(id);
      expect(d.driveStatus, DriveStatus.uploaded);
      final copy = drive.entries[d.driveFileId]!;
      expect(
        drive.pathOf(copy.item.id),
        'Personal Life Manager/Documents/Property and Vehicle/policy.pdf',
      );
      expect(copy.bytes, _pdf);
      expect(progress, containsAllInOrder([0.0, 1.0]));
      expect(uploader.progress.value, isEmpty);
      expect(await docs.fileFor(d), isA<Ok<File>>());
      // Not an edit of the document.
      expect(d.updatedAt, d.createdAt);
    });

    test('a failure is shown as failed and can be retried', () async {
      final id = await addDoc(DocumentCategory.medical);
      drive.failNext['upload'] = DriveProblem.offline;
      final r = await uploader.upload(id);
      expect(_problem((r as Err).failure), DriveProblem.offline);
      expect((await doc(id)).driveStatus, DriveStatus.failed);

      expect(await uploader.upload(id), isA<Ok<void>>());
      expect((await doc(id)).driveStatus, DriveStatus.uploaded);
    });

    test('cancelling returns it to "this phone only"', () async {
      final id = await addDoc(DocumentCategory.medical);
      drive.holdUpload = Completer<void>();
      final run = uploader.upload(id);
      await pumpEventQueue();
      expect((await doc(id)).driveStatus, DriveStatus.uploading);
      uploader.cancel(id);
      final r = await run;
      expect(_problem((r as Err).failure), DriveProblem.cancelled);
      expect((await doc(id)).driveStatus, DriveStatus.notUploaded);
    });

    test('an upload cut off by closing the app shows as failed', () async {
      final id = await addDoc(DocumentCategory.medical);
      await docs.setDriveStatus(id, DriveStatus.uploading);
      await docs.markInterruptedUploadsFailed();
      expect((await doc(id)).driveStatus, DriveStatus.failed);
    });

    test('delete with the Drive copy trashes it first', () async {
      final id = await addDoc(DocumentCategory.personal);
      await uploader.upload(id);
      final fileId = (await doc(id)).driveFileId!;

      final cubit = DocumentViewCubit(
        repository: docs,
        documentId: id,
        uploader: uploader,
        driveAuth: auth,
      )..start();
      addTearDown(cubit.close);
      await pumpEventQueue();
      expect(cubit.state.driveConnected, isTrue);

      // Drive unreachable: nothing is deleted anywhere.
      drive.failNext['trash'] = DriveProblem.offline;
      await cubit.deleteWithDrive(alsoDrive: true);
      expect(_problem(cubit.state.failure), DriveProblem.offline);
      expect(await docs.watchDocument(id).first, isNotNull);

      await cubit.deleteWithDrive(alsoDrive: true);
      await pumpEventQueue();
      expect(drive.entries[fileId]!.trashed, isTrue);
      expect(await docs.watchDocument(id).first, isNull);
    });

    test('upload from the document connects first when needed', () async {
      final id = await addDoc(DocumentCategory.others);
      auth.signedIn = null;
      final cubit = DocumentViewCubit(
        repository: docs,
        documentId: id,
        uploader: uploader,
        driveAuth: auth,
      )..start();
      addTearDown(cubit.close);
      await pumpEventQueue();

      auth.connectAs = null; // backs out
      await cubit.uploadToDrive();
      expect((await doc(id)).driveStatus, DriveStatus.notUploaded);

      auth.connectAs = 'me@example.com';
      await cubit.uploadToDrive();
      expect(auth.connects, 2);
      expect((await doc(id)).driveStatus, DriveStatus.uploaded);
    });
  });

  group('Drive Storage browser', () {
    DriveBrowserCubit make() => DriveBrowserCubit(
      auth: auth,
      drive: drive,
      folders: folders,
      tempDir: Directory(p.join(dir.path, 'tmp')),
    );

    test('not connected: nothing is created or listed', () async {
      auth.signedIn = null;
      final c = make();
      addTearDown(c.close);
      await c.start();
      expect(c.state.account, isNull);
      expect(c.state.status, LoadStatus.ready);
      expect(drive.calls, isEmpty);
    });

    test('connect → layout made → top folder shown with counts', () async {
      auth.signedIn = null;
      final c = make();
      addTearDown(c.close);
      await c.start();
      await c.connect();
      await pumpEventQueue();
      expect(c.state.account, 'me@example.com');
      expect(c.state.crumbs.single.name, 'Personal Life Manager');
      expect(c.state.folders.map((f) => f.name), [
        'Backups',
        'Documents',
        'Receipts',
      ]);
      final documents = c.state.folders[1];
      expect(c.state.counts[documents.id], 7);

      await c.openFolder(documents);
      await pumpEventQueue();
      expect(c.state.crumbs.map((x) => x.name), [
        'Personal Life Manager',
        'Documents',
      ]);
      expect(c.state.folders.map((f) => f.name), contains('Educational'));

      expect(c.up(), isTrue);
      await pumpEventQueue();
      expect(c.state.crumbs, hasLength(1));
      expect(c.up(), isFalse);
    });

    test('upload into the open folder, retry after a failure', () async {
      final c = make();
      addTearDown(c.close);
      await c.start();
      final backups = c.state.folders.firstWhere((f) => f.name == 'Backups');
      await c.openFolder(backups);

      final notices = <DriveNotice>[];
      final sub = c.stream.listen((s) {
        if (s.notice case final n?) notices.add(n);
      });
      addTearDown(sub.cancel);
      drive.failNext['upload'] = DriveProblem.quotaExceeded;
      await c.upload(source('notes.pdf'), 'notes.pdf');
      final failed = c.state.uploads.single;
      expect(_problem(failed.failure), DriveProblem.quotaExceeded);
      expect(c.state.files, isEmpty);

      await c.retryUpload(failed.key);
      await pumpEventQueue();
      expect(c.state.uploads, isEmpty);
      expect(notices, [DriveNotice.uploaded]);
      expect(c.state.files.single.name, 'notes.pdf');
    });

    test('open fetches a copy; delete moves to trash', () async {
      final c = make();
      addTearDown(c.close);
      await c.start();
      final receipts = c.state.folders.firstWhere((f) => f.name == 'Receipts');
      drive.put('bill.pdf', parent: receipts.id, bytes: _pdf);
      await c.openFolder(receipts);
      final bill = c.state.files.single;

      final file = await c.fetch(bill);
      expect(file!.readAsBytesSync(), _pdf);
      expect(c.state.busyItemId, isNull);

      await c.delete(bill);
      expect(drive.entries[bill.id]!.trashed, isTrue);
      expect(c.state.files, isEmpty);
      expect(c.state.notice, DriveNotice.deleted);
    });

    test('expired access is shown with a way back in', () async {
      drive.failNext['findFolder'] = DriveProblem.authExpired;
      final c = make();
      addTearDown(c.close);
      await c.start();
      expect(c.state.status, LoadStatus.failure);
      expect(c.state.problem, DriveProblem.authExpired);
    });

    test('disconnect forgets the account and folder IDs', () async {
      final c = make();
      addTearDown(c.close);
      await c.start();
      await c.disconnect();
      await pumpEventQueue();
      expect(auth.disconnects, 1);
      expect(c.state.account, isNull);
      expect(c.state.crumbs, isEmpty);
      expect(await SharedPreferencesAsync().getString('drive.folders'), isNull);
    });
  });

  group('backup to and restore from Drive', () {
    late _BackupService service;
    late _BackupFiles files;
    late _Last last;

    setUp(() {
      service = _BackupService();
      files = _BackupFiles();
      last = _Last();
      when(() => service.discard(any())).thenAnswer((_) async {});
      when(last.load).thenAnswer((_) async => null);
      when(() => last.save(any())).thenAnswer((_) async {});
    });

    BackupDrive backupDrive() =>
        BackupDrive(auth: auth, service: drive, folders: folders);

    Future<BackupCubit> built() async {
      final file = source('plm-2026-11-05.plmbackup', [1, 2, 3, 4]);
      when(() => service.estimate(any()))
          .thenAnswer((_) async => (counts: <BackupCategory, int>{}, bytes: 4));
      when(() => service.create(any(), token: any(named: 'token')))
          .thenAnswer((_) async => file);
      final c = BackupCubit(
        service: service,
        files: files,
        last: last,
        drive: backupDrive(),
      )..chooseDrive(value: true);
      await c.prepare();
      await c.build();
      expect(c.state.phase, BackupPhase.built);
      return c;
    }

    test('saves into Backups/ and records the backup', () async {
      final c = await built();
      addTearDown(c.close);
      await c.deliver(BackupDestination.drive);
      expect(c.state.phase, BackupPhase.done);
      expect(c.state.savedToDrive, isTrue);
      final saved = drive.entries.values.where((e) => !e.item.isFolder).single;
      expect(
        drive.pathOf(saved.item.id),
        'Personal Life Manager/Backups/plm-2026-11-05.plmbackup',
      );
      verify(() => last.save(any())).called(1);
      verify(() => service.discard(any())).called(1);
    });

    test('a Drive failure keeps the file and offers the phone', () async {
      final c = await built();
      addTearDown(c.close);
      drive.failNext['upload'] = DriveProblem.offline;
      await c.deliver(BackupDestination.drive);
      expect(c.state.phase, BackupPhase.built);
      expect(c.state.toDrive, isFalse);
      expect(_problem(c.state.failure), DriveProblem.offline);
      expect(c.state.file, isNotNull);
      verifyNever(() => last.save(any()));
    });

    test('restore lists Drive backups newest first, then checks one', () async {
      final backupsId = (await folders.resolve(['Backups']))
          .fold((f) => fail('$f'), (v) => v);
      drive
        ..put(
          'old.plmbackup',
          parent: backupsId,
          bytes: [1],
          modifiedAt: DateTime(2026),
        )
        ..put(
          'new.plmbackup',
          parent: backupsId,
          bytes: [9, 9],
          modifiedAt: DateTime(2026, 11),
        );
      final temp = Directory(p.join(dir.path, 'tmp'))..createSync();
      final c = RestoreCubit(
        service: service,
        files: files,
        drive: backupDrive(),
        tempDir: temp,
      );
      addTearDown(c.close);
      final list = (await c.driveBackups() as Ok<List<DriveItem>?>).value!;
      expect(list.map((i) => i.name), ['new.plmbackup', 'old.plmbackup']);

      List<int>? checked;
      when(() => service.inspect(any(), token: any(named: 'token')))
          .thenAnswer((i) async {
            checked = (i.positionalArguments.first as File).readAsBytesSync();
            return BackupPreview(
              manifest: BackupManifest(
                appVersion: '1',
                formatVersion: backupFormatVersion,
                schemaVersion: 1,
                createdAt: DateTime(2026, 11),
                platform: 'android',
                categories: const [BackupCategory.notes],
                counts: const {BackupCategory.notes: 2},
                files: const [],
              ),
              stagingPath: p.join(temp.path, 'staged'),
              fileSize: 2,
            );
          });
      await c.pickFromDrive(list.first);
      expect(checked, [9, 9]);
      expect(c.state.phase, RestorePhase.preview);
      // The downloaded copy is removed once it has been checked.
      expect(temp.listSync(), isEmpty);
    });
  });

  test('receipt copy goes to Receipts/, named by the trip date', () async {
    final repo = _Shopping();
    final receiptFile = source('IMG_2041.pdf');
    const receipt = Receipt(
      fileKey: 'k',
      originalName: 'IMG_2041.pdf',
      fileType: SupportedFileType.pdf,
    );
    final list = ShoppingList(
      id: 'l',
      name: 'Weekly',
      status: ShoppingListStatus.completed,
      items: const [],
      createdAt: DateTime(2026, 10, 28),
      updatedAt: DateTime(2026, 10, 30),
      purchasedOn: DateTime(2026, 10, 29),
      receipt: receipt,
    );
    when(() => repo.watchList('l')).thenAnswer((_) => Stream.value(list));
    when(() => repo.receiptFile(any()))
        .thenAnswer((_) async => Ok(receiptFile));
    final c = HistoryCubit(
      repository: repo,
      listId: 'l',
      drive: DriveCopier(auth: auth, drive: drive, folders: folders),
    )..start();
    addTearDown(c.close);
    await pumpEventQueue();
    await c.saveReceiptToDrive();
    expect(c.state.receiptSaved, isTrue);
    final copy = drive.entries.values.where((e) => !e.item.isFolder).single;
    expect(
      drive.pathOf(copy.item.id),
      'Personal Life Manager/Receipts/2026-10-29 IMG_2041.pdf',
    );
  });

  test('cancel token: whenCancelled fires once, removable', () {
    final t = CancelToken();
    var n = 0;
    final off = t.whenCancelled(() => n++);
    off();
    t
      ..whenCancelled(() => n += 10)
      ..cancel()
      ..cancel();
    expect(n, 10);
    t.whenCancelled(() => n += 100); // already cancelled: at once
    expect(n, 110);
  });
}

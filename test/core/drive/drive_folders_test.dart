import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/drive/drive_folders.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/drive_storage/presentation/drive_browser_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../helpers/fake_drive.dart';

void main() {
  late FakeDriveService drive;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    drive = FakeDriveService();
  });

  String ok(Result<String> r) => r.fold((f) => fail('unexpected $f'), (v) => v);

  test('creates the PRD layout with the agreed category names', () async {
    final folders = DriveFolders(drive, SharedPreferencesAsync());
    expect(await folders.bootstrap(standardDriveFolders()), isA<Ok<void>>());
    final paths = {
      for (final e in drive.entries.values) drive.pathOf(e.item.id),
    };
    expect(paths, {
      'Personal Life Manager',
      'Personal Life Manager/Documents',
      for (final c in [
        'Personal',
        'Financial',
        'Medical',
        'Employment',
        'Educational',
        'Property and Vehicle',
        'Others',
      ])
        'Personal Life Manager/Documents/$c',
      'Personal Life Manager/Backups',
      'Personal Life Manager/Receipts',
    });
  });

  test('is idempotent, also after a restart or a lost cache', () async {
    await DriveFolders(
      drive,
      SharedPreferencesAsync(),
    ).bootstrap(standardDriveFolders());
    final made = drive.folderCount;

    // Same run, again.
    final again = DriveFolders(drive, SharedPreferencesAsync());
    await again.bootstrap(standardDriveFolders());
    await again.bootstrap(standardDriveFolders());
    expect(drive.folderCount, made);

    // Cache gone (e.g. reinstall): the folders are found, not duplicated.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    await DriveFolders(
      drive,
      SharedPreferencesAsync(),
    ).bootstrap(standardDriveFolders());
    expect(drive.folderCount, made);
  });

  test('a folder deleted in Drive is made again, with its children', () async {
    final folders = DriveFolders(drive, SharedPreferencesAsync());
    final old = ok(await folders.resolve(['Documents', 'Medical']));
    final documents = ok(await folders.resolve(['Documents']));
    drive.entries[documents]!.trashed = true;

    // A fresh run re-checks cached IDs.
    final next = DriveFolders(drive, SharedPreferencesAsync());
    final medical = ok(await next.resolve(['Documents', 'Medical']));
    expect(medical, isNot(old));
    expect(drive.pathOf(medical), 'Personal Life Manager/Documents/Medical');
    expect(drive.entries[drive.entries[medical]!.parent]!.trashed, isFalse);
  });

  test('two uploads at once share one new folder', () async {
    final folders = DriveFolders(drive, SharedPreferencesAsync());
    final ids = await Future.wait([
      folders.resolve(['Backups']),
      folders.resolve(['Backups']),
    ]);
    expect(ok(ids[0]), ok(ids[1]));
    expect(drive.folderCount, 2); // root + Backups
  });

  test('a Drive error is passed on, not cached', () async {
    final folders = DriveFolders(drive, SharedPreferencesAsync());
    drive.failNext['createFolder'] = DriveProblem.offline;
    final r = await folders.resolve(['Backups']);
    expect(
      r.fold((f) => (f as DriveFailure).problem, (_) => null),
      DriveProblem.offline,
    );
    expect(await folders.resolve(['Backups']), isA<Ok<String>>());
  });

  test('clear forgets IDs (another account has other folders)', () async {
    final folders = DriveFolders(drive, SharedPreferencesAsync());
    await folders.resolve(['Backups']);
    await folders.clear();
    drive.entries.clear();
    final id = ok(await folders.resolve(['Backups']));
    expect(drive.pathOf(id), 'Personal Life Manager/Backups');
  });
}

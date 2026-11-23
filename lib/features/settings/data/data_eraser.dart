import 'dart:io';

import 'package:drift/drift.dart' show TableUpdate;
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/storage/secure_store.dart';
import 'package:personal_life_manager/features/settings/data/app_settings.dart';

/// Sign-out and "Delete all my data": removes every record, file,
/// notification and preference on this phone, then returns to sign-in.
/// Nothing in Google Drive is touched here (the records stay there for the
/// next sign-in); backup files saved elsewhere stay too.
class DataEraser {
  DataEraser({
    required this._db,
    required this._filesDir,
    required this._tempDir,
    required this._secure,
    required this._settings,
    required this._clearNotifications,
    required this._lock,
    this._forgetDrive,
  });

  final AppDatabase _db;
  final Directory _filesDir;
  final Directory _tempDir;
  final SecureStore _secure;
  final AppSettings _settings;

  /// Cancels every pending and shown notification.
  final Future<void> Function() _clearNotifications;
  final AppLock _lock;

  /// Disconnects Google Drive on this phone (the files on Drive stay).
  final Future<void> Function()? _forgetDrive;

  Future<void> eraseEverything() async {
    // Nothing may ring for data that no longer exists.
    await _clearNotifications();
    await _db.transaction(() async {
      // Muted: wiping this phone must not delete anything from Drive.
      await _db.customStatement('INSERT OR IGNORE INTO sync_mute VALUES (1)');
      // Children first; FTS indexes follow through their triggers.
      for (final t in _db.allTables.toList().reversed) {
        final name = t.actualTableName;
        if (name.endsWith('_fts') || name.startsWith('sync_')) continue;
        await _db.customStatement('DELETE FROM "$name"');
      }
      await _db.customStatement('DELETE FROM sync_outbox');
      await _db.customStatement('DELETE FROM sync_remote');
      await _db.customStatement('DELETE FROM sync_mute');
    });
    _db.notifyUpdates({for (final t in _db.allTables) TableUpdate.onTable(t)});
    for (final dir in [_filesDir, _tempDir]) {
      if (dir.existsSync()) {
        await for (final e in dir.list()) {
          await e.delete(recursive: true);
        }
      }
    }
    await _forgetDrive?.call();
    await _settings.reset();
    await _secure.deleteAll();
    _lock.markNotSetUp();
  }
}

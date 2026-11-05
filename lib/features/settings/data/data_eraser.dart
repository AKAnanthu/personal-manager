import 'dart:io';

import 'package:drift/drift.dart' show TableUpdate;
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/storage/secure_store.dart';
import 'package:personal_life_manager/features/settings/data/app_settings.dart';

/// "Forgot password" and "Erase all data": with no server, the only way
/// back in is a clean start. Removes every record, file, notification,
/// the password and preferences on this phone, then returns to first-time
/// setup. Backup files saved elsewhere and Drive copies are not touched.
class DataEraser {
  DataEraser({
    required this._db,
    required this._filesDir,
    required this._tempDir,
    required this._secure,
    required this._settings,
    required this._clearNotifications,
    required this._lock,
  });

  final AppDatabase _db;
  final Directory _filesDir;
  final Directory _tempDir;
  final SecureStore _secure;
  final AppSettings _settings;

  /// Cancels every pending and shown notification.
  final Future<void> Function() _clearNotifications;
  final AppLock _lock;

  Future<void> eraseEverything() async {
    // Nothing may ring for data that no longer exists.
    await _clearNotifications();
    await _db.transaction(() async {
      // Children first; FTS indexes follow through their triggers.
      for (final t in _db.allTables.toList().reversed) {
        if (t.actualTableName.endsWith('_fts')) continue;
        await _db.customStatement('DELETE FROM "${t.actualTableName}"');
      }
    });
    _db.notifyUpdates({for (final t in _db.allTables) TableUpdate.onTable(t)});
    for (final dir in [_filesDir, _tempDir]) {
      if (dir.existsSync()) {
        await for (final e in dir.list()) {
          await e.delete(recursive: true);
        }
      }
    }
    await _settings.reset();
    await _secure.deleteAll();
    _lock.markNotSetUp();
  }
}

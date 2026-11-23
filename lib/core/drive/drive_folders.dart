import 'dart:async';
import 'dart:convert';

import 'package:personal_life_manager/core/drive/drive_service.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's folder in the user's Drive (PRD §16.2):
///
///     Personal Life Manager/
///       Documents/<one folder per document category>
///       Backups/
///       Receipts/
///
/// Folder names are fixed English names, not translated, so the same
/// folders are found again whatever the phone's language.
abstract final class DriveLayout {
  static const root = 'Personal Life Manager';
  static const documents = 'Documents';
  static const backups = 'Backups';
  static const receipts = 'Receipts';

  /// A path below [root]; empty for the root itself.
  static List<String> documentFolder(String category) => [documents, category];
  static const List<String> backupsFolder = [backups];
  static const List<String> receiptsFolder = [receipts];
}

/// Finds or creates folders by path, idempotently. IDs are cached; a
/// cached folder the user deleted or trashed is created again.
class DriveFolders {
  DriveFolders(this._drive, [SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  final DriveService _drive;
  final SharedPreferencesAsync _prefs;
  static const _cacheKey = 'drive.folders';

  Map<String, String>? _cache;

  /// Checked during this run; not re-checked on every use.
  final _verified = <String>{};

  /// One resolution at a time, so two uploads can't create twin folders.
  Future<void> _queue = Future.value();

  Future<Map<String, String>> _load() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await _prefs.getString(_cacheKey);
    var map = <String, String>{};
    if (raw != null) {
      try {
        map = (jsonDecode(raw) as Map<String, dynamic>).cast<String, String>();
      } on FormatException {
        // Rebuilt below.
      }
    }
    return _cache = map;
  }

  /// The ID of the folder at [path] below [DriveLayout.root].
  Future<Result<String>> resolve(List<String> path) {
    final done = Completer<Result<String>>();
    _queue = _queue.then((_) async => done.complete(await _resolve(path)));
    return done.future;
  }

  Future<Result<String>> _resolve(List<String> path) async {
    final cache = await _load();
    String? parent;
    final segments = [DriveLayout.root, ...path];
    for (var i = 0; i < segments.length; i++) {
      final key = segments.sublist(0, i + 1).join('/');
      final name = segments[i];
      final cached = cache[key];
      if (cached != null) {
        if (_verified.contains(cached)) {
          parent = cached;
          continue;
        }
        switch (await _drive.folderExists(cached)) {
          case Ok(value: true):
            _verified.add(cached);
            parent = cached;
            continue;
          case Ok(value: false):
            // Deleted in Drive: forget it and everything below it.
            cache.removeWhere((k, _) => k == key || k.startsWith('$key/'));
          case Err(:final failure):
            return Err(failure);
        }
      }
      final found = await _drive.findFolder(name, parentId: parent);
      final String id;
      switch (found) {
        case Ok(value: final item?):
          id = item.id;
        case Ok():
          final created = await _drive.createFolder(name, parentId: parent);
          switch (created) {
            case Ok(value: final item):
              id = item.id;
            case Err(:final failure):
              return Err(failure);
          }
        case Err(:final failure):
          return Err(failure);
      }
      cache[key] = id;
      _verified.add(id);
      await _prefs.setString(_cacheKey, jsonEncode(cache));
      parent = id;
    }
    return Ok(parent!);
  }

  /// Creates the whole standard layout (on connect).
  Future<Result<void>> bootstrap(Iterable<List<String>> paths) async {
    for (final p in paths) {
      if (await resolve(p) case Err(:final failure)) return Err(failure);
    }
    return const Ok(null);
  }

  /// Forgets cached IDs (on disconnect: another account has other IDs).
  Future<void> clear() async {
    _cache = {};
    _verified.clear();
    await _prefs.remove(_cacheKey);
  }
}

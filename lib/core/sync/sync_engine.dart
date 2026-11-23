import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/sync/sync_store.dart';
import 'package:personal_life_manager/core/sync/sync_tables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum SyncActivity { idle, saving, syncing }

/// What the sync row and the Sync page show.
final class SyncStatus extends Equatable {
  const SyncStatus({
    this.activity = SyncActivity.idle,
    this.pending = 0,
    this.lastSyncedAt,
    this.failure,
    this.done = 0,
    this.total = 0,
  });

  final SyncActivity activity;

  /// Changes on this phone not yet saved to Drive.
  final int pending;

  /// The last completed "Sync now" (or first download after sign-in).
  final DateTime? lastSyncedAt;

  /// Why the last save or sync stopped; cleared by the next success.
  final Failure? failure;

  /// Download progress of a sync.
  final int done;
  final int total;

  SyncStatus copyWith({
    SyncActivity? activity,
    int? pending,
    DateTime? lastSyncedAt,
    Failure? Function()? failure,
    int? done,
    int? total,
  }) => SyncStatus(
    activity: activity ?? this.activity,
    pending: pending ?? this.pending,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    failure: failure != null ? failure() : this.failure,
    done: done ?? this.done,
    total: total ?? this.total,
  );

  @override
  List<Object?> get props => [
    activity,
    pending,
    lastSyncedAt,
    failure,
    done,
    total,
  ];
}

/// What one sync changed on this phone.
final class SyncReport extends Equatable {
  const SyncReport({this.received = 0, this.removed = 0});

  /// Records added or updated from Drive.
  final int received;

  /// Records removed because they were deleted on another phone.
  final int removed;

  @override
  List<Object?> get props => [received, removed];
}

/// Remembers when the last sync finished.
abstract interface class SyncMemo {
  Future<DateTime?> lastSyncedAt();
  Future<void> setLastSyncedAt(DateTime? at);
}

final class PrefsSyncMemo implements SyncMemo {
  PrefsSyncMemo([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;
  static const _key = 'sync.lastSyncedAt';

  @override
  Future<DateTime?> lastSyncedAt() async {
    final raw = await _prefs.getString(_key);
    return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
  }

  @override
  Future<void> setLastSyncedAt(DateTime? at) => at == null
      ? _prefs.remove(_key)
      : _prefs.setString(_key, at.toUtc().toIso8601String());
}

/// Keeps the user's records in their Google Drive (hidden app folder).
///
/// - **Saving**: every change on this phone is recorded by database
///   triggers (sync.drift) and uploaded within a second; while offline it
///   waits and is retried. One small file per record, so the last saved
///   version of a record is what Drive keeps.
/// - **Sync now** (and right after sign-in): saves what's waiting, then
///   makes this phone match Drive: new and changed records come in,
///   records deleted elsewhere go.
///
/// Nothing runs in the background and Drive isn't watched for changes.
class SyncEngine {
  SyncEngine({
    required this._db,
    required this._store,
    required this._files,
    required this._tempDir,
    required this._memo,
    this._onReceived,
    this._clock = DateTime.now,
    this._debounce = const Duration(seconds: 1),
    this._retryDelays = const [
      Duration(seconds: 30),
      Duration(minutes: 1),
      Duration(minutes: 5),
    ],
  });

  final AppDatabase _db;
  final SyncStore _store;
  final FileStore _files;
  final Directory _tempDir;
  final SyncMemo _memo;

  /// After a sync changed records (notifications are planned again).
  final Future<void> Function()? _onReceived;
  final DateTime Function() _clock;
  final Duration _debounce;
  final List<Duration> _retryDelays;

  final ValueNotifier<SyncStatus> _status = ValueNotifier(const SyncStatus());
  StreamSubscription<void>? _changes;
  AppLifecycleListener? _lifecycle;
  Timer? _timer;
  int _failures = 0;
  bool _running = false;
  Future<void> _queue = Future.value();

  static const _downloadsAtOnce = 6;
  static const _uuid = Uuid();

  ValueListenable<SyncStatus> get status => _status;

  List<TableInfo<Table, Object?>> get _tables => [
    for (final t in _db.allTables)
      if (SyncTables.byName.containsKey(t.actualTableName)) t,
  ];

  /// Starts saving changes as they happen (after sign-in or app start).
  Future<void> start() async {
    if (_running) return;
    _running = true;
    _status.value = _status.value.copyWith(
      lastSyncedAt: await _memo.lastSyncedAt(),
      pending: await _pendingCount(),
    );
    _changes = _db
        .tableUpdates(TableUpdateQuery.onAllTables(_tables))
        .listen((_) => _schedule(_debounce));
    _lifecycle ??= AppLifecycleListener(onResume: () => _schedule(_debounce));
    _schedule(Duration.zero);
  }

  /// Stops saving (before sign-out). Waits for an upload in progress.
  Future<void> stop() async {
    _running = false;
    _timer?.cancel();
    _timer = null;
    await _changes?.cancel();
    _changes = null;
    _lifecycle?.dispose();
    _lifecycle = null;
    await _queue;
  }

  void _schedule(Duration after) {
    if (!_running) return;
    _timer?.cancel();
    _timer = Timer(after, () => unawaited(save()));
  }

  Future<T> _serial<T>(Future<T> Function() op) {
    final next = _queue.then((_) => op());
    _queue = next.then((_) {}, onError: (_) {});
    return next;
  }

  Future<int> _pendingCount() async {
    final r = await _db
        .customSelect('SELECT COUNT(*) AS n FROM sync_outbox')
        .getSingle();
    return r.read<int>('n');
  }

  /// Notes every existing record as changed, so it is uploaded. Used at
  /// sign-in: records made before sync existed (or before signing in)
  /// reach Drive too. Rows already waiting keep their entry.
  Future<void> seedAll() async {
    for (final t in SyncTables.all) {
      await _db.customStatement(
        'INSERT OR IGNORE INTO sync_outbox (tbl, row_id, deleted, seq) '
        "SELECT '${t.name}', id, 0, "
        '(SELECT COALESCE(MAX(seq), 0) + 1 FROM sync_outbox) '
        'FROM "${t.name}"',
      );
    }
    _status.value = _status.value.copyWith(pending: await _pendingCount());
  }

  // ---- Saving -------------------------------------------------------------

  /// Uploads every waiting change. Ok when nothing is left waiting.
  Future<Result<void>> save() => _serial(_save);

  Future<Result<void>> _save() async {
    var pending = await _pendingCount();
    if (pending == 0) {
      _failures = 0;
      _status.value = _status.value.copyWith(pending: 0, failure: () => null);
      return const Ok(null);
    }
    _status.value = _status.value.copyWith(
      activity: _status.value.activity == SyncActivity.syncing
          ? SyncActivity.syncing
          : SyncActivity.saving,
      pending: pending,
    );
    while (true) {
      final batch = await _db
          .customSelect(
            'SELECT tbl, row_id, deleted, seq FROM sync_outbox '
            'ORDER BY seq LIMIT 50',
          )
          .get();
      if (batch.isEmpty) break;
      for (final e in batch) {
        final r = await _saveOne(
          e.read<String>('tbl'),
          e.read<String>('row_id'),
          deleted: e.read<bool>('deleted'),
          seq: e.read<int>('seq'),
        );
        if (r case Err(:final failure)) {
          _status.value = _status.value.copyWith(
            activity: SyncActivity.idle,
            pending: await _pendingCount(),
            failure: () => failure,
          );
          _retryLater();
          return Err(failure);
        }
        pending = pending > 0 ? pending - 1 : 0;
        _status.value = _status.value.copyWith(pending: pending);
      }
    }
    _failures = 0;
    _status.value = _status.value.copyWith(
      activity: _status.value.activity == SyncActivity.syncing
          ? SyncActivity.syncing
          : SyncActivity.idle,
      pending: await _pendingCount(),
      failure: () => null,
    );
    return const Ok(null);
  }

  void _retryLater() {
    if (_retryDelays.isEmpty) return;
    final i = _failures < _retryDelays.length
        ? _failures
        : _retryDelays.length - 1;
    _failures++;
    _schedule(_retryDelays[i]);
  }

  Future<Result<void>> _saveOne(
    String table,
    String id, {
    required bool deleted,
    required int seq,
  }) async {
    final spec = SyncTables.byName[table];
    if (spec != null) {
      final name = SyncNames.record(table, id);
      final row = deleted ? null : await _readRow(table, id);
      final Result<void> r;
      if (row == null) {
        r = await _deleteRemote(name);
      } else {
        r = await _writeRecord(spec, name, id, row);
      }
      if (r is Err<void>) return r;
    }
    await _db.customStatement(
      'DELETE FROM sync_outbox WHERE tbl = ? AND row_id = ? AND seq = ?',
      [table, id, seq],
    );
    return const Ok(null);
  }

  Future<Map<String, Object?>?> _readRow(String table, String id) async {
    final r = await _db
        .customSelect(
          'SELECT * FROM "$table" WHERE id = ?',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    return r?.data;
  }

  Future<Result<void>> _writeRecord(
    SyncTable spec,
    String name,
    String id,
    Map<String, Object?> row,
  ) async {
    // Files first, so a record on Drive never points at a missing file.
    for (final column in spec.fileColumns) {
      if (row[column] case final String key when key.isNotEmpty) {
        final r = await _uploadFile(key);
        if (r is Err<void>) return r;
      }
    }
    final bytes = utf8.encode(
      jsonEncode({
        'table': spec.name,
        'id': id,
        'schema': _db.schemaVersion,
        'row': row,
      }),
    );
    final known = await _remote(name);
    var r = await _store.write(name, bytes, fileId: known?.$1);
    if (known != null && _isNotFound(r)) {
      // Deleted on Drive in the meantime: write it again.
      r = await _store.write(name, bytes);
    }
    switch (r) {
      case Ok(:final value):
        await _remember(value);
        return const Ok(null);
      case Err(:final failure):
        return Err(failure);
    }
  }

  static bool _isNotFound(Result<Object?> r) =>
      r is Err<Object?> &&
      r.failure is DriveFailure &&
      (r.failure as DriveFailure).problem == DriveProblem.notFound;

  Future<Result<void>> _uploadFile(String key) async {
    final name = SyncNames.file(key);
    if (await _remote(name) != null) return const Ok(null);
    final File file;
    switch (await _files.resolve(key)) {
      case Ok(:final value):
        file = value;
      case Err():
        // Gone from this phone: nothing to upload.
        return const Ok(null);
    }
    final r = await _store.upload(name, file);
    switch (r) {
      case Ok(:final value):
        await _remember(value);
        return const Ok(null);
      case Err(:final failure):
        return Err(failure);
    }
  }

  Future<Result<void>> _deleteRemote(String name) async {
    final known = await _remote(name);
    if (known != null) {
      final r = await _store.delete(known.$1);
      if (r case Err(:final failure)
          when failure is! DriveFailure ||
              failure.problem != DriveProblem.notFound) {
        return Err(failure);
      }
    }
    await _db.customStatement('DELETE FROM sync_remote WHERE name = ?', [name]);
    return const Ok(null);
  }

  /// (file id, modified) of [name] on Drive: remembered, else looked up
  /// (another phone may have uploaded it).
  Future<(String, String?)?> _remote(String name) async {
    final r = await _db
        .customSelect(
          'SELECT file_id, modified FROM sync_remote WHERE name = ?',
          variables: [Variable.withString(name)],
        )
        .getSingleOrNull();
    if (r != null) {
      return (r.read<String>('file_id'), r.readNullable<String>('modified'));
    }
    final found = await _store.find(name);
    if (found case Ok(value: final f?)) {
      await _remember(f);
      return (f.id, f.modified);
    }
    return null;
  }

  Future<void> _remember(RemoteFile f) => _db.customStatement(
    'INSERT OR REPLACE INTO sync_remote (name, file_id, modified) '
    'VALUES (?, ?, ?)',
    [f.name, f.id, f.modified],
  );

  // ---- Sync now -----------------------------------------------------------

  /// Saves what's waiting, then makes this phone match Drive.
  Future<Result<SyncReport>> syncNow() => _serial(() async {
    _status.value = _status.value.copyWith(
      activity: SyncActivity.syncing,
      done: 0,
      total: 0,
    );
    try {
      final saved = await _save();
      if (saved case Err(:final failure)) return Err(failure);
      final r = await _pull();
      if (r case Err(:final failure)) {
        _status.value = _status.value.copyWith(failure: () => failure);
      } else {
        final now = _clock();
        await _memo.setLastSyncedAt(now);
        _status.value = _status.value.copyWith(
          lastSyncedAt: now,
          failure: () => null,
        );
      }
      return r;
    } finally {
      _status.value = _status.value.copyWith(
        activity: SyncActivity.idle,
        pending: await _pendingCount(),
      );
    }
  });

  Future<Result<SyncReport>> _pull() async {
    final List<RemoteFile> listing;
    switch (await _store.list()) {
      case Ok(:final value):
        listing = value;
      case Err(:final failure):
        return Err(failure);
    }

    // The newest file of each name; older duplicates (two phones creating
    // the same record at once) are removed.
    final byName = <String, RemoteFile>{};
    final duplicates = <RemoteFile>[];
    for (final f in listing) {
      final had = byName[f.name];
      if (had == null) {
        byName[f.name] = f;
      } else if ((f.modified ?? '').compareTo(had.modified ?? '') > 0) {
        duplicates.add(had);
        byName[f.name] = f;
      } else {
        duplicates.add(f);
      }
    }
    for (final d in duplicates) {
      await _store.delete(d.id);
    }

    final known = {
      for (final r
          in await _db
              .customSelect('SELECT name, file_id, modified FROM sync_remote')
              .get())
        r.read<String>('name'): (
          r.read<String>('file_id'),
          r.readNullable<String>('modified'),
        ),
    };

    final remoteIds = <String, Set<String>>{
      for (final t in SyncTables.all) t.name: {},
    };
    final changed = <RemoteFile>[];
    for (final f in byName.values) {
      final rec = SyncNames.parseRecord(f.name);
      if (rec == null) continue;
      final (table, id) = rec;
      final ids = remoteIds[table];
      if (ids == null) continue;
      ids.add(id);
      final k = known[f.name];
      if (k == null || k.$1 != f.id || k.$2 != f.modified) changed.add(f);
    }

    // Download changed records, a few at a time.
    _status.value = _status.value.copyWith(done: 0, total: changed.length);
    final incoming = <String, List<Map<String, Object?>>>{};
    var done = 0;
    for (var i = 0; i < changed.length; i += _downloadsAtOnce) {
      final chunk = changed.skip(i).take(_downloadsAtOnce).toList();
      final results = await Future.wait([
        for (final f in chunk) _store.read(f.id),
      ]);
      for (var j = 0; j < chunk.length; j++) {
        switch (results[j]) {
          case Ok(:final value):
            final rec = SyncNames.parseRecord(chunk[j].name);
            final row = rec == null ? null : _decode(value, rec.$1, rec.$2);
            if (row != null) (incoming[rec!.$1] ??= []).add(row);
          case Err(:final failure)
              when failure is DriveFailure &&
                  failure.problem == DriveProblem.notFound:
            // Deleted while we listed: treated as deleted.
            final rec = SyncNames.parseRecord(chunk[j].name);
            if (rec != null) remoteIds[rec.$1]?.remove(rec.$2);
          case Err(:final failure):
            return Err(failure);
        }
      }
      done += chunk.length;
      _status.value = _status.value.copyWith(done: done);
    }

    final report = await _apply(incoming, remoteIds, byName.values);

    final fetched = await _fetchMissingFiles(byName);
    if (fetched case Err(:final failure)) return Err(failure);
    await _removeUnusedFiles(byName);

    _db.notifyUpdates({for (final t in _tables) TableUpdate.onTable(t)});
    if (report.received > 0 || report.removed > 0) await _onReceived?.call();
    // Rows changed by a clash (see _resolveClashes) go back to Drive.
    final saved = await _save();
    if (saved case Err(:final failure)) return Err(failure);
    return Ok(report);
  }

  static Map<String, Object?>? _decode(
    List<int> bytes,
    String table,
    String id,
  ) {
    try {
      final data = jsonDecode(utf8.decode(bytes));
      if (data is! Map<String, Object?>) return null;
      final row = data['row'];
      if (data['table'] != table || row is! Map<String, Object?>) return null;
      if (row['id'] != id) return null;
      return row;
    } on FormatException {
      return null;
    }
  }

  Future<SyncReport> _apply(
    Map<String, List<Map<String, Object?>>> incoming,
    Map<String, Set<String>> remoteIds,
    Iterable<RemoteFile> remote,
  ) async {
    var received = 0;
    var removed = 0;
    final clashed = <(String, String, bool)>[];
    await _db.transaction(() async {
      await _db.customStatement('INSERT OR IGNORE INTO sync_mute VALUES (1)');
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');
      // A change made on this phone while syncing wins until it is saved.
      final waiting = {
        for (final r
            in await _db
                .customSelect('SELECT tbl, row_id FROM sync_outbox')
                .get())
          '${r.read<String>('tbl')}/${r.read<String>('row_id')}',
      };
      final columns = {
        for (final t in _tables)
          t.actualTableName: {for (final c in t.$columns) c.name},
      };

      for (final t in SyncTables.all) {
        for (final row in incoming[t.name] ?? const <Map<String, Object?>>[]) {
          final id = row['id']! as String;
          if (waiting.contains('${t.name}/$id')) continue;
          clashed.addAll(await _resolveClashes(t.name, row));
          if (await _upsert(t.name, row, columns[t.name] ?? const {})) {
            received++;
          }
        }
      }

      // Deleted on Drive (by another phone) → deleted here.
      for (final t in SyncTables.all.reversed) {
        final ids = remoteIds[t.name] ?? const <String>{};
        final local = await _db
            .customSelect('SELECT id FROM "${t.name}"')
            .get();
        final gone = [
          for (final r in local)
            if (r.read<String>('id') case final id
                when !ids.contains(id) && !waiting.contains('${t.name}/$id'))
              id,
        ];
        for (var i = 0; i < gone.length; i += 500) {
          final part = gone.skip(i).take(500).toList();
          await _db.customStatement(
            'DELETE FROM "${t.name}" WHERE id IN '
            '(${List.filled(part.length, '?').join(', ')})',
            part,
          );
        }
        removed += gone.length;
      }
      // Children whose parent went (or never arrived).
      for (final t in SyncTables.all) {
        if (t.parent case (final column, final parent)) {
          await _db.customStatement(
            'DELETE FROM "${t.name}" WHERE "$column" NOT IN '
            '(SELECT id FROM "$parent")',
          );
        }
      }

      await _db.customStatement(
        "DELETE FROM sync_remote WHERE name LIKE 'r.%'",
      );
      for (final f in remote) {
        if (SyncNames.parseRecord(f.name) == null) continue;
        if (clashed.any((c) => SyncNames.record(c.$1, c.$2) == f.name)) {
          continue;
        }
        await _remember(f);
      }
      await _db.customStatement('DELETE FROM sync_mute');
    });

    // Recorded after unmuting, so the next save sends them.
    for (final (table, id, deleted) in clashed) {
      await _db.customStatement(
        'INSERT OR REPLACE INTO sync_outbox (tbl, row_id, deleted, seq) '
        'VALUES (?, ?, ?, (SELECT COALESCE(MAX(seq), 0) + 1 FROM sync_outbox))',
        [table, id, if (deleted) 1 else 0],
      );
    }
    return SyncReport(received: received, removed: removed);
  }

  /// Rules that allow only one row per value (one budget per month, one
  /// expense per shopping trip, one shopping trip in progress): the row
  /// from Drive wins, the other is removed or set back to a draft.
  /// Returns (table, id, deleted) of rows changed here.
  Future<List<(String, String, bool)>> _resolveClashes(
    String table,
    Map<String, Object?> row,
  ) async {
    final id = row['id'];
    Future<List<String>> ids(String sql, List<Object?> args) async => [
      for (final r
          in await _db
              .customSelect(sql, variables: [for (final a in args) Variable(a)])
              .get())
        r.read<String>('id'),
    ];
    switch (table) {
      case 'budget_amounts':
        final clash = await ids(
          'SELECT id FROM budget_amounts WHERE from_month = ? AND id != ?',
          [row['from_month'], id],
        );
        for (final c in clash) {
          await _db.customStatement('DELETE FROM budget_amounts WHERE id = ?', [
            c,
          ]);
        }
        return [for (final c in clash) (table, c, true)];
      case 'expenses' when row['source_id'] != null:
        final clash = await ids(
          'SELECT id FROM expenses WHERE source = ? AND source_id = ? '
          'AND id != ?',
          [row['source'], row['source_id'], id],
        );
        for (final c in clash) {
          await _db.customStatement('DELETE FROM expenses WHERE id = ?', [c]);
        }
        return [for (final c in clash) (table, c, true)];
      case 'shopping_lists' when row['status'] == 'active':
        final clash = await ids(
          "SELECT id FROM shopping_lists WHERE status = 'active' AND id != ?",
          [id],
        );
        for (final c in clash) {
          await _db.customStatement(
            "UPDATE shopping_lists SET status = 'draft' WHERE id = ?",
            [c],
          );
        }
        return [for (final c in clash) (table, c, false)];
    }
    return const [];
  }

  Future<bool> _upsert(
    String table,
    Map<String, Object?> row,
    Set<String> columns,
  ) async {
    // Only this version's columns, so a row from a newer app still fits.
    final cols = [
      for (final c in row.keys)
        if (columns.contains(c)) c,
    ];
    if (!cols.contains('id')) return false;
    final names = cols.map((c) => '"$c"').join(', ');
    final marks = List.filled(cols.length, '?').join(', ');
    final sets = [
      for (final c in cols)
        if (c != 'id') '"$c" = excluded."$c"',
    ].join(', ');
    try {
      await _db.customStatement(
        'INSERT INTO "$table" ($names) VALUES ($marks) '
        'ON CONFLICT (id) DO ${sets.isEmpty ? 'NOTHING' : 'UPDATE SET $sets'}',
        [
          for (final c in cols)
            switch (row[c]) {
              final bool b => b ? 1 : 0,
              final v => v,
            },
        ],
      );
      return true;
    } on Exception {
      // A row this version can't store (e.g. from an older app): skipped.
      return false;
    }
  }

  Future<Set<String>> _usedFileKeys() async => {
    for (final t in SyncTables.all)
      for (final c in t.fileColumns)
        for (final r
            in await _db
                .customSelect(
                  'SELECT "$c" AS k FROM "${t.name}" WHERE "$c" IS NOT NULL',
                )
                .get())
          r.read<String>('k'),
  };

  Future<Result<void>> _fetchMissingFiles(
    Map<String, RemoteFile> remote,
  ) async {
    for (final key in await _usedFileKeys()) {
      if (!FileStore.isValidKey(key) || _files.exists(key)) continue;
      final f = remote[SyncNames.file(key)];
      if (f == null) continue;
      if (!_tempDir.existsSync()) await _tempDir.create(recursive: true);
      final tmp = File(p.join(_tempDir.path, 'sync-${_uuid.v4()}'));
      final r = await _store.download(f.id, tmp);
      if (r is Err<void>) return r;
      await _files.importAs(tmp, key);
      if (tmp.existsSync()) await tmp.delete();
      await _remember(f);
    }
    return const Ok(null);
  }

  /// Files no record uses any more (after a full sync this phone knows
  /// every record).
  Future<void> _removeUnusedFiles(Map<String, RemoteFile> remote) async {
    final used = await _usedFileKeys();
    for (final f in remote.values) {
      final key = SyncNames.parseFile(f.name);
      if (key == null || used.contains(key)) continue;
      if (await _store.delete(f.id) case Ok()) {
        await _db.customStatement('DELETE FROM sync_remote WHERE name = ?', [
          f.name,
        ]);
      }
    }
  }

  // ---- Leaving --------------------------------------------------------------

  /// Deletes everything this app keeps in Drive's hidden folder (when the
  /// user deletes their data). Files saved to visible Drive folders stay.
  Future<Result<void>> deleteDriveData() => _serial(() async {
    final List<RemoteFile> listing;
    switch (await _store.list()) {
      case Ok(:final value):
        listing = value;
      case Err(:final failure):
        return Err(failure);
    }
    for (final f in listing) {
      final r = await _store.delete(f.id);
      if (r case Err(:final failure)
          when failure is! DriveFailure ||
              failure.problem != DriveProblem.notFound) {
        return Err(failure);
      }
    }
    await _db.customStatement('DELETE FROM sync_remote');
    return const Ok(null);
  });

  /// What this app keeps in Drive's hidden folder (size, records, files)
  /// and the account's storage.
  Future<Result<({int appBytes, int records, int files, StorageQuota quota})>>
  storage() async {
    final List<RemoteFile> listing;
    switch (await _store.list()) {
      case Ok(:final value):
        listing = value;
      case Err(:final failure):
        return Err(failure);
    }
    return switch (await _store.quota()) {
      Ok(:final value) => Ok((
        appBytes: listing.fold(0, (s, f) => s + f.sizeBytes),
        records: {
          for (final f in listing)
            if (SyncNames.parseRecord(f.name) != null) f.name,
        }.length,
        files: {
          for (final f in listing)
            if (SyncNames.parseFile(f.name) != null) f.name,
        }.length,
        quota: value,
      )),
      Err(:final failure) => Err(failure),
    };
  }

  /// Forgets sync state after this phone was wiped (sign-out).
  Future<void> reset() async {
    await _memo.setLastSyncedAt(null);
    _failures = 0;
    _status.value = const SyncStatus();
  }

  void dispose() {
    _timer?.cancel();
    unawaited(_changes?.cancel());
    _lifecycle?.dispose();
    _status.dispose();
  }
}

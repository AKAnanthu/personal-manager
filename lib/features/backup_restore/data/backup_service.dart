import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_archive.dart';
import 'package:personal_life_manager/features/backup_restore/domain/backup.dart';

/// App preferences that go into a backup ("Relevant application
/// preferences"). Values must be JSON-safe.
abstract interface class PreferencesBackup {
  Future<Map<String, Object?>> export();
  Future<void> import(Map<String, Object?> values);
}

/// One table in a category. [fileKey] names the column holding a file
/// store key; [unique] lists other unique keys besides `id`.
final class _TableSpec {
  const _TableSpec(this.name, {this.fileKey, this.unique = const []});

  final String name;
  final String? fileKey;
  final List<List<String>> unique;
}

/// Parent tables first (children reference them).
const _catalog = <BackupCategory, List<_TableSpec>>{
  BackupCategory.personal: [_TableSpec('personal_entries')],
  BackupCategory.notes: [
    _TableSpec('notes'),
    _TableSpec('note_attachments', fileKey: 'file_key'),
  ],
  BackupCategory.documents: [_TableSpec('documents', fileKey: 'file_key')],
  BackupCategory.reminders: [_TableSpec('reminders')],
  BackupCategory.tasks: [
    _TableSpec('tasks'),
    _TableSpec('task_checklist_items'),
  ],
  BackupCategory.passwords: [_TableSpec('password_notes')],
  BackupCategory.shopping: [
    _TableSpec('shopping_lists', fileKey: 'receipt_key'),
    _TableSpec('shopping_items'),
  ],
  BackupCategory.budget: [
    _TableSpec(
      'budget_amounts',
      unique: [
        ['from_month'],
      ],
    ),
    _TableSpec(
      'expenses',
      unique: [
        ['source', 'source_id'],
      ],
    ),
  ],
  BackupCategory.lending: [_TableSpec('lending_records')],
  BackupCategory.medicine: [_TableSpec('medicines')],
  BackupCategory.preferences: [],
};

/// Estimate shown before the user confirms a backup.
typedef BackupEstimate = ({Map<BackupCategory, int> counts, int bytes});

/// Creates and restores backup files. No encryption (PRD §17.6); manual
/// only — nothing here runs on its own.
class BackupService {
  BackupService({
    required this._db,
    required this._files,
    required this._prefs,
    required this._tempDir,
    required this.appVersion,
    required this.platform,
    this._onRestored,
    this._clock = DateTime.now,
  });

  final AppDatabase _db;
  final FileStore _files;
  final PreferencesBackup _prefs;

  /// Where backup files are built and backups are unpacked; cleaned up
  /// after each step.
  final Directory _tempDir;
  final String appVersion;
  final String platform;

  /// Called after a restore (e.g. to reschedule notifications).
  final Future<void> Function()? _onRestored;
  final DateTime Function() _clock;

  // ---- backup ----------------------------------------------------------

  Future<BackupEstimate> estimate(Set<BackupCategory> categories) async {
    final counts = <BackupCategory, int>{};
    var bytes = 0;
    for (final c in categories) {
      final export = await _exportCategory(c);
      counts[c] = export.count;
      bytes += utf8.encode(export.json).length;
      for (final path in export.files.values) {
        bytes += File(path).lengthSync();
      }
    }
    return (counts: counts, bytes: bytes);
  }

  /// Builds the backup in a temp file and returns it. Cancelling stops it
  /// and removes the partial file.
  Future<File> create(
    Set<BackupCategory> categories, {
    required CancelToken token,
  }) async {
    final ordered = BackupCategory.values.where(categories.contains).toList();
    final data = <String, String>{};
    final files = <String, String>{};
    final counts = <BackupCategory, int>{};
    for (final c in ordered) {
      if (token.isCancelled) throw const Cancelled();
      final export = await _exportCategory(c);
      data['data/${c.name}.json'] = export.json;
      files.addAll(export.files);
      counts[c] = export.count;
    }
    final now = _clock();
    final out = File(p.join(_tempDir.path, backupFileName(now)));
    await _tempDir.create(recursive: true);
    final schema = _db.schemaVersion;
    final version = appVersion;
    final os = platform;
    try {
      await runCancellable(
        () => writeBackup(
          BackupContent(
            data: data,
            files: files,
            manifestFor: (entries) => BackupManifest(
              formatVersion: backupFormatVersion,
              appVersion: version,
              schemaVersion: schema,
              createdAt: now.toUtc(),
              platform: os,
              categories: ordered,
              counts: counts,
              files: entries,
            ),
          ),
          out.path,
        ),
        token: token,
      );
      return out;
    } on Object {
      if (out.existsSync()) await out.delete();
      rethrow;
    }
  }

  /// "PLM backup 2026-11-03 1830.plmbackup".
  static String backupFileName(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'PLM backup ${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}${two(t.minute)}.$backupExtension';
  }

  Future<({String json, Map<String, String> files, int count})> _exportCategory(
    BackupCategory c,
  ) async {
    if (c == BackupCategory.preferences) {
      return (
        json: jsonEncode({'prefs': await _prefs.export()}),
        files: const <String, String>{},
        count: 1,
      );
    }
    final tables = <String, List<Map<String, Object?>>>{};
    final files = <String, String>{};
    for (final t in _catalog[c] ?? const <_TableSpec>[]) {
      final rows = await _db.customSelect('SELECT * FROM "${t.name}"').get();
      tables[t.name] = [for (final r in rows) r.data];
      final keyCol = t.fileKey;
      if (keyCol == null) continue;
      for (final r in rows) {
        final key = r.data[keyCol];
        if (key is String && _files.exists(key)) {
          final file = await _files.resolve(key);
          file.fold((_) {}, (f) => files['files/$key'] = f.path);
        }
      }
    }
    final first = _catalog[c]?.firstOrNull;
    return (
      json: jsonEncode({'tables': tables}),
      files: files,
      count: first == null ? 0 : tables[first.name]?.length ?? 0,
    );
  }

  // ---- restore ---------------------------------------------------------

  /// Validates [file] and unpacks it to a private staging folder. Throws
  /// [BackupInvalid] with the reason, or [Cancelled].
  Future<BackupPreview> inspect(File file, {required CancelToken token}) async {
    final staging = Directory(
      p.join(_tempDir.path, 'restore-${_clock().microsecondsSinceEpoch}'),
    );
    final zipPath = file.path;
    final maxSchema = _db.schemaVersion;
    try {
      final manifestJson = await runCancellable(
        () =>
            verifyAndStage(zipPath, staging.path, maxSchemaVersion: maxSchema),
        token: token,
      );
      return BackupPreview(
        manifest: BackupManifest.fromJson(jsonDecode(manifestJson)),
        stagingPath: staging.path,
        fileSize: await file.length(),
      );
    } on IsolateFailure catch (e) {
      await discard(staging.path);
      throw BackupInvalid(
        ArchiveErrors.parse(e.code) ?? BackupProblem.notABackup,
      );
    } on Object {
      await discard(staging.path);
      rethrow;
    }
  }

  /// Restores [categories] from a staged backup, one transaction per
  /// category: a failure leaves that category exactly as it was. Other
  /// categories are never touched.
  Future<Map<BackupCategory, int>> restore(
    BackupPreview preview,
    Set<BackupCategory> categories,
    RestoreStrategy strategy,
  ) async {
    final restored = <BackupCategory, int>{};
    try {
      for (final c in BackupCategory.values) {
        if (!categories.contains(c) ||
            !preview.manifest.categories.contains(c)) {
          continue;
        }
        final file = File(
          p.join(preview.stagingPath, 'data', '${c.name}.json'),
        );
        final json = jsonDecode(await file.readAsString());
        if (json is! Map<String, Object?>) {
          throw const BackupInvalid(BackupProblem.damaged);
        }
        restored[c] = await _restoreCategory(
          c,
          json,
          strategy,
          preview.stagingPath,
        );
      }
    } finally {
      await _onRestored?.call();
    }
    return restored;
  }

  Future<int> _restoreCategory(
    BackupCategory c,
    Map<String, Object?> json,
    RestoreStrategy strategy,
    String staging,
  ) async {
    if (c == BackupCategory.preferences) {
      final prefs = json['prefs'];
      if (prefs is! Map<String, Object?>) {
        throw const BackupInvalid(BackupProblem.damaged);
      }
      await _prefs.import(prefs);
      return 1;
    }
    final specs = _catalog[c] ?? const <_TableSpec>[];
    final tables = json['tables'];
    if (tables is! Map<String, Object?>) {
      throw const BackupInvalid(BackupProblem.damaged);
    }
    List<Map<String, Object?>> rowsOf(_TableSpec t) => [
      for (final r in tables[t.name] as List<Object?>? ?? const [])
        if (r is Map<String, Object?>) r,
    ];

    // Files first, under their original keys, so records never point at
    // a file that isn't there. New copies are removed again on failure.
    final copied = <String>{};
    for (final t in specs) {
      final col = t.fileKey;
      if (col == null) continue;
      for (final r in rowsOf(t)) {
        final key = r[col];
        if (key is! String || _files.exists(key)) continue;
        final staged = File(p.join(staging, 'files', key));
        if (!staged.existsSync()) continue;
        final res = await _files.importAs(staged, key);
        if (res.isSuccess) copied.add(key);
      }
    }

    final before = strategy == RestoreStrategy.replace
        ? await _fileKeys(specs)
        : const <String>{};
    try {
      await _db.transaction(() async {
        if (strategy == RestoreStrategy.replace) {
          for (final t in specs.reversed) {
            await _db.customStatement('DELETE FROM "${t.name}"');
          }
        }
        for (final t in specs) {
          for (final row in rowsOf(t)) {
            await _upsert(t, row);
          }
        }
      });
    } on Object {
      for (final key in copied) {
        await _files.delete(key);
      }
      rethrow;
    }
    // Drop files nothing refers to any more (replaced records, or copies
    // for records where the local version was newer).
    final now = await _fileKeys(specs);
    for (final key in {...before, ...copied}.difference(now)) {
      await _files.delete(key);
    }
    // Raw statements don't notify drift's streams; open screens refresh.
    final names = {for (final t in specs) t.name};
    _db.notifyUpdates({
      for (final tbl in _db.allTables)
        if (names.contains(tbl.actualTableName)) TableUpdate.onTable(tbl),
    });
    return specs.isEmpty ? 0 : rowsOf(specs.first).length;
  }

  Future<Set<String>> _fileKeys(List<_TableSpec> specs) async => {
    for (final t in specs)
      if (t.fileKey case final col?)
        for (final r
            in await _db
                .customSelect('SELECT "$col" AS k FROM "${t.name}"')
                .get())
          if (r.data['k'] case final String k) k,
  };

  Future<void> _upsert(_TableSpec t, Map<String, Object?> raw) async {
    var row = raw;
    // Only one shopping session may be active: a restored active list
    // becomes a saved list if another one is in progress here.
    if (t.name == 'shopping_lists' && row['status'] == 'active') {
      final other = await _db
          .customSelect(
            'SELECT 1 FROM shopping_lists WHERE status = ? AND id <> ?',
            variables: [const Variable('active'), Variable(row['id'])],
          )
          .get();
      if (other.isNotEmpty) {
        row = {...row, 'status': 'draft', 'paused_at': null};
      }
    }
    final known = _columns(t.name);
    final cols = [
      for (final k in row.keys)
        if (known.contains(k)) k,
    ];
    if (!cols.contains('id') || !cols.contains('updated_at')) {
      throw const BackupInvalid(BackupProblem.damaged);
    }
    String q(String c) => '"$c"';
    final set = [
      for (final c in cols)
        if (c != 'id') '${q(c)} = excluded.${q(c)}',
    ].join(', ');
    final newer = 'WHERE excluded."updated_at" > "${t.name}"."updated_at"';
    final sql = StringBuffer()
      ..write('INSERT INTO "${t.name}" (${cols.map(q).join(', ')}) ')
      ..write('VALUES (${List.filled(cols.length, '?').join(', ')}) ')
      ..write('ON CONFLICT("id") DO UPDATE SET $set $newer');
    for (final u in t.unique) {
      sql.write(
        ' ON CONFLICT(${u.map(q).join(', ')}) DO UPDATE SET $set $newer',
      );
    }
    await _db.customStatement(sql.toString(), [for (final c in cols) row[c]]);
  }

  /// Column names of a table in this app version (unknown backup columns
  /// are ignored; never interpolated unchecked into SQL).
  Set<String> _columns(String table) => {
    for (final t in _db.allTables)
      if (t.actualTableName == table)
        for (final c in t.$columns) c.name,
  };

  /// Removes a staging folder or a built backup file.
  Future<void> discard(String path) async {
    final type = FileSystemEntity.typeSync(path);
    if (type == FileSystemEntityType.directory) {
      await Directory(path).delete(recursive: true);
    } else if (type == FileSystemEntityType.file) {
      await File(path).delete();
    }
  }
}

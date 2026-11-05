// Runs inside a background isolate: plain dart:io, no Flutter, no database.
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';
import 'package:personal_life_manager/features/backup_restore/domain/backup.dart';

/// What goes into a backup. Data is already JSON text; files are paths
/// in the app's file store.
final class BackupContent {
  const BackupContent({
    required this.data,
    required this.files,
    required this.manifestFor,
  });

  /// `data/<category>.json` → JSON text.
  final Map<String, String> data;

  /// `files/<key>` → source path.
  final Map<String, String> files;

  /// Builds the manifest once checksums are known.
  final BackupManifest Function(List<ManifestFile> files) manifestFor;
}

/// Writes the backup zip to [outPath]; returns its size in bytes.
Future<int> writeBackup(BackupContent content, String outPath) async {
  final entries = <ManifestFile>[];
  final dataBytes = <String, List<int>>{};
  for (final MapEntry(:key, :value) in content.data.entries) {
    final bytes = utf8.encode(value);
    dataBytes[key] = bytes;
    entries.add(
      ManifestFile(
        path: key,
        size: bytes.length,
        sha256: sha256.convert(bytes).toString(),
      ),
    );
  }
  for (final MapEntry(:key, :value) in content.files.entries) {
    final file = File(value);
    entries.add(
      ManifestFile(
        path: key,
        size: await file.length(),
        sha256: (await sha256.bind(file.openRead()).first).toString(),
      ),
    );
  }
  final manifest = utf8.encode(
    const JsonEncoder.withIndent('  ')
        .convert(content.manifestFor(entries).toJson()),
  );

  final zip = ZipFileEncoder()..create(outPath);
  try {
    zip.addArchiveFile(ArchiveFile.bytes('manifest.json', manifest));
    for (final MapEntry(:key, :value) in dataBytes.entries) {
      zip.addArchiveFile(ArchiveFile.bytes(key, value));
    }
    for (final MapEntry(:key, :value) in content.files.entries) {
      // Photos and PDFs are already compressed; storing them is faster.
      await zip.addFile(File(value), key, 0);
    }
  } finally {
    await zip.close();
  }
  return await File(outPath).length();
}

/// Error codes passed back from [verifyAndStage].
abstract final class ArchiveErrors {
  static String of(BackupProblem p) => 'backup:${p.name}';

  static BackupProblem? parse(String code) => code.startsWith('backup:')
      ? BackupProblem.values
            .where((p) => p.name == code.substring(7))
            .firstOrNull
      : null;
}

/// Checks a backup file and unpacks it into [stagingPath]: the manifest
/// must be ours and not from a newer app, every listed part must be present
/// with a matching size and SHA-256, and names must be safe. Returns the
/// manifest JSON.
Future<String> verifyAndStage(
  String zipPath,
  String stagingPath, {
  required int maxSchemaVersion,
}) async {
  Never fail(BackupProblem p) => throw IsolateError(ArchiveErrors.of(p));

  final InputFileStream input;
  final Archive archive;
  try {
    input = InputFileStream(zipPath);
    archive = ZipDecoder().decodeStream(input);
  } on Exception {
    fail(BackupProblem.notABackup);
  }
  try {
    final manifestEntry = archive.find('manifest.json');
    if (manifestEntry == null) fail(BackupProblem.notABackup);
    final manifestText = utf8.decode(
      manifestEntry.readBytes() ?? const [],
      allowMalformed: false,
    );
    final BackupManifest manifest;
    try {
      manifest = BackupManifest.fromJson(jsonDecode(manifestText));
    } on BackupInvalid catch (e) {
      fail(e.problem);
    } on FormatException {
      fail(BackupProblem.notABackup);
    }
    if (manifest.formatVersion > backupFormatVersion ||
        manifest.schemaVersion > maxSchemaVersion) {
      fail(BackupProblem.tooNew);
    }
    for (final c in manifest.categories) {
      if (!manifest.files.any((f) => f.path == 'data/${c.name}.json')) {
        fail(BackupProblem.damaged);
      }
    }

    final staging = Directory(stagingPath)..createSync(recursive: true);
    for (final f in manifest.files) {
      if (!_safeName(f.path)) fail(BackupProblem.damaged);
      final entry = archive.find(f.path);
      if (entry == null || !entry.isFile) fail(BackupProblem.damaged);
      final out = File(p.join(staging.path, f.path));
      out.parent.createSync(recursive: true);
      final sink = OutputFileStream(out.path);
      try {
        entry.writeContent(sink);
      } finally {
        sink.closeSync();
      }
      if (out.lengthSync() != f.size ||
          (await sha256.bind(out.openRead()).first).toString() != f.sha256) {
        fail(BackupProblem.damaged);
      }
    }
    return manifestText;
  } finally {
    await input.close();
  }
}

/// Only `data/<category>.json` and `files/<store key>`: nothing can escape
/// the staging folder or address other app files.
bool _safeName(String name) {
  if (name.startsWith('data/')) {
    final cat = name.substring(5);
    return BackupCategory.values.any((c) => '${c.name}.json' == cat);
  }
  if (name.startsWith('files/')) {
    return FileStore.isValidKey(name.substring(6));
  }
  return false;
}

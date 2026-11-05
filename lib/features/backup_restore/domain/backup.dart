import 'package:equatable/equatable.dart';

/// What can go in a backup (PRD §17.2–17.3). The first five are selected by
/// default; the rest (password notes especially) are opt-in.
enum BackupCategory {
  personal(defaultSelected: true),
  notes(defaultSelected: true),
  documents(defaultSelected: true),
  reminders(defaultSelected: true),
  tasks(defaultSelected: true),
  passwords(sensitive: true),
  shopping(),
  budget(),
  lending(),
  medicine(),
  preferences();

  BackupCategory({this.defaultSelected = false, this.sensitive = false});

  final bool defaultSelected;

  /// Gets the stronger unencrypted-file warning.
  final bool sensitive;

  static Set<BackupCategory> get defaults =>
      values.where((c) => c.defaultSelected).toSet();
}

/// Merge: add what's missing, update records where the backup's copy is
/// newer (by updatedAt). Replace: the category is cleared first.
enum RestoreStrategy { merge, replace }

/// Bumped when the file layout changes. Older formats are migrated on
/// restore; newer ones are rejected with a clear message.
const backupFormatVersion = 1;

/// Identifies our files (a renamed zip from elsewhere is rejected).
const backupAppId = 'app.plm.personal_life_manager';

const backupExtension = 'plmbackup';

final class ManifestFile extends Equatable {
  const ManifestFile({
    required this.path,
    required this.size,
    required this.sha256,
  });

  final String path;
  final int size;
  final String sha256;

  Map<String, Object?> toJson() => {
    'path': path,
    'size': size,
    'sha256': sha256,
  };

  @override
  List<Object?> get props => [path, size, sha256];
}

final class BackupManifest extends Equatable {
  const BackupManifest({
    required this.formatVersion,
    required this.appVersion,
    required this.schemaVersion,
    required this.createdAt,
    required this.platform,
    required this.categories,
    required this.counts,
    required this.files,
  });

  /// Throws [BackupInvalid] for anything that isn't a well-formed manifest
  /// of ours.
  factory BackupManifest.fromJson(Object? json) {
    if (json is! Map<String, Object?> || json['app'] != backupAppId) {
      throw const BackupInvalid(BackupProblem.notABackup);
    }
    T field<T>(String k) {
      final v = json[k];
      if (v is! T) throw const BackupInvalid(BackupProblem.damaged);
      return v;
    }

    final created = DateTime.tryParse(field<String>('createdAt'));
    final cats = field<List<Object?>>('categories');
    final counts = field<Map<String, Object?>>('counts');
    final files = field<List<Object?>>('files');
    if (created == null) throw const BackupInvalid(BackupProblem.damaged);
    BackupCategory? cat(Object? name) =>
        BackupCategory.values.where((c) => c.name == name).firstOrNull;
    return BackupManifest(
      formatVersion: field<int>('formatVersion'),
      appVersion: field<String>('appVersion'),
      schemaVersion: field<int>('schemaVersion'),
      createdAt: created,
      platform: field<String>('platform'),
      // Unknown categories (from a newer app) are ignored.
      categories: [for (final c in cats) ?cat(c)],
      counts: {
        for (final e in counts.entries)
          if (cat(e.key) case final c? when e.value is int) c: e.value! as int,
      },
      files: [
        for (final f in files)
          if (f case {
            'path': final String path,
            'size': final int size,
            'sha256': final String sha,
          })
            ManifestFile(path: path, size: size, sha256: sha)
          else
            throw const BackupInvalid(BackupProblem.damaged),
      ],
    );
  }

  final int formatVersion;
  final String appVersion;
  final int schemaVersion;

  /// UTC.
  final DateTime createdAt;
  final String platform;
  final List<BackupCategory> categories;

  /// Records per category.
  final Map<BackupCategory, int> counts;

  /// Every other entry in the zip, with its checksum.
  final List<ManifestFile> files;

  int get totalBytes => files.fold(0, (a, f) => a + f.size);

  Map<String, Object?> toJson() => {
    'app': backupAppId,
    'formatVersion': formatVersion,
    'appVersion': appVersion,
    'schemaVersion': schemaVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'platform': platform,
    'categories': [for (final c in categories) c.name],
    'counts': {for (final e in counts.entries) e.key.name: e.value},
    'files': [for (final f in files) f.toJson()],
  };

  @override
  List<Object?> get props => [
    formatVersion,
    appVersion,
    schemaVersion,
    createdAt,
    platform,
    categories,
    counts,
    files,
  ];
}

enum BackupProblem {
  /// Not a zip, or not one of ours.
  notABackup,

  /// A checksum or size doesn't match, or a part is missing.
  damaged,

  /// Made by a newer version of the app.
  tooNew,
}

final class BackupInvalid implements Exception {
  const BackupInvalid(this.problem);
  final BackupProblem problem;

  @override
  String toString() => 'BackupInvalid(${problem.name})';
}

/// A backup file that passed validation, unpacked to a private staging
/// folder and ready to restore.
final class BackupPreview extends Equatable {
  const BackupPreview({
    required this.manifest,
    required this.stagingPath,
    required this.fileSize,
  });

  final BackupManifest manifest;
  final String stagingPath;
  final int fileSize;

  @override
  List<Object?> get props => [manifest, stagingPath, fileSize];
}

/// The last backup made on this device ("Last backup: 28 Oct · 41 MB").
final class LastBackup extends Equatable {
  const LastBackup({required this.at, required this.size});

  final DateTime at;
  final int size;

  @override
  List<Object?> get props => [at, size];
}

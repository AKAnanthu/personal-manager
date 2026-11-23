import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:personal_life_manager/core/drive/drive_auth.dart';
import 'package:personal_life_manager/core/drive/drive_service.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';

/// A file in Drive's hidden app folder.
final class RemoteFile extends Equatable {
  const RemoteFile({
    required this.id,
    required this.name,
    this.modified,
    this.sizeBytes = 0,
  });

  final String id;
  final String name;

  /// Drive's modification stamp (UTC, ISO 8601); changes on every write.
  final String? modified;
  final int sizeBytes;

  @override
  List<Object?> get props => [id, name, modified, sizeBytes];
}

/// The user's Google storage (shared by Drive, Gmail and Photos).
final class StorageQuota extends Equatable {
  const StorageQuota({required this.usedBytes, this.limitBytes});

  final int usedBytes;

  /// Null for unlimited plans.
  final int? limitBytes;

  @override
  List<Object?> get props => [usedBytes, limitBytes];
}

/// Drive's hidden app folder (`appDataFolder`): only this app can see it,
/// it doesn't show in the Drive app, and it counts towards the user's
/// storage. Every method returns a [DriveFailure] instead of throwing.
abstract interface class SyncStore {
  Future<Result<List<RemoteFile>>> list();

  /// The newest file named [name], or null.
  Future<Result<RemoteFile?>> find(String name);

  /// Creates [name], or replaces the content of [fileId].
  Future<Result<RemoteFile>> write(
    String name,
    List<int> bytes, {
    String? fileId,
  });

  Future<Result<RemoteFile>> upload(String name, File file);

  Future<Result<List<int>>> read(String fileId);

  /// Downloads [fileId] to [target].
  Future<Result<void>> download(String fileId, File target);

  /// Deletes for good (hidden app data has no trash).
  Future<Result<void>> delete(String fileId);

  Future<Result<StorageQuota>> quota();
}

final class DriveSyncStore implements SyncStore {
  DriveSyncStore(this._auth, {this._delay = Future<void>.delayed});

  final DriveAuth _auth;
  final Future<void> Function(Duration) _delay;

  static const _space = 'appDataFolder';
  static const _fields = 'id,name,modifiedTime,size';

  Future<Result<T>> _run<T>(
    Future<T> Function(drive.DriveApi api) op, {
    bool retry = false,
  }) => runDriveCall(_auth, op, retry: retry, delay: _delay);

  static RemoteFile _file(drive.File f) => RemoteFile(
    id: f.id ?? '',
    name: f.name ?? '',
    modified: f.modifiedTime?.toUtc().toIso8601String(),
    sizeBytes: int.tryParse(f.size ?? '') ?? 0,
  );

  @override
  Future<Result<List<RemoteFile>>> list() => _run((api) async {
    final out = <RemoteFile>[];
    String? token;
    do {
      final r = await api.files.list(
        spaces: _space,
        q: 'trashed = false',
        pageSize: 1000,
        pageToken: token,
        $fields: 'nextPageToken,files($_fields)',
      );
      out.addAll([for (final f in r.files ?? <drive.File>[]) _file(f)]);
      token = r.nextPageToken;
    } while (token != null);
    return out;
  }, retry: true);

  @override
  Future<Result<RemoteFile?>> find(String name) => _run((api) async {
    final r = await api.files.list(
      spaces: _space,
      q: "name = '${GoogleDriveService.quote(name)}' and trashed = false",
      orderBy: 'modifiedTime desc',
      pageSize: 1,
      $fields: 'files($_fields)',
    );
    final f = r.files?.firstOrNull;
    return f == null ? null : _file(f);
  }, retry: true);

  @override
  Future<Result<RemoteFile>> write(
    String name,
    List<int> bytes, {
    String? fileId,
  }) => _send(
    name,
    () => drive.Media(Stream.value(bytes), bytes.length),
    fileId: fileId,
  );

  @override
  Future<Result<RemoteFile>> upload(String name, File file) async {
    final int length;
    try {
      length = await file.length();
    } on FileSystemException {
      return const Err(StorageFailure('upload source missing'));
    }
    return await _send(name, () => drive.Media(file.openRead(), length));
  }

  Future<Result<RemoteFile>> _send(
    String name,
    drive.Media Function() media, {
    String? fileId,
  }) => _run((api) async {
    if (fileId != null) {
      return _file(
        await api.files.update(
          drive.File(),
          fileId,
          uploadMedia: media(),
          $fields: _fields,
        ),
      );
    }
    return _file(
      await api.files.create(
        drive.File(name: name, parents: [_space]),
        uploadMedia: media(),
        $fields: _fields,
      ),
    );
  });

  @override
  Future<Result<List<int>>> read(String fileId) => _run((api) async {
    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final bytes = <int>[];
    await media.stream.forEach(bytes.addAll);
    return bytes;
  }, retry: true);

  @override
  Future<Result<void>> download(String fileId, File target) async {
    final part = File('${target.path}.part');
    final r = await _run<void>((api) async {
      final media = await api.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      final sink = part.openWrite();
      try {
        await sink.addStream(media.stream);
      } finally {
        await sink.close();
      }
    }, retry: true);
    if (r is Err<void>) {
      if (part.existsSync()) await part.delete();
      return r;
    }
    try {
      await part.rename(target.path);
    } on FileSystemException {
      return const Err(StorageFailure('download move failed'));
    }
    return r;
  }

  @override
  Future<Result<void>> delete(String fileId) =>
      _run<void>((api) => api.files.delete(fileId));

  @override
  Future<Result<StorageQuota>> quota() => _run((api) async {
    final about = await api.about.get($fields: 'storageQuota(limit,usage)');
    final q = about.storageQuota;
    return StorageQuota(
      usedBytes: int.tryParse(q?.usage ?? '') ?? 0,
      limitBytes: int.tryParse(q?.limit ?? ''),
    );
  }, retry: true);
}

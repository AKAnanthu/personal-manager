import 'dart:io';

import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/sync/sync_store.dart';

/// Drive's hidden app folder in memory, shared by the "phones" of a test.
final class FakeSyncStore implements SyncStore {
  final files = <String, ({String name, List<int> bytes, String modified})>{};
  var _ids = 0;
  var _tick = 0;

  /// While set, every call fails with this problem (e.g. offline).
  DriveProblem? failWith;
  final calls = <String>[];
  StorageQuota storageQuota = const StorageQuota(
    usedBytes: 1000,
    limitBytes: 15000,
  );

  String _stamp() =>
      '2026-01-01T00:00:${(_tick++).toString().padLeft(6, '0')}Z';

  RemoteFile _file(String id) {
    final f = files[id]!;
    return RemoteFile(
      id: id,
      name: f.name,
      modified: f.modified,
      sizeBytes: f.bytes.length,
    );
  }

  Result<T>? _fail<T>(String op) {
    calls.add(op);
    final p = failWith;
    return p == null ? null : Err(DriveFailure(p));
  }

  Iterable<String> named(String name) =>
      files.keys.where((id) => files[id]!.name == name);

  @override
  Future<Result<List<RemoteFile>>> list() async =>
      _fail('list') ?? Ok([for (final id in files.keys) _file(id)]);

  @override
  Future<Result<RemoteFile?>> find(String name) async =>
      _fail('find') ?? Ok(named(name).isEmpty ? null : _file(named(name).last));

  @override
  Future<Result<RemoteFile>> write(
    String name,
    List<int> bytes, {
    String? fileId,
  }) async {
    if (_fail<RemoteFile>('write') case final e?) return e;
    if (fileId != null && !files.containsKey(fileId)) {
      return const Err(DriveFailure(DriveProblem.notFound));
    }
    final id = fileId ?? 'id${_ids++}';
    files[id] = (name: name, bytes: List.of(bytes), modified: _stamp());
    return Ok(_file(id));
  }

  @override
  Future<Result<RemoteFile>> upload(String name, File file) async {
    if (_fail<RemoteFile>('upload') case final e?) return e;
    return await write(name, await file.readAsBytes());
  }

  @override
  Future<Result<List<int>>> read(String fileId) async {
    if (_fail<List<int>>('read') case final e?) return e;
    final f = files[fileId];
    return f == null
        ? const Err(DriveFailure(DriveProblem.notFound))
        : Ok(f.bytes);
  }

  @override
  Future<Result<void>> download(String fileId, File target) async {
    if (_fail<void>('download') case final e?) return e;
    final f = files[fileId];
    if (f == null) return const Err(DriveFailure(DriveProblem.notFound));
    await target.writeAsBytes(f.bytes);
    return const Ok(null);
  }

  @override
  Future<Result<void>> delete(String fileId) async {
    if (_fail<void>('delete') case final e?) return e;
    return files.remove(fileId) == null
        ? const Err(DriveFailure(DriveProblem.notFound))
        : const Ok(null);
  }

  @override
  Future<Result<StorageQuota>> quota() async =>
      _fail('quota') ?? Ok(storageQuota);
}

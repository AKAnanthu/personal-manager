import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:personal_life_manager/core/drive/drive_auth.dart';
import 'package:personal_life_manager/core/drive/drive_models.dart';
import 'package:personal_life_manager/core/drive/drive_service.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';

/// An account switch the tests flip by hand.
final class FakeDriveAuth implements DriveAuth {
  FakeDriveAuth({String? account, this.connectAs = 'me@example.com'})
    : _account = ValueNotifier(account);

  final ValueNotifier<String?> _account;

  /// What [connect] answers: an e-mail, null (backed out) or a failure.
  Object? connectAs;
  int connects = 0;
  int disconnects = 0;

  @override
  ValueListenable<String?> get account => _account;

  // ignore: avoid_setters_without_getters, the account getter covers it
  set signedIn(String? email) => _account.value = email;

  @override
  Future<void> load() async {}

  @override
  Future<Result<String?>> connect() async {
    connects++;
    final c = connectAs;
    if (c is Failure) return Err(c);
    _account.value = c as String?;
    return Ok(c);
  }

  @override
  Future<void> disconnect() async {
    disconnects++;
    _account.value = null;
  }

  @override
  Future<http.Client> client({bool prompt = false}) async =>
      throw UnimplementedError();

  @override
  Future<void> tokenRejected() async {}
}

final class FakeEntry {
  FakeEntry(
    this.item,
    this.parent, {
    this.bytes = const [],
    this.trashed = false,
  });

  DriveItem item;
  final String? parent;
  List<int> bytes;
  bool trashed;
}

/// Drive in memory: folders, files and their bytes. Set [failNext] to
/// make the next call of a kind fail.
final class FakeDriveService implements DriveService {
  final entries = <String, FakeEntry>{};
  final calls = <String>[];
  var _ids = 0;

  /// Operation name ('list', 'upload', ...) → failure for its next call.
  final failNext = <String, DriveProblem>{};

  /// Upload completes only when this is completed (to test progress and
  /// cancelling); null → at once.
  Completer<void>? holdUpload;

  Result<T>? _fail<T>(String op) {
    calls.add(op);
    final p = failNext.remove(op);
    return p == null ? null : Err(DriveFailure(p));
  }

  String _id() => 'id${++_ids}';

  /// Adds a folder or file directly (as if already on Drive).
  DriveItem put(
    String name, {
    String? parent,
    bool folder = false,
    List<int> bytes = const [],
    DateTime? modifiedAt,
  }) {
    final item = DriveItem(
      id: _id(),
      name: name,
      mimeType: folder ? DriveItem.folderMimeType : 'application/pdf',
      sizeBytes: folder ? null : bytes.length,
      modifiedAt: modifiedAt,
    );
    entries[item.id] = FakeEntry(item, parent, bytes: bytes);
    return item;
  }

  List<FakeEntry> childrenOf(String? parent) => [
    for (final e in entries.values)
      if (e.parent == parent && !e.trashed) e,
  ];

  /// Path of names from the top, e.g. 'Personal Life Manager/Backups'.
  String pathOf(String id) {
    final names = <String>[];
    String? cur = id;
    while (cur != null) {
      final e = entries[cur]!;
      names.insert(0, e.item.name);
      cur = e.parent;
    }
    return names.join('/');
  }

  int get folderCount => entries.values.where((e) => e.item.isFolder).length;

  @override
  Future<Result<DrivePage>> list(String folderId, {String? pageToken}) async {
    if (_fail<DrivePage>('list') case final f?) return f;
    final kids = childrenOf(folderId)
      ..sort((a, b) {
        if (a.item.isFolder != b.item.isFolder) return a.item.isFolder ? -1 : 1;
        return a.item.name.compareTo(b.item.name);
      });
    return Ok(DrivePage([for (final k in kids) k.item]));
  }

  @override
  Future<Result<int>> count(String folderId, {int cap = 999}) async {
    if (_fail<int>('count') case final f?) return f;
    return Ok(childrenOf(folderId).length);
  }

  @override
  Future<Result<DriveItem?>> findFolder(String name, {String? parentId}) async {
    if (_fail<DriveItem?>('findFolder') case final f?) return f;
    return Ok(
      childrenOf(parentId)
          .where((e) => e.item.isFolder && e.item.name == name)
          .firstOrNull
          ?.item,
    );
  }

  @override
  Future<Result<DriveItem>> createFolder(
    String name, {
    String? parentId,
  }) async {
    if (_fail<DriveItem>('createFolder') case final f?) return f;
    return Ok(put(name, parent: parentId, folder: true));
  }

  @override
  Future<Result<bool>> folderExists(String id) async {
    if (_fail<bool>('folderExists') case final f?) return f;
    final e = entries[id];
    return Ok(e != null && !e.trashed && e.item.isFolder);
  }

  @override
  Future<Result<DriveItem>> upload(
    File file, {
    required String name,
    required String parentId,
    required String mimeType,
    DriveProgress? onProgress,
    CancelToken? token,
  }) async {
    if (_fail<DriveItem>('upload') case final f?) return f;
    final bytes = await file.readAsBytes();
    onProgress?.call(bytes.length ~/ 2, bytes.length);
    final hold = holdUpload;
    if (hold != null) {
      final cancelled = Completer<void>();
      final off = token?.whenCancelled(cancelled.complete);
      await Future.any([hold.future, cancelled.future]);
      off?.call();
    }
    if (token?.isCancelled ?? false) {
      return const Err(DriveFailure(DriveProblem.cancelled));
    }
    onProgress?.call(bytes.length, bytes.length);
    final item = DriveItem(
      id: _id(),
      name: name,
      mimeType: mimeType,
      sizeBytes: bytes.length,
      modifiedAt: DateTime(2026, 11, 5),
    );
    entries[item.id] = FakeEntry(item, parentId, bytes: bytes);
    return Ok(item);
  }

  @override
  Future<Result<void>> download(
    String fileId,
    File target, {
    DriveProgress? onProgress,
    CancelToken? token,
  }) async {
    if (_fail<void>('download') case final f?) return f;
    final e = entries[fileId];
    if (e == null || e.trashed) {
      return const Err(DriveFailure(DriveProblem.notFound));
    }
    await target.writeAsBytes(e.bytes);
    onProgress?.call(e.bytes.length, e.bytes.length);
    return const Ok(null);
  }

  @override
  Future<Result<void>> trash(String id) async {
    if (_fail<void>('trash') case final f?) return f;
    final e = entries[id];
    if (e == null || e.trashed) {
      return const Err(DriveFailure(DriveProblem.notFound));
    }
    e.trashed = true;
    return const Ok(null);
  }
}

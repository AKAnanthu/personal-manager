import 'dart:io';

import 'package:personal_life_manager/core/drive/drive_auth.dart';
import 'package:personal_life_manager/core/drive/drive_folders.dart';
import 'package:personal_life_manager/core/drive/drive_models.dart';
import 'package:personal_life_manager/core/drive/drive_service.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';

/// "Save a copy to Drive" for one file: connects first when needed, finds
/// or creates the folder, uploads. A copy only; nothing syncs afterwards.
class DriveCopier {
  DriveCopier({
    required this._auth,
    required this._drive,
    required this._folders,
  });

  final DriveAuth _auth;
  final DriveService _drive;
  final DriveFolders _folders;

  /// Ok(null) when the user backed out of connecting.
  Future<Result<DriveItem?>> copy(
    File file, {
    required List<String> folder,
    required String name,
    required String mimeType,
    DriveProgress? onProgress,
    CancelToken? token,
  }) async {
    if (_auth.account.value == null) {
      switch (await _auth.connect()) {
        case Ok(value: null):
          return const Ok(null);
        case Err(:final failure):
          return Err(failure);
        case Ok():
          break;
      }
    }
    final String parentId;
    switch (await _folders.resolve(folder)) {
      case Ok(:final value):
        parentId = value;
      case Err(:final failure):
        return Err(failure);
    }
    return switch (await _drive.upload(
      file,
      name: name,
      parentId: parentId,
      mimeType: mimeType,
      onProgress: onProgress,
      token: token,
    )) {
      Ok(:final value) => Ok(value),
      Err(:final failure) => Err(failure),
    };
  }
}

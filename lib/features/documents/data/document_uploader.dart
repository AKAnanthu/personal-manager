import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:personal_life_manager/core/drive/drive_folders.dart';
import 'package:personal_life_manager/core/drive/drive_service.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/domain/documents_repository.dart';

/// Uploads a copy of a document to `Documents/<category>/` on Drive
/// (PRD §7.5). Only ever started by the user; a failure keeps the local
/// file and can be retried by hand. The two copies don't sync afterwards.
class DocumentUploader {
  DocumentUploader({
    required this._documents,
    required this._drive,
    required this._folders,
  });

  final DocumentsRepository _documents;
  final DriveService _drive;
  final DriveFolders _folders;
  final _tokens = <String, CancelToken>{};
  final _progress = ValueNotifier<Map<String, double>>(const {});

  /// Document ID → 0..1 for uploads in progress.
  ValueListenable<Map<String, double>> get progress => _progress;

  void _setProgress(String id, double? value) {
    final m = {..._progress.value};
    if (value == null) {
      m.remove(id);
    } else {
      m[id] = value;
    }
    _progress.value = m;
  }

  Future<Result<void>> upload(String documentId) async {
    if (_tokens.containsKey(documentId)) return const Ok(null);
    final doc = await _documents.watchDocument(documentId).first;
    if (doc == null) return const Err(NotFoundFailure());
    final File source;
    switch (await _documents.fileFor(doc)) {
      case Ok(:final value):
        source = value;
      case Err(:final failure):
        return Err(failure);
    }
    final token = _tokens[documentId] = CancelToken();
    _setProgress(documentId, 0);
    await _documents.setDriveStatus(documentId, DriveStatus.uploading);
    try {
      final outcome = await _send(doc, source, token);
      if (outcome case Err(:final failure)) {
        // Stopped by the user: back to "on this phone only".
        final cancelled =
            failure is DriveFailure &&
            failure.problem == DriveProblem.cancelled;
        await _documents.setDriveStatus(
          documentId,
          cancelled ? DriveStatus.notUploaded : DriveStatus.failed,
        );
      }
      return outcome;
    } finally {
      _tokens.remove(documentId);
      _setProgress(documentId, null);
    }
  }

  Future<Result<void>> _send(
    AppDocument doc,
    File source,
    CancelToken token,
  ) async {
    final String parentId;
    switch (await _folders.resolve(
      DriveLayout.documentFolder(doc.category.driveFolder),
    )) {
      case Ok(:final value):
        parentId = value;
      case Err(:final failure):
        return Err(failure);
    }
    final uploaded = await _drive.upload(
      source,
      name: doc.originalName,
      parentId: parentId,
      mimeType: doc.fileType.mimeType,
      token: token,
      onProgress: (done, total) =>
          _setProgress(doc.id, total == 0 ? 0 : done / total),
    );
    return switch (uploaded) {
      Ok(:final value) => await _documents.setDriveStatus(
        doc.id,
        DriveStatus.uploaded,
        driveFileId: value.id,
      ),
      Err(:final failure) => Err(failure),
    };
  }

  void cancel(String documentId) => _tokens[documentId]?.cancel();

  /// Moves the Drive copy to Drive's trash (asked when deleting).
  Future<Result<void>> trashDriveCopy(AppDocument d) async {
    final id = d.driveFileId;
    if (id == null) return const Ok(null);
    final r = await _drive.trash(id);
    // Already gone from Drive is fine.
    if (r case Err(failure: DriveFailure(problem: DriveProblem.notFound))) {
      return const Ok(null);
    }
    return r;
  }
}

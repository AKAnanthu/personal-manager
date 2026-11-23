import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/drive/drive_auth.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/documents/data/document_uploader.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/domain/documents_repository.dart';

final class DocumentViewState extends Equatable {
  const DocumentViewState({
    this.status = LoadStatus.loading,
    this.document,
    this.file,
    this.busy = false,
    this.failure,
    this.deleted = false,
    this.driveConnected = false,
    this.uploadProgress,
  });

  final LoadStatus status;
  final AppDocument? document;

  /// The local file, for previews. Null if missing on disk.
  final File? file;
  final bool busy;
  final Failure? failure;
  final bool deleted;

  /// A Google account is connected.
  final bool driveConnected;

  /// 0..1 while this document is uploading to Drive.
  final double? uploadProgress;

  DocumentViewState copyWith({
    LoadStatus? status,
    AppDocument? Function()? document,
    File? Function()? file,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
    bool? deleted,
    bool? driveConnected,
    double? Function()? uploadProgress,
  }) => DocumentViewState(
    status: status ?? this.status,
    document: document != null ? document() : this.document,
    file: file != null ? file() : this.file,
    busy: busy ?? this.busy,
    failure: clearFailure ? null : (failure ?? this.failure),
    deleted: deleted ?? this.deleted,
    driveConnected: driveConnected ?? this.driveConnected,
    uploadProgress: uploadProgress != null
        ? uploadProgress()
        : this.uploadProgress,
  );

  @override
  List<Object?> get props => [
    status,
    document,
    file?.path,
    busy,
    failure,
    deleted,
    driveConnected,
    uploadProgress,
  ];
}

/// One document, live: details, its local file, favourite, delete and
/// its Drive copy (when Drive is available).
class DocumentViewCubit extends Cubit<DocumentViewState> {
  DocumentViewCubit({
    required this._repository,
    required this.documentId,
    this._uploader,
    this._driveAuth,
  }) : super(const DocumentViewState());

  final DocumentsRepository _repository;
  final String documentId;
  final DocumentUploader? _uploader;
  final DriveAuth? _driveAuth;
  StreamSubscription<(AppDocument?, File?)>? _sub;

  /// Drive actions are offered (an account can be connected on demand).
  bool get driveAvailable => _uploader != null && _driveAuth != null;

  void _onDrive() {
    if (isClosed) return;
    emit(
      state.copyWith(
        driveConnected: _driveAuth?.account.value != null,
        uploadProgress: () => _uploader?.progress.value[documentId],
      ),
    );
  }

  void start() {
    _driveAuth?.account.addListener(_onDrive);
    _uploader?.progress.addListener(_onDrive);
    _onDrive();
    _sub ??= _repository
        .watchDocument(documentId)
        .asyncMap((d) async {
          if (d == null) return (d, null);
          final f = await _repository.fileFor(d);
          return (d, f.fold((_) => null, (file) => file));
        })
        .listen(
          (pair) {
            final (doc, file) = pair;
            if (doc == null && state.document != null) {
              emit(state.copyWith(deleted: true));
              return;
            }
            emit(
              state.copyWith(
                status: doc == null ? LoadStatus.failure : LoadStatus.ready,
                document: () => doc,
                file: () => file,
                failure: doc == null ? const NotFoundFailure() : null,
              ),
            );
          },
          onError: (Object _) =>
              emit(state.copyWith(status: LoadStatus.failure)),
        );
  }

  Future<void> toggleFavourite() async {
    final d = state.document;
    if (d == null) return;
    final r = await _repository.setFavourite(d.id, value: !d.isFavourite);
    if (isClosed) return;
    if (r case Err(:final failure)) emit(state.copyWith(failure: failure));
  }

  Future<void> delete() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, clearFailure: true));
    final r = await _repository.delete(documentId);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(busy: false, failure: f),
        (_) => state.copyWith(busy: false, deleted: true),
      ),
    );
  }

  void clearFailure() => emit(state.copyWith(clearFailure: true));

  /// Uploads a copy to Drive, connecting an account first if needed.
  Future<void> uploadToDrive() async {
    final uploader = _uploader;
    final auth = _driveAuth;
    if (uploader == null || auth == null) return;
    if (auth.account.value == null) {
      final r = await auth.connect();
      if (isClosed) return;
      switch (r) {
        case Err(:final failure):
          emit(state.copyWith(failure: failure));
          return;
        case Ok(value: null):
          return; // backed out
        case Ok():
          break;
      }
    }
    final r = await uploader.upload(documentId);
    if (isClosed) return;
    if (r case Err(:final failure)
        when !(failure is DriveFailure &&
            failure.problem == DriveProblem.cancelled)) {
      emit(state.copyWith(failure: failure));
    }
  }

  void cancelUpload() => _uploader?.cancel(documentId);

  /// Deletes the document; with [alsoDrive] its Drive copy is moved to
  /// Drive's trash first (if that fails, nothing is deleted).
  Future<void> deleteWithDrive({required bool alsoDrive}) async {
    final d = state.document;
    final uploader = _uploader;
    if (alsoDrive && d != null && uploader != null) {
      emit(state.copyWith(busy: true, clearFailure: true));
      final r = await uploader.trashDriveCopy(d);
      if (isClosed) return;
      if (r case Err(:final failure)) {
        emit(state.copyWith(busy: false, failure: failure));
        return;
      }
      emit(state.copyWith(busy: false));
    }
    await delete();
  }

  @override
  Future<void> close() async {
    _driveAuth?.account.removeListener(_onDrive);
    _uploader?.progress.removeListener(_onDrive);
    await _sub?.cancel();
    await super.close();
  }
}

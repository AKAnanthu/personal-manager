import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
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
  });

  final LoadStatus status;
  final AppDocument? document;

  /// The local file, for previews. Null if missing on disk.
  final File? file;
  final bool busy;
  final Failure? failure;
  final bool deleted;

  DocumentViewState copyWith({
    LoadStatus? status,
    AppDocument? Function()? document,
    File? Function()? file,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
    bool? deleted,
  }) => DocumentViewState(
    status: status ?? this.status,
    document: document != null ? document() : this.document,
    file: file != null ? file() : this.file,
    busy: busy ?? this.busy,
    failure: clearFailure ? null : (failure ?? this.failure),
    deleted: deleted ?? this.deleted,
  );

  @override
  List<Object?> get props => [
    status,
    document,
    file?.path,
    busy,
    failure,
    deleted,
  ];
}

/// One document, live: details, its local file, favourite and delete.
class DocumentViewCubit extends Cubit<DocumentViewState> {
  DocumentViewCubit({required this._repository, required this.documentId})
    : super(const DocumentViewState());

  final DocumentsRepository _repository;
  final String documentId;
  StreamSubscription<(AppDocument?, File?)>? _sub;

  void start() {
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

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await super.close();
  }
}

import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/utils/event_transformers.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/domain/documents_repository.dart';

sealed class DocumentsEvent {
  const DocumentsEvent();
}

final class DocumentsStarted extends DocumentsEvent {
  const DocumentsStarted();
}

final class DocumentsQueryChanged extends DocumentsEvent {
  const DocumentsQueryChanged(this.query);
  final String query;
}

/// All (both unset), Favourites, or one category.
final class DocumentsFilterSelected extends DocumentsEvent {
  const DocumentsFilterSelected({this.category, this.favourites = false});
  final DocumentCategory? category;
  final bool favourites;
}

final class DocumentFavouriteToggled extends DocumentsEvent {
  const DocumentFavouriteToggled(this.id, {required this.value});
  final String id;
  final bool value;
}

final class _Subscribe extends DocumentsEvent {
  const _Subscribe();
}

final class _ExpiringUpdated extends DocumentsEvent {
  const _ExpiringUpdated(this.documents);
  final List<AppDocument> documents;
}

final class DocumentsState extends Equatable {
  const DocumentsState({
    this.status = LoadStatus.loading,
    this.filter = const DocumentFilter(),
    this.documents = const [],
    this.expiringSoon = const [],
    this.failure,
  });

  final LoadStatus status;
  final DocumentFilter filter;
  final List<AppDocument> documents;
  final List<AppDocument> expiringSoon;
  final Failure? failure;

  bool get isFiltered =>
      filter.query.trim().isNotEmpty ||
      filter.category != null ||
      filter.favouritesOnly;

  DocumentsState copyWith({
    LoadStatus? status,
    DocumentFilter? filter,
    List<AppDocument>? documents,
    List<AppDocument>? expiringSoon,
    Failure? failure,
    bool clearFailure = false,
  }) => DocumentsState(
    status: status ?? this.status,
    filter: filter ?? this.filter,
    documents: documents ?? this.documents,
    expiringSoon: expiringSoon ?? this.expiringSoon,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [status, filter, documents, expiringSoon, failure];
}

/// Document list with search and filters. [watchExpiry] is off for the
/// link-a-document picker, which needs only the list.
class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  DocumentsBloc(
    this._repository, {
    this.watchExpiry = true,
    this._clock = DateTime.now,
  }) : super(const DocumentsState()) {
    on<DocumentsStarted>((_, _) {
      if (watchExpiry) {
        _expirySub ??= _repository
            .watchExpiringSoon(_clock())
            .listen((d) => add(_ExpiringUpdated(d)));
      }
      add(const _Subscribe());
    });
    on<DocumentsQueryChanged>((e, emit) {
      emit(
        state.copyWith(
          filter: DocumentFilter(
            query: e.query,
            category: state.filter.category,
            favouritesOnly: state.filter.favouritesOnly,
          ),
        ),
      );
      add(const _Subscribe());
    }, transformer: debounceRestartable());
    on<DocumentsFilterSelected>((e, emit) {
      emit(
        state.copyWith(
          filter: DocumentFilter(
            query: state.filter.query,
            category: e.category,
            favouritesOnly: e.favourites,
          ),
        ),
      );
      add(const _Subscribe());
    });
    on<_Subscribe>(
      (_, emit) => emit.forEach<List<AppDocument>>(
        _repository.watch(state.filter),
        onData: (d) => state.copyWith(documents: d, status: LoadStatus.ready),
        onError: (_, _) => state.copyWith(status: LoadStatus.failure),
      ),
      transformer: restartable(),
    );
    on<_ExpiringUpdated>(
      (e, emit) => emit(state.copyWith(expiringSoon: e.documents)),
    );
    on<DocumentFavouriteToggled>((e, emit) async {
      emit(state.copyWith(clearFailure: true));
      final r = await _repository.setFavourite(e.id, value: e.value);
      if (r case Err(:final failure)) emit(state.copyWith(failure: failure));
    });
  }

  final DocumentsRepository _repository;
  final bool watchExpiry;
  final DateTime Function() _clock;
  StreamSubscription<List<AppDocument>>? _expirySub;

  @override
  Future<void> close() async {
    await _expirySub?.cancel();
    await super.close();
  }
}

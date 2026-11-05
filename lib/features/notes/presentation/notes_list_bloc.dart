import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/utils/event_transformers.dart';
import 'package:personal_life_manager/features/notes/domain/note.dart';
import 'package:personal_life_manager/features/notes/domain/notes_repository.dart';

sealed class NotesListEvent {
  const NotesListEvent();
}

final class NotesStarted extends NotesListEvent {
  const NotesStarted();
}

final class NotesQueryChanged extends NotesListEvent {
  const NotesQueryChanged(this.query);
  final String query;
}

final class NotesViewChanged extends NotesListEvent {
  const NotesViewChanged(this.view, {this.tag});
  final NotesView view;
  final String? tag;
}

final class _Subscribe extends NotesListEvent {
  const _Subscribe();
}

final class _TagsUpdated extends NotesListEvent {
  const _TagsUpdated(this.tags);
  final List<String> tags;
}

final class NotesListState extends Equatable {
  const NotesListState({
    this.status = LoadStatus.loading,
    this.filter = const NotesFilter(),
    this.notes = const [],
    this.tags = const [],
  });

  final LoadStatus status;
  final NotesFilter filter;
  final List<Note> notes;
  final List<String> tags;

  List<Note> get pinned => notes.where((n) => n.isPinned).toList();
  List<Note> get others => notes.where((n) => !n.isPinned).toList();

  NotesListState copyWith({
    LoadStatus? status,
    NotesFilter? filter,
    List<Note>? notes,
    List<String>? tags,
  }) => NotesListState(
    status: status ?? this.status,
    filter: filter ?? this.filter,
    notes: notes ?? this.notes,
    tags: tags ?? this.tags,
  );

  @override
  List<Object?> get props => [status, filter, notes, tags];
}

class NotesListBloc extends Bloc<NotesListEvent, NotesListState> {
  NotesListBloc(this._repository) : super(const NotesListState()) {
    on<NotesStarted>((_, _) {
      _tagSub ??= _repository.watchTags().listen((t) => add(_TagsUpdated(t)));
      add(const _Subscribe());
    });
    on<NotesQueryChanged>((e, _) {
      _query = e.query;
      add(const _Subscribe());
    }, transformer: debounceRestartable());
    on<NotesViewChanged>((e, emit) {
      emit(
        state.copyWith(
          filter: NotesFilter(query: _query, view: e.view, tag: e.tag),
          status: LoadStatus.loading,
        ),
      );
      add(const _Subscribe());
    });
    // Each new filter replaces the previous database subscription.
    on<_Subscribe>((_, emit) {
      final filter = NotesFilter(
        query: _query,
        view: state.filter.view,
        tag: state.filter.tag,
      );
      emit(state.copyWith(filter: filter));
      return emit.forEach<List<Note>>(
        _repository.watchNotes(filter),
        onData: (notes) =>
            state.copyWith(notes: notes, status: LoadStatus.ready),
        onError: (_, _) => state.copyWith(status: LoadStatus.failure),
      );
    }, transformer: restartable());
    on<_TagsUpdated>((e, emit) => emit(state.copyWith(tags: e.tags)));
  }

  final NotesRepository _repository;
  StreamSubscription<List<String>>? _tagSub;
  String _query = '';

  @override
  Future<void> close() async {
    await _tagSub?.cancel();
    await super.close();
  }
}

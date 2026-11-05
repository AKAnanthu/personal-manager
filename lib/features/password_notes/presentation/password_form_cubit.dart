import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_note.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_notes_repository.dart';

final class PasswordFormState extends Equatable {
  const PasswordFormState({
    this.loading = true,
    this.noteId,
    this.name = '',
    this.url = '',
    this.username = '',
    this.password = '',
    this.notes = '',
    this.category = '',
    this.isFavourite = false,
    this.categories = defaultPasswordCategories,
    this.dirty = false,
    this.busy = false,
    this.showErrors = false,
    this.failure,
    this.outcome = EditorOutcome.none,
  });

  final bool loading;
  final String? noteId;
  final String name;
  final String url;
  final String username;
  final String password;
  final String notes;
  final String category;
  final bool isFavourite;

  /// Chips: the suggested categories plus any in use or just added.
  final List<String> categories;
  final bool dirty;
  final bool busy;
  final bool showErrors;
  final Failure? failure;
  final EditorOutcome outcome;

  bool get isNew => noteId == null;
  bool get nameMissing => name.trim().isEmpty;

  PasswordFormState copyWith({
    bool? loading,
    String? noteId,
    String? name,
    String? url,
    String? username,
    String? password,
    String? notes,
    String? category,
    bool? isFavourite,
    List<String>? categories,
    bool? dirty,
    bool? busy,
    bool? showErrors,
    Failure? failure,
    bool clearFailure = false,
    EditorOutcome? outcome,
  }) => PasswordFormState(
    loading: loading ?? this.loading,
    noteId: noteId ?? this.noteId,
    name: name ?? this.name,
    url: url ?? this.url,
    username: username ?? this.username,
    password: password ?? this.password,
    notes: notes ?? this.notes,
    category: category ?? this.category,
    isFavourite: isFavourite ?? this.isFavourite,
    categories: categories ?? this.categories,
    dirty: dirty ?? this.dirty,
    busy: busy ?? this.busy,
    showErrors: showErrors ?? this.showErrors,
    failure: clearFailure ? null : (failure ?? this.failure),
    outcome: outcome ?? this.outcome,
  );

  @override
  List<Object?> get props => [
    loading,
    noteId,
    name,
    url,
    username,
    password,
    notes,
    category,
    isFavourite,
    categories,
    dirty,
    busy,
    showErrors,
    failure,
    outcome,
  ];
}

class PasswordFormCubit extends Cubit<PasswordFormState> {
  PasswordFormCubit({required this._repository, this.noteId})
    : super(const PasswordFormState());

  final PasswordNotesRepository _repository;
  final String? noteId;

  Future<void> load() async {
    final inUse = await _repository.watchCategories().first;
    final id = noteId;
    final note = id == null ? null : await _repository.watchNote(id).first;
    if (isClosed) return;
    if (id != null && note == null) {
      emit(state.copyWith(loading: false, failure: const NotFoundFailure()));
      return;
    }
    emit(
      state.copyWith(
        loading: false,
        noteId: note?.id,
        name: note?.name,
        url: note?.url,
        username: note?.username,
        password: note?.password,
        notes: note?.notes,
        category: note?.category,
        isFavourite: note?.isFavourite,
        categories: _merge(defaultPasswordCategories, [
          ...inUse,
          ?note?.category,
        ]),
      ),
    );
  }

  void nameChanged(String v) => emit(state.copyWith(name: v, dirty: true));
  void urlChanged(String v) => emit(state.copyWith(url: v, dirty: true));
  void usernameChanged(String v) =>
      emit(state.copyWith(username: v, dirty: true));
  void passwordChanged(String v) =>
      emit(state.copyWith(password: v, dirty: true));
  void notesChanged(String v) => emit(state.copyWith(notes: v, dirty: true));
  void favouriteChanged({required bool value}) =>
      emit(state.copyWith(isFavourite: value, dirty: true));

  /// Tapping the selected chip clears the category.
  void categoryToggled(String c) =>
      emit(state.copyWith(category: state.category == c ? '' : c, dirty: true));

  /// Adds a user-typed category and selects it.
  void categoryAdded(String name) {
    final c = name.trim();
    if (c.isEmpty) return;
    final existing = state.categories
        .where((e) => e.toLowerCase() == c.toLowerCase())
        .firstOrNull;
    emit(
      state.copyWith(
        categories: existing == null ? [...state.categories, c] : null,
        category: existing ?? c,
        dirty: true,
      ),
    );
  }

  Future<void> save() async {
    if (state.busy) return;
    if (state.nameMissing) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(busy: true, clearFailure: true));
    final r = await _repository.save(
      PasswordNoteDraft(
        id: state.noteId,
        name: state.name,
        url: state.url,
        username: state.username,
        password: state.password,
        notes: state.notes,
        category: state.category,
        isFavourite: state.isFavourite,
      ),
    );
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(busy: false, failure: f),
        (_) => state.copyWith(
          busy: false,
          dirty: false,
          outcome: EditorOutcome.saved,
        ),
      ),
    );
  }

  Future<void> delete() async {
    final id = state.noteId;
    if (id == null) {
      emit(state.copyWith(outcome: EditorOutcome.discarded));
      return;
    }
    emit(state.copyWith(busy: true));
    final r = await _repository.delete(id);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(busy: false, failure: f),
        (_) => state.copyWith(busy: false, outcome: EditorOutcome.deleted),
      ),
    );
  }

  void clearFailure() => emit(state.copyWith(clearFailure: true));

  /// Case-insensitive union, keeping the first spelling and order.
  static List<String> _merge(List<String> a, List<String> b) {
    final seen = <String>{};
    return [
      for (final c in [...a, ...b])
        if (c.trim().isNotEmpty && seen.add(c.toLowerCase())) c,
    ];
  }
}

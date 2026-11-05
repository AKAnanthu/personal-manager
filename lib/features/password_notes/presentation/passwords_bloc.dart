import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/ui/session_notices.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/utils/event_transformers.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_note.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_notes_repository.dart';

sealed class PasswordsEvent {
  const PasswordsEvent();
}

final class PasswordsStarted extends PasswordsEvent {
  const PasswordsStarted();
}

final class PasswordsQueryChanged extends PasswordsEvent {
  const PasswordsQueryChanged(this.query);
  final String query;
}

/// All (both null/false), Favourites, or one category.
final class PasswordsFilterSelected extends PasswordsEvent {
  const PasswordsFilterSelected({this.category, this.favourites = false});
  final String? category;
  final bool favourites;
}

/// Expands a card to show its login details; null collapses.
final class PasswordExpanded extends PasswordsEvent {
  const PasswordExpanded(this.id);
  final String? id;
}

final class PasswordFavouriteToggled extends PasswordsEvent {
  const PasswordFavouriteToggled(this.id, {required this.value});
  final String id;
  final bool value;
}

final class PasswordsWarningDismissed extends PasswordsEvent {
  const PasswordsWarningDismissed();
}

final class _Subscribe extends PasswordsEvent {
  const _Subscribe();
}

final class _CategoriesUpdated extends PasswordsEvent {
  const _CategoriesUpdated(this.categories);
  final List<String> categories;
}

final class PasswordsState extends Equatable {
  const PasswordsState({
    this.status = LoadStatus.loading,
    this.filter = const PasswordFilter(),
    this.notes = const [],
    this.categories = const [],
    this.expandedId,
    this.warningDismissed = false,
    this.failure,
  });

  final LoadStatus status;
  final PasswordFilter filter;
  final List<PasswordNote> notes;
  final List<String> categories;
  final String? expandedId;
  final bool warningDismissed;
  final Failure? failure;

  bool get isFiltered =>
      filter.query.trim().isNotEmpty ||
      filter.category != null ||
      filter.favouritesOnly;

  PasswordsState copyWith({
    LoadStatus? status,
    PasswordFilter? filter,
    List<PasswordNote>? notes,
    List<String>? categories,
    String? Function()? expandedId,
    bool? warningDismissed,
    Failure? failure,
    bool clearFailure = false,
  }) => PasswordsState(
    status: status ?? this.status,
    filter: filter ?? this.filter,
    notes: notes ?? this.notes,
    categories: categories ?? this.categories,
    expandedId: expandedId != null ? expandedId() : this.expandedId,
    warningDismissed: warningDismissed ?? this.warningDismissed,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [
    status,
    filter,
    notes,
    categories,
    expandedId,
    warningDismissed,
    failure,
  ];
}

class PasswordsBloc extends Bloc<PasswordsEvent, PasswordsState> {
  PasswordsBloc(this._repository, this._notices)
    : super(
        PasswordsState(warningDismissed: _notices.passwordWarningDismissed),
      ) {
    on<PasswordsStarted>((_, _) {
      _categorySub ??= _repository.watchCategories().listen(
        (c) => add(_CategoriesUpdated(c)),
      );
      add(const _Subscribe());
    });
    on<PasswordsQueryChanged>((e, emit) {
      emit(
        state.copyWith(
          filter: PasswordFilter(
            query: e.query,
            category: state.filter.category,
            favouritesOnly: state.filter.favouritesOnly,
          ),
        ),
      );
      add(const _Subscribe());
    }, transformer: debounceRestartable());
    on<PasswordsFilterSelected>((e, emit) {
      emit(
        state.copyWith(
          filter: PasswordFilter(
            query: state.filter.query,
            category: e.category,
            favouritesOnly: e.favourites,
          ),
        ),
      );
      add(const _Subscribe());
    });
    on<_Subscribe>(
      (_, emit) => emit.forEach<List<PasswordNote>>(
        _repository.watch(state.filter),
        onData: (notes) =>
            state.copyWith(notes: notes, status: LoadStatus.ready),
        onError: (_, _) => state.copyWith(status: LoadStatus.failure),
      ),
      transformer: restartable(),
    );
    on<_CategoriesUpdated>((e, emit) {
      // A category filter for a category that no longer exists shows nothing.
      final selected = state.filter.category;
      emit(state.copyWith(categories: e.categories));
      if (selected != null && !e.categories.contains(selected)) {
        add(const PasswordsFilterSelected());
      }
    });
    on<PasswordExpanded>(
      (e, emit) => emit(state.copyWith(expandedId: () => e.id)),
    );
    on<PasswordFavouriteToggled>((e, emit) async {
      emit(state.copyWith(clearFailure: true));
      final r = await _repository.setFavourite(e.id, value: e.value);
      if (r case Err(:final failure)) emit(state.copyWith(failure: failure));
    });
    on<PasswordsWarningDismissed>((_, emit) {
      _notices.passwordWarningDismissed = true;
      emit(state.copyWith(warningDismissed: true));
    });
  }

  final PasswordNotesRepository _repository;
  final SessionNotices _notices;
  StreamSubscription<List<String>>? _categorySub;

  @override
  Future<void> close() async {
    await _categorySub?.cancel();
    await super.close();
  }
}

import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/utils/event_transformers.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_details_repository.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';

sealed class PersonalEvent {
  const PersonalEvent();
}

final class PersonalStarted extends PersonalEvent {
  const PersonalStarted();
}

final class PersonalCategorySelected extends PersonalEvent {
  const PersonalCategorySelected(this.category);
  final DetailCategory category;
}

/// Empty query leaves search mode.
final class PersonalQueryChanged extends PersonalEvent {
  const PersonalQueryChanged(this.query);
  final String query;
}

final class _Subscribe extends PersonalEvent {
  const _Subscribe();
}

final class _ProfileUpdated extends PersonalEvent {
  const _ProfileUpdated(this.profile);
  final PersonalEntry? profile;
}

final class PersonalState extends Equatable {
  const PersonalState({
    this.status = LoadStatus.loading,
    this.category = DetailCategory.personal,
    this.profile,
    this.profileLoaded = false,
    this.entries = const [],
    this.query = '',
  });

  final LoadStatus status;
  final DetailCategory category;
  final PersonalEntry? profile;
  final bool profileLoaded;

  /// The selected category's entries, or the search results.
  final List<PersonalEntry> entries;
  final String query;

  bool get searching => query.trim().isNotEmpty;

  PersonalState copyWith({
    LoadStatus? status,
    DetailCategory? category,
    PersonalEntry? Function()? profile,
    bool? profileLoaded,
    List<PersonalEntry>? entries,
    String? query,
  }) => PersonalState(
    status: status ?? this.status,
    category: category ?? this.category,
    profile: profile != null ? profile() : this.profile,
    profileLoaded: profileLoaded ?? this.profileLoaded,
    entries: entries ?? this.entries,
    query: query ?? this.query,
  );

  @override
  List<Object?> get props => [
    status,
    category,
    profile,
    profileLoaded,
    entries,
    query,
  ];
}

class PersonalBloc extends Bloc<PersonalEvent, PersonalState> {
  PersonalBloc(this._repository) : super(const PersonalState()) {
    on<PersonalStarted>((_, _) {
      _profileSub ??= _repository.watchProfile().listen(
        (p) => add(_ProfileUpdated(p)),
      );
      add(const _Subscribe());
    });
    on<PersonalCategorySelected>((e, emit) {
      if (e.category == state.category) return;
      emit(
        state.copyWith(
          category: e.category,
          status: LoadStatus.loading,
          entries: const [],
        ),
      );
      add(const _Subscribe());
    });
    on<PersonalQueryChanged>((e, emit) {
      emit(state.copyWith(query: e.query));
      add(const _Subscribe());
    }, transformer: debounceRestartable());
    on<_Subscribe>((_, emit) {
      final stream = state.searching
          ? _repository.search(state.query)
          // The Personal tab shows the profile itself, not a list.
          : state.category == DetailCategory.personal
          ? Stream.value(const <PersonalEntry>[])
          : _repository.watchCategory(state.category);
      return emit.forEach<List<PersonalEntry>>(
        stream,
        onData: (list) =>
            state.copyWith(entries: list, status: LoadStatus.ready),
        onError: (_, _) => state.copyWith(status: LoadStatus.failure),
      );
    }, transformer: restartable());
    on<_ProfileUpdated>(
      (e, emit) =>
          emit(state.copyWith(profile: () => e.profile, profileLoaded: true)),
    );
  }

  final PersonalDetailsRepository _repository;
  StreamSubscription<PersonalEntry?>? _profileSub;

  @override
  Future<void> close() async {
    await _profileSub?.cancel();
    await super.close();
  }
}

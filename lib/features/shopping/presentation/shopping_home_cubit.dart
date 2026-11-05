import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';

final class ShoppingHomeState extends Equatable {
  const ShoppingHomeState({
    this.loading = true,
    this.active,
    this.drafts = const [],
    this.history = const [],
    this.failure,
    this.started,
  });

  final bool loading;
  final ShoppingList? active;
  final List<ShoppingList> drafts;
  final List<ShoppingList> history;
  final Failure? failure;

  /// Set after a session was started or resumed, to open the session page.
  final String? started;

  ShoppingHomeState copyWith({
    bool? loading,
    ShoppingList? Function()? active,
    List<ShoppingList>? drafts,
    List<ShoppingList>? history,
    Failure? failure,
    String? started,
    bool clearTransient = false,
  }) => ShoppingHomeState(
    loading: loading ?? this.loading,
    active: active != null ? active() : this.active,
    drafts: drafts ?? this.drafts,
    history: history ?? this.history,
    failure: clearTransient ? null : (failure ?? this.failure),
    started: clearTransient ? null : (started ?? this.started),
  );

  @override
  List<Object?> get props => [
    loading,
    active,
    drafts,
    history,
    failure,
    started,
  ];
}

class ShoppingHomeCubit extends Cubit<ShoppingHomeState> {
  ShoppingHomeCubit(this._repository) : super(const ShoppingHomeState());

  final ShoppingRepository _repository;
  final _subs = <StreamSubscription<Object?>>[];

  void start() {
    if (_subs.isNotEmpty) return;
    // Loading ends once each of the three streams has delivered once.
    final seen = <int>{};
    void on<T>(int n, Stream<T> stream, ShoppingHomeState Function(T) next) =>
        _subs.add(
          stream.listen((v) {
            seen.add(n);
            emit(next(v).copyWith(loading: seen.length < 3));
          }),
        );

    on(0, _repository.watchActive(), (a) => state.copyWith(active: () => a));
    on(1, _repository.watchDrafts(), (d) => state.copyWith(drafts: d));
    on(2, _repository.watchHistory(), (h) => state.copyWith(history: h));
  }

  /// Starts a saved list. Fails with [ConflictFailure] while another
  /// session is in progress.
  Future<void> startDraft(String listId) async {
    emit(state.copyWith(clearTransient: true));
    final r = await _repository.startSession(listId);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(failure: f),
        (_) => state.copyWith(started: listId),
      ),
    );
  }

  Future<void> resume() async {
    final a = state.active;
    if (a == null) return;
    emit(state.copyWith(clearTransient: true));
    final r = await _repository.resumeSession(a.id);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(failure: f),
        (_) => state.copyWith(started: a.id),
      ),
    );
  }

  Future<void> deleteDraft(String listId) async {
    emit(state.copyWith(clearTransient: true));
    final r = await _repository.deleteList(listId);
    if (r case Err(:final failure)) emit(state.copyWith(failure: failure));
  }

  void clearTransient() => emit(state.copyWith(clearTransient: true));

  @override
  Future<void> close() async {
    for (final s in _subs) {
      await s.cancel();
    }
    await super.close();
  }
}

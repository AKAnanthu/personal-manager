import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';

final class SessionState extends Equatable {
  const SessionState({
    this.loading = true,
    this.list,
    this.failure,
    this.paused = false,
  });

  final bool loading;

  /// The active list; null once there is none (finished elsewhere).
  final ShoppingList? list;
  final Failure? failure;

  /// "Continue later" done; the page closes.
  final bool paused;

  SessionState copyWith({
    bool? loading,
    ShoppingList? Function()? list,
    Failure? failure,
    bool clearFailure = false,
    bool? paused,
  }) => SessionState(
    loading: loading ?? this.loading,
    list: list != null ? list() : this.list,
    failure: clearFailure ? null : (failure ?? this.failure),
    paused: paused ?? this.paused,
  );

  @override
  List<Object?> get props => [loading, list, failure, paused];
}

/// The shopping screen: tick items off, add or edit them on the way.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._repository) : super(const SessionState());

  final ShoppingRepository _repository;
  StreamSubscription<ShoppingList?>? _sub;

  /// Opening the screen (also from the notification) resumes the session.
  void start() {
    _sub ??= _repository.watchActive().listen((l) {
      final wasLoading = state.loading;
      emit(state.copyWith(loading: false, list: () => l));
      if (wasLoading && l != null && l.pausedAt != null) {
        unawaited(_run(() => _repository.resumeSession(l.id)));
      }
    });
  }

  Future<void> toggle(ShoppingItem item) =>
      _run(() => _repository.setPurchased(item.id, value: !item.isPurchased));

  Future<void> addItem(ItemDraft item) async {
    final l = state.list;
    if (l != null) await _run(() => _repository.addItem(l.id, item));
  }

  Future<void> updateItem(String itemId, ItemDraft item) =>
      _run(() => _repository.updateItem(itemId, item));

  Future<void> removeItem(String itemId) =>
      _run(() => _repository.removeItem(itemId));

  /// "Continue later": one notification listing what's left.
  Future<void> continueLater() async {
    final l = state.list;
    if (l == null) return;
    final r = await _repository.pauseSession(l.id);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(failure: f),
        (_) => state.copyWith(paused: true),
      ),
    );
  }

  Future<void> _run(Future<Result<void>> Function() action) async {
    emit(state.copyWith(clearFailure: true));
    final r = await action();
    if (isClosed) return;
    if (r case Err(:final failure)) emit(state.copyWith(failure: failure));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await super.close();
  }
}

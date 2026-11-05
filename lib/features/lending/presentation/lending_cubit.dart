import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';
import 'package:personal_life_manager/features/lending/domain/lending_repository.dart';

final class LendingState extends Equatable {
  const LendingState({
    this.direction = LendingDirection.lent,
    this.tab,
    this.failure,
  });

  final LendingDirection direction;

  /// Null while the selected tab loads.
  final LendingTab? tab;
  final Failure? failure;

  LendingState copyWith({
    LendingDirection? direction,
    LendingTab? Function()? tab,
    Failure? failure,
    bool clearFailure = false,
  }) => LendingState(
    direction: direction ?? this.direction,
    tab: tab != null ? tab() : this.tab,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [direction, tab, failure];
}

class LendingCubit extends Cubit<LendingState> {
  LendingCubit(this._repository) : super(const LendingState());

  final LendingRepository _repository;
  StreamSubscription<LendingTab>? _sub;

  void start() => _watch();

  void select(LendingDirection d) {
    if (d == state.direction) return;
    emit(state.copyWith(direction: d, tab: () => null, clearFailure: true));
    _watch();
  }

  void _watch() {
    unawaited(_sub?.cancel());
    final d = state.direction;
    _sub = _repository
        .watchTab(d)
        .listen(
          (t) {
            if (state.direction == d) emit(state.copyWith(tab: () => t));
          },
          onError: (Object _) {
            emit(state.copyWith(failure: const DatabaseFailure()));
          },
        );
  }

  /// "Mark repaid" / "Mark pending".
  Future<void> setStatus(LendingRecord r, LendingStatus status) async {
    emit(state.copyWith(clearFailure: true));
    final result = await _repository.setStatus(r.id, status);
    if (isClosed) return;
    if (result case Err(:final failure)) {
      emit(state.copyWith(failure: failure));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await super.close();
  }
}

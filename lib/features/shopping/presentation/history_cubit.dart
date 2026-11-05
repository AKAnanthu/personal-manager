import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';

final class HistoryState extends Equatable {
  const HistoryState({
    this.loading = true,
    this.list,
    this.failure,
    this.deleted = false,
  });

  final bool loading;
  final ShoppingList? list;
  final Failure? failure;
  final bool deleted;

  HistoryState copyWith({
    bool? loading,
    ShoppingList? Function()? list,
    Failure? failure,
    bool clearFailure = false,
    bool? deleted,
  }) => HistoryState(
    loading: loading ?? this.loading,
    list: list != null ? list() : this.list,
    failure: clearFailure ? null : (failure ?? this.failure),
    deleted: deleted ?? this.deleted,
  );

  @override
  List<Object?> get props => [loading, list, failure, deleted];
}

/// A completed list in history: details, receipt, delete.
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({required this._repository, required this.listId})
    : super(const HistoryState());

  final ShoppingRepository _repository;
  final String listId;
  StreamSubscription<ShoppingList?>? _sub;

  void start() {
    _sub ??= _repository.watchList(listId).listen((l) {
      if (l == null && state.list != null) {
        emit(state.copyWith(deleted: true));
        return;
      }
      emit(
        state.copyWith(
          loading: false,
          list: () => l,
          failure: l == null ? const NotFoundFailure() : null,
        ),
      );
    });
  }

  Future<Result<File>> receiptFile(Receipt r) => _repository.receiptFile(r);

  Future<void> delete({required bool deleteExpense}) async {
    final r = await _repository.deleteList(
      listId,
      deleteExpense: deleteExpense,
    );
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(failure: f),
        (_) => state.copyWith(deleted: true),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await super.close();
  }
}

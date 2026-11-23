import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:personal_life_manager/core/drive/drive_copier.dart';
import 'package:personal_life_manager/core/drive/drive_folders.dart';
import 'package:personal_life_manager/core/drive/drive_models.dart';
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
    this.receiptUploading = false,
    this.receiptSaved = false,
  });

  final bool loading;
  final ShoppingList? list;
  final Failure? failure;
  final bool deleted;
  final bool receiptUploading;

  /// A copy just went to Drive (shown once).
  final bool receiptSaved;

  HistoryState copyWith({
    bool? loading,
    ShoppingList? Function()? list,
    Failure? failure,
    bool clearFailure = false,
    bool? deleted,
    bool? receiptUploading,
    bool? receiptSaved,
  }) => HistoryState(
    receiptUploading: receiptUploading ?? this.receiptUploading,
    receiptSaved: receiptSaved ?? false,
    loading: loading ?? this.loading,
    list: list != null ? list() : this.list,
    failure: clearFailure ? null : (failure ?? this.failure),
    deleted: deleted ?? this.deleted,
  );

  @override
  List<Object?> get props => [
    loading,
    list,
    failure,
    deleted,
    receiptUploading,
    receiptSaved,
  ];
}

/// A completed list in history: details, receipt, delete.
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({required this._repository, required this.listId, this._drive})
    : super(const HistoryState());

  final ShoppingRepository _repository;
  final String listId;
  final DriveCopier? _drive;

  bool get driveAvailable => _drive != null;

  static final _day = DateFormat('yyyy-MM-dd');
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

  /// A copy of the receipt into Drive's `Receipts/` folder, named by the
  /// trip's date so copies sort in order.
  Future<void> saveReceiptToDrive() async {
    final drive = _drive;
    final list = state.list;
    final receipt = list?.receipt;
    if (drive == null || list == null || receipt == null) return;
    if (state.receiptUploading) return;
    emit(state.copyWith(receiptUploading: true, clearFailure: true));
    final file = await _repository.receiptFile(receipt);
    final r = switch (file) {
      Err(:final failure) => Err<DriveItem?>(failure),
      Ok(:final value) => await drive.copy(
        value,
        folder: DriveLayout.receiptsFolder,
        name:
            '${_day.format(list.purchasedOn ?? list.updatedAt)} '
            '${receipt.originalName}',
        mimeType: receipt.fileType.mimeType,
      ),
    };
    if (isClosed) return;
    emit(switch (r) {
      Ok(:final value) => state.copyWith(
        receiptUploading: false,
        receiptSaved: value != null,
      ),
      Err(:final failure) => state.copyWith(
        receiptUploading: false,
        failure: failure,
      ),
    });
  }

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

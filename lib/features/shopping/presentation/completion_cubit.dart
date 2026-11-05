import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/storage/file_access.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/utils/money.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';

/// The receipt on the form: the saved one or a newly picked file.
final class ReceiptChoice extends Equatable {
  const ReceiptChoice({required this.name, required this.type, this.picked});

  final String name;
  final SupportedFileType type;
  final PickedFile? picked;

  @override
  List<Object?> get props => [name, type, picked?.file.path];
}

final class CompletionState extends Equatable {
  const CompletionState({
    this.loading = true,
    this.list,
    this.totalText = '',
    this.store = '',
    this.payment,
    this.purchasedOn,
    this.receipt,
    this.receiptRemoved = false,
    this.dirty = false,
    this.busy = false,
    this.picking = false,
    this.showErrors = false,
    this.failure,
    this.outcome = EditorOutcome.none,
  });

  final bool loading;
  final ShoppingList? list;
  final String totalText;
  final String store;
  final PaymentMethod? payment;
  final DateTime? purchasedOn;
  final ReceiptChoice? receipt;
  final bool receiptRemoved;
  final bool dirty;
  final bool busy;
  final bool picking;
  final bool showErrors;
  final Failure? failure;
  final EditorOutcome outcome;

  bool get editing => list?.status == ShoppingListStatus.completed;

  /// Paise; null unless a valid amount above zero.
  int? get totalPaise {
    final v = Money.parseRupees(totalText);
    return v != null && v > 0 ? v : null;
  }

  CompletionState copyWith({
    bool? loading,
    ShoppingList? list,
    String? totalText,
    String? store,
    PaymentMethod? Function()? payment,
    DateTime? purchasedOn,
    ReceiptChoice? Function()? receipt,
    bool? receiptRemoved,
    bool? dirty,
    bool? busy,
    bool? picking,
    bool? showErrors,
    Failure? failure,
    bool clearFailure = false,
    EditorOutcome? outcome,
  }) => CompletionState(
    loading: loading ?? this.loading,
    list: list ?? this.list,
    totalText: totalText ?? this.totalText,
    store: store ?? this.store,
    payment: payment != null ? payment() : this.payment,
    purchasedOn: purchasedOn ?? this.purchasedOn,
    receipt: receipt != null ? receipt() : this.receipt,
    receiptRemoved: receiptRemoved ?? this.receiptRemoved,
    dirty: dirty ?? this.dirty,
    busy: busy ?? this.busy,
    picking: picking ?? this.picking,
    showErrors: showErrors ?? this.showErrors,
    failure: clearFailure ? null : (failure ?? this.failure),
    outcome: outcome ?? this.outcome,
  );

  @override
  List<Object?> get props => [
    loading,
    list,
    totalText,
    store,
    payment,
    purchasedOn,
    receipt,
    receiptRemoved,
    dirty,
    busy,
    picking,
    showErrors,
    failure,
    outcome,
  ];
}

/// "Finish shopping" for the active list, or editing a completed one.
class CompletionCubit extends Cubit<CompletionState> {
  CompletionCubit({
    required this._repository,
    required this._pickers,
    required this.listId,
    this._clock = DateTime.now,
  }) : super(const CompletionState());

  final ShoppingRepository _repository;
  final FilePickers _pickers;
  final String listId;
  final DateTime Function() _clock;

  Future<void> load() async {
    final l = await _repository.watchList(listId).first;
    if (isClosed) return;
    if (l == null) {
      emit(state.copyWith(loading: false, failure: const NotFoundFailure()));
      return;
    }
    final now = _clock();
    final total = l.totalPaise;
    final receipt = l.receipt;
    emit(
      state.copyWith(
        loading: false,
        list: l,
        totalText: total == null ? '' : Money.toInput(total),
        store: l.store,
        payment: () => l.paymentMethod,
        purchasedOn: l.purchasedOn ?? DateTime(now.year, now.month, now.day),
        receipt: () => receipt == null
            ? null
            : ReceiptChoice(name: receipt.originalName, type: receipt.fileType),
      ),
    );
  }

  void totalChanged(String v) =>
      emit(state.copyWith(totalText: v, dirty: true));
  void storeChanged(String v) => emit(state.copyWith(store: v, dirty: true));

  /// Tapping the selected method clears it (it's optional).
  void paymentToggled(PaymentMethod m) => emit(
    state.copyWith(payment: () => state.payment == m ? null : m, dirty: true),
  );

  void dateChanged(DateTime d) =>
      emit(state.copyWith(purchasedOn: d, dirty: true));

  Future<void> takePhoto() => _pick(_pickers.takePhoto);
  Future<void> choosePhoto() => _pick(_pickers.choosePhoto);
  Future<void> chooseFile() => _pick(_pickers.chooseDocument);

  void removeReceipt() => emit(
    state.copyWith(receipt: () => null, receiptRemoved: true, dirty: true),
  );

  /// Receipts are images or PDFs only.
  Future<void> _pick(Future<PickedFile?> Function() pick) async {
    if (state.picking) return;
    emit(state.copyWith(picking: true, clearFailure: true));
    final p = await pick();
    if (isClosed) return;
    if (p == null) {
      emit(state.copyWith(picking: false));
      return;
    }
    final check = await FileTypeValidator.check(p.file, originalName: p.name);
    if (isClosed) return;
    switch (check) {
      case FileAccepted(:final type) when type.hasInAppPreview:
        emit(
          state.copyWith(
            picking: false,
            dirty: true,
            receipt: () => ReceiptChoice(name: p.name, type: type, picked: p),
          ),
        );
      case FileTooLarge(:final maxBytes):
        emit(
          state.copyWith(
            picking: false,
            failure: FileTooLargeFailure(maxBytes),
          ),
        );
      case FileAccepted() || FileUnsupported():
        emit(
          state.copyWith(
            picking: false,
            failure: const UnsupportedFileFailure('receipt'),
          ),
        );
    }
  }

  Future<void> save() async {
    if (state.busy || state.picking) return;
    final total = state.totalPaise;
    final date = state.purchasedOn;
    final l = state.list;
    if (total == null || date == null || l == null) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(busy: true, clearFailure: true));
    final completion = Completion(
      totalPaise: total,
      purchasedOn: date,
      store: state.store,
      paymentMethod: state.payment,
    );
    final picked = state.receipt?.picked;
    final r = state.editing
        ? await _repository.updateCompletion(
            l.id,
            completion,
            receipt: picked?.file,
            receiptName: picked?.name,
            removeReceipt: state.receiptRemoved && picked == null,
          )
        : await _repository.complete(
            l.id,
            completion,
            receipt: picked?.file,
            receiptName: picked?.name,
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

  void clearFailure() => emit(state.copyWith(clearFailure: true));
}

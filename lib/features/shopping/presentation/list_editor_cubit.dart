import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_parser.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';

/// An editable item row. [key] is local and stable for list rendering.
final class EditRow extends Equatable {
  const EditRow({
    required this.key,
    required this.name,
    this.id,
    this.quantity = '',
    this.unit = '',
  });

  final int key;
  final String? id;
  final String name;
  final String quantity;
  final String unit;

  /// Empty is allowed; anything typed must be a positive number.
  bool get quantityInvalid =>
      quantity.trim().isNotEmpty &&
      ShoppingParser.quantityValue(quantity) == null;

  EditRow copyWith({String? name, String? quantity, String? unit}) => EditRow(
    key: key,
    id: id,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
  );

  @override
  List<Object?> get props => [key, id, name, quantity, unit];
}

enum ListEditorOutcome { none, saved, started }

final class ListEditorState extends Equatable {
  const ListEditorState({
    this.loading = true,
    this.listId,
    this.name = '',
    this.rows = const [],
    this.copiedFrom,
    this.dirty = false,
    this.busy = false,
    this.showErrors = false,
    this.failure,
    this.outcome = ListEditorOutcome.none,
  });

  final bool loading;
  final String? listId;
  final String name;
  final List<EditRow> rows;

  /// The previous list this one was copied from ("Reuse").
  final ShoppingList? copiedFrom;
  final bool dirty;
  final bool busy;
  final bool showErrors;
  final Failure? failure;
  final ListEditorOutcome outcome;

  bool get nameMissing => name.trim().isEmpty;
  List<EditRow> get filledRows =>
      rows.where((r) => r.name.trim().isNotEmpty).toList();
  bool get itemsMissing => filledRows.isEmpty;
  bool get hasErrors =>
      nameMissing || itemsMissing || rows.any((r) => r.quantityInvalid);

  ListEditorState copyWith({
    bool? loading,
    String? listId,
    String? name,
    List<EditRow>? rows,
    ShoppingList? copiedFrom,
    bool? dirty,
    bool? busy,
    bool? showErrors,
    Failure? failure,
    bool clearFailure = false,
    ListEditorOutcome? outcome,
  }) => ListEditorState(
    loading: loading ?? this.loading,
    listId: listId ?? this.listId,
    name: name ?? this.name,
    rows: rows ?? this.rows,
    copiedFrom: copiedFrom ?? this.copiedFrom,
    dirty: dirty ?? this.dirty,
    busy: busy ?? this.busy,
    showErrors: showErrors ?? this.showErrors,
    failure: clearFailure ? null : (failure ?? this.failure),
    outcome: outcome ?? this.outcome,
  );

  @override
  List<Object?> get props => [
    loading,
    listId,
    name,
    rows,
    copiedFrom,
    dirty,
    busy,
    showErrors,
    failure,
    outcome,
  ];
}

/// Create a list by typing, edit a saved one ([listId]), or start from a
/// copy of a previous list ([copyFromId]); then save it or start shopping.
class ListEditorCubit extends Cubit<ListEditorState> {
  ListEditorCubit({required this._repository, this.listId, this.copyFromId})
    : super(const ListEditorState());

  final ShoppingRepository _repository;
  final String? listId;
  final String? copyFromId;
  int _nextKey = 0;

  Future<void> load({String defaultName = ''}) async {
    final id = listId ?? copyFromId;
    final source = id == null ? null : await _repository.watchList(id).first;
    if (isClosed) return;
    if (id != null && source == null) {
      emit(state.copyWith(loading: false, failure: const NotFoundFailure()));
      return;
    }
    final copying = listId == null && source != null;
    emit(
      state.copyWith(
        loading: false,
        listId: listId,
        name: source?.name ?? defaultName,
        copiedFrom: copying ? source : null,
        rows: [
          for (final i in source?.items ?? const <ShoppingItem>[])
            EditRow(
              key: _nextKey++,
              // A copy gets new items; an edit keeps their ids.
              id: copying ? null : i.id,
              name: i.name,
              quantity: i.quantity,
              unit: i.unit,
            ),
        ],
      ),
    );
  }

  void nameChanged(String v) => emit(state.copyWith(name: v, dirty: true));

  void rowChanged(int key, {String? name, String? quantity, String? unit}) =>
      emit(
        state.copyWith(
          rows: [
            for (final r in state.rows)
              if (r.key == key)
                r.copyWith(name: name, quantity: quantity, unit: unit)
              else
                r,
          ],
          dirty: true,
        ),
      );

  void removeRow(int key) => emit(
    state.copyWith(
      rows: state.rows.where((r) => r.key != key).toList(),
      dirty: true,
    ),
  );

  /// The "Add an item" row. Several pasted lines become several items; a
  /// single "rice 5 kg" is split into name, quantity and unit.
  void addFromInput(String text, {String quantity = ''}) {
    final added = <EditRow>[];
    if (text.contains('\n')) {
      for (final p in ShoppingParser.parse(text)) {
        added.add(_rowFrom(p));
      }
    } else if (quantity.trim().isEmpty) {
      if (ShoppingParser.parseOne(text) case final p?) added.add(_rowFrom(p));
    } else if (text.trim().isNotEmpty) {
      added.add(
        EditRow(
          key: _nextKey++,
          name: text.trim(),
          quantity: ShoppingParser.normaliseQuantity(quantity) ?? quantity,
        ),
      );
    }
    if (added.isEmpty) return;
    emit(state.copyWith(rows: [...state.rows, ...added], dirty: true));
  }

  EditRow _rowFrom(ParsedItem p) => EditRow(
    key: _nextKey++,
    name: p.name,
    quantity: p.quantity ?? '',
    unit: p.unit ?? '',
  );

  Future<void> saveForLater() => _save(start: false);

  Future<void> startShopping() => _save(start: true);

  Future<void> _save({required bool start}) async {
    if (state.busy) return;
    if (state.hasErrors) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(busy: true, clearFailure: true));
    final saved = await _repository.saveList(
      ListDraft(
        id: state.listId,
        name: state.name,
        copiedFromId: state.copiedFrom?.id,
        items: [
          for (final r in state.filledRows)
            ItemDraft(
              id: r.id,
              name: r.name,
              quantity: ShoppingParser.normaliseQuantity(r.quantity) ?? '',
              unit: r.unit,
            ),
        ],
      ),
    );
    if (isClosed) return;
    final String id;
    switch (saved) {
      case Err(:final failure):
        emit(state.copyWith(busy: false, failure: failure));
        return;
      case Ok(:final value):
        id = value;
    }
    // Saved: from here on this is an edit of that list.
    emit(state.copyWith(listId: id, dirty: false));
    if (!start) {
      emit(state.copyWith(busy: false, outcome: ListEditorOutcome.saved));
      return;
    }
    final r = await _repository.startSession(id);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(busy: false, failure: f),
        (_) => state.copyWith(busy: false, outcome: ListEditorOutcome.started),
      ),
    );
  }

  void clearFailure() => emit(state.copyWith(clearFailure: true));
}

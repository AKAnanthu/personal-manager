import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_parser.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';

/// A parsed line under review.
final class ReviewRow extends Equatable {
  const ReviewRow({
    required this.key,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.flagged,
    required this.line,
  });

  final int key;
  final String name;
  final String quantity;
  final String unit;

  /// The parser couldn't find a clear quantity; stays highlighted.
  final bool flagged;
  final String line;

  bool get quantityValid => ShoppingParser.quantityValue(quantity) != null;

  /// Every row needs a name and a confirmed quantity before import.
  bool get ready => name.trim().isNotEmpty && quantityValid;

  ReviewRow copyWith({String? name, String? quantity, String? unit}) =>
      ReviewRow(
        key: key,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        flagged: flagged,
        line: line,
      );

  @override
  List<Object?> get props => [key, name, quantity, unit, flagged, line];
}

/// Rows sharing a name (ignoring case). Merging is offered, never automatic.
final class DuplicateGroup extends Equatable {
  const DuplicateGroup(this.name, this.keys, {required this.mergeable});

  final String name;
  final List<int> keys;

  /// Same unit and numeric quantities, so they can be added up.
  final bool mergeable;

  @override
  List<Object?> get props => [name, keys, mergeable];
}

final class ImportState extends Equatable {
  const ImportState({
    this.text = '',
    this.rows = const [],
    this.busy = false,
    this.failure,
    this.savedListId,
  });

  final String text;
  final List<ReviewRow> rows;
  final bool busy;
  final Failure? failure;
  final String? savedListId;

  bool get parsed => text.trim().isNotEmpty;
  int get unresolved => rows.where((r) => !r.ready).length;
  bool get canImport => rows.isNotEmpty && unresolved == 0;

  List<DuplicateGroup> get duplicates {
    final byName = <String, List<ReviewRow>>{};
    for (final r in rows) {
      final k = r.name.trim().toLowerCase();
      if (k.isNotEmpty) (byName[k] ??= []).add(r);
    }
    return [
      for (final group in byName.values)
        if (group.length > 1)
          DuplicateGroup(
            group.first.name.trim(),
            [for (final r in group) r.key],
            mergeable:
                group.every((r) => r.quantityValid) &&
                group.map((r) => r.unit.trim().toLowerCase()).toSet().length ==
                    1,
          ),
    ];
  }

  ImportState copyWith({
    String? text,
    List<ReviewRow>? rows,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
    String? savedListId,
  }) => ImportState(
    text: text ?? this.text,
    rows: rows ?? this.rows,
    busy: busy ?? this.busy,
    failure: clearFailure ? null : (failure ?? this.failure),
    savedListId: savedListId ?? this.savedListId,
  );

  @override
  List<Object?> get props => [text, rows, busy, failure, savedListId];
}

/// Paste → review → import. Only the text the user pastes is read.
class ImportCubit extends Cubit<ImportState> {
  ImportCubit(this._repository) : super(const ImportState());

  final ShoppingRepository _repository;
  int _nextKey = 0;

  /// Parses a (new) pasted message; replaces the rows under review.
  void textPasted(String text) => emit(
    state.copyWith(
      text: text,
      rows: [
        for (final p in ShoppingParser.parse(text))
          ReviewRow(
            key: _nextKey++,
            name: p.name,
            quantity: p.quantity ?? '',
            unit: p.unit ?? '',
            flagged: p.needsReview,
            line: p.line,
          ),
      ],
    ),
  );

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
        ),
      );

  void removeRow(int key) => emit(
    state.copyWith(rows: state.rows.where((r) => r.key != key).toList()),
  );

  /// Adds the group's quantities into its first row, after the user
  /// confirmed the merge.
  void merge(DuplicateGroup group) {
    if (!group.mergeable) return;
    final rows = [
      for (final k in group.keys) state.rows.firstWhere((r) => r.key == k),
    ];
    var total = rows.first.quantity;
    for (final r in rows.skip(1)) {
      total = ShoppingParser.addQuantities(total, r.quantity) ?? total;
    }
    final drop = group.keys.skip(1).toSet();
    emit(
      state.copyWith(
        rows: [
          for (final r in state.rows)
            if (r.key == group.keys.first)
              r.copyWith(quantity: total)
            else if (!drop.contains(r.key))
              r,
        ],
      ),
    );
  }

  /// Saves the reviewed items as a new list (opened next for editing).
  Future<void> confirm({required String listName}) async {
    if (!state.canImport || state.busy) return;
    emit(state.copyWith(busy: true, clearFailure: true));
    final r = await _repository.saveList(
      ListDraft(
        name: listName,
        items: [
          for (final row in state.rows)
            ItemDraft(
              name: row.name,
              quantity: ShoppingParser.normaliseQuantity(row.quantity) ?? '',
              unit: row.unit,
            ),
        ],
      ),
    );
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(busy: false, failure: f),
        (id) => state.copyWith(busy: false, savedListId: id),
      ),
    );
  }
}

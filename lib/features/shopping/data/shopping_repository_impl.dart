import 'dart:io';

import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/db/db_guard.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/storage/validated_import.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';
import 'package:uuid/uuid.dart';

final class ShoppingRepositoryImpl implements ShoppingRepository {
  ShoppingRepositoryImpl({
    required this._db,
    required this._files,
    required this._notice,
    this._uuid = const Uuid(),
    this._clock = DateTime.now,
  });

  final AppDatabase _db;
  final FileStore _files;
  final PendingShoppingNotice _notice;
  final Uuid _uuid;
  final DateTime Function() _clock;

  $ShoppingListsTable get _l => _db.shoppingLists;
  $ShoppingItemsTable get _i => _db.shoppingItems;
  $ExpensesTable get _e => _db.expenses;

  // ---- reads ---------------------------------------------------------

  /// Re-runs [load] whenever lists or items change (data sets are small).
  Stream<T> _watch<T>(Future<T> Function() load) => _db
      .customSelect('SELECT 1', readsFrom: {_l, _i})
      .watch()
      .asyncMap((_) => load());

  Future<List<ShoppingList>> _lists(
    Expression<bool> Function($ShoppingListsTable) where,
    List<OrderingTerm Function($ShoppingListsTable)> order,
  ) async {
    final rows =
        await (_db.select(_l)
              ..where(where)
              ..orderBy(order))
            .get();
    if (rows.isEmpty) return const [];
    final items =
        await (_db.select(_i)
              ..where((i) => i.listId.isIn([for (final r in rows) r.id]))
              ..orderBy([(i) => OrderingTerm.asc(i.position)]))
            .get();
    final byList = <String, List<ShoppingItem>>{};
    for (final i in items) {
      (byList[i.listId] ??= []).add(_item(i));
    }
    return [for (final r in rows) _list(r, byList[r.id] ?? const [])];
  }

  @override
  Stream<ShoppingList?> watchActive() => _watch(
    () async => (await _lists(
      (l) => l.status.equalsValue(ShoppingListStatus.active),
      const [],
    )).firstOrNull,
  );

  @override
  Stream<List<ShoppingList>> watchDrafts() => _watch(
    () => _lists((l) => l.status.equalsValue(ShoppingListStatus.draft), [
      (l) => OrderingTerm.desc(l.updatedAt),
    ]),
  );

  @override
  Stream<List<ShoppingList>> watchHistory() => _watch(
    () => _lists((l) => l.status.equalsValue(ShoppingListStatus.completed), [
      (l) => OrderingTerm.desc(l.purchasedOn),
      (l) => OrderingTerm.desc(l.updatedAt),
    ]),
  );

  @override
  Stream<ShoppingList?> watchList(String id) => _watch(
    () async => (await _lists((l) => l.id.equals(id), const [])).firstOrNull,
  );

  // ---- lists ---------------------------------------------------------

  @override
  Future<Result<String>> saveList(ListDraft draft) => dbGuard(
    () => _db.transaction(() async {
      final now = _clock();
      final name = draft.name.trim();
      if (name.isEmpty) throw const FailWith(ValidationFailure('no name'));
      var id = draft.id;
      if (id == null) {
        id = _uuid.v4();
        await _db
            .into(_l)
            .insert(
              ShoppingListsCompanion.insert(
                id: id,
                name: name,
                status: ShoppingListStatus.draft,
                copiedFromId: Value(draft.copiedFromId),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        final target = id;
        final n = await (_db.update(_l)..where((l) => l.id.equals(target)))
            .write(
              ShoppingListsCompanion(name: Value(name), updatedAt: Value(now)),
            );
        if (n == 0) throw const RecordNotFound();
      }
      await _replaceItems(id, draft.items, now);
      return id;
    }),
  );

  /// Keeps ids of edited items, inserts new ones, removes dropped ones.
  Future<void> _replaceItems(
    String listId,
    List<ItemDraft> items,
    DateTime now,
  ) async {
    final keep = {for (final i in items) ?i.id};
    await (_db.delete(
      _i,
    )..where((i) => i.listId.equals(listId) & i.id.isNotIn(keep))).go();
    var position = 0;
    for (final d in items) {
      final name = d.name.trim();
      if (name.isEmpty) continue;
      final companion = ShoppingItemsCompanion(
        listId: Value(listId),
        name: Value(name),
        quantity: Value(d.quantity.trim()),
        unit: Value(d.unit.trim()),
        isPurchased: Value(d.isPurchased),
        position: Value(position++),
        updatedAt: Value(now),
      );
      final id = d.id;
      if (id != null) {
        final n =
            await (_db.update(_i)
                  ..where((i) => i.id.equals(id) & i.listId.equals(listId)))
                .write(companion);
        if (n > 0) continue;
      }
      await _db
          .into(_i)
          .insert(
            companion.copyWith(id: Value(_uuid.v4()), createdAt: Value(now)),
          );
    }
  }

  // ---- session -------------------------------------------------------

  @override
  Future<Result<void>> startSession(String listId) async {
    final r = await dbGuard(
      () => _db.transaction(() async {
        final active =
            await (_db.select(_l)
                  ..where(
                    (l) => l.status.equalsValue(ShoppingListStatus.active),
                  )
                  ..limit(1))
                .getSingleOrNull();
        if (active != null) {
          if (active.id == listId) return;
          throw FailWith(ConflictFailure(active.id));
        }
        final n =
            await (_db.update(_l)..where(
                  (l) =>
                      l.id.equals(listId) &
                      l.status.equalsValue(ShoppingListStatus.draft),
                ))
                .write(
                  ShoppingListsCompanion(
                    status: const Value(ShoppingListStatus.active),
                    startedAt: Value(_clock()),
                    pausedAt: const Value(null),
                    updatedAt: Value(_clock()),
                  ),
                );
        if (n == 0) throw const RecordNotFound();
      }),
    );
    if (r.isSuccess) await _notice.clear(listId);
    return r;
  }

  @override
  Future<Result<void>> pauseSession(String listId) async {
    final r = await _setPaused(listId, _clock());
    if (!r.isSuccess) return r;
    final list = await watchList(listId).first;
    // Exactly one notice for this session, and none if nothing is left.
    if (list != null && list.pending.isNotEmpty) {
      await _notice.show(list);
    } else {
      await _notice.clear(listId);
    }
    return r;
  }

  @override
  Future<Result<void>> resumeSession(String listId) async {
    final r = await _setPaused(listId, null);
    if (r.isSuccess) await _notice.clear(listId);
    return r;
  }

  Future<Result<void>> _setPaused(String listId, DateTime? at) =>
      dbGuard(() async {
        final n =
            await (_db.update(_l)..where(
                  (l) =>
                      l.id.equals(listId) &
                      l.status.equalsValue(ShoppingListStatus.active),
                ))
                .write(
                  ShoppingListsCompanion(
                    pausedAt: Value(at),
                    updatedAt: Value(_clock()),
                  ),
                );
        if (n == 0) throw const RecordNotFound();
      });

  // ---- items ---------------------------------------------------------

  @override
  Future<Result<void>> setPurchased(String itemId, {required bool value}) =>
      _itemWrite(itemId, ShoppingItemsCompanion(isPurchased: Value(value)));

  @override
  Future<Result<void>> updateItem(String itemId, ItemDraft item) {
    final name = item.name.trim();
    if (name.isEmpty) {
      return Future.value(const Err(ValidationFailure('no name')));
    }
    return _itemWrite(
      itemId,
      ShoppingItemsCompanion(
        name: Value(name),
        quantity: Value(item.quantity.trim()),
        unit: Value(item.unit.trim()),
      ),
    );
  }

  Future<Result<void>> _itemWrite(
    String itemId,
    ShoppingItemsCompanion patch,
  ) async {
    final row = await (_db.select(
      _i,
    )..where((i) => i.id.equals(itemId))).getSingleOrNull();
    if (row == null) return const Err(NotFoundFailure());
    final r = await dbGuard(
      () => (_db.update(_i)..where((i) => i.id.equals(itemId))).write(
        patch.copyWith(updatedAt: Value(_clock())),
      ),
    );
    if (r case Err(:final failure)) return Err(failure);
    await _afterItemChange(row.listId);
    return const Ok(null);
  }

  @override
  Future<Result<void>> addItem(String listId, ItemDraft item) async {
    final name = item.name.trim();
    if (name.isEmpty) return const Err(ValidationFailure('no name'));
    final r = await dbGuard(() async {
      final max = _i.position.max();
      final last =
          await (_db.selectOnly(_i)
                ..addColumns([max])
                ..where(_i.listId.equals(listId)))
              .map((r) => r.read(max))
              .getSingle();
      final now = _clock();
      await _db
          .into(_i)
          .insert(
            ShoppingItemsCompanion.insert(
              id: _uuid.v4(),
              listId: listId,
              name: name,
              quantity: Value(item.quantity.trim()),
              unit: Value(item.unit.trim()),
              position: (last ?? -1) + 1,
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
    if (r.isSuccess) await _afterItemChange(listId);
    return r;
  }

  @override
  Future<Result<void>> removeItem(String itemId) async {
    final row = await (_db.select(
      _i,
    )..where((i) => i.id.equals(itemId))).getSingleOrNull();
    if (row == null) return const Ok(null);
    final r = await dbGuard(
      () => (_db.delete(_i)..where((i) => i.id.equals(itemId))).go(),
    );
    if (r case Err(:final failure)) return Err(failure);
    await _afterItemChange(row.listId);
    return const Ok(null);
  }

  /// A paused session's notice must not outlive its pending items.
  Future<void> _afterItemChange(String listId) async {
    final list = await watchList(listId).first;
    if (list == null || list.pausedAt == null) return;
    if (list.pending.isEmpty) await _notice.clear(listId);
  }

  // ---- completion ----------------------------------------------------

  @override
  Future<Result<void>> complete(
    String listId,
    Completion completion, {
    File? receipt,
    String? receiptName,
  }) => _saveCompletion(
    listId,
    completion,
    receipt: receipt,
    receiptName: receiptName,
    allowed: const {ShoppingListStatus.active, ShoppingListStatus.draft},
  );

  @override
  Future<Result<void>> updateCompletion(
    String listId,
    Completion completion, {
    File? receipt,
    String? receiptName,
    bool removeReceipt = false,
  }) => _saveCompletion(
    listId,
    completion,
    receipt: receipt,
    receiptName: receiptName,
    removeReceipt: removeReceipt,
    allowed: const {ShoppingListStatus.completed},
  );

  Future<Result<void>> _saveCompletion(
    String listId,
    Completion c, {
    required Set<ShoppingListStatus> allowed,
    File? receipt,
    String? receiptName,
    bool removeReceipt = false,
  }) async {
    if (c.totalPaise <= 0) return const Err(ValidationFailure('total'));
    final before = await (_db.select(
      _l,
    )..where((l) => l.id.equals(listId))).getSingleOrNull();
    if (before == null || !allowed.contains(before.status)) {
      return const Err(NotFoundFailure());
    }

    ImportedFile? file;
    if (receipt != null) {
      switch (await _files.importValidated(
        receipt,
        originalName: receiptName ?? '',
      )) {
        case Ok(:final value):
          file = value;
        case Err(:final failure):
          return Err(failure);
      }
    }

    final now = _clock();
    final r = await dbGuard(
      () => _db.transaction(() async {
        await (_db.update(_l)..where((l) => l.id.equals(listId))).write(
          ShoppingListsCompanion(
            status: const Value(ShoppingListStatus.completed),
            pausedAt: const Value(null),
            purchasedOn: Value(c.purchasedOn),
            totalPaise: Value(c.totalPaise),
            store: Value(c.store.trim()),
            paymentMethod: Value(c.paymentMethod),
            updatedAt: Value(now),
            receiptKey: file != null
                ? Value(file.key)
                : removeReceipt
                ? const Value(null)
                : const Value.absent(),
            receiptName: file != null
                ? Value(receiptName ?? '')
                : removeReceipt
                ? const Value(null)
                : const Value.absent(),
            receiptType: file != null
                ? Value(file.type)
                : removeReceipt
                ? const Value(null)
                : const Value.absent(),
          ),
        );
        // One expense per shopping trip: the unique (source, sourceId) key
        // turns a repeat into an update, never a second expense.
        await _db
            .into(_e)
            .insert(
              ExpensesCompanion.insert(
                id: _uuid.v4(),
                amountPaise: c.totalPaise,
                description: Value(before.name),
                spentOn: c.purchasedOn,
                source: ExpenseSource.shopping,
                sourceId: Value(listId),
                createdAt: now,
                updatedAt: now,
              ),
              onConflict: DoUpdate(
                (_) => ExpensesCompanion(
                  amountPaise: Value(c.totalPaise),
                  description: Value(before.name),
                  spentOn: Value(c.purchasedOn),
                  updatedAt: Value(now),
                ),
                target: [_e.source, _e.sourceId],
              ),
            );
      }),
    );
    if (!r.isSuccess) {
      if (file != null) await _files.delete(file.key);
      return r;
    }
    final oldKey = before.receiptKey;
    if (oldKey != null && (file != null || removeReceipt)) {
      await _files.delete(oldKey);
    }
    await _notice.clear(listId);
    return const Ok(null);
  }

  @override
  Future<Result<void>> deleteList(
    String listId, {
    bool deleteExpense = false,
  }) async {
    final row = await (_db.select(
      _l,
    )..where((l) => l.id.equals(listId))).getSingleOrNull();
    if (row == null) return const Ok(null);
    final r = await dbGuard(
      () => _db.transaction(() async {
        final expense = _db.update(_e)
          ..where(
            (e) =>
                e.source.equalsValue(ExpenseSource.shopping) &
                e.sourceId.equals(listId),
          );
        if (deleteExpense) {
          await (_db.delete(_e)..where(
                (e) =>
                    e.source.equalsValue(ExpenseSource.shopping) &
                    e.sourceId.equals(listId),
              ))
              .go();
        } else {
          // The money was still spent: keep it as an ordinary expense.
          await expense.write(
            ExpensesCompanion(
              source: const Value(ExpenseSource.manual),
              sourceId: const Value(null),
              updatedAt: Value(_clock()),
            ),
          );
        }
        await (_db.delete(_l)..where((l) => l.id.equals(listId))).go();
      }),
    );
    if (!r.isSuccess) return r;
    if (row.receiptKey case final key?) await _files.delete(key);
    await _notice.clear(listId);
    return const Ok(null);
  }

  @override
  Future<Result<File>> receiptFile(Receipt receipt) =>
      _files.resolve(receipt.fileKey);

  // ---- mapping -------------------------------------------------------

  static ShoppingItem _item(ShoppingItemRow r) => ShoppingItem(
    id: r.id,
    name: r.name,
    quantity: r.quantity,
    unit: r.unit,
    isPurchased: r.isPurchased,
  );

  static ShoppingList _list(ShoppingListRow r, List<ShoppingItem> items) {
    final key = r.receiptKey;
    final type = r.receiptType;
    return ShoppingList(
      id: r.id,
      name: r.name,
      status: r.status,
      items: items,
      copiedFromId: r.copiedFromId,
      startedAt: r.startedAt,
      pausedAt: r.pausedAt,
      purchasedOn: r.purchasedOn,
      totalPaise: r.totalPaise,
      store: r.store,
      paymentMethod: r.paymentMethod,
      receipt: key != null && type != null
          ? Receipt(
              fileKey: key,
              originalName: r.receiptName ?? '',
              fileType: type,
            )
          : null,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
  }
}

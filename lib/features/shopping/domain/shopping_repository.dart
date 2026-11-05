import 'dart:io';

import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';

/// The one "items left" notification per paused session. Implemented with
/// the NotificationScheduler; the repository decides when.
abstract interface class PendingShoppingNotice {
  Future<void> show(ShoppingList list);
  Future<void> clear(String listId);
}

abstract interface class ShoppingRepository {
  /// The session in progress (running or paused), if any.
  Stream<ShoppingList?> watchActive();

  /// Lists saved for later, newest first.
  Stream<List<ShoppingList>> watchDrafts();

  /// Completed lists, newest purchase first.
  Stream<List<ShoppingList>> watchHistory();

  Stream<ShoppingList?> watchList(String id);

  /// Creates or updates a draft (or the active list's items, if [ListDraft.id]
  /// is the active one). Returns the list id.
  Future<Result<String>> saveList(ListDraft draft);

  /// Makes the list the active session. Fails with a `ConflictFailure`
  /// naming the active list when another session is in progress.
  Future<Result<void>> startSession(String listId);

  /// "Continue later": pauses and shows one notification listing what's
  /// left (none if nothing is left).
  Future<Result<void>> pauseSession(String listId);

  /// Back to shopping; clears the notification.
  Future<Result<void>> resumeSession(String listId);

  Future<Result<void>> setPurchased(String itemId, {required bool value});

  Future<Result<void>> addItem(String listId, ItemDraft item);

  Future<Result<void>> updateItem(String itemId, ItemDraft item);

  Future<Result<void>> removeItem(String itemId);

  /// Saves to history and records the total as one Budget expense in the
  /// same transaction. Re-running (or editing later) updates that expense;
  /// it is never added twice.
  Future<Result<void>> complete(
    String listId,
    Completion completion, {
    File? receipt,
    String? receiptName,
  });

  /// Edits a completed list's details (and its expense).
  Future<Result<void>> updateCompletion(
    String listId,
    Completion completion, {
    File? receipt,
    String? receiptName,
    bool removeReceipt = false,
  });

  /// Deletes a list. For a completed list, [deleteExpense] decides whether
  /// its Budget expense goes too; if kept, it becomes a manual expense.
  Future<Result<void>> deleteList(String listId, {bool deleteExpense = false});

  Future<Result<File>> receiptFile(Receipt receipt);
}

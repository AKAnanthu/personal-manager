import 'package:equatable/equatable.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';

/// draft: saved for later; active: the one shopping session in progress;
/// completed: in history.
enum ShoppingListStatus { draft, active, completed }

enum PaymentMethod { cash, upi, card, other }

final class ShoppingItem extends Equatable {
  const ShoppingItem({
    required this.id,
    required this.name,
    this.quantity = '',
    this.unit = '',
    this.isPurchased = false,
  });

  final String id;
  final String name;

  /// As text ("2", "1.5", "1/2"); may be empty for items added in a hurry.
  final String quantity;
  final String unit;
  final bool isPurchased;

  /// "2", "5 kg", "" — for display and notifications.
  String get amountLabel =>
      [quantity, unit].where((s) => s.isNotEmpty).join(' ');

  @override
  List<Object?> get props => [id, name, quantity, unit, isPurchased];
}

final class Receipt extends Equatable {
  const Receipt({
    required this.fileKey,
    required this.originalName,
    required this.fileType,
  });

  final String fileKey;
  final String originalName;
  final SupportedFileType fileType;

  @override
  List<Object?> get props => [fileKey, originalName, fileType];
}

final class ShoppingList extends Equatable {
  const ShoppingList({
    required this.id,
    required this.name,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.copiedFromId,
    this.startedAt,
    this.pausedAt,
    this.purchasedOn,
    this.totalPaise,
    this.store = '',
    this.paymentMethod,
    this.receipt,
  });

  final String id;
  final String name;
  final ShoppingListStatus status;
  final List<ShoppingItem> items;
  final String? copiedFromId;
  final DateTime? startedAt;

  /// Set while an active session is paused ("Continue later").
  final DateTime? pausedAt;

  /// Completion details.
  final DateTime? purchasedOn;
  final int? totalPaise;
  final String store;
  final PaymentMethod? paymentMethod;
  final Receipt? receipt;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get purchasedCount => items.where((i) => i.isPurchased).length;
  List<ShoppingItem> get pending => items.where((i) => !i.isPurchased).toList();
  bool get allPurchased => items.isNotEmpty && pending.isEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    items,
    copiedFromId,
    startedAt,
    pausedAt,
    purchasedOn,
    totalPaise,
    store,
    paymentMethod,
    receipt,
    createdAt,
    updatedAt,
  ];
}

/// An item as edited (id null for new ones).
final class ItemDraft extends Equatable {
  const ItemDraft({
    required this.name,
    this.id,
    this.quantity = '',
    this.unit = '',
    this.isPurchased = false,
  });

  final String? id;
  final String name;
  final String quantity;
  final String unit;
  final bool isPurchased;

  @override
  List<Object?> get props => [id, name, quantity, unit, isPurchased];
}

final class ListDraft extends Equatable {
  const ListDraft({
    required this.name,
    required this.items,
    this.id,
    this.copiedFromId,
  });

  final String? id;
  final String name;
  final List<ItemDraft> items;
  final String? copiedFromId;

  @override
  List<Object?> get props => [id, name, items, copiedFromId];
}

/// What "Finish shopping" records (also used to edit it in history).
final class Completion extends Equatable {
  const Completion({
    required this.totalPaise,
    required this.purchasedOn,
    this.store = '',
    this.paymentMethod,
  });

  final int totalPaise;
  final DateTime purchasedOn;
  final String store;
  final PaymentMethod? paymentMethod;

  @override
  List<Object?> get props => [totalPaise, purchasedOn, store, paymentMethod];
}

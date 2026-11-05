import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/columns.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';

@DataClassName('ShoppingListRow')
class ShoppingLists extends Table with RecordColumns {
  TextColumn get name => text()();
  TextColumn get status => textEnum<ShoppingListStatus>()();
  TextColumn get copiedFromId => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get pausedAt => dateTime().nullable()();
  TextColumn get purchasedOn =>
      text().map(const DateOnlyConverter()).nullable()();

  /// Integer paise (INR); never a double.
  IntColumn get totalPaise => integer().nullable()();
  TextColumn get store => text().withDefault(const Constant(''))();
  TextColumn get paymentMethod => textEnum<PaymentMethod>().nullable()();
  TextColumn get receiptKey => text().nullable()();
  TextColumn get receiptName => text().nullable()();
  TextColumn get receiptType => textEnum<SupportedFileType>().nullable()();
}

@DataClassName('ShoppingItemRow')
class ShoppingItems extends Table with RecordColumns {
  TextColumn get listId =>
      text().references(ShoppingLists, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get quantity => text().withDefault(const Constant(''))();
  TextColumn get unit => text().withDefault(const Constant(''))();
  BoolColumn get isPurchased => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer()();
}

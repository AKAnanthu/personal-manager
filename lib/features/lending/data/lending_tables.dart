import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/columns.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';

@DataClassName('LendingRow')
class LendingRecords extends Table with RecordColumns {
  TextColumn get direction => textEnum<LendingDirection>()();
  TextColumn get person => text()();

  /// Integer paise (INR).
  IntColumn get amountPaise => integer()();
  TextColumn get givenOn => text().map(const DateOnlyConverter())();
  TextColumn get dueOn => text().map(const DateOnlyConverter()).nullable()();
  TextColumn get status => textEnum<LendingStatus>()();
  TextColumn get completedOn =>
      text().map(const DateOnlyConverter()).nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get remind => boolean().withDefault(const Constant(false))();
}

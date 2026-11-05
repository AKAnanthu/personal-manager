import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/columns.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';

/// Budget expenses (the Budget screens arrive in the next milestone).
/// The unique (source, sourceId) key makes a shopping trip count once,
/// however often it is completed or edited.
@DataClassName('ExpenseRow')
class Expenses extends Table with RecordColumns {
  IntColumn get amountPaise => integer()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get spentOn => text().map(const DateOnlyConverter())();
  TextColumn get source => textEnum<ExpenseSource>()();

  /// Null for manual expenses (NULLs never collide in a UNIQUE key).
  TextColumn get sourceId => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {source, sourceId},
  ];
}

/// The budget amount from a month onwards: a month uses the latest row at or
/// before it, so changing the budget doesn't rewrite earlier months.
@DataClassName('BudgetAmountRow')
class BudgetAmounts extends Table with RecordColumns {
  /// "yyyy-MM" (BudgetMonth.key); one row per month at most.
  TextColumn get fromMonth => text().unique()();
  IntColumn get amountPaise => integer()();
}

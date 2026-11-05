import 'package:equatable/equatable.dart';

/// Where an expense came from. Shopping expenses carry the list id.
enum ExpenseSource { manual, shopping }

final class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.amountPaise,
    required this.description,
    required this.spentOn,
    required this.source,
    this.sourceId,
  });

  final String id;
  final int amountPaise;
  final String description;

  /// Calendar date.
  final DateTime spentOn;
  final ExpenseSource source;

  /// The shopping list for [ExpenseSource.shopping].
  final String? sourceId;

  /// Shopping expenses are edited from the shopping history, so the total
  /// stays in one place.
  bool get fromShopping => source == ExpenseSource.shopping;

  @override
  List<Object?> get props => [
    id,
    amountPaise,
    description,
    spentOn,
    source,
    sourceId,
  ];
}

final class ExpenseDraft extends Equatable {
  const ExpenseDraft({
    required this.amountPaise,
    required this.spentOn,
    this.id,
    this.description = '',
  });

  final String? id;
  final int amountPaise;
  final DateTime spentOn;
  final String description;

  @override
  List<Object?> get props => [id, amountPaise, spentOn, description];
}

/// A calendar month (owner decision: budgets are per calendar month).
final class BudgetMonth extends Equatable {
  const BudgetMonth(this.year, this.month);

  factory BudgetMonth.of(DateTime d) => BudgetMonth(d.year, d.month);

  final int year;
  final int month;

  DateTime get first => DateTime(year, month);
  DateTime get last => DateTime(year, month + 1, 0);
  BudgetMonth get previous => BudgetMonth.of(DateTime(year, month - 1));
  BudgetMonth get next => BudgetMonth.of(DateTime(year, month + 1));

  /// "2026-11"; sorts correctly as text.
  String get key =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}';

  bool isAfter(BudgetMonth o) => key.compareTo(o.key) > 0;

  @override
  List<Object?> get props => [year, month];
}

/// Total Budget, Total Spent, Remaining (may be negative), and the month's
/// expenses. Nothing else, by design.
final class BudgetSummary extends Equatable {
  const BudgetSummary({
    required this.month,
    required this.expenses,
    this.budgetPaise,
  });

  final BudgetMonth month;

  /// Null until the user sets a budget.
  final int? budgetPaise;

  /// Newest first.
  final List<Expense> expenses;

  int get spentPaise => expenses.fold(0, (a, e) => a + e.amountPaise);
  int? get remainingPaise {
    final b = budgetPaise;
    return b == null ? null : b - spentPaise;
  }

  @override
  List<Object?> get props => [month, budgetPaise, expenses];
}

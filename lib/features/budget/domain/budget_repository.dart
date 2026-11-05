import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';

abstract interface class BudgetRepository {
  Stream<BudgetSummary> watchMonth(BudgetMonth month);

  Stream<Expense?> watchExpense(String id);

  /// Sets the budget for [month] and the months after it.
  Future<Result<void>> setBudget(BudgetMonth month, int amountPaise);

  /// Manual expenses only; shopping ones change through shopping history.
  Future<Result<String>> saveExpense(ExpenseDraft draft);

  Future<Result<void>> deleteExpense(String id);
}

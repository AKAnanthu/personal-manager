import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/db/columns.dart';
import 'package:personal_life_manager/core/db/db_guard.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/budget/domain/budget_repository.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';
import 'package:uuid/uuid.dart';

final class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({
    required this._db,
    this._uuid = const Uuid(),
    this._clock = DateTime.now,
  });

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _clock;

  $ExpensesTable get _e => _db.expenses;
  $BudgetAmountsTable get _b => _db.budgetAmounts;

  static const _dates = DateOnlyConverter();

  @override
  Stream<BudgetSummary> watchMonth(BudgetMonth month) => _db
      .customSelect('SELECT 1', readsFrom: {_e, _b})
      .watch()
      .asyncMap((_) => _summary(month));

  Future<BudgetSummary> _summary(BudgetMonth month) async {
    final amount =
        await (_db.select(_b)
              ..where((b) => b.fromMonth.isSmallerOrEqualValue(month.key))
              ..orderBy([(b) => OrderingTerm.desc(b.fromMonth)])
              ..limit(1))
            .getSingleOrNull();
    // ISO dates compare correctly as text.
    final rows =
        await (_db.select(_e)
              ..where(
                (e) =>
                    e.spentOn.isBiggerOrEqualValue(_dates.toSql(month.first)) &
                    e.spentOn.isSmallerOrEqualValue(_dates.toSql(month.last)),
              )
              ..orderBy([
                (e) => OrderingTerm.desc(e.spentOn),
                (e) => OrderingTerm.desc(e.createdAt),
              ]))
            .get();
    return BudgetSummary(
      month: month,
      budgetPaise: amount?.amountPaise,
      expenses: [for (final r in rows) _map(r)],
    );
  }

  @override
  Stream<Expense?> watchExpense(String id) =>
      (_db.select(_e)..where((e) => e.id.equals(id))).watchSingleOrNull().map(
        (r) => r == null ? null : _map(r),
      );

  @override
  Future<Result<void>> setBudget(BudgetMonth month, int amountPaise) {
    if (amountPaise <= 0) {
      return Future.value(const Err(ValidationFailure('budget')));
    }
    return dbGuard(() async {
      final now = _clock();
      await _db
          .into(_b)
          .insert(
            BudgetAmountsCompanion.insert(
              id: _uuid.v4(),
              fromMonth: month.key,
              amountPaise: amountPaise,
              createdAt: now,
              updatedAt: now,
            ),
            onConflict: DoUpdate(
              (_) => BudgetAmountsCompanion(
                amountPaise: Value(amountPaise),
                updatedAt: Value(now),
              ),
              target: [_b.fromMonth],
            ),
          );
    });
  }

  @override
  Future<Result<String>> saveExpense(ExpenseDraft d) {
    if (d.amountPaise <= 0) {
      return Future.value(const Err(ValidationFailure('amount')));
    }
    return dbGuard(() async {
      final now = _clock();
      final companion = ExpensesCompanion(
        amountPaise: Value(d.amountPaise),
        description: Value(d.description.trim()),
        spentOn: Value(d.spentOn),
        updatedAt: Value(now),
      );
      final id = d.id;
      if (id == null) {
        final newId = _uuid.v4();
        await _db
            .into(_e)
            .insert(
              companion.copyWith(
                id: Value(newId),
                source: const Value(ExpenseSource.manual),
                createdAt: Value(now),
              ),
            );
        return newId;
      }
      final n =
          await (_db.update(_e)..where(
                (e) =>
                    e.id.equals(id) &
                    e.source.equalsValue(ExpenseSource.manual),
              ))
              .write(companion);
      if (n == 0) throw const RecordNotFound();
      return id;
    });
  }

  @override
  Future<Result<void>> deleteExpense(String id) => dbGuard(() async {
    final n =
        await (_db.delete(_e)..where(
              (e) =>
                  e.id.equals(id) & e.source.equalsValue(ExpenseSource.manual),
            ))
            .go();
    if (n == 0) {
      final exists = await (_db.select(
        _e,
      )..where((e) => e.id.equals(id))).getSingleOrNull();
      // A shopping expense: delete it with its shopping list instead.
      if (exists != null) throw const FailWith(ValidationFailure('shopping'));
    }
  });

  static Expense _map(ExpenseRow r) => Expense(
    id: r.id,
    amountPaise: r.amountPaise,
    description: r.description,
    spentOn: r.spentOn,
    source: r.source,
    sourceId: r.sourceId,
  );
}

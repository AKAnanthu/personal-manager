import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/features/budget/data/budget_repository_impl.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';
import 'package:personal_life_manager/features/lending/data/lending_repository_impl.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';
import 'package:personal_life_manager/features/medicine/data/medicine_repository_impl.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine.dart';

import '../helpers/fakes.dart';

T ok<T>(Result<T> r) => r.fold((f) => fail('unexpected $f'), (v) => v);
Failure? failureOf<T>(Result<T> r) => r.fold((f) => f, (_) => null);

void main() {
  late AppDatabase db;
  final clock = TestClock(DateTime(2026, 11, 3, 18));
  var replans = 0;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    replans = 0;
  });
  tearDown(() => db.close());

  group('Budget', () {
    late BudgetRepositoryImpl repo;
    const nov = BudgetMonth(2026, 11);
    setUp(() => repo = BudgetRepositoryImpl(db: db, clock: clock.call));

    Future<String> spend(int paise, DateTime on, [String d = '']) async =>
        ok<String>(
          await repo.saveExpense(
            ExpenseDraft(amountPaise: paise, spentOn: on, description: d),
          ),
        );

    test(
      'a budget applies from its month on; earlier months keep theirs',
      () async {
        ok(await repo.setBudget(const BudgetMonth(2026, 9), 2000000));
        ok(await repo.setBudget(nov, 2500000));
        expect(
          (await repo.watchMonth(const BudgetMonth(2026, 8)).first).budgetPaise,
          isNull,
        );
        expect(
          (await repo.watchMonth(const BudgetMonth(2026, 10)).first)
              .budgetPaise,
          2000000,
        );
        expect((await repo.watchMonth(nov).first).budgetPaise, 2500000);
        expect(
          (await repo.watchMonth(const BudgetMonth(2027, 2)).first).budgetPaise,
          2500000,
        );
        // Changing it again in the same month replaces it.
        ok(await repo.setBudget(nov, 3000000));
        expect((await repo.watchMonth(nov).first).budgetPaise, 3000000);
        expect(
          failureOf(await repo.setBudget(nov, 0)),
          isA<ValidationFailure>(),
        );
      },
    );

    test('only that month counts; remaining can go negative', () async {
      ok(await repo.setBudget(nov, 100000));
      await spend(30000, DateTime(2026, 10, 31));
      await spend(80000, DateTime(2026, 11), 'Rent');
      await spend(40000, DateTime(2026, 11, 30), 'Bill');
      final s = await repo.watchMonth(nov).first;
      expect(s.expenses.map((e) => e.description), ['Bill', 'Rent']);
      expect(s.spentPaise, 120000);
      expect(s.remainingPaise, -20000);
    });

    test('shopping expenses count but are changed only via shopping', () async {
      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              id: 'shop',
              amountPaise: 184600,
              spentOn: DateTime(2026, 11, 3),
              source: ExpenseSource.shopping,
              sourceId: const Value('list-1'),
              createdAt: clock.now,
              updatedAt: clock.now,
            ),
          );
      final s = await repo.watchMonth(nov).first;
      expect(s.spentPaise, 184600);
      expect(s.expenses.single.fromShopping, isTrue);
      expect(
        failureOf(await repo.deleteExpense('shop')),
        isA<ValidationFailure>(),
      );
      expect(
        failureOf(
          await repo.saveExpense(
            ExpenseDraft(
              id: 'shop',
              amountPaise: 1,
              spentOn: DateTime(2026, 11, 3),
            ),
          ),
        ),
        const NotFoundFailure(),
      );
      expect((await repo.watchMonth(nov).first).spentPaise, 184600);
    });

    test('edit and delete manual expenses', () async {
      final id = await spend(35000, DateTime(2026, 11, 3), 'Auto');
      ok(
        await repo.saveExpense(
          ExpenseDraft(
            id: id,
            amountPaise: 40000,
            spentOn: DateTime(2026, 11, 3),
            description: 'Auto fare',
          ),
        ),
      );
      expect((await repo.watchExpense(id).first)?.amountPaise, 40000);
      ok(await repo.deleteExpense(id));
      expect(await repo.watchExpense(id).first, isNull);
    });
  });

  group('Lending', () {
    late LendingRepositoryImpl repo;
    setUp(
      () => repo = LendingRepositoryImpl(
        db: db,
        onScheduleChanged: () => replans++,
        clock: clock.call,
      ),
    );

    Future<String> add(
      String person,
      int paise, {
      LendingDirection dir = LendingDirection.lent,
      DateTime? due,
      bool remind = false,
      LendingStatus status = LendingStatus.pending,
    }) async => ok<String>(
      await repo.save(
        LendingDraft(
          direction: dir,
          person: person,
          amountPaise: paise,
          givenOn: DateTime(2026, 10, 12),
          dueOn: due,
          remind: remind,
          status: status,
        ),
      ),
    );

    test('totals count pending records only; tabs are separate', () async {
      await add('Rahul', 200000, due: DateTime(2026, 11, 10));
      await add('Priya', 550000, due: DateTime(2026, 11, 30));
      await add('rahul', 10000);
      await add('Anoop', 120000, status: LendingStatus.completed);
      await add('Bank', 999900, dir: LendingDirection.borrowed);

      final lent = await repo.watchTab(LendingDirection.lent).first;
      expect(lent.pendingTotalPaise, 760000);
      expect(lent.pendingPeople, 2);
      expect(lent.nextDue, DateTime(2026, 11, 10));
      // Pending by due date (undated last), then completed.
      expect(lent.records.map((r) => r.person), [
        'Rahul',
        'Priya',
        'rahul',
        'Anoop',
      ]);
      expect(
        (await repo.watchTab(LendingDirection.borrowed).first)
            .pendingTotalPaise,
        999900,
      );
    });

    test('marking repaid stops the reminder and counts no more', () async {
      final id = await add(
        'Rahul',
        200000,
        due: DateTime(2026, 11, 10),
        remind: true,
      );
      final sources = await repo.notificationSources(
        (r) => (title: r.person, body: 'b'),
      );
      expect(
        sources.single.schedule,
        OneTimeSchedule(DateTime(2026, 11, 10, 9)),
      );
      expect(sources.single.kind, NotificationKind.lending);
      expect(sources.single.route, '/lending/$id');

      ok(await repo.setStatus(id, LendingStatus.completed));
      final r = await repo.watchRecord(id).first;
      expect(r?.completedOn, DateTime(2026, 11, 3));
      expect(
        await repo.notificationSources((r) => (title: '', body: '')),
        isEmpty,
      );
      expect(
        (await repo.watchTab(LendingDirection.lent).first).pendingTotalPaise,
        0,
      );
      expect(replans, 2);
    });

    test('a reminder needs a due date; invalid records are rejected', () async {
      final id = await add('Rahul', 100, remind: true);
      expect((await repo.watchRecord(id).first)?.remind, isFalse);
      expect(
        failureOf(
          await repo.save(
            LendingDraft(
              direction: LendingDirection.lent,
              person: ' ',
              amountPaise: 100,
              givenOn: DateTime(2026),
            ),
          ),
        ),
        isA<ValidationFailure>(),
      );
    });
  });

  group('Medicine', () {
    late MedicineRepositoryImpl repo;
    setUp(
      () => repo = MedicineRepositoryImpl(
        db: db,
        onScheduleChanged: () => replans++,
        clock: clock.call,
      ),
    );

    test('times are sorted and de-duplicated; seven days = every day; one '
        'notification source per time; paused ones have none', () async {
      final id = ok<String>(
        await repo.save(
          const MedicineDraft(
            name: 'Iron supplement',
            times: [
              TimeOfDayMinutes(21, 0),
              TimeOfDayMinutes(9, 0),
              TimeOfDayMinutes(21, 0),
            ],
            weekdays: {1, 2, 3, 4, 5, 6},
          ),
        ),
      );
      ok(
        await repo.save(
          const MedicineDraft(
            name: 'Vitamin D3',
            times: [TimeOfDayMinutes(20, 0)],
            weekdays: {1, 2, 3, 4, 5, 6, 7},
          ),
        ),
      );
      final all = await repo.watchAll().first;
      expect(all.first.times, const [
        TimeOfDayMinutes(9, 0),
        TimeOfDayMinutes(21, 0),
      ]);
      expect(all.last.everyDay, isTrue);
      expect(all.last.weekdays, isEmpty);

      var sources = await repo.notificationSources(
        (m, t) => (title: 'Time for ${m.name}', body: '${t.hour}'),
      );
      expect(sources, hasLength(3));
      expect(sources.every((s) => s.kind == NotificationKind.medicine), isTrue);
      expect(
        sources.first.schedule,
        const DailyTimesSchedule(
          times: [TimeOfDayMinutes(9, 0)],
          weekdays: {1, 2, 3, 4, 5, 6},
        ),
      );

      ok(await repo.setEnabled(id, value: false));
      sources = await repo.notificationSources((m, t) => (title: '', body: ''));
      expect(sources.single.title, '');
      expect(replans, 3);
    });

    test('a schedule needs a name and a time', () async {
      expect(
        failureOf(await repo.save(const MedicineDraft(name: 'X', times: []))),
        isA<ValidationFailure>(),
      );
    });
  });

  group('nextDose', () {
    const vit = Medicine(
      id: 'v',
      name: 'Vitamin D3',
      times: [TimeOfDayMinutes(20, 0)],
    );
    const iron = Medicine(
      id: 'i',
      name: 'Iron',
      times: [TimeOfDayMinutes(9, 0), TimeOfDayMinutes(21, 0)],
      weekdays: {1, 2, 3, 4, 5, 6},
    );

    test('soonest enabled dose, honouring days', () {
      // Tue 3 Nov 2026, 18:40.
      final d = nextDose([iron, vit], DateTime(2026, 11, 3, 18, 40));
      expect((d?.medicine.id, d?.at), ('v', DateTime(2026, 11, 3, 20)));
      // Saturday night → Iron skips Sunday, so Vitamin D3 on Sunday wins.
      final sat = nextDose([iron, vit], DateTime(2026, 11, 7, 21, 30));
      expect((sat?.medicine.id, sat?.at), ('v', DateTime(2026, 11, 8, 20)));
      const off = Medicine(
        id: 'o',
        name: 'Off',
        times: [TimeOfDayMinutes(0, 0)],
        enabled: false,
      );
      expect(nextDose([off], DateTime(2026, 11, 3)), isNull);
    });
  });
}

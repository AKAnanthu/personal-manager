import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/breathing/domain/breathing.dart';
import 'package:personal_life_manager/features/budget/domain/budget_repository.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';
import 'package:personal_life_manager/features/budget/presentation/budget_cubit.dart';
import 'package:personal_life_manager/features/budget/presentation/expense_form_cubit.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';
import 'package:personal_life_manager/features/lending/domain/lending_repository.dart';
import 'package:personal_life_manager/features/lending/presentation/lending_form_cubit.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine_repository.dart';
import 'package:personal_life_manager/features/medicine/presentation/medicine_cubits.dart';

class _Budget extends Mock implements BudgetRepository;

class _Lending extends Mock implements LendingRepository;

class _Medicine extends Mock implements MedicineRepository;

class _Perms extends Mock implements NotificationPermissions;

void main() {
  const nov = BudgetMonth(2026, 11);
  final rent = Expense(
    id: 'rent',
    amountPaise: 950000,
    description: 'Rent',
    spentOn: DateTime(2026, 11),
    source: ExpenseSource.manual,
  );

  setUpAll(() {
    registerFallbackValue(nov);
    registerFallbackValue(ExpenseDraft(amountPaise: 1, spentOn: DateTime(0)));
    registerFallbackValue(
      LendingDraft(
        direction: LendingDirection.lent,
        person: '',
        amountPaise: 1,
        givenOn: DateTime(0),
      ),
    );
    registerFallbackValue(const MedicineDraft(name: '', times: []));
  });

  late _Perms perms;
  setUp(() {
    perms = _Perms();
    when(perms.ensurePermission).thenAnswer((_) async => true);
  });

  group('Breathing timing', () {
    const s = BreathingSettings(minutes: 1, pace: BreathingPace.longExhale);

    test('in for 4 s, out for 6 s, repeating; ends at zero', () {
      final start = BreathingMoment.at(Duration.zero, s);
      expect((start.inhaling, start.fullness, start.cycle), (true, 0.0, 0));
      final full = BreathingMoment.at(const Duration(seconds: 4), s);
      expect((full.inhaling, full.fullness), (false, 1.0));
      final mid = BreathingMoment.at(const Duration(seconds: 7), s);
      expect(mid.fullness, closeTo(0.5, 1e-9));
      final next = BreathingMoment.at(const Duration(seconds: 10), s);
      expect((next.inhaling, next.cycle), (true, 1));
      expect(
        BreathingMoment.at(const Duration(seconds: 15), s).remaining,
        const Duration(seconds: 45),
      );
      expect(
        BreathingMoment.at(const Duration(minutes: 9), s).remaining,
        Duration.zero,
      );
    });
  });

  group('Budget', () {
    late _Budget repo;
    setUp(() => repo = _Budget());

    blocTest<BudgetCubit, BudgetState>(
      'browses back but not into future months',
      setUp: () => when(() => repo.watchMonth(any())).thenAnswer(
        (i) => Stream.value(
          BudgetSummary(
            month: i.positionalArguments.first as BudgetMonth,
            expenses: const [],
          ),
        ),
      ),
      build: () => BudgetCubit(repo, clock: () => DateTime(2026, 11, 3)),
      act: (c) async {
        c
          ..start()
          ..nextMonth();
        expect(c.state.month, nov);
        c.previousMonth();
        await Future<void>.delayed(Duration.zero);
      },
      verify: (c) {
        expect(c.state.month, const BudgetMonth(2026, 10));
        expect(c.state.loading, isFalse);
        expect(c.state.isCurrentMonth, isFalse);
      },
    );

    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'shows what an edit leaves of the budget (its old amount excluded)',
      setUp: () {
        when(() => repo.watchExpense('rent'))
            .thenAnswer((_) => Stream.value(rent));
        when(() => repo.watchMonth(nov)).thenAnswer(
          (_) => Stream.value(
            BudgetSummary(month: nov, budgetPaise: 2500000, expenses: [rent]),
          ),
        );
        when(() => repo.saveExpense(any()))
            .thenAnswer((_) async => const Ok('rent'));
      },
      build: () => ExpenseFormCubit(
        repository: repo,
        expenseId: 'rent',
        clock: () => DateTime(2026, 11, 3),
      ),
      act: (c) async {
        await c.load();
        await Future<void>.delayed(Duration.zero);
        c.amountChanged('10,000');
        expect(c.state.leaves, 2500000 - 1000000);
        await c.save();
      },
      verify: (c) {
        expect(c.state.outcome, EditorOutcome.saved);
        verify(
          () => repo.saveExpense(
            ExpenseDraft(
              id: 'rent',
              amountPaise: 1000000,
              spentOn: DateTime(2026, 11),
              description: 'Rent',
            ),
          ),
        ).called(1);
      },
    );
  });

  group('Lending form', () {
    late _Lending repo;
    setUp(() {
      repo = _Lending();
      when(() => repo.save(any())).thenAnswer((_) async => const Ok('id'));
    });

    LendingFormCubit build() => LendingFormCubit(
      repository: repo,
      permissions: perms,
      initialDirection: LendingDirection.borrowed,
      clock: () => DateTime(2026, 11, 3, 18),
    );

    blocTest<LendingFormCubit, LendingFormState>(
      'needs a person, an amount and a due date not before the date given',
      build: build,
      act: (c) async {
        await c.load();
        c
          ..personChanged('Rahul')
          ..amountChanged('2,000')
          ..dueOnChanged(DateTime(2026, 11));
        await c.save();
      },
      verify: (c) {
        expect(c.state.dueBeforeGiven, isTrue);
        verifyNever(() => repo.save(any()));
      },
    );

    blocTest<LendingFormCubit, LendingFormState>(
      'saves in paise; asks notification permission only for a reminder',
      build: build,
      act: (c) async {
        await c.load();
        c
          ..personChanged('Rahul')
          ..amountChanged('2,000')
          ..dueOnChanged(DateTime(2026, 11, 10));
        await c.save();
      },
      verify: (c) {
        verify(
          () => repo.save(
            LendingDraft(
              direction: LendingDirection.borrowed,
              person: 'Rahul',
              amountPaise: 200000,
              givenOn: DateTime(2026, 11, 3),
              dueOn: DateTime(2026, 11, 10),
              remind: true,
            ),
          ),
        ).called(1);
        verify(perms.ensurePermission).called(1);
      },
    );
  });

  group('Medicine form', () {
    late _Medicine repo;
    setUp(() {
      repo = _Medicine();
      when(() => repo.save(any())).thenAnswer((_) async => const Ok('id'));
    });

    blocTest<MedicineFormCubit, MedicineFormState>(
      'selected days start with all ticked; at least one day and time',
      build: () => MedicineFormCubit(repository: repo, permissions: perms),
      act: (c) async {
        await c.load();
        c
          ..nameChanged('Iron')
          ..everyDayChanged(value: false);
        expect(c.state.weekdays, {1, 2, 3, 4, 5, 6, 7});
        for (var d = 1; d <= 7; d++) {
          c.weekdayToggled(d);
        }
        await c.save();
        expect(c.state.daysMissing && c.state.timesMissing, isTrue);
        c
          ..weekdayToggled(1)
          ..addTime(const TimeOfDayMinutes(21, 0))
          ..addTime(const TimeOfDayMinutes(9, 0))
          ..addTime(const TimeOfDayMinutes(9, 0));
        await c.save();
      },
      verify: (c) {
        verify(
          () => repo.save(
            const MedicineDraft(
              name: 'Iron',
              times: [TimeOfDayMinutes(9, 0), TimeOfDayMinutes(21, 0)],
              weekdays: {1},
            ),
          ),
        ).called(1);
        expect(c.state.outcome, EditorOutcome.saved);
      },
    );

    blocTest<MedicineListCubit, MedicineListState>(
      'pausing a schedule goes to the repository',
      setUp: () {
        when(repo.watchAll).thenAnswer((_) => Stream.value(const <Medicine>[]));
        when(() => repo.setEnabled('m', value: false))
            .thenAnswer((_) async => const Ok(null));
      },
      build: () => MedicineListCubit(repo),
      act: (c) async {
        c.start();
        await c.setEnabled(
          const Medicine(id: 'm', name: 'X', times: []),
          value: false,
        );
      },
      verify: (c) {
        expect(c.state.status, LoadStatus.ready);
        verify(() => repo.setEnabled('m', value: false)).called(1);
      },
    );
  });
}

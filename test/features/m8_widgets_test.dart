import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/features/breathing/data/breathing_services.dart';
import 'package:personal_life_manager/features/breathing/domain/breathing.dart';
import 'package:personal_life_manager/features/breathing/presentation/breathe_page.dart';
import 'package:personal_life_manager/features/breathing/presentation/breathing_settings_cubit.dart';
import 'package:personal_life_manager/features/budget/domain/budget_repository.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';
import 'package:personal_life_manager/features/budget/presentation/budget_cubit.dart';
import 'package:personal_life_manager/features/budget/presentation/budget_page.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';
import 'package:personal_life_manager/features/lending/domain/lending_repository.dart';
import 'package:personal_life_manager/features/lending/presentation/lending_cubit.dart';
import 'package:personal_life_manager/features/lending/presentation/lending_page.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine_repository.dart';
import 'package:personal_life_manager/features/medicine/presentation/medicine_cubits.dart';
import 'package:personal_life_manager/features/medicine/presentation/medicine_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';
import 'package:personal_life_manager/l10n/locales.dart';

class _Budget extends Mock implements BudgetRepository;

class _Lending extends Mock implements LendingRepository;

class _Medicine extends Mock implements MedicineRepository;

class _Store extends Mock implements BreathingSettingsStore;

final class _Feedback implements BreathingFeedback {
  final events = <String>[];

  @override
  Future<void> keepScreenOn({required bool on}) async =>
      events.add('awake:$on');

  @override
  Future<void> cue() async => events.add('cue');

  @override
  Future<void> chime() async => events.add('chime');

  @override
  Future<void> dispose() async => events.add('dispose');
}

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  localizationsDelegates: const [
    ...AppLocalizations.localizationsDelegates,
    GlobalMaterialLocalizations.delegate,
  ],
  supportedLocales: appSupportedLocales,
  locale: const Locale('en', 'IN'),
  home: child,
);

void _phone(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1170, 2532)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() {
    registerFallbackValue(const BudgetMonth(2026, 11));
    registerFallbackValue(const BreathingSettings());
  });

  testWidgets('budget: over budget is shown clearly; shopping is marked', (
    tester,
  ) async {
    _phone(tester);
    final repo = _Budget();
    when(() => repo.watchMonth(any())).thenAnswer(
      (_) => Stream.value(
        BudgetSummary(
          month: const BudgetMonth(2026, 11),
          budgetPaise: 1000000,
          expenses: [
            Expense(
              id: 's',
              amountPaise: 184600,
              description: 'Weekly groceries',
              spentOn: DateTime(2026, 11, 3),
              source: ExpenseSource.shopping,
              sourceId: 'l',
            ),
            Expense(
              id: 'r',
              amountPaise: 950000,
              description: 'Rent share',
              spentOn: DateTime(2026, 11),
              source: ExpenseSource.manual,
            ),
          ],
        ),
      ),
    );
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) =>
              BudgetCubit(repo, clock: () => DateTime(2026, 11, 3))..start(),
          child: const BudgetPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('Over budget by'), findsOneWidget);
    expect(find.text('₹1,346'), findsOneWidget);
    expect(find.text('₹10,000'), findsOneWidget);
    expect(find.text('₹11,346'), findsOneWidget);
    expect(find.text('3 Nov · From shopping'), findsOneWidget);
    // The current month is the latest one.
    final next = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(LucideIcons.chevronRight),
        matching: find.byType(IconButton),
      ),
    );
    expect(next.onPressed, isNull);
  });

  testWidgets('lending: pending total and repaid action', (tester) async {
    _phone(tester);
    final repo = _Lending();
    when(() => repo.watchTab(LendingDirection.lent)).thenAnswer(
      (_) => Stream.value(
        LendingTab([
          LendingRecord(
            id: 'r',
            direction: LendingDirection.lent,
            person: 'Rahul',
            amountPaise: 200000,
            givenOn: DateTime(2026, 10, 12),
            dueOn: DateTime(2026, 11, 10),
            status: LendingStatus.pending,
            remind: true,
          ),
          LendingRecord(
            id: 'a',
            direction: LendingDirection.lent,
            person: 'Anoop',
            amountPaise: 120000,
            givenOn: DateTime(2026, 10),
            status: LendingStatus.completed,
            completedOn: DateTime(2026, 10, 25),
          ),
        ]),
      ),
    );
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) => LendingCubit(repo)..start(),
          child: const LendingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Total lent · pending'), findsOneWidget);
    expect(find.text('₹2,000'), findsNWidgets(2));
    expect(find.text('1 person · next due 10 Nov'), findsOneWidget);
    expect(find.text('Given 12 Oct · Due 10 Nov'), findsOneWidget);
    expect(find.text('Repaid 25 Oct'), findsOneWidget);
    expect(find.text('Mark repaid'), findsOneWidget);
    expect(find.textContaining('Reminder 10 Nov'), findsOneWidget);
  });

  testWidgets('medicine: next dose, days and paused state', (tester) async {
    _phone(tester);
    final repo = _Medicine();
    when(repo.watchAll).thenAnswer(
      (_) => Stream.value(const [
        Medicine(
          id: 'i',
          name: 'Iron supplement',
          times: [TimeOfDayMinutes(9, 0), TimeOfDayMinutes(21, 0)],
          weekdays: {1, 2, 3, 4, 5, 6},
        ),
        Medicine(
          id: 'e',
          name: 'Eye drops',
          times: [TimeOfDayMinutes(7, 0)],
          enabled: false,
        ),
      ]),
    );
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) => MedicineListCubit(repo)..start(),
          child: MedicinePage(now: () => DateTime(2026, 11, 3, 19, 40)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Next up · in 1 h 20 min'), findsOneWidget);
    expect(find.textContaining('Iron supplement · 9:00'), findsOneWidget);
    expect(find.text('Mon – Sat'), findsOneWidget);
    expect(find.text('Every day · Paused'), findsOneWidget);
    expect(find.textContaining('no dosage or medical advice'), findsOneWidget);
  });

  testWidgets('breathing: guides in and out, pauses, chimes at the end', (
    tester,
  ) async {
    // Tall enough that the whole page is built (no scrolling needed).
    tester.view
      ..physicalSize = const Size(1170, 4200)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final store = _Store();
    when(store.load).thenAnswer(
      (_) async => const BreathingSettings(minutes: 1, vibration: true),
    );
    when(() => store.save(any())).thenAnswer((_) async {});
    final feedback = _Feedback();
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) {
            final c = BreathingSettingsCubit(store);
            unawaited(c.load());
            return c;
          },
          child: BreathePage(feedback: feedback),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('1:00 remaining · 4 s in, 4 s out'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Breathe in'), findsOneWidget);
    expect(feedback.events, ['awake:true', 'cue']);

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Breathe out'), findsOneWidget);
    expect(feedback.events.last, 'cue');

    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Paused'), findsWidgets);
    expect(feedback.events.last, 'awake:false');
    await tester.pump(const Duration(seconds: 30));
    expect(find.text('0:55 remaining · 4 s in, 4 s out'), findsOneWidget);

    await tester.tap(find.text('Resume'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 56));
    await tester.pump();
    expect(find.text('Well done'), findsOneWidget);
    expect(feedback.events, containsAllInOrder(['awake:false', 'chime']));
    expect(find.text('Start again'), findsOneWidget);
  });
}

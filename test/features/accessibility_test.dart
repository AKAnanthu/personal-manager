// Accessibility pass: every main screen at 200% text on a small phone
// (320 × 568) must lay out without overflow, and icon-only buttons must
// have labels for screen readers.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/security/biometric_auth.dart';
import 'package:personal_life_manager/core/security/sensitive_clipboard.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/core/ui/session_notices.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/features/auth/domain/auth_repository.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_platform.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_service.dart';
import 'package:personal_life_manager/features/backup_restore/presentation/backup_cubits.dart';
import 'package:personal_life_manager/features/backup_restore/presentation/backup_page.dart';
import 'package:personal_life_manager/features/breathing/data/breathing_services.dart';
import 'package:personal_life_manager/features/breathing/domain/breathing.dart';
import 'package:personal_life_manager/features/breathing/presentation/breathe_page.dart';
import 'package:personal_life_manager/features/breathing/presentation/breathing_settings_cubit.dart';
import 'package:personal_life_manager/features/budget/domain/budget_repository.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';
import 'package:personal_life_manager/features/budget/presentation/budget_cubit.dart';
import 'package:personal_life_manager/features/budget/presentation/budget_page.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/domain/documents_repository.dart';
import 'package:personal_life_manager/features/documents/presentation/documents_bloc.dart';
import 'package:personal_life_manager/features/documents/presentation/documents_page.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';
import 'package:personal_life_manager/features/lending/domain/lending_repository.dart';
import 'package:personal_life_manager/features/lending/presentation/lending_cubit.dart';
import 'package:personal_life_manager/features/lending/presentation/lending_page.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine_repository.dart';
import 'package:personal_life_manager/features/medicine/presentation/medicine_cubits.dart';
import 'package:personal_life_manager/features/medicine/presentation/medicine_page.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_note.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_notes_repository.dart';
import 'package:personal_life_manager/features/password_notes/presentation/passwords_bloc.dart';
import 'package:personal_life_manager/features/password_notes/presentation/passwords_page.dart';
import 'package:personal_life_manager/features/settings/data/app_settings.dart';
import 'package:personal_life_manager/features/settings/data/data_eraser.dart';
import 'package:personal_life_manager/features/settings/presentation/settings_cubits.dart';
import 'package:personal_life_manager/features/settings/presentation/settings_page.dart';
import 'package:personal_life_manager/features/shopping/data/instruction_sharer.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';
import 'package:personal_life_manager/features/shopping/presentation/session_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/session_page.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_home_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_home_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';
import 'package:personal_life_manager/l10n/locales.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _Budget extends Mock implements BudgetRepository;

class _Lending extends Mock implements LendingRepository;

class _Medicine extends Mock implements MedicineRepository;

class _Docs extends Mock implements DocumentsRepository;

class _Passwords extends Mock implements PasswordNotesRepository;

class _Shopping extends Mock implements ShoppingRepository;

class _Service extends Mock implements BackupService;

class _Files extends Mock implements BackupFiles;

class _Last extends Mock implements LastBackupStore;

class _Store extends Mock implements BreathingSettingsStore;

class _Feedback extends Mock implements BreathingFeedback;

class _Clipboard extends Mock implements SensitiveClipboard;

class _Sharer extends Mock implements InstructionSharer;

class _Auth extends Mock implements AuthRepository;

class _Bio extends Mock implements BiometricAuth;

class _Perms extends Mock implements NotificationPermissions;

class _Eraser extends Mock implements DataEraser;

final _now = DateTime(2026, 11, 3, 18);

Future<void> _pumpLarge(WidgetTester tester, Widget page) async {
  tester.view
    ..physicalSize = const Size(320, 568)
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: appSupportedLocales,
      locale: const Locale('en', 'IN'),
      home: page,
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  // Scroll through, so lazily built rows are laid out and checked too.
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    for (var i = 0; i < 6; i++) {
      await tester.drag(scrollables.first, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  }
}

/// Every IconButton needs a tooltip (its screen-reader label).
void _expectLabelledIconButtons(WidgetTester tester) {
  for (final b in tester.widgetList<IconButton>(find.byType(IconButton))) {
    expect(b.tooltip, isNotNull, reason: 'IconButton without a label');
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(const BudgetMonth(2026, 11));
    registerFallbackValue(const DocumentFilter());
    registerFallbackValue(const PasswordFilter());
    registerFallbackValue(LendingDirection.lent);
  });
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  testWidgets('budget', (tester) async {
    final repo = _Budget();
    when(() => repo.watchMonth(any())).thenAnswer(
      (_) => Stream.value(
        BudgetSummary(
          month: const BudgetMonth(2026, 11),
          budgetPaise: 2500000,
          expenses: [
            Expense(
              id: 'e',
              amountPaise: 12345600,
              description: 'A rather long expense description here',
              spentOn: DateTime(2026, 11, 3),
              source: ExpenseSource.shopping,
              sourceId: 'l',
            ),
          ],
        ),
      ),
    );
    await _pumpLarge(
      tester,
      BlocProvider(
        create: (_) => BudgetCubit(repo, clock: () => _now)..start(),
        child: const BudgetPage(),
      ),
    );
    _expectLabelledIconButtons(tester);
  });

  testWidgets('lending', (tester) async {
    final repo = _Lending();
    when(() => repo.watchTab(any())).thenAnswer(
      (_) => Stream.value(
        LendingTab([
          LendingRecord(
            id: 'r',
            direction: LendingDirection.lent,
            person: 'Rahul Krishnan Nair',
            amountPaise: 12345600,
            givenOn: DateTime(2026, 10, 12),
            dueOn: DateTime(2026, 11, 10),
            status: LendingStatus.pending,
            remind: true,
            notes: 'For the laptop repair at the shop near the station',
          ),
        ]),
      ),
    );
    await _pumpLarge(
      tester,
      BlocProvider(
        create: (_) => LendingCubit(repo)..start(),
        child: const LendingPage(),
      ),
    );
  });

  testWidgets('medicine', (tester) async {
    final repo = _Medicine();
    when(repo.watchAll).thenAnswer(
      (_) => Stream.value(const [
        Medicine(
          id: 'm',
          name: 'Iron supplement with a long name',
          times: [
            TimeOfDayMinutes(7, 0),
            TimeOfDayMinutes(13, 0),
            TimeOfDayMinutes(19, 0),
            TimeOfDayMinutes(22, 30),
          ],
          weekdays: {1, 3, 5},
        ),
      ]),
    );
    await _pumpLarge(
      tester,
      BlocProvider(
        create: (_) => MedicineListCubit(repo)..start(),
        child: MedicinePage(now: () => _now),
      ),
    );
  });

  testWidgets('documents', (tester) async {
    final repo = _Docs();
    final doc = AppDocument(
      id: 'd',
      title: 'Vehicle insurance policy document',
      description: '',
      category: DocumentCategory.propertyVehicle,
      fileKey: 'k',
      originalName: 'policy.pdf',
      fileType: SupportedFileType.xlsx,
      sizeBytes: 2400000,
      isFavourite: true,
      expiryDate: DateTime(2026, 11, 12),
      createdAt: _now,
      updatedAt: _now,
    );
    when(() => repo.watch(any())).thenAnswer((_) => Stream.value([doc]));
    when(() => repo.watchExpiringSoon(any()))
        .thenAnswer((_) => Stream.value([doc]));
    await _pumpLarge(
      tester,
      BlocProvider(
        create: (_) =>
            DocumentsBloc(repo, clock: () => _now)
              ..add(const DocumentsStarted()),
        child: DocumentsPage(now: () => _now),
      ),
    );
    _expectLabelledIconButtons(tester);
  });

  testWidgets('password notes', (tester) async {
    final repo = _Passwords();
    when(() => repo.watch(any())).thenAnswer(
      (_) => Stream.value(const [
        PasswordNote(
          id: 'p',
          name: 'Electricity board consumer portal',
          url: 'https://portal.example.org/login',
          username: 'consumer-1156-0402-1987',
          password: 'secret',
          notes: '',
          category: 'Bills',
          isFavourite: true,
        ),
      ]),
    );
    when(repo.watchCategories).thenAnswer((_) => Stream.value(['Bills']));
    await _pumpLarge(
      tester,
      BlocProvider(
        create: (_) =>
            PasswordsBloc(repo, SessionNotices())
              ..add(const PasswordsStarted()),
        child: PasswordsPage(clipboard: _Clipboard()),
      ),
    );
    _expectLabelledIconButtons(tester);
  });

  final list = ShoppingList(
    id: 'l',
    name: 'Weekly groceries and household things',
    status: ShoppingListStatus.active,
    items: const [
      ShoppingItem(id: 'a', name: 'Basmati rice', quantity: '5', unit: 'kg'),
      ShoppingItem(id: 'b', name: 'Milk', quantity: '2', isPurchased: true),
    ],
    pausedAt: _now,
    createdAt: _now,
    updatedAt: _now,
  );

  testWidgets('shopping home and session', (tester) async {
    final repo = _Shopping();
    when(repo.watchActive).thenAnswer((_) => Stream.value(list));
    when(repo.watchDrafts).thenAnswer(
      (_) => Stream.value([
        ShoppingList(
          id: 'd',
          name: 'Monthly provisions for the house',
          status: ShoppingListStatus.draft,
          items: const [],
          createdAt: _now,
          updatedAt: _now,
        ),
      ]),
    );
    when(repo.watchHistory).thenAnswer(
      (_) => Stream.value([
        ShoppingList(
          id: 'h',
          name: 'Vegetables and fruit',
          status: ShoppingListStatus.completed,
          items: const [],
          purchasedOn: DateTime(2026, 10, 29),
          totalPaise: 173400,
          createdAt: _now,
          updatedAt: _now,
        ),
      ]),
    );
    when(() => repo.resumeSession(any()))
        .thenAnswer((_) async => const Ok(null));
    await _pumpLarge(
      tester,
      BlocProvider(
        create: (_) => ShoppingHomeCubit(repo)..start(),
        child: ShoppingHomePage(sharer: _Sharer(), now: () => _now),
      ),
    );
    await _pumpLarge(
      tester,
      BlocProvider(
        create: (_) => SessionCubit(repo)..start(),
        child: const SessionPage(),
      ),
    );
  });

  testWidgets('breathing', (tester) async {
    final store = _Store();
    final feedback = _Feedback();
    when(store.load).thenAnswer((_) async => const BreathingSettings());
    when(feedback.dispose).thenAnswer((_) async {});
    await _pumpLarge(
      tester,
      BlocProvider(
        create: (_) {
          final c = BreathingSettingsCubit(store);
          unawaited(c.load());
          return c;
        },
        child: BreathePage(feedback: feedback),
      ),
    );
  });

  testWidgets('backup and settings', (tester) async {
    final last = _Last();
    when(last.load).thenAnswer((_) async => null);
    await _pumpLarge(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                BackupCubit(service: _Service(), files: _Files(), last: last),
          ),
          BlocProvider(
            create: (_) => RestoreCubit(service: _Service(), files: _Files()),
          ),
        ],
        child: const BackupPage(),
      ),
    );

    final auth = _Auth();
    final bio = _Bio();
    final perms = _Perms();
    when(bio.availableKind).thenAnswer((_) async => BiometricKind.face);
    when(auth.isBiometricEnabled).thenAnswer((_) async => const Ok(true));
    when(perms.areEnabled).thenAnswer((_) async => false);
    when(() => perms.exactAlarmsAvailable).thenReturn(true);
    final lock = AppLock(initialStatus: LockStatus.unlocked);
    addTearDown(lock.dispose);
    await _pumpLarge(
      tester,
      BlocProvider(
        create: (_) {
          final c = SettingsCubit(
            auth: auth,
            biometrics: bio,
            permissions: perms,
            settings: AppSettings(lock),
            lastBackup: last,
            eraser: _Eraser(),
          );
          unawaited(c.load());
          return c;
        },
        child: const SettingsPage(appVersion: '1.0.0'),
      ),
    );
    _expectLabelledIconButtons(tester);
  });
}

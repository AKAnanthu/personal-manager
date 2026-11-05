// End-to-end flows through the real app: real screens, routing, database
// code, notification planning and backup. Platform plugins are swapped
// for in-memory versions (see DependencyOverrides), so running this on a
// phone never touches the installed app's data, shows no permission
// dialogs and schedules no real notifications.
//
//   fvm flutter test integration_test --flavor dev -d <device id>
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:personal_life_manager/app/app.dart';
import 'package:personal_life_manager/app/di.dart';
import 'package:personal_life_manager/app/flavor.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/notification_platform.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/notifications/time_zone_service.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/security/biometric_auth.dart';
import 'package:personal_life_manager/core/storage/app_directories.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_service.dart';
import 'package:personal_life_manager/features/backup_restore/domain/backup.dart';
import 'package:personal_life_manager/features/budget/domain/budget_repository.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';
import 'package:personal_life_manager/features/notes/domain/note.dart';
import 'package:personal_life_manager/features/notes/domain/notes_repository.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_note.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_notes_repository.dart';
import 'package:personal_life_manager/features/reminders/domain/reminder.dart';
import 'package:personal_life_manager/features/reminders/domain/reminders_repository.dart';
import 'package:personal_life_manager/features/settings/data/app_settings.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../test/helpers/fakes.dart';

/// Records what the app asks the OS to do.
final class _RecordingPlatform implements NotificationPlatform {
  final scheduled = <int, PlannedNotification>{};
  final shown = <int, NotificationPayload>{};

  @override
  Future<void> initialize({
    required void Function(NotificationTap) onTap,
  }) async {}

  @override
  Future<NotificationTap?> launchTap() async => null;

  @override
  Future<List<PendingNotification>> pending() async => [
    for (final n in scheduled.values) PendingNotification(n.id, n.payload),
  ];

  @override
  Future<void> schedule(PlannedNotification n, {required bool exact}) async =>
      scheduled[n.id] = n;

  @override
  Future<void> show(int id, NotificationPayload payload) async =>
      shown[id] = payload;

  @override
  Future<void> snooze(int id, NotificationPayload p, int minutes) async {}

  @override
  Future<void> cancel(int id) async {
    scheduled.remove(id);
    shown.remove(id);
  }

  @override
  Future<void> cancelAll() async {
    scheduled.clear();
    shown.clear();
  }

  @override
  Future<bool> areEnabled() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> canScheduleExact() async => true;

  @override
  Future<void> requestExactAlarms() async {}

  @override
  Future<void> openSettings() async {}
}

final class _NoBiometrics implements BiometricAuth {
  @override
  Future<BiometricKind?> availableKind() async => null;

  @override
  Future<bool> authenticate({required String reason}) async => false;
}

const _password = 'Garden-Path-42';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  late _RecordingPlatform notifications;

  Future<void> startApp(WidgetTester tester) async {
    // A phone-sized screen when run on the host test engine.
    if (!Platform.isAndroid && !Platform.isIOS) {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
    }
    await sl.reset();
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    root = Directory.systemTemp.createTempSync('plm_it');
    notifications = _RecordingPlatform();
    await configureDependencies(
      AppFlavor.dev,
      overrides: DependencyOverrides(
        directories: AppDirectories(root),
        database: AppDatabase(NativeDatabase.memory()),
        secureStore: InMemorySecureStore(),
        biometrics: _NoBiometrics(),
        notifications: notifications,
        timeZone: TimeZoneService(deviceZone: () async => 'Asia/Kolkata'),
      ),
    );
    await tester.pumpWidget(
      PlmApp(lock: sl<AppLock>(), themeMode: sl<AppSettings>().themeMode),
    );
    await tester.pumpAndSettle();
  }

  tearDown(() async {
    await sl.reset();
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  /// Scrolls [text] into view first (lists build lazily), then taps it.
  Future<void> tapText(
    WidgetTester tester,
    String text, {
    int index = 0,
  }) async {
    // On a phone the real keyboard shrinks the screen and lazy lists drop
    // rows; close it first so the layout is stable.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final f = find.text(text);
    if (f.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        f,
        150,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.ensureVisible(f.at(index));
    await tester.pumpAndSettle();
    await tester.tap(f.at(index));
    await tester.pumpAndSettle();
  }

  Future<void> setUpPassword(WidgetTester tester) async {
    await tapText(tester, 'Continue');
    await tester.enterText(find.byType(TextField).at(0), _password);
    await tester.enterText(find.byType(TextField).at(1), _password);
    await tapText(tester, 'I understand how my data is stored');
    await tapText(tester, 'Continue');
    // Password hashing is deliberately slow.
    for (
      var i = 0;
      i < 120 && find.text('Quick access').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pumpAndSettle();
  }

  GoRouter router(WidgetTester tester) =>
      GoRouter.of(tester.element(find.byType(Scaffold).first));

  testWidgets('first-time setup, then lock and unlock', (tester) async {
    await startApp(tester);
    expect(find.text('Welcome'), findsOneWidget);
    await setUpPassword(tester);
    expect(find.text('Quick access'), findsOneWidget);

    sl<AppLock>().lock();
    await tester.pumpAndSettle();
    expect(find.text('Unlock'), findsWidgets);
    await tester.enterText(find.byType(TextField), 'wrong-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
    // Password checks are deliberately slow, more so on a real phone.
    for (
      var i = 0;
      i < 120 && find.textContaining('Wrong password').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(find.textContaining('Wrong password'), findsOneWidget);
    await tester.enterText(find.byType(TextField), _password);
    await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
    for (
      var i = 0;
      i < 120 && find.text('Quick access').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pumpAndSettle();
    expect(sl<AppLock>().status, LockStatus.unlocked);
    expect(find.text('Quick access'), findsOneWidget);
  });

  testWidgets('a reminder is scheduled and shows on Home', (tester) async {
    await startApp(tester);
    await setUpPassword(tester);
    final at = DateTime.now().add(const Duration(days: 1));
    final when = DateTime(at.year, at.month, at.day, 9);
    final saved = await sl<RemindersRepository>().save(
      ReminderDraft(
        title: 'Pay electricity bill',
        at: when,
        repeat: RepeatFrequency.none,
      ),
    );
    expect(saved.isSuccess, isTrue);
    await tester.pumpAndSettle();

    final planned = notifications.scheduled.values.single;
    expect(planned.title, 'Pay electricity bill');
    expect(planned.kind, NotificationKind.reminder);
    expect(
      (planned.at.year, planned.at.month, planned.at.day, planned.at.hour),
      (when.year, when.month, when.day, 9),
    );
    expect(find.text('Pay electricity bill'), findsOneWidget);
  });

  testWidgets('shopping: paste → review → shop → finish → budget, once', (
    tester,
  ) async {
    await startApp(tester);
    await setUpPassword(tester);

    await tapText(tester, 'Shopping');
    await tapText(tester, 'Paste a message');
    await tester.enterText(
      find.byType(TextField),
      'Milk 2\nRice 5 kg\nTomatoes',
    );
    await tapText(tester, 'Review items');
    expect(find.text('Confirm 1 item to import'), findsOneWidget);
    await tester.enterText(
      find
          .byWidgetPredicate(
            (w) => w is TextField && w.decoration?.hintText == '?',
          )
          .at(2),
      '1',
    );
    await tester.pumpAndSettle();
    await tapText(tester, 'Import 3 items');

    await tapText(tester, 'Start shopping');
    for (final item in ['Milk', 'Rice', 'Tomatoes']) {
      await tapText(tester, item);
    }
    expect(find.text('3 / 3'), findsOneWidget);
    await tapText(tester, 'Finish shopping');
    await tester.enterText(find.byType(TextField).first, '1,846');
    await tester.pumpAndSettle();
    await tapText(tester, 'Save to history');
    expect(find.textContaining('₹1,846'), findsOneWidget);

    final now = DateTime.now();
    Future<BudgetSummary> month() => sl<BudgetRepository>()
        .watchMonth(BudgetMonth(now.year, now.month))
        .first;
    var summary = await month();
    expect(summary.expenses.single.amountPaise, 184600);
    expect(summary.expenses.single.fromShopping, isTrue);

    // Editing the trip's total later updates the same expense.
    await tester.tap(find.textContaining('₹1,846'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '1,900');
    await tester.tap(find.widgetWithText(FilledButton, 'Save').first);
    await tester.pumpAndSettle();
    summary = await month();
    expect(summary.expenses, hasLength(1));
    expect(summary.spentPaise, 190000);

    router(tester).go('/budget');
    await tester.pumpAndSettle();
    expect(find.text('₹1,900'), findsWidgets);
  });

  testWidgets('backup, then restore only the chosen category', (tester) async {
    await startApp(tester);
    await setUpPassword(tester);
    final notes = sl<NotesRepository>();
    final passwords = sl<PasswordNotesRepository>();
    final noteId = (await notes.save(
      const NoteDraft(title: 'Gate code', contentJson: '[]', plainText: '4471'),
    )).fold((_) => '', (id) => id);
    await passwords.save(const PasswordNoteDraft(name: 'Bank'));

    final service = sl<BackupService>();
    final file = await service.create({
      BackupCategory.notes,
      BackupCategory.passwords,
    }, token: CancelToken());

    // Lose the note, and add a login after the backup.
    await notes.delete(noteId);
    await passwords.save(const PasswordNoteDraft(name: 'Added later'));

    final preview = await service.inspect(file, token: CancelToken());
    expect(preview.manifest.counts[BackupCategory.notes], 1);
    await service.restore(preview, {
      BackupCategory.notes,
    }, RestoreStrategy.replace);

    final restored = await notes.watchNotes(const NotesFilter()).first;
    expect(restored.single.title, 'Gate code');
    final logins = await passwords.watch(const PasswordFilter()).first;
    expect(logins.map((l) => l.name), containsAll(['Bank', 'Added later']));

    router(tester).go('/notes');
    await tester.pumpAndSettle();
    expect(find.text('Gate code'), findsOneWidget);
  });
}

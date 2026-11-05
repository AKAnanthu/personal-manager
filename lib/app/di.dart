import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/app/flavor.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/notifications/local_notifications_platform.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/notifications/notification_planner.dart';
import 'package:personal_life_manager/core/notifications/notification_platform.dart';
import 'package:personal_life_manager/core/notifications/notification_scheduler.dart';
import 'package:personal_life_manager/core/notifications/time_zone_service.dart';
import 'package:personal_life_manager/core/platform/backup_exclusion.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/security/biometric_auth.dart';
import 'package:personal_life_manager/core/security/sensitive_clipboard.dart';
import 'package:personal_life_manager/core/storage/app_directories.dart';
import 'package:personal_life_manager/core/storage/file_access.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/storage/secure_store.dart';
import 'package:personal_life_manager/core/ui/session_notices.dart';
import 'package:personal_life_manager/core/utils/app_logger.dart';
import 'package:personal_life_manager/core/utils/money.dart';
import 'package:personal_life_manager/features/auth/data/auth_repository_impl.dart';
import 'package:personal_life_manager/features/auth/domain/auth_repository.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_platform.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_service.dart';
import 'package:personal_life_manager/features/breathing/data/breathing_services.dart';
import 'package:personal_life_manager/features/budget/data/budget_repository_impl.dart';
import 'package:personal_life_manager/features/budget/domain/budget_repository.dart';
import 'package:personal_life_manager/features/dashboard/domain/upcoming_item.dart';
import 'package:personal_life_manager/features/documents/data/documents_repository_impl.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/domain/documents_repository.dart';
import 'package:personal_life_manager/features/lending/data/lending_repository_impl.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';
import 'package:personal_life_manager/features/lending/domain/lending_repository.dart';
import 'package:personal_life_manager/features/medicine/data/medicine_repository_impl.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine_repository.dart';
import 'package:personal_life_manager/features/notes/data/notes_repository_impl.dart';
import 'package:personal_life_manager/features/notes/domain/notes_repository.dart';
import 'package:personal_life_manager/features/password_notes/data/password_notes_repository_impl.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_notes_repository.dart';
import 'package:personal_life_manager/features/personal_details/data/personal_details_repository_impl.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_details_repository.dart';
import 'package:personal_life_manager/features/reminders/data/reminders_repository_impl.dart';
import 'package:personal_life_manager/features/reminders/domain/reminders_repository.dart';
import 'package:personal_life_manager/features/settings/data/app_settings.dart';
import 'package:personal_life_manager/features/settings/data/data_eraser.dart';
import 'package:personal_life_manager/features/shopping/data/instruction_sharer.dart';
import 'package:personal_life_manager/features/shopping/data/shopping_notice.dart';
import 'package:personal_life_manager/features/shopping/data/shopping_repository_impl.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';
import 'package:personal_life_manager/features/tasks/data/tasks_repository_impl.dart';
import 'package:personal_life_manager/features/tasks/domain/tasks_repository.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

final GetIt sl = GetIt.instance;

/// Replacements for the platform-backed services, used by the integration
/// tests so they run the real app in isolation: no real data, no system
/// permission dialogs, no notifications actually scheduled.
final class DependencyOverrides {
  const DependencyOverrides({
    this.directories,
    this.database,
    this.secureStore,
    this.biometrics,
    this.notifications,
    this.timeZone,
  });

  final AppDirectories? directories;
  final AppDatabase? database;
  final SecureStore? secureStore;
  final BiometricAuth? biometrics;
  final NotificationPlatform? notifications;
  final TimeZoneService? timeZone;
}

/// Resolves storage, excludes it from OS backups and registers core services.
Future<void> configureDependencies(
  AppFlavor flavor, {
  DependencyOverrides overrides = const DependencyOverrides(),
}) async {
  final logger = AppLogger(verbose: flavor.isDev);
  final dirs = overrides.directories ?? await AppDirectories.resolve();
  if (overrides.directories == null) {
    await const BackupExclusion().exclude(dirs.root);
  }

  sl
    ..registerSingleton<AppFlavor>(flavor)
    ..registerSingleton<AppLogger>(logger)
    ..registerSingleton<AppDirectories>(dirs)
    ..registerSingleton<AppDatabase>(
      overrides.database ?? AppDatabase.open(dirs.database),
      dispose: (db) => db.close(),
    )
    ..registerSingleton<FileStore>(FileStore(dirs.files))
    ..registerSingleton<SecureStore>(
      overrides.secureStore ?? const PlatformSecureStore(),
    )
    ..registerSingleton<BiometricAuth>(
      overrides.biometrics ?? LocalBiometricAuth(),
    );

  await _clearStaleKeychainAfterReinstall(dirs, sl());
  // Leftovers from a backup or restore interrupted by the app being closed.
  if (dirs.temp.existsSync()) await dirs.temp.delete(recursive: true);

  final auth = AuthRepositoryImpl(store: sl());
  sl.registerSingleton<AuthRepository>(auth);

  // Cold start is always locked. If secure storage can't be read, treat the
  // app as set up (locked) rather than offering setup over existing data.
  final setUp = (await auth.isSetUp()).fold((_) => true, (v) => v);
  final lock = AppLock(
    initialStatus: setUp ? LockStatus.locked : LockStatus.notSetUp,
  )..attachLifecycle();
  sl.registerSingleton<AppLock>(lock, dispose: (l) => l.dispose());
  // Applies the saved auto-lock time and theme before the first frame.
  final settings = AppSettings(lock);
  await settings.load();
  sl.registerSingleton<AppSettings>(settings, dispose: (s) => s.dispose());

  await _configureNotifications(logger, overrides);
  _configureFeatures(lock);

  // Feature notification sources register above this line. The first
  // re-plan must run after them, or it would cancel their notifications.
  unawaited(sl<NotificationScheduler>().replan());
}

Future<void> _configureNotifications(
  AppLogger logger,
  DependencyOverrides overrides,
) async {
  final timeZone = overrides.timeZone ?? TimeZoneService();
  await timeZone.init();
  final platform = overrides.notifications ?? LocalNotificationsPlatform();
  final scheduler = NotificationScheduler(
    platform: platform,
    planner: NotificationPlanner(
      budget: Platform.isIOS
          ? NotificationPlanner.iosBudget
          : NotificationPlanner.androidBudget,
    ),
    timeZone: timeZone,
    logger: logger,
  );
  await scheduler.initialize();
  scheduler.attachLifecycle();
  sl
    ..registerSingleton<TimeZoneService>(timeZone)
    ..registerSingleton<NotificationPlatform>(platform)
    ..registerSingleton<NotificationScheduler>(
      scheduler,
      dispose: (s) => s.dispose(),
    );
}

void _configureFeatures(AppLock lock) {
  final scheduler = sl<NotificationScheduler>();
  void replan() => unawaited(scheduler.replan());

  final notes = NotesRepositoryImpl(db: sl(), files: sl());
  final tasks = TasksRepositoryImpl(db: sl(), onScheduleChanged: replan);
  final reminders = RemindersRepositoryImpl(
    db: sl(),
    onScheduleChanged: replan,
  );

  final documents = DocumentsRepositoryImpl(
    db: sl(),
    files: sl(),
    onScheduleChanged: replan,
  );

  final lending = LendingRepositoryImpl(db: sl(), onScheduleChanged: replan);
  final medicine = MedicineRepositoryImpl(db: sl(), onScheduleChanged: replan);

  scheduler
    ..registerSource(
      'medicine',
      () => medicine.notificationSources((m, t) {
        final l10n = _backgroundL10n();
        // Background text: the plain locale time format ("8:00 PM").
        final time = DateFormat.jm().format(
          DateTime(2000, 1, 1, t.hour, t.minute),
        );
        return (
          title: l10n.medicineNotificationTitle(m.name),
          body: l10n.medicineNotificationBody(time),
        );
      }),
    )
    ..registerSource(
      'lending',
      () => lending.notificationSources((r) {
        final l10n = _backgroundL10n();
        final amount = Money.format(r.amountPaise);
        return r.direction == LendingDirection.lent
            ? (
                title: l10n.lendingDueLentTitle(r.person),
                body: l10n.lendingDueLentBody(amount),
              )
            : (
                title: l10n.lendingDueBorrowedTitle(r.person),
                body: l10n.lendingDueBorrowedBody(amount),
              );
      }),
    )
    ..registerSource('tasks', tasks.notificationSources)
    ..registerSource('reminders', reminders.notificationSources)
    ..registerSource(
      'documents',
      () => documents.notificationSources((d) {
        final l10n = _backgroundL10n();
        return (
          title: l10n.documentExpiryNotificationTitle(d.title),
          body: l10n.documentExpiryNotificationBody(expiryReminderLead.inDays),
        );
      }),
    );

  sl
    ..registerSingleton<NotificationPermissions>(scheduler)
    ..registerSingleton<FilePickers>(PlatformFilePickers(lock))
    ..registerSingleton<FileOpener>(PlatformFileOpener(lock))
    ..registerSingleton<NotesRepository>(notes)
    ..registerSingleton<TasksRepository>(tasks)
    ..registerSingleton<RemindersRepository>(reminders)
    ..registerSingleton<DocumentsRepository>(documents)
    ..registerSingleton<BudgetRepository>(BudgetRepositoryImpl(db: sl()))
    ..registerSingleton<LendingRepository>(lending)
    ..registerSingleton<MedicineRepository>(medicine)
    ..registerSingleton<BreathingSettingsStore>(PrefsBreathingSettingsStore())
    ..registerSingleton<BackupFiles>(PlatformBackupFiles(lock))
    ..registerSingleton<LastBackupStore>(PrefsLastBackupStore())
    ..registerLazySingleton<DataEraser>(
      () => DataEraser(
        db: sl(),
        filesDir: sl<AppDirectories>().files,
        tempDir: sl<AppDirectories>().temp,
        secure: sl(),
        settings: sl(),
        clearNotifications: scheduler.cancelAll,
        lock: lock,
      ),
    )
    ..registerLazySingleton<BackupService>(
      () => BackupService(
        db: sl(),
        files: sl(),
        prefs: AppPreferencesBackup(sl(), sl()),
        tempDir: sl<AppDirectories>().temp,
        // Set by `flutter build` from pubspec.yaml's version.
        appVersion: const String.fromEnvironment(
          'FLUTTER_BUILD_NAME',
          defaultValue: 'dev',
        ),
        platform: Platform.operatingSystem,
        // Restored reminders, tasks, medicine, lending and documents need
        // their notifications rescheduled.
        onRestored: scheduler.replan,
      ),
    )
    ..registerSingleton<ShoppingRepository>(
      ShoppingRepositoryImpl(
        db: sl(),
        files: sl(),
        notice: SchedulerShoppingNotice(scheduler, (list) {
          final l10n = _backgroundL10n();
          final left = list.pending;
          return (
            title: l10n.shoppingNoticeTitle(left.length, list.name),
            body: [
              for (final i in left)
                if (i.amountLabel.isEmpty)
                  i.name
                else
                  '${i.name} · ${i.amountLabel}',
            ].join('\n'),
          );
        }),
      ),
    )
    ..registerSingleton<InstructionSharer>(PlatformInstructionSharer(lock))
    ..registerSingleton<PersonalDetailsRepository>(
      PersonalDetailsRepositoryImpl(db: sl()),
    )
    ..registerSingleton<PasswordNotesRepository>(
      PasswordNotesRepositoryImpl(db: sl()),
    )
    ..registerSingleton<SensitiveClipboard>(const PlatformSensitiveClipboard())
    ..registerSingleton<SessionNotices>(SessionNotices())
    // Dashboard "Coming up" (no budget data, by design).
    ..registerSingleton<List<UpcomingSource>>([
      () => reminders.watchOpen().map(
        (list) => [
          for (final r in list)
            UpcomingItem(
              kind: UpcomingKind.reminder,
              title: r.title,
              at: r.effectiveAt,
              route: '/reminders/${r.id}',
            ),
        ],
      ),
      () => tasks
          .watchTasks(completed: false)
          .map(
            (list) => [
              for (final t in list)
                if (t.reminderAt ?? t.dueDate case final at?)
                  UpcomingItem(
                    kind: UpcomingKind.task,
                    title: t.title,
                    at: at,
                    hasTime: t.reminderAt != null,
                    route: '/tasks/${t.id}',
                  ),
            ],
          ),
      () => lending.watchUpcomingDue().map(
        (list) => [
          for (final r in list)
            if (r.dueOn case final due?)
              UpcomingItem(
                kind: UpcomingKind.lending,
                title: r.person,
                at: due,
                hasTime: false,
                route: '/lending/${r.id}',
              ),
        ],
      ),
      // Each enabled medicine's next dose within the next day.
      () => medicine.watchAll().map((list) {
        final now = DateTime.now();
        return [
          for (final m in list)
            if (nextDose([m], now) case final d?
                when d.at.difference(now) < const Duration(days: 1))
              UpcomingItem(
                kind: UpcomingKind.medicine,
                title: m.name,
                at: d.at,
                route: '/medicine/${m.id}',
              ),
        ];
      }),
      () => documents
          .watchExpiringSoon(DateTime.now())
          .map(
            (list) => [
              for (final d in list)
                if (d.expiryDate case final at?)
                  UpcomingItem(
                    kind: UpcomingKind.documentExpiry,
                    title: d.title,
                    at: at,
                    hasTime: false,
                    route: '/documents/${d.id}',
                  ),
            ],
          ),
    ]);
}

/// Strings for text built outside the widget tree (notification content).
AppLocalizations _backgroundL10n() {
  final locale = PlatformDispatcher.instance.locale;
  return lookupAppLocalizations(
    AppLocalizations.supportedLocales.any(
          (l) => l.languageCode == locale.languageCode,
        )
        ? Locale(locale.languageCode)
        : const Locale('en'),
  );
}

/// iOS keeps Keychain items after uninstall while app files are deleted. A
/// missing install marker means a fresh install, so an old password hash
/// must not lock the user out of a now-empty app.
Future<void> _clearStaleKeychainAfterReinstall(
  AppDirectories dirs,
  SecureStore store,
) async {
  final marker = File(p.join(dirs.root.path, '.installed'));
  if (marker.existsSync()) return;
  await store.deleteAll();
  await marker.create(recursive: true);
}

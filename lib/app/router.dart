import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_life_manager/app/di.dart';
import 'package:personal_life_manager/app/modules.dart';
import 'package:personal_life_manager/app/shell/app_shell.dart';
import 'package:personal_life_manager/app/shell/more_page.dart';
import 'package:personal_life_manager/core/drive/drive_auth.dart';
import 'package:personal_life_manager/core/drive/drive_copier.dart';
import 'package:personal_life_manager/core/drive/drive_folders.dart';
import 'package:personal_life_manager/core/drive/drive_service.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/security/secure_screen.dart';
import 'package:personal_life_manager/core/security/sensitive_clipboard.dart';
import 'package:personal_life_manager/core/storage/app_directories.dart';
import 'package:personal_life_manager/core/storage/file_access.dart';
import 'package:personal_life_manager/core/sync/sync_engine.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/account/data/account_session.dart';
import 'package:personal_life_manager/features/account/presentation/account_cubit.dart';
import 'package:personal_life_manager/features/account/presentation/account_page.dart';
import 'package:personal_life_manager/features/account/presentation/sign_in_cubit.dart';
import 'package:personal_life_manager/features/account/presentation/sign_in_page.dart';
import 'package:personal_life_manager/features/account/presentation/sync_button.dart';
import 'package:personal_life_manager/features/account/presentation/unlock_page.dart';
import 'package:personal_life_manager/features/backup_restore/presentation/backup_cubits.dart';
import 'package:personal_life_manager/features/backup_restore/presentation/backup_page.dart';
import 'package:personal_life_manager/features/breathing/data/breathing_services.dart';
import 'package:personal_life_manager/features/breathing/presentation/breathe_page.dart';
import 'package:personal_life_manager/features/breathing/presentation/breathing_settings_cubit.dart';
import 'package:personal_life_manager/features/budget/presentation/budget_cubit.dart';
import 'package:personal_life_manager/features/budget/presentation/budget_page.dart';
import 'package:personal_life_manager/features/budget/presentation/expense_form_cubit.dart';
import 'package:personal_life_manager/features/budget/presentation/expense_form_page.dart';
import 'package:personal_life_manager/features/dashboard/presentation/dashboard_cubit.dart';
import 'package:personal_life_manager/features/dashboard/presentation/dashboard_page.dart';
import 'package:personal_life_manager/features/documents/data/document_uploader.dart';
import 'package:personal_life_manager/features/documents/presentation/document_form_cubit.dart';
import 'package:personal_life_manager/features/documents/presentation/document_form_page.dart';
import 'package:personal_life_manager/features/documents/presentation/document_view_cubit.dart';
import 'package:personal_life_manager/features/documents/presentation/document_view_page.dart';
import 'package:personal_life_manager/features/documents/presentation/document_widgets.dart';
import 'package:personal_life_manager/features/documents/presentation/documents_bloc.dart';
import 'package:personal_life_manager/features/documents/presentation/documents_page.dart';
import 'package:personal_life_manager/features/documents/presentation/linked_documents.dart';
import 'package:personal_life_manager/features/drive_storage/presentation/drive_browser_cubit.dart';
import 'package:personal_life_manager/features/drive_storage/presentation/drive_storage_page.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';
import 'package:personal_life_manager/features/lending/presentation/lending_cubit.dart';
import 'package:personal_life_manager/features/lending/presentation/lending_form_cubit.dart';
import 'package:personal_life_manager/features/lending/presentation/lending_form_page.dart';
import 'package:personal_life_manager/features/lending/presentation/lending_page.dart';
import 'package:personal_life_manager/features/medicine/presentation/medicine_cubits.dart';
import 'package:personal_life_manager/features/medicine/presentation/medicine_form_page.dart';
import 'package:personal_life_manager/features/medicine/presentation/medicine_page.dart';
import 'package:personal_life_manager/features/notes/presentation/note_editor_cubit.dart';
import 'package:personal_life_manager/features/notes/presentation/note_editor_page.dart';
import 'package:personal_life_manager/features/notes/presentation/notes_list_bloc.dart';
import 'package:personal_life_manager/features/notes/presentation/notes_page.dart';
import 'package:personal_life_manager/features/password_notes/presentation/password_form_cubit.dart';
import 'package:personal_life_manager/features/password_notes/presentation/password_form_page.dart';
import 'package:personal_life_manager/features/password_notes/presentation/passwords_bloc.dart';
import 'package:personal_life_manager/features/password_notes/presentation/passwords_page.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';
import 'package:personal_life_manager/features/personal_details/presentation/entry_editor_cubit.dart';
import 'package:personal_life_manager/features/personal_details/presentation/entry_editor_page.dart';
import 'package:personal_life_manager/features/personal_details/presentation/entry_view_cubit.dart';
import 'package:personal_life_manager/features/personal_details/presentation/entry_view_page.dart';
import 'package:personal_life_manager/features/personal_details/presentation/personal_bloc.dart';
import 'package:personal_life_manager/features/personal_details/presentation/personal_page.dart';
import 'package:personal_life_manager/features/reminders/presentation/reminder_form_cubit.dart';
import 'package:personal_life_manager/features/reminders/presentation/reminder_form_page.dart';
import 'package:personal_life_manager/features/reminders/presentation/reminders_cubit.dart';
import 'package:personal_life_manager/features/reminders/presentation/reminders_page.dart';
import 'package:personal_life_manager/features/settings/presentation/privacy_page.dart';
import 'package:personal_life_manager/features/settings/presentation/settings_cubits.dart';
import 'package:personal_life_manager/features/settings/presentation/settings_page.dart';
import 'package:personal_life_manager/features/shopping/data/instruction_sharer.dart';
import 'package:personal_life_manager/features/shopping/presentation/completion_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/completion_page.dart';
import 'package:personal_life_manager/features/shopping/presentation/history_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/history_page.dart';
import 'package:personal_life_manager/features/shopping/presentation/import_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/import_page.dart';
import 'package:personal_life_manager/features/shopping/presentation/list_editor_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/list_editor_page.dart';
import 'package:personal_life_manager/features/shopping/presentation/session_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/session_page.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_home_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_home_page.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_routes.dart';
import 'package:personal_life_manager/features/tasks/presentation/task_editor_cubit.dart';
import 'package:personal_life_manager/features/tasks/presentation/task_editor_page.dart';
import 'package:personal_life_manager/features/tasks/presentation/tasks_bloc.dart';
import 'package:personal_life_manager/features/tasks/presentation/tasks_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

abstract final class AppRoutes {
  static const signIn = '/sign-in';
  static const unlock = '/unlock';
  static const home = '/home';
  static const documents = '/documents';
  static const shopping = '/shopping';
  static const more = '/more';

  /// Query parameter carrying the location to continue to after unlock.
  static const fromParam = 'from';
}

/// Lock guard. Pure so it can be unit-tested.
///
/// - privacy policy and terms → always (also before signing in)
/// - not signed in → `/sign-in`
/// - locked → `/unlock?from=<original location>` (deep links resume after)
/// - unlocked on an auth route → the saved `from` location, else home
String? lockRedirect(LockStatus status, Uri uri) {
  final path = uri.path;
  if (path == LegalRoutes.privacy || path == LegalRoutes.terms) return null;
  final onAuthRoute = path == AppRoutes.signIn || path == AppRoutes.unlock;
  switch (status) {
    case LockStatus.notSetUp:
      return path == AppRoutes.signIn ? null : AppRoutes.signIn;
    case LockStatus.locked:
      if (path == AppRoutes.unlock) return null;
      if (onAuthRoute) return AppRoutes.unlock;
      return Uri(
        path: AppRoutes.unlock,
        queryParameters: {AppRoutes.fromParam: uri.toString()},
      ).toString();
    case LockStatus.unlocked:
      if (!onAuthRoute) return null;
      final from = uri.queryParameters[AppRoutes.fromParam];
      return _isSafeInternal(from) ? from : AppRoutes.home;
  }
}

/// Only in-app paths; rejects `//host`, schemes and auth routes (loops).
bool _isSafeInternal(String? location) {
  if (location == null || !location.startsWith('/')) return false;
  if (location.startsWith('//')) return false;
  final path = Uri.tryParse(location)?.path;
  return path != null && path != AppRoutes.signIn && path != AppRoutes.unlock;
}

GoRouter buildRouter({required AppLock lock, String? initialLocation}) =>
    GoRouter(
      initialLocation: initialLocation ?? AppRoutes.home,
      refreshListenable: lock,
      redirect: (context, state) => lockRedirect(lock.status, state.uri),
      routes: [
        GoRoute(
          path: AppRoutes.signIn,
          builder: (context, state) => BlocProvider(
            create: (_) => SignInCubit(
              session: sl(),
              sync: sl(),
              deviceLock: sl(),
              settings: sl(),
              lock: lock,
            ),
            child: const SignInPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.unlock,
          builder: (context, state) => BlocProvider(
            create: (_) =>
                UnlockCubit(deviceLock: sl(), settings: sl(), lock: lock),
            child: const UnlockPage(),
          ),
        ),
        GoRoute(
          path: LegalRoutes.privacy,
          builder: (context, state) => const PrivacyPage(),
        ),
        GoRoute(
          path: LegalRoutes.terms,
          builder: (context, state) => const TermsPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(shell: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (context, state) => BlocProvider(
                    create: (_) => DashboardCubit(sl())..start(),
                    child: DashboardPage(
                      onLock: lock.lock,
                      // Resolved lazily: tests may run without sync set up.
                      syncAction: sl.isRegistered<SyncEngine>()
                          ? SyncButton(
                              status: sl<SyncEngine>().status,
                              onSync: sl<AccountSession>().syncNow,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.documents,
                  builder: (context, state) => BlocProvider(
                    create: (_) =>
                        DocumentsBloc(sl())..add(const DocumentsStarted()),
                    child: const DocumentsPage(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.shopping,
                  builder: (context, state) => BlocProvider(
                    create: (_) => ShoppingHomeCubit(sl())..start(),
                    child: ShoppingHomePage(sharer: sl<InstructionSharer>()),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.more,
                  builder: (context, state) => const MorePage(),
                ),
              ],
            ),
          ],
        ),
        ..._noteRoutes(),
        ..._taskRoutes(),
        ..._reminderRoutes(),
        ..._personalRoutes(),
        ..._passwordRoutes(),
        ..._documentRoutes(),
        ..._shoppingRoutes(),
        ..._budgetRoutes(),
        ..._lendingRoutes(),
        ..._medicineRoutes(),
        GoRoute(
          path: SettingsRoutes.root,
          builder: (context, state) => BlocProvider(
            create: (_) {
              final cubit = SettingsCubit(
                permissions: sl(),
                settings: sl(),
                lastBackup: sl(),
              );
              unawaited(cubit.load());
              return cubit;
            },
            child: SettingsPage(
              appVersion: const String.fromEnvironment(
                'FLUTTER_BUILD_NAME',
                defaultValue: 'dev',
              ),
              driveAccount: sl<DriveAuth>().account,
            ),
          ),
          routes: [
            GoRoute(
              path: 'account',
              builder: (context, state) => BlocProvider(
                create: (_) {
                  final cubit = AccountCubit(
                    session: sl(),
                    sync: sl(),
                    settings: sl(),
                    lock: lock,
                  );
                  unawaited(cubit.load());
                  return cubit;
                },
                child: const AccountPage(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppModule.backup.route,
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) {
                  final cubit = BackupCubit(
                    service: sl(),
                    files: sl(),
                    last: sl(),
                    drive: _backupDrive(),
                  );
                  unawaited(cubit.load());
                  return cubit;
                },
              ),
              BlocProvider(
                create: (_) => RestoreCubit(
                  service: sl(),
                  files: sl(),
                  drive: _backupDrive(),
                  tempDir: sl<AppDirectories>().temp,
                ),
              ),
            ],
            child: const BackupPage(),
          ),
        ),
        GoRoute(
          path: AppModule.breathe.route,
          builder: (context, state) => BlocProvider(
            create: (_) {
              final cubit = BreathingSettingsCubit(sl());
              unawaited(cubit.load());
              return cubit;
            },
            child: BreathePage(feedback: PlatformBreathingFeedback()),
          ),
        ),
        GoRoute(
          path: AppModule.drive.route,
          builder: (context, state) => _secure(
            BlocProvider(
              create: (_) {
                final cubit = DriveBrowserCubit(
                  auth: sl(),
                  drive: sl(),
                  folders: sl(),
                  tempDir: sl<AppDirectories>().temp,
                );
                unawaited(cubit.start());
                return cubit;
              },
              child: DriveStoragePage(pickers: sl(), opener: sl(), saver: sl()),
            ),
          ),
        ),
      ],
    );

BackupDrive _backupDrive() => BackupDrive(
  auth: sl<DriveAuth>(),
  service: sl<DriveService>(),
  folders: sl<DriveFolders>(),
);

List<GoRoute> _noteRoutes() {
  Widget editor(String? id) => BlocProvider(
    create: (_) {
      final cubit = NoteEditorCubit(
        repository: sl(),
        pickers: sl(),
        noteId: id,
      );
      unawaited(cubit.load());
      return cubit;
    },
    child: NoteEditorPage(opener: sl<FileOpener>()),
  );
  return [
    GoRoute(
      path: AppModule.notes.route,
      builder: (context, state) => BlocProvider(
        create: (_) => NotesListBloc(sl())..add(const NotesStarted()),
        child: const NotesPage(),
      ),
      routes: [
        GoRoute(path: 'new', builder: (context, state) => editor(null)),
        GoRoute(
          path: ':id',
          builder: (context, state) => editor(state.pathParameters['id']),
        ),
      ],
    ),
  ];
}

List<GoRoute> _taskRoutes() {
  Widget editor(String? id) => BlocProvider(
    create: (_) {
      final cubit = TaskEditorCubit(
        repository: sl(),
        permissions: sl(),
        taskId: id,
      );
      unawaited(cubit.load());
      return cubit;
    },
    child: TaskEditorPage(permissions: sl<NotificationPermissions>()),
  );
  return [
    GoRoute(
      path: AppModule.tasks.route,
      builder: (context, state) => BlocProvider(
        create: (_) => TasksBloc(sl())..add(const TasksStarted()),
        child: const TasksPage(),
      ),
      routes: [
        GoRoute(path: 'new', builder: (context, state) => editor(null)),
        GoRoute(
          path: ':id',
          builder: (context, state) => editor(state.pathParameters['id']),
        ),
      ],
    ),
  ];
}

List<GoRoute> _reminderRoutes() {
  Widget form(String? id) => BlocProvider(
    create: (_) {
      final cubit = ReminderFormCubit(
        repository: sl(),
        permissions: sl(),
        reminderId: id,
      );
      unawaited(cubit.load());
      return cubit;
    },
    child: ReminderFormPage(permissions: sl<NotificationPermissions>()),
  );
  return [
    GoRoute(
      path: AppModule.reminders.route,
      builder: (context, state) => BlocProvider(
        create: (_) => RemindersCubit(sl())..start(),
        child: const RemindersPage(),
      ),
      routes: [
        GoRoute(path: 'new', builder: (context, state) => form(null)),
        GoRoute(
          path: ':id',
          builder: (context, state) => form(state.pathParameters['id']),
        ),
      ],
    ),
  ];
}

/// Personal details and password notes show ID numbers and passwords, so
/// every page is a [SecureScreen] (no screenshots or Recents thumbnail).
Widget _secure(Widget child) => SecureScreen(child: child);

List<GoRoute> _personalRoutes() {
  Widget editor({DetailKind? kind, String? id}) => _secure(
    BlocProvider(
      create: (_) {
        final cubit = EntryEditorCubit(
          repository: sl(),
          kind: kind,
          entryId: id,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: EntryEditorPage(documents: sl()),
    ),
  );
  return [
    GoRoute(
      path: AppModule.personal.route,
      builder: (context, state) => _secure(
        BlocProvider(
          create: (_) => PersonalBloc(sl())..add(const PersonalStarted()),
          child: PersonalPage(clipboard: sl<SensitiveClipboard>()),
        ),
      ),
      routes: [
        GoRoute(
          path: 'profile',
          builder: (context, state) => editor(kind: DetailKind.profile),
        ),
        GoRoute(
          path: 'new/:kind',
          redirect: (context, state) =>
              _detailKind(state.pathParameters['kind']) == null
              ? AppModule.personal.route
              : null,
          builder: (context, state) =>
              editor(kind: _detailKind(state.pathParameters['kind'])),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => _secure(
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => EntryViewCubit(
                    repository: sl(),
                    entryId: state.pathParameters['id'] ?? '',
                  )..start(),
                ),
                BlocProvider(create: (_) => LinkedDocumentsCubit(sl())),
              ],
              child: EntryViewPage(clipboard: sl<SensitiveClipboard>()),
            ),
          ),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) =>
                  editor(id: state.pathParameters['id']),
            ),
          ],
        ),
      ],
    ),
  ];
}

/// Profile has its own route; anything else unknown is rejected.
DetailKind? _detailKind(String? name) => DetailKind.values
    .where((k) => k.name == name && k != DetailKind.profile)
    .firstOrNull;

List<GoRoute> _passwordRoutes() {
  Widget form(String? id) => _secure(
    BlocProvider(
      create: (_) {
        final cubit = PasswordFormCubit(repository: sl(), noteId: id);
        unawaited(cubit.load());
        return cubit;
      },
      child: const PasswordFormPage(),
    ),
  );
  return [
    GoRoute(
      path: AppModule.passwords.route,
      builder: (context, state) => _secure(
        BlocProvider(
          create: (_) =>
              PasswordsBloc(sl(), sl())..add(const PasswordsStarted()),
          child: PasswordsPage(clipboard: sl<SensitiveClipboard>()),
        ),
      ),
      routes: [
        GoRoute(path: 'new', builder: (context, state) => form(null)),
        GoRoute(
          path: ':id',
          builder: (context, state) => form(state.pathParameters['id']),
        ),
      ],
    ),
  ];
}

/// Add/view/edit sit outside the tab shell (full-screen, no nav bar). They
/// show scans of IDs, so they are secure screens too.
List<GoRoute> _documentRoutes() {
  Widget form(String? id) => _secure(
    BlocProvider(
      create: (_) {
        final cubit = DocumentFormCubit(
          repository: sl(),
          pickers: sl(),
          permissions: sl(),
          documentId: id,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: DocumentFormPage(permissions: sl<NotificationPermissions>()),
    ),
  );
  return [
    GoRoute(path: DocumentRoutes.add, builder: (context, state) => form(null)),
    GoRoute(
      path: '${DocumentRoutes.root}/:id',
      builder: (context, state) => _secure(
        BlocProvider(
          create: (_) => DocumentViewCubit(
            repository: sl(),
            documentId: state.pathParameters['id'] ?? '',
            uploader: sl<DocumentUploader>(),
            driveAuth: sl<DriveAuth>(),
          )..start(),
          child: DocumentViewPage(opener: sl<FileOpener>()),
        ),
      ),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) => form(state.pathParameters['id']),
        ),
      ],
    ),
  ];
}

List<GoRoute> _budgetRoutes() {
  Widget form(String? id) => BlocProvider(
    create: (_) {
      final cubit = ExpenseFormCubit(repository: sl(), expenseId: id);
      unawaited(cubit.load());
      return cubit;
    },
    child: const ExpenseFormPage(),
  );
  return [
    GoRoute(
      path: BudgetRoutes.root,
      builder: (context, state) => BlocProvider(
        create: (_) => BudgetCubit(sl())..start(),
        child: const BudgetPage(),
      ),
      routes: [
        GoRoute(path: 'expenses/new', builder: (context, state) => form(null)),
        GoRoute(
          path: 'expenses/:id',
          builder: (context, state) => form(state.pathParameters['id']),
        ),
      ],
    ),
  ];
}

List<GoRoute> _lendingRoutes() {
  Widget form({String? id, LendingDirection? direction}) => BlocProvider(
    create: (_) {
      final cubit = LendingFormCubit(
        repository: sl(),
        permissions: sl(),
        recordId: id,
        initialDirection: direction ?? LendingDirection.lent,
      );
      unawaited(cubit.load());
      return cubit;
    },
    child: LendingFormPage(permissions: sl<NotificationPermissions>()),
  );
  return [
    GoRoute(
      path: LendingRoutes.root,
      builder: (context, state) => BlocProvider(
        create: (_) => LendingCubit(sl())..start(),
        child: const LendingPage(),
      ),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => form(
            direction: LendingDirection.values
                .where((d) => d.name == state.uri.queryParameters['dir'])
                .firstOrNull,
          ),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => form(id: state.pathParameters['id']),
        ),
      ],
    ),
  ];
}

List<GoRoute> _medicineRoutes() {
  Widget form(String? id) => BlocProvider(
    create: (_) {
      final cubit = MedicineFormCubit(
        repository: sl(),
        permissions: sl(),
        medicineId: id,
      );
      unawaited(cubit.load());
      return cubit;
    },
    child: MedicineFormPage(permissions: sl<NotificationPermissions>()),
  );
  return [
    GoRoute(
      path: MedicineRoutes.root,
      builder: (context, state) => BlocProvider(
        create: (_) => MedicineListCubit(sl())..start(),
        child: const MedicinePage(),
      ),
      routes: [
        GoRoute(path: 'new', builder: (context, state) => form(null)),
        GoRoute(
          path: ':id',
          builder: (context, state) => form(state.pathParameters['id']),
        ),
      ],
    ),
  ];
}

/// Full-screen shopping flows (outside the tab shell).
List<GoRoute> _shoppingRoutes() {
  // The default name is worked out while building the route, not inside
  // the lazy `create` (which must not depend on inherited widgets).
  Widget editor(BuildContext context, {String? listId, String? copyFromId}) {
    final defaultName = AppLocalizations.of(
      context,
    ).shoppingDefaultListName(AppFormats.of(context).shortDate(DateTime.now()));
    return BlocProvider(
      create: (_) {
        final cubit = ListEditorCubit(
          repository: sl(),
          listId: listId,
          copyFromId: copyFromId,
        );
        unawaited(cubit.load(defaultName: defaultName));
        return cubit;
      },
      child: const ListEditorPage(),
    );
  }

  Widget completion(String id) => BlocProvider(
    create: (_) {
      final cubit = CompletionCubit(
        repository: sl(),
        pickers: sl(),
        listId: id,
      );
      unawaited(cubit.load());
      return cubit;
    },
    child: const CompletionPage(),
  );
  return [
    GoRoute(
      path: ShoppingRoutes.newList,
      builder: (context, state) =>
          editor(context, copyFromId: state.uri.queryParameters['from']),
    ),
    GoRoute(
      path: ShoppingRoutes.import,
      builder: (context, state) => BlocProvider(
        create: (_) => ImportCubit(sl()),
        child: const ImportPage(),
      ),
    ),
    GoRoute(
      path: ShoppingRoutes.session,
      builder: (context, state) => BlocProvider(
        create: (_) => SessionCubit(sl())..start(),
        child: const SessionPage(),
      ),
    ),
    GoRoute(
      path: '/shopping/lists/:id',
      builder: (context, state) =>
          editor(context, listId: state.pathParameters['id']),
      routes: [
        GoRoute(
          path: 'finish',
          builder: (context, state) =>
              completion(state.pathParameters['id'] ?? ''),
        ),
      ],
    ),
    GoRoute(
      path: '/shopping/history/:id',
      builder: (context, state) => BlocProvider(
        create: (_) => HistoryCubit(
          repository: sl(),
          listId: state.pathParameters['id'] ?? '',
          drive: sl<DriveCopier>(),
        )..start(),
        child: const HistoryPage(),
      ),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) =>
              completion(state.pathParameters['id'] ?? ''),
        ),
      ],
    ),
  ];
}

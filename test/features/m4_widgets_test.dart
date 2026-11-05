import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/storage/file_access.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/features/dashboard/domain/upcoming_item.dart';
import 'package:personal_life_manager/features/dashboard/presentation/dashboard_cubit.dart';
import 'package:personal_life_manager/features/dashboard/presentation/dashboard_page.dart';
import 'package:personal_life_manager/features/notes/domain/note.dart';
import 'package:personal_life_manager/features/notes/domain/notes_repository.dart';
import 'package:personal_life_manager/features/notes/presentation/note_editor_cubit.dart';
import 'package:personal_life_manager/features/notes/presentation/note_editor_page.dart';
import 'package:personal_life_manager/features/reminders/domain/reminder.dart';
import 'package:personal_life_manager/features/reminders/domain/reminders_repository.dart';
import 'package:personal_life_manager/features/reminders/presentation/reminders_cubit.dart';
import 'package:personal_life_manager/features/reminders/presentation/reminders_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';
import 'package:personal_life_manager/l10n/locales.dart';

class _Reminders extends Mock implements RemindersRepository;

class _Notes extends Mock implements NotesRepository;

class _Pickers extends Mock implements FilePickers;

class _Opener extends Mock implements FileOpener;

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  localizationsDelegates: const [
    ...AppLocalizations.localizationsDelegates,
    FlutterQuillLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
  ],
  supportedLocales: appSupportedLocales,
  locale: const Locale('en', 'IN'),
  home: child,
);

void main() {
  final now = DateTime(2026, 11, 3, 18);

  setUpAll(
    () => registerFallbackValue(
      const NoteDraft(title: '', contentJson: '[]', plainText: ''),
    ),
  );

  testWidgets('reminders: overdue card actions and upcoming list', (
    tester,
  ) async {
    final repo = _Reminders();
    when(repo.watchOpen).thenAnswer(
      (_) => Stream.value([
        Reminder(
          id: 'o',
          title: 'Recharge mobile plan',
          description: '',
          anchorAt: DateTime(2026, 10, 2, 19),
          dueAt: DateTime(2026, 11, 2, 19),
          repeat: RepeatFrequency.monthly,
          isCompleted: false,
        ),
        Reminder(
          id: 'u',
          title: 'Pay electricity bill',
          description: '',
          anchorAt: DateTime(2026, 11, 4, 10),
          dueAt: DateTime(2026, 11, 4, 10),
          repeat: RepeatFrequency.none,
          isCompleted: false,
        ),
      ]),
    );
    when(() => repo.markDone('o')).thenAnswer((_) async => const Ok(null));

    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) => RemindersCubit(repo, clock: () => now)..start(),
          child: const RemindersPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('OVERDUE · 1'), findsOneWidget);
    expect(find.textContaining('Yesterday'), findsOneWidget);
    expect(find.text('Pay electricity bill'), findsOneWidget);
    expect(find.textContaining('Tomorrow, 10:00 AM · Once'), findsOneWidget);

    await tester.tap(find.text('Mark done'));
    await tester.pump();
    verify(() => repo.markDone('o')).called(1);
    expect(find.text('Marked done'), findsOneWidget);

    // Timers from the cubit's minute tick.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('dashboard: coming up, quick add, and no budget figures', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: BlocProvider(
            create: (_) => DashboardCubit([
              () => Stream.value([
                UpcomingItem(
                  kind: UpcomingKind.task,
                  title: 'Renew car insurance',
                  at: DateTime(2026, 11, 12),
                  hasTime: false,
                  route: '/tasks/1',
                ),
              ]),
            ], clock: () => now)..start(),
            child: DashboardPage(onLock: () {}),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Good evening'), findsOneWidget);
    expect(find.text('Renew car insurance'), findsOneWidget);
    expect(find.text('Task · Due 12 Nov'), findsOneWidget);
    expect(find.bySemanticsLabel('New reminder'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget, reason: 'shortcut only');
    expect(find.textContaining('₹'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('note editor: typing a title and saving creates the note', (
    tester,
  ) async {
    final repo = _Notes();
    when(() => repo.save(any())).thenAnswer((_) async => const Ok('n1'));

    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) {
            final c = NoteEditorCubit(repository: repo, pickers: _Pickers());
            unawaited(c.load());
            return c;
          },
          child: NoteEditorPage(opener: _Opener()),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, 'Wi-Fi info');
    await tester.tap(find.text('Save'));
    await tester.pump();

    final draft =
        verify(() => repo.save(captureAny())).captured.single as NoteDraft;
    expect(draft.title, 'Wi-Fi info');
    expect(draft.id, isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('note editor: an empty new note is discarded, not saved', (
    tester,
  ) async {
    final repo = _Notes();
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) {
            final c = NoteEditorCubit(repository: repo, pickers: _Pickers());
            unawaited(c.load());
            return c;
          },
          child: NoteEditorPage(opener: _Opener()),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();

    verifyNever(() => repo.save(any()));
    // Dispose the editor so its cursor-blink timer stops.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}

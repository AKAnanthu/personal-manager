import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/security/sensitive_clipboard.dart';
import 'package:personal_life_manager/core/ui/session_notices.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_note.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_notes_repository.dart';
import 'package:personal_life_manager/features/password_notes/presentation/passwords_bloc.dart';
import 'package:personal_life_manager/features/password_notes/presentation/passwords_page.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_details_repository.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';
import 'package:personal_life_manager/features/personal_details/presentation/personal_bloc.dart';
import 'package:personal_life_manager/features/personal_details/presentation/personal_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';
import 'package:personal_life_manager/l10n/locales.dart';

class _Passwords extends Mock implements PasswordNotesRepository;

class _Personal extends Mock implements PersonalDetailsRepository;

class _Clipboard implements SensitiveClipboard {
  final copies = <(String, bool)>[];

  @override
  Future<void> copy(String text, {bool sensitive = true}) async =>
      copies.add((text, sensitive));
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

void main() {
  setUpAll(() => registerFallbackValue(const PasswordFilter()));

  testWidgets('password notes: dismiss warning, expand, reveal, copy', (
    tester,
  ) async {
    final repo = _Passwords();
    final clipboard = _Clipboard();
    when(() => repo.watch(any())).thenAnswer(
      (_) => Stream.value(const [
        PasswordNote(
          id: 'e',
          name: 'Electricity board',
          url: '',
          username: '1156 0402',
          password: 'hunter22',
          notes: 'Uses consumer number',
          category: 'Bills',
          isFavourite: false,
        ),
      ]),
    );
    when(repo.watchCategories).thenAnswer((_) => Stream.value(['Bills']));
    final notices = SessionNotices();

    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) =>
              PasswordsBloc(repo, notices)..add(const PasswordsStarted()),
          child: PasswordsPage(clipboard: clipboard),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Saved without encryption'), findsOneWidget);
    expect(find.text('1156 0402 · Bills'), findsOneWidget);
    expect(find.text('hunter22'), findsNothing);

    // The collapsed row copies the password, marked sensitive.
    await tester.tap(find.byTooltip('Copy password for Electricity board'));
    await tester.pump();
    expect(clipboard.copies.single, ('hunter22', true));
    expect(find.textContaining('cleared from the clipboard'), findsOneWidget);

    await tester.tap(find.byTooltip('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Saved without encryption'), findsNothing);
    expect(notices.passwordWarningDismissed, isTrue);

    await tester.tap(find.text('Electricity board'));
    await tester.pumpAndSettle();
    expect(find.text('Uses consumer number'), findsOneWidget);
    expect(find.text('hunter22'), findsNothing);
    await tester.tap(find.byTooltip('Show Password'));
    await tester.pump();
    expect(find.text('hunter22'), findsOneWidget);

    // Username copies are not sensitive.
    await tester.tap(find.byTooltip('Copy Username or email'));
    await tester.pump();
    expect(clipboard.copies.last, ('1156 0402', false));
  });

  testWidgets('password notes: empty state', (tester) async {
    final repo = _Passwords();
    when(() => repo.watch(any())).thenAnswer((_) => Stream.value(const []));
    when(repo.watchCategories).thenAnswer((_) => Stream.value(const []));
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) =>
              PasswordsBloc(repo, SessionNotices())
                ..add(const PasswordsStarted()),
          child: PasswordsPage(clipboard: _Clipboard()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No password notes yet'), findsOneWidget);
  });

  testWidgets('personal details: profile card, IDs tab masks and copies', (
    tester,
  ) async {
    final repo = _Personal();
    final clipboard = _Clipboard();
    when(repo.watchProfile).thenAnswer(
      (_) => Stream.value(
        PersonalEntry(
          id: 'me',
          kind: DetailKind.profile,
          title: '',
          fields: const [
            DetailField(key: 'fullName', value: 'Asha Menon'),
            DetailField(key: 'dateOfBirth', value: '1992-03-14'),
          ],
          updatedAt: DateTime(2026),
        ),
      ),
    );
    when(() => repo.watchCategory(DetailCategory.identification)).thenAnswer(
      (_) => Stream.value([
        PersonalEntry(
          id: 'a',
          kind: DetailKind.aadhaar,
          title: '',
          fields: const [
            DetailField(
              key: 'number',
              value: '1234 5678 4821',
              sensitive: true,
            ),
          ],
          updatedAt: DateTime(2026),
        ),
      ]),
    );

    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) => PersonalBloc(repo)..add(const PersonalStarted()),
          child: PersonalPage(clipboard: clipboard),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AM'), findsOneWidget);
    expect(find.text('Born 14 Mar 1992'), findsOneWidget);
    // Personal tab lists the profile fields; no add button there.
    expect(find.text('Full name'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.tap(find.text('IDs'));
    await tester.pumpAndSettle();
    expect(find.text('•••• •••• 4821'), findsOneWidget);
    expect(find.text('1234 5678 4821'), findsNothing);
    expect(find.text('Add ID'), findsOneWidget);

    await tester.tap(find.byTooltip('Copy Aadhaar'));
    await tester.pump();
    expect(clipboard.copies.single, ('1234 5678 4821', true));
  });
}

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/ui/session_notices.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_note.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_notes_repository.dart';
import 'package:personal_life_manager/features/password_notes/presentation/password_form_cubit.dart';
import 'package:personal_life_manager/features/password_notes/presentation/passwords_bloc.dart';

class _Repo extends Mock implements PasswordNotesRepository;

const _bank = PasswordNote(
  id: 'b',
  name: 'Bank',
  url: 'bank.example',
  username: 'me',
  password: ' secret ',
  notes: '',
  category: 'Banking',
  isFavourite: true,
);

void main() {
  late _Repo repo;

  setUpAll(() {
    registerFallbackValue(const PasswordFilter());
    registerFallbackValue(const PasswordNoteDraft(name: ''));
  });

  setUp(() {
    repo = _Repo();
    when(() => repo.watch(any())).thenAnswer((_) => Stream.value([_bank]));
    when(repo.watchCategories)
        .thenAnswer((_) => Stream.value(const ['Banking', 'Travel']));
    when(() => repo.save(any())).thenAnswer((_) async => const Ok('id'));
  });

  group('PasswordsBloc', () {
    blocTest<PasswordsBloc, PasswordsState>(
      'loads notes and categories; filters pass to the repository',
      build: () => PasswordsBloc(repo, SessionNotices()),
      act: (b) async {
        b.add(const PasswordsStarted());
        await Future<void>.delayed(Duration.zero);
        b.add(const PasswordsFilterSelected(category: 'Banking'));
        await Future<void>.delayed(Duration.zero);
        b.add(const PasswordsFilterSelected(favourites: true));
      },
      wait: const Duration(milliseconds: 10),
      verify: (b) {
        expect(b.state.status, LoadStatus.ready);
        expect(b.state.notes, [_bank]);
        expect(b.state.categories, ['Banking', 'Travel']);
        expect(b.state.filter, const PasswordFilter(favouritesOnly: true));
        verify(() => repo.watch(const PasswordFilter(category: 'Banking')))
            .called(1);
      },
    );

    blocTest<PasswordsBloc, PasswordsState>(
      'search is debounced: only the last query reaches the repository',
      build: () => PasswordsBloc(repo, SessionNotices()),
      act: (b) => b
        ..add(const PasswordsQueryChanged('b'))
        ..add(const PasswordsQueryChanged('ba'))
        ..add(const PasswordsQueryChanged('ban')),
      wait: const Duration(milliseconds: 400),
      verify: (_) {
        verify(() => repo.watch(const PasswordFilter(query: 'ban'))).called(1);
        verifyNever(() => repo.watch(const PasswordFilter(query: 'b')));
      },
    );

    test('warning dismissal lasts for the session only', () async {
      final notices = SessionNotices();
      final first = PasswordsBloc(repo, notices);
      expect(first.state.warningDismissed, isFalse);
      first.add(const PasswordsWarningDismissed());
      await Future<void>.delayed(Duration.zero);
      await first.close();
      // Same session (e.g. page reopened): stays dismissed.
      expect(PasswordsBloc(repo, notices).state.warningDismissed, isTrue);
      // New session (app restart → new SessionNotices): shown again.
      expect(
        PasswordsBloc(repo, SessionNotices()).state.warningDismissed,
        isFalse,
      );
    });

    blocTest<PasswordsBloc, PasswordsState>(
      'a removed category clears that filter',
      setUp: () {
        final c = StreamController<List<String>>();
        when(repo.watchCategories).thenAnswer((_) => c.stream);
        addTearDown(c.close);
        scheduleMicrotask(() async {
          c.add(['Banking']);
          await Future<void>.delayed(const Duration(milliseconds: 5));
          c.add(const []);
        });
      },
      build: () => PasswordsBloc(repo, SessionNotices()),
      act: (b) => b
        ..add(const PasswordsStarted())
        ..add(const PasswordsFilterSelected(category: 'Banking')),
      wait: const Duration(milliseconds: 20),
      verify: (b) => expect(b.state.filter.category, isNull),
    );

    blocTest<PasswordsBloc, PasswordsState>(
      'favourite failure is surfaced',
      setUp: () =>
          when(() => repo.setFavourite('b', value: false))
              .thenAnswer((_) async => const Err(DatabaseFailure())),
      build: () => PasswordsBloc(repo, SessionNotices()),
      act: (b) => b.add(const PasswordFavouriteToggled('b', value: false)),
      verify: (b) => expect(b.state.failure, const DatabaseFailure()),
    );
  });

  group('PasswordFormCubit', () {
    blocTest<PasswordFormCubit, PasswordFormState>(
      'requires a name',
      build: () => PasswordFormCubit(repository: repo),
      act: (c) async {
        await c.load();
        await c.save();
      },
      verify: (c) {
        expect(c.state.showErrors, isTrue);
        verifyNever(() => repo.save(any()));
      },
    );

    blocTest<PasswordFormCubit, PasswordFormState>(
      'loads an entry and merges its categories with the suggestions',
      setUp: () =>
          when(() => repo.watchNote('b'))
              .thenAnswer((_) => Stream.value(_bank)),
      build: () => PasswordFormCubit(repository: repo, noteId: 'b'),
      act: (c) => c.load(),
      verify: (c) {
        expect(c.state.name, 'Bank');
        expect(c.state.password, ' secret ');
        expect(c.state.categories, [...defaultPasswordCategories, 'Travel']);
      },
    );

    blocTest<PasswordFormCubit, PasswordFormState>(
      'missing entry reports not found',
      setUp: () =>
          when(() => repo.watchNote('x')).thenAnswer((_) => Stream.value(null)),
      build: () => PasswordFormCubit(repository: repo, noteId: 'x'),
      act: (c) => c.load(),
      verify: (c) => expect(c.state.failure, const NotFoundFailure()),
    );

    blocTest<PasswordFormCubit, PasswordFormState>(
      'new category: reuses an existing spelling, toggles off, saves',
      build: () => PasswordFormCubit(repository: repo),
      act: (c) async {
        await c.load();
        c
          ..nameChanged('Airline')
          ..passwordChanged('pw')
          ..categoryAdded('  banking ')
          ..categoryAdded('Flights');
        expect(c.state.categories.where((x) => x == 'Banking'), hasLength(1));
        c
          ..categoryToggled('Flights')
          ..categoryToggled('Flights')
          ..favouriteChanged(value: true);
        await c.save();
      },
      verify: (c) {
        expect(c.state.outcome, EditorOutcome.saved);
        verify(
          () => repo.save(
            const PasswordNoteDraft(
              name: 'Airline',
              password: 'pw',
              category: 'Flights',
              isFavourite: true,
            ),
          ),
        ).called(1);
      },
    );

    blocTest<PasswordFormCubit, PasswordFormState>(
      'save failure keeps the form open',
      setUp: () =>
          when(() => repo.save(any()))
              .thenAnswer((_) async => const Err(DatabaseFailure())),
      build: () => PasswordFormCubit(repository: repo),
      act: (c) async {
        await c.load();
        c.nameChanged('X');
        await c.save();
      },
      verify: (c) {
        expect(c.state.outcome, EditorOutcome.none);
        expect(c.state.failure, const DatabaseFailure());
        expect(c.state.dirty, isTrue);
      },
    );
  });
}

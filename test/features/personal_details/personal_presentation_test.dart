import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_details_repository.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';
import 'package:personal_life_manager/features/personal_details/presentation/entry_editor_cubit.dart';
import 'package:personal_life_manager/features/personal_details/presentation/entry_view_cubit.dart';
import 'package:personal_life_manager/features/personal_details/presentation/personal_bloc.dart';

class _Repo extends Mock implements PersonalDetailsRepository;

final _passport = PersonalEntry(
  id: 'p',
  kind: DetailKind.passport,
  title: '',
  fields: const [
    DetailField(key: 'number', value: 'X1234567', sensitive: true),
    DetailField(key: 'c3', label: 'File no.', value: 'F-9'),
  ],
  linkedDocumentIds: const ['doc-1'],
  updatedAt: DateTime(2026),
);

void main() {
  late _Repo repo;

  setUpAll(
    () => registerFallbackValue(
      const PersonalEntryDraft(kind: DetailKind.custom, fields: []),
    ),
  );

  setUp(() {
    repo = _Repo();
    when(repo.watchProfile).thenAnswer((_) => Stream.value(null));
    when(() => repo.save(any())).thenAnswer((_) async => const Ok('id'));
  });

  group('EntryEditorCubit', () {
    blocTest<EntryEditorCubit, EntryEditorState>(
      'an ID needs its number; a named kind needs its title',
      build: () => EntryEditorCubit(repository: repo, kind: DetailKind.aadhaar),
      act: (c) async {
        await c.load();
        await c.save();
      },
      verify: (c) {
        expect(c.state.requiredMissing, isTrue);
        expect(c.state.showErrors, isTrue);
        verifyNever(() => repo.save(any()));
        const family = EntryEditorState(kind: DetailKind.familyMember);
        expect(family.titleMissing, isTrue);
        expect(family.requiredKey, isNull);
      },
    );

    blocTest<EntryEditorCubit, EntryEditorState>(
      'custom field with a value but no label is rejected',
      build: () => EntryEditorCubit(repository: repo, kind: DetailKind.custom),
      act: (c) async {
        await c.load();
        c
          ..titleChanged('Gym')
          ..addCustomField();
        c.customChanged(c.state.custom.single.localKey, value: '42');
        await c.save();
      },
      verify: (_) => verifyNever(() => repo.save(any())),
    );

    blocTest<EntryEditorCubit, EntryEditorState>(
      'edit takes the kind from the entry, keeps custom keys and links, '
      'drops empty custom rows and numbers new ones after existing',
      setUp: () =>
          when(() => repo.watchEntry('p'))
              .thenAnswer((_) => Stream.value(_passport)),
      build: () => EntryEditorCubit(repository: repo, entryId: 'p'),
      act: (c) async {
        await c.load();
        c
          ..valueChanged('expiryDate', '2031-08-01')
          ..addCustomField()
          ..addCustomField();
        final added = c.state.custom.skip(1).toList();
        c.customChanged(added.first.localKey, label: 'Office', value: 'Kochi');
        await c.save();
      },
      verify: (c) {
        expect(c.state.kind, DetailKind.passport);
        expect(c.state.outcome, EditorOutcome.saved);
        final draft =
            verify(() => repo.save(captureAny())).captured.single
                as PersonalEntryDraft;
        expect(draft.id, 'p');
        expect(draft.kind, DetailKind.passport);
        expect(draft.linkedDocumentIds, ['doc-1']);
        expect(draft.fields.map((f) => (f.key, f.value)), [
          ('number', 'X1234567'),
          ('nameOnId', ''),
          ('expiryDate', '2031-08-01'),
          ('notes', ''),
          ('c3', 'F-9'),
          ('c4', 'Kochi'),
        ]);
      },
    );

    blocTest<EntryEditorCubit, EntryEditorState>(
      'profile without an id edits the saved profile',
      setUp: () => when(repo.watchProfile).thenAnswer(
        (_) => Stream.value(
          PersonalEntry(
            id: 'me',
            kind: DetailKind.profile,
            title: '',
            fields: const [DetailField(key: 'fullName', value: 'A B')],
            updatedAt: DateTime(2026),
          ),
        ),
      ),
      build: () => EntryEditorCubit(repository: repo, kind: DetailKind.profile),
      act: (c) => c.load(),
      verify: (c) {
        expect(c.state.entryId, 'me');
        expect(c.state.values['fullName'], 'A B');
      },
    );

    blocTest<EntryEditorCubit, EntryEditorState>(
      'links documents once each, unlinks, and saves the ids',
      build: () => EntryEditorCubit(repository: repo, kind: DetailKind.pan),
      act: (c) async {
        await c.load();
        c
          ..valueChanged('number', 'ABCDE1234F')
          ..linkDocument('d1')
          ..linkDocument('d2')
          ..linkDocument('d1')
          ..linkDocument('d3')
          ..unlinkDocument('d2');
        await c.save();
      },
      verify: (c) {
        final draft =
            verify(() => repo.save(captureAny())).captured.single
                as PersonalEntryDraft;
        expect(draft.linkedDocumentIds, ['d1', 'd3']);
      },
    );

    blocTest<EntryEditorCubit, EntryEditorState>(
      'missing entry reports not found',
      setUp: () =>
          when(() => repo.watchEntry('x'))
              .thenAnswer((_) => Stream.value(null)),
      build: () => EntryEditorCubit(repository: repo, entryId: 'x'),
      act: (c) => c.load(),
      verify: (c) => expect(c.state.failure, const NotFoundFailure()),
    );
  });

  group('PersonalBloc', () {
    blocTest<PersonalBloc, PersonalState>(
      'Personal tab needs no list query; other tabs watch their category',
      setUp: () =>
          when(() => repo.watchCategory(DetailCategory.identification))
              .thenAnswer((_) => Stream.value([_passport])),
      build: () => PersonalBloc(repo),
      act: (b) async {
        b.add(const PersonalStarted());
        await Future<void>.delayed(Duration.zero);
        b.add(const PersonalCategorySelected(DetailCategory.identification));
      },
      wait: const Duration(milliseconds: 10),
      verify: (b) {
        expect(b.state.profileLoaded, isTrue);
        expect(b.state.entries, [_passport]);
        expect(b.state.status, LoadStatus.ready);
        verifyNever(() => repo.watchCategory(DetailCategory.personal));
      },
    );

    blocTest<PersonalBloc, PersonalState>(
      'search goes across categories; clearing it returns to the tab',
      setUp: () {
        when(() => repo.search('x12'))
            .thenAnswer((_) => Stream.value([_passport]));
      },
      build: () => PersonalBloc(repo),
      act: (b) async {
        b.add(const PersonalQueryChanged('x12'));
        await Future<void>.delayed(const Duration(milliseconds: 300));
        expect(b.state.entries, [_passport]);
        b.add(const PersonalQueryChanged(''));
      },
      wait: const Duration(milliseconds: 300),
      verify: (b) {
        expect(b.state.searching, isFalse);
        expect(b.state.entries, isEmpty);
      },
    );
  });

  group('EntryViewCubit', () {
    test('closes when the entry disappears; delete failure is shown', () async {
      when(() => repo.watchEntry('p'))
          .thenAnswer((_) => Stream.fromIterable([_passport, null]));
      when(() => repo.delete('p'))
          .thenAnswer((_) async => const Err(DatabaseFailure()));
      final c = EntryViewCubit(repository: repo, entryId: 'p')..start();
      await Future<void>.delayed(Duration.zero);
      expect(c.state.deleted, isTrue);
      await c.delete();
      expect(c.state.failure, const DatabaseFailure());
      await c.close();
    });
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/notes/domain/note.dart';
import 'package:personal_life_manager/features/notes/domain/notes_repository.dart';
import 'package:personal_life_manager/features/notes/presentation/notes_list_bloc.dart';

class _Repo extends Mock implements NotesRepository;

Note _note(String id, {bool pinned = false}) => Note(
  id: id,
  title: id,
  contentJson: '[]',
  plainText: '',
  tags: const [],
  isPinned: pinned,
  isFavourite: false,
  isArchived: false,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late _Repo repo;

  setUpAll(() => registerFallbackValue(const NotesFilter()));

  setUp(() {
    repo = _Repo();
    when(repo.watchTags).thenAnswer((_) => Stream.value(['home']));
    when(
      () => repo.watchNotes(any()),
    ).thenAnswer((_) => Stream.value([_note('a', pinned: true), _note('b')]));
  });

  blocTest<NotesListBloc, NotesListState>(
    'loads notes and tags, splitting pinned from others',
    build: () => NotesListBloc(repo),
    act: (b) => b.add(const NotesStarted()),
    wait: const Duration(milliseconds: 10),
    verify: (b) {
      expect(b.state.status, LoadStatus.ready);
      expect(b.state.pinned.map((n) => n.id), ['a']);
      expect(b.state.others.map((n) => n.id), ['b']);
      expect(b.state.tags, ['home']);
    },
  );

  blocTest<NotesListBloc, NotesListState>(
    'typing is debounced into a single search',
    build: () => NotesListBloc(repo),
    act: (b) async {
      b.add(const NotesStarted());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      b
        ..add(const NotesQueryChanged('r'))
        ..add(const NotesQueryChanged('ro'))
        ..add(const NotesQueryChanged('rou'));
    },
    wait: const Duration(milliseconds: 400),
    verify: (b) {
      final filters = verify(() => repo.watchNotes(captureAny())).captured;
      expect(filters.map((f) => (f as NotesFilter).query), ['', 'rou']);
      expect(b.state.filter.query, 'rou');
    },
  );

  blocTest<NotesListBloc, NotesListState>(
    'tag and view changes keep the current query',
    build: () => NotesListBloc(repo),
    act: (b) async {
      b.add(const NotesQueryChanged('wifi'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      b.add(const NotesViewChanged(NotesView.all, tag: 'home'));
    },
    wait: const Duration(milliseconds: 10),
    verify: (b) =>
        expect(b.state.filter, const NotesFilter(query: 'wifi', tag: 'home')),
  );
}

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/features/notes/data/notes_repository_impl.dart';
import 'package:personal_life_manager/features/notes/domain/note.dart';

import '../../helpers/fakes.dart';

T ok<T>(Result<T> r) => r.fold((f) => fail('unexpected $f'), (v) => v);

void main() {
  late AppDatabase db;
  late Directory dir;
  late TestClock clock;
  late NotesRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dir = Directory.systemTemp.createTempSync('notes_repo');
    clock = TestClock();
    repo = NotesRepositoryImpl(
      db: db,
      files: FileStore(dir),
      clock: clock.call,
    );
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  Future<String> add(
    String title, {
    String body = '',
    List<String> tags = const [],
    bool pinned = false,
  }) async {
    clock.advance(const Duration(minutes: 1));
    return ok<String>(
      await repo.save(
        NoteDraft(
          title: title,
          contentJson: '[]',
          plainText: body,
          tags: tags,
          isPinned: pinned,
        ),
      ),
    );
  }

  Future<List<String>> titles([
    NotesFilter filter = const NotesFilter(),
  ]) async => [for (final n in await repo.watchNotes(filter).first) n.title];

  test('lists pinned first, then most recently edited', () async {
    await add('Old');
    await add('Pinned', pinned: true);
    await add('New');

    expect(await titles(), ['Pinned', 'New', 'Old']);
  });

  test('full-text prefix search over title, body and tags', () async {
    await add('Wi-Fi & house info', body: 'Router is in the hall cupboard');
    await add('Trip packing', body: 'Chargers, ID cards', tags: ['travel']);
    await add('Gift ideas');

    expect(await titles(const NotesFilter(query: 'rout')), [
      'Wi-Fi & house info',
    ]);
    expect(await titles(const NotesFilter(query: 'trav')), ['Trip packing']);
    expect(await titles(const NotesFilter(query: 'CHARGER id')), [
      'Trip packing',
    ]);
    expect(await titles(const NotesFilter(query: 'nothing')), isEmpty);
  });

  test('search input cannot inject FTS syntax', () async {
    await add('A "quoted" note', body: 'x');
    for (final q in ['"', 'NEAR(', 'a OR', '*', '-x', 'title:']) {
      await expectLater(
        repo.watchNotes(NotesFilter(query: q)).first,
        completes,
      );
    }
  });

  test('search index follows edits and deletes', () async {
    final id = await add('Groceries', body: 'milk');
    ok(
      await repo.save(
        NoteDraft(
          id: id,
          title: 'Groceries',
          contentJson: '[]',
          plainText: 'bread',
        ),
      ),
    );

    expect(await titles(const NotesFilter(query: 'milk')), isEmpty);
    expect(await titles(const NotesFilter(query: 'bread')), ['Groceries']);

    ok(await repo.delete(id));
    expect(await titles(const NotesFilter(query: 'bread')), isEmpty);
  });

  test(
    'tags are normalised and filterable; tag list is unique and sorted',
    () async {
      await add('A', tags: ['#Home', 'travel plans']);
      await add('B', tags: ['home']);
      await add('C', tags: ['homework']);

      expect(await repo.watchTags().first, [
        'home',
        'homework',
        'travel-plans',
      ]);
      expect(await titles(const NotesFilter(tag: 'home')), ['B', 'A']);
    },
  );

  test('favourites and archive views', () async {
    final a = await add('A');
    final b = await add('B', pinned: true);
    ok(await repo.setFavourite(a, value: true));
    ok(await repo.setArchived(b, value: true));

    expect(await titles(const NotesFilter(view: NotesView.favourites)), ['A']);
    expect(await titles(), ['A']);
    final archived = await repo
        .watchNotes(const NotesFilter(view: NotesView.archived))
        .first;
    expect(archived.single.title, 'B');
    expect(archived.single.isPinned, isFalse, reason: 'archiving unpins');
  });

  test('missing note → NotFoundFailure', () async {
    final r = await repo.setPinned('nope', value: true);
    expect(r.fold((f) => f, (_) => null), isA<NotFoundFailure>());
  });

  group('attachments', () {
    File write(String name, List<int> bytes) =>
        File(p.join(dir.path, name))..writeAsBytesSync(bytes);

    test('valid image is stored under a UUID key and listed', () async {
      final id = await add('Paint colours');
      final src = write('wall.png', [
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0,
      ]);

      final att = ok(
        await repo.addAttachment(id, src, originalName: 'wall.png'),
      );

      expect(att.isImage, isTrue);
      expect(att.fileKey, isNot(contains('wall')));
      final note = await repo.watchNote(id).first;
      expect(note?.attachments.single.originalName, 'wall.png');
      expect((await repo.attachmentFile(att)).isSuccess, isTrue);
    });

    test('rejects a renamed file whose content does not match', () async {
      final id = await add('X');
      final fake = write('report.pdf', [0x4D, 0x5A, 0, 0, 0, 0, 0, 0]);

      final r = await repo.addAttachment(id, fake, originalName: 'report.pdf');

      expect(r.fold((f) => f, (_) => null), isA<UnsupportedFileFailure>());
    });

    test('rejects unsupported extensions', () async {
      final id = await add('X');
      final exe = write('tool.exe', [0x4D, 0x5A]);
      final r = await repo.addAttachment(id, exe, originalName: 'tool.exe');
      expect(r.fold((f) => f, (_) => null), isA<UnsupportedFileFailure>());
    });

    test('deleting the note deletes attachment rows and files', () async {
      final id = await add('X');
      final src = write('a.pdf', [0x25, 0x50, 0x44, 0x46, 0x2D]);
      final att = ok(await repo.addAttachment(id, src, originalName: 'a.pdf'));

      ok(await repo.delete(id));

      expect(await db.select(db.noteAttachments).get(), isEmpty);
      expect((await repo.attachmentFile(att)).isSuccess, isFalse);
    });
  });
}

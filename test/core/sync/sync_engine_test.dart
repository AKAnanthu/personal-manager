import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/sync/sync_engine.dart';
import 'package:personal_life_manager/core/sync/sync_tables.dart';

import '../../helpers/fake_sync_store.dart';

final class MemoryMemo implements SyncMemo {
  DateTime? at;

  @override
  Future<DateTime?> lastSyncedAt() async => at;

  @override
  Future<void> setLastSyncedAt(DateTime? value) async => at = value;
}

/// One phone: its own database and files, sharing `store` with the others.
final class Phone {
  Phone(FakeSyncStore store, {this.onReceived}) {
    db = AppDatabase(NativeDatabase.memory());
    dir = Directory.systemTemp.createTempSync('sync_phone');
    files = FileStore(Directory('${dir.path}/files')..createSync());
    engine = SyncEngine(
      db: db,
      store: store,
      files: files,
      tempDir: Directory('${dir.path}/tmp'),
      memo: MemoryMemo(),
      onReceived: () async => received++,
      retryDelays: const [],
    );
  }

  late final AppDatabase db;
  late final Directory dir;
  late final FileStore files;
  late final SyncEngine engine;
  final void Function()? onReceived;
  int received = 0;

  Future<void> close() async {
    engine.dispose();
    await db.close();
    dir.deleteSync(recursive: true);
  }

  Future<void> addNote(String id, String title) => db.customStatement(
    'INSERT INTO notes (id, created_at, updated_at, title, content_json) '
    "VALUES (?, 0, 0, ?, '[]')",
    [id, title],
  );

  Future<void> renameNote(String id, String title) => db.customStatement(
    'UPDATE notes SET title = ? WHERE id = ?',
    [title, id],
  );

  Future<void> deleteNote(String id) =>
      db.customStatement('DELETE FROM notes WHERE id = ?', [id]);

  Future<Map<String, String>> notes() async => {
    for (final r in await db.customSelect('SELECT id, title FROM notes').get())
      r.read<String>('id'): r.read<String>('title'),
  };

  Future<int> pending() async =>
      (await db
              .customSelect('SELECT COUNT(*) AS n FROM sync_outbox')
              .getSingle())
          .read<int>('n');
}

T ok<T>(Result<T> r) => r.fold((f) => fail('unexpected $f'), (v) => v);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeSyncStore store;
  late Phone a;
  late Phone b;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    store = FakeSyncStore();
    a = Phone(store);
    b = Phone(store);
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  test('a change is saved to Drive as one file per record', () async {
    await a.addNote('n1', 'Milk');
    expect(await a.pending(), 1);
    ok(await a.engine.save());
    expect(await a.pending(), 0);
    expect(store.named(SyncNames.record('notes', 'n1')), hasLength(1));

    // Editing rewrites the same file rather than adding one.
    await a.renameNote('n1', 'Milk and eggs');
    ok(await a.engine.save());
    expect(store.files, hasLength(1));
  });

  test('another phone gets new, changed and deleted records on sync', () async {
    await a.addNote('n1', 'One');
    await a.addNote('n2', 'Two');
    ok(await a.engine.save());

    final first = ok(await b.engine.syncNow());
    expect(first.received, 2);
    expect(await b.notes(), {'n1': 'One', 'n2': 'Two'});
    expect(b.received, 1);
    // Applying what came from Drive isn't sent back.
    expect(await b.pending(), 0);

    await a.renameNote('n1', 'One (edited)');
    await a.deleteNote('n2');
    ok(await a.engine.save());

    final second = ok(await b.engine.syncNow());
    expect(second, const SyncReport(received: 1, removed: 1));
    expect(await b.notes(), {'n1': 'One (edited)'});
    expect(b.engine.status.value.lastSyncedAt, isNotNull);
  });

  test('the last saved edit is what Drive keeps', () async {
    await a.addNote('n1', 'Start');
    ok(await a.engine.save());
    ok(await b.engine.syncNow());

    await a.renameNote('n1', 'From A');
    ok(await a.engine.save());
    await b.renameNote('n1', 'From B');
    ok(await b.engine.save());

    ok(await a.engine.syncNow());
    expect(await a.notes(), {'n1': 'From B'});
  });

  test('sync saves this phone’s waiting changes first', () async {
    await b.addNote('mine', 'Not yet saved');
    await a.addNote('theirs', 'Saved');
    ok(await a.engine.save());

    ok(await b.engine.syncNow());
    expect(await b.notes(), {'mine': 'Not yet saved', 'theirs': 'Saved'});
    expect(store.named(SyncNames.record('notes', 'mine')), hasLength(1));
  });

  test('offline: changes wait and are saved later', () async {
    store.failWith = DriveProblem.offline;
    await a.addNote('n1', 'Offline note');
    final r = await a.engine.save();
    expect(r, isA<Err<void>>());
    expect(await a.pending(), 1);
    expect(a.engine.status.value.pending, 1);
    expect(
      a.engine.status.value.failure,
      const DriveFailure(DriveProblem.offline),
    );

    final sync = await a.engine.syncNow();
    expect(sync, isA<Err<SyncReport>>());
    // A failed sync removes nothing on this phone.
    expect(await a.notes(), {'n1': 'Offline note'});

    store.failWith = null;
    ok(await a.engine.save());
    expect(await a.pending(), 0);
    expect(a.engine.status.value.failure, isNull);
  });

  test('files travel with their records', () async {
    final src = File('${a.dir.path}/scan.pdf')
      ..writeAsBytesSync([0x25, 0x50, 0x44, 0x46, 1, 2, 3]);
    final key = ok(await a.files.importFile(src));
    await a.db.customStatement(
      'INSERT INTO documents (id, created_at, updated_at, title, category, '
      'file_key, original_name, file_type, size_bytes) '
      "VALUES ('d1', 0, 0, 'Passport', 'personal', ?, 'scan.pdf', 'pdf', 7)",
      [key],
    );
    ok(await a.engine.save());
    expect(store.named(SyncNames.file(key)), hasLength(1));

    ok(await b.engine.syncNow());
    expect(b.files.exists(key), isTrue);
    expect(
      ok(await b.files.resolve(key)).readAsBytesSync(),
      src.readAsBytesSync(),
    );

    // Deleting the document removes its file from Drive at the next sync.
    await a.db.customStatement("DELETE FROM documents WHERE id = 'd1'");
    ok(await a.engine.syncNow());
    expect(store.named(SyncNames.file(key)), isEmpty);
  });

  test('children follow their parent', () async {
    await a.db.customStatement(
      'INSERT INTO tasks (id, created_at, updated_at, title) '
      "VALUES ('t1', 0, 0, 'Pack')",
    );
    await a.db.customStatement(
      'INSERT INTO task_checklist_items '
      '(id, created_at, updated_at, task_id, label, position) '
      "VALUES ('c1', 0, 0, 't1', 'Socks', 0)",
    );
    ok(await a.engine.save());
    ok(await b.engine.syncNow());
    expect(
      await b.db.customSelect('SELECT id FROM task_checklist_items').get(),
      hasLength(1),
    );

    // The cascade on A records the child's deletion too.
    await a.db.customStatement("DELETE FROM tasks WHERE id = 't1'");
    ok(await a.engine.save());
    expect(store.files, isEmpty);
    ok(await b.engine.syncNow());
    expect(
      await b.db.customSelect('SELECT id FROM task_checklist_items').get(),
      isEmpty,
    );
  });

  test('seedAll uploads records made before signing in', () async {
    await a.db.customStatement('INSERT INTO sync_mute VALUES (1)');
    await a.addNote('old', 'From before');
    await a.db.customStatement('DELETE FROM sync_mute');
    expect(await a.pending(), 0);

    await a.engine.seedAll();
    ok(await a.engine.syncNow());
    expect(store.named(SyncNames.record('notes', 'old')), hasLength(1));
    expect(await a.notes(), {'old': 'From before'});
  });

  test('a budget month set on both phones keeps the one from Drive', () async {
    Future<void> budget(Phone p, String id, int paise) => p.db.customStatement(
      'INSERT INTO budget_amounts '
      '(id, created_at, updated_at, from_month, amount_paise) '
      "VALUES (?, 0, 0, '2026-11', ?)",
      [id, paise],
    );
    await budget(a, 'ba', 500000);
    ok(await a.engine.save());
    // B set the same month before syncing: its own row was saved first,
    // so Drive briefly has both; the sync settles on one.
    await budget(b, 'bb', 700000);
    ok(await b.engine.syncNow());

    final rows = await b.db.customSelect('SELECT id FROM budget_amounts').get();
    expect(rows, hasLength(1));
    ok(await a.engine.syncNow());
    final remaining = store.files.values
        .where((f) => f.name.startsWith('r.budget_amounts.'))
        .toList();
    expect(remaining, hasLength(1));
  });

  test('duplicate files of one record are cleaned up', () async {
    await a.addNote('n1', 'Old');
    ok(await a.engine.save());
    // Another phone created the same record without seeing ours.
    await b.addNote('n1', 'New');
    await b.db.customStatement('DELETE FROM sync_remote');
    store.files['dup'] = (
      name: SyncNames.record('notes', 'n1'),
      bytes: store.files.values.first.bytes,
      modified: '2099-01-01T00:00:00Z',
    );
    ok(await a.engine.syncNow());
    expect(store.named(SyncNames.record('notes', 'n1')), ['dup']);
  });

  test('deleteDriveData empties the hidden folder', () async {
    await a.addNote('n1', 'x');
    ok(await a.engine.save());
    ok(await a.engine.deleteDriveData());
    expect(store.files, isEmpty);
  });

  test('storage reports app data size and quota', () async {
    await a.addNote('n1', 'x');
    ok(await a.engine.save());
    final s = ok(await a.engine.storage());
    expect(s.appBytes, greaterThan(0));
    expect((s.records, s.files), (1, 0));
    expect(s.quota.limitBytes, 15000);
  });

  test('watching starts saving without being asked', () async {
    await a.engine.start();
    await a.db
        .into(a.db.notes)
        .insert(
          NotesCompanion.insert(
            id: 'w1',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
            contentJson: '[]',
          ),
        );
    await pumpUntil(() async => store.files.isNotEmpty);
    await a.engine.stop();
    expect(store.named(SyncNames.record('notes', 'w1')), hasLength(1));
  });
}

Future<void> pumpUntil(Future<bool> Function() done) async {
  for (var i = 0; i < 100; i++) {
    if (await done()) return;
    await Future<void>.delayed(const Duration(milliseconds: 30));
  }
  fail('timed out');
}

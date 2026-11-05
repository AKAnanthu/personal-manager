import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_service.dart';
import 'package:personal_life_manager/features/backup_restore/domain/backup.dart';
import 'package:personal_life_manager/features/budget/data/budget_repository_impl.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';
import 'package:personal_life_manager/features/documents/data/documents_repository_impl.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/notes/data/notes_repository_impl.dart';
import 'package:personal_life_manager/features/notes/domain/note.dart';
import 'package:personal_life_manager/features/password_notes/data/password_notes_repository_impl.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_note.dart';
import 'package:personal_life_manager/features/shopping/data/shopping_repository_impl.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';

import '../../helpers/fakes.dart';

T ok<T>(Result<T> r) => r.fold((f) => fail('unexpected $f'), (v) => v);

final class _Prefs implements PreferencesBackup {
  Map<String, Object?> values = {
    'breathing': {'minutes': 5},
  };

  @override
  Future<Map<String, Object?>> export() async => values;

  @override
  Future<void> import(Map<String, Object?> v) async => values = v;
}

final class _Notice implements PendingShoppingNotice {
  @override
  Future<void> show(ShoppingList list) async {}
  @override
  Future<void> clear(String listId) async {}
}

/// One "phone": a database, a file store and the services on top.
final class _Phone {
  _Phone(Directory root, this.clock)
    : db = AppDatabase(NativeDatabase.memory()),
      filesDir = Directory(p.join(root.path, 'files'))..createSync(),
      tmp = Directory(p.join(root.path, 'tmp')),
      prefs = _Prefs() {
    store = FileStore(filesDir);
    service = BackupService(
      db: db,
      files: store,
      prefs: prefs,
      tempDir: tmp,
      appVersion: '0.1.0',
      platform: 'android',
      onRestored: () async => restoredCalls++,
      clock: clock.call,
    );
  }

  final AppDatabase db;
  final Directory filesDir;
  late final FileStore store;
  final Directory tmp;
  final _Prefs prefs;
  final TestClock clock;
  late final BackupService service;
  int restoredCalls = 0;

  NotesRepositoryImpl get notes =>
      NotesRepositoryImpl(db: db, files: store, clock: clock.call);
  DocumentsRepositoryImpl get documents => DocumentsRepositoryImpl(
    db: db,
    files: store,
    onScheduleChanged: () {},
    clock: clock.call,
  );
  PasswordNotesRepositoryImpl get passwords =>
      PasswordNotesRepositoryImpl(db: db, clock: clock.call);
  ShoppingRepositoryImpl get shopping => ShoppingRepositoryImpl(
    db: db,
    files: store,
    notice: _Notice(),
    clock: clock.call,
  );
  BudgetRepositoryImpl get budget =>
      BudgetRepositoryImpl(db: db, clock: clock.call);

  Future<List<String>> noteTitles([String query = '']) async => [
    for (final n in await notes.watchNotes(NotesFilter(query: query)).first)
      n.title,
  ]..sort();

  int storedFiles() => filesDir.listSync().length;
}

void main() {
  late Directory dir;
  late _Phone phone;
  late TestClock clock;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('backup_test');
    clock = TestClock(DateTime(2026, 11, 3, 18));
    phone = _Phone(Directory(p.join(dir.path, 'a'))..createSync(), clock);
  });
  tearDown(() async {
    await phone.db.close();
    dir.deleteSync(recursive: true);
  });

  _Phone otherPhone(String name) =>
      _Phone(Directory(p.join(dir.path, name))..createSync(), clock);

  File pdf(String name) =>
      File(p.join(dir.path, name))
        ..writeAsBytesSync([0x25, 0x50, 0x44, 0x46, ...utf8.encode(name)]);

  Future<String> note(_Phone ph, String title, {String body = ''}) async {
    clock.advance(const Duration(seconds: 5));
    return ok<String>(
      await ph.notes.save(
        NoteDraft(title: title, contentJson: '[]', plainText: body),
      ),
    );
  }

  Future<BackupPreview> inspect(_Phone ph, File f) =>
      ph.service.inspect(f, token: CancelToken());

  Future<File> backup(Set<BackupCategory> cats) =>
      phone.service.create(cats, token: CancelToken());

  test('round trip: defaults exclude password notes; files, search and '
      'notifications come back on another phone', () async {
    final n = await note(phone, 'Gate code', body: 'Locker 42');
    ok(
      await phone.notes.addAttachment(
        n,
        pdf('scan.pdf'),
        originalName: 'scan.pdf',
      ),
    );
    ok(
      await phone.documents.add(
        const DocumentDraft(
          title: 'Passport',
          category: DocumentCategory.personal,
        ),
        source: pdf('passport.pdf'),
        originalName: 'passport.pdf',
      ),
    );
    ok(await phone.passwords.save(const PasswordNoteDraft(name: 'Bank')));

    final file = await backup(BackupCategory.defaults);
    expect(p.basename(file.path), 'PLM backup 2026-11-03 1800.plmbackup');
    final preview = await inspect(phone, file);
    final m = preview.manifest;
    expect(m.categories, [
      BackupCategory.personal,
      BackupCategory.notes,
      BackupCategory.documents,
      BackupCategory.reminders,
      BackupCategory.tasks,
    ]);
    expect(m.counts[BackupCategory.notes], 1);
    expect(m.counts[BackupCategory.documents], 1);
    expect(m.files.where((f) => f.path.startsWith('files/')), hasLength(2));
    expect(m.files.every((f) => f.sha256.length == 64), isTrue);
    expect(m.schemaVersion, phone.db.schemaVersion);

    final b = otherPhone('b');
    addTearDown(b.db.close);
    final restored = await b.service.restore(
      await inspect(b, file),
      m.categories.toSet(),
      RestoreStrategy.merge,
    );
    expect(restored[BackupCategory.notes], 1);
    expect(await b.noteTitles('locker'), ['Gate code']);
    final docs = await b.documents.watch(const DocumentFilter()).first;
    expect(ok(await b.documents.fileFor(docs.single)).existsSync(), isTrue);
    final attachment = (await b.notes.watchNote(n).first)?.attachments.single;
    expect(attachment, isNotNull);
    expect(await b.passwords.watch(const PasswordFilter()).first, isEmpty);
    expect(b.restoredCalls, 1);
  });

  test('merge: newer copy wins, local-only items stay', () async {
    final a = await note(phone, 'Shared');
    final file = await backup({BackupCategory.notes});

    final b = otherPhone('b');
    addTearDown(b.db.close);
    await b.service.restore(await inspect(b, file), {
      BackupCategory.notes,
    }, RestoreStrategy.merge);
    // Edited on phone B after the backup; plus one B-only note.
    clock.advance(const Duration(minutes: 1));
    ok(
      await b.notes.save(
        NoteDraft(
          id: a,
          title: 'Shared (edited)',
          contentJson: '[]',
          plainText: '',
        ),
      ),
    );
    await note(b, 'Only on B');

    await b.service.restore(await inspect(b, file), {
      BackupCategory.notes,
    }, RestoreStrategy.merge);
    expect(await b.noteTitles(), ['Only on B', 'Shared (edited)']);

    // A newer backup does win.
    clock.advance(const Duration(minutes: 1));
    ok(
      await phone.notes.save(
        NoteDraft(id: a, title: 'Shared v3', contentJson: '[]', plainText: ''),
      ),
    );
    final newer = await backup({BackupCategory.notes});
    await b.service.restore(await inspect(b, newer), {
      BackupCategory.notes,
    }, RestoreStrategy.merge);
    expect(await b.noteTitles(), ['Only on B', 'Shared v3']);
  });

  test(
    'replace: clears only the chosen category and its orphan files',
    () async {
      await note(phone, 'From backup');
      final file = await backup({
        BackupCategory.notes,
        BackupCategory.passwords,
      });

      final b = otherPhone('b');
      addTearDown(b.db.close);
      final local = await note(b, 'Local note');
      ok(
        await b.notes.addAttachment(
          local,
          pdf('old.pdf'),
          originalName: 'old.pdf',
        ),
      );
      ok(await b.passwords.save(const PasswordNoteDraft(name: 'Local login')));
      expect(b.storedFiles(), 1);

      await b.service.restore(await inspect(b, file), {
        BackupCategory.notes,
      }, RestoreStrategy.replace);
      expect(await b.noteTitles(), ['From backup']);
      expect(b.storedFiles(), 0);
      // Not selected → untouched.
      final logins = await b.passwords.watch(const PasswordFilter()).first;
      expect(logins.single.name, 'Local login');
    },
  );

  test(
    'budget and shopping: one expense per trip, one active session',
    () async {
      final listId = ok<String>(
        await phone.shopping.saveList(
          const ListDraft(
            name: 'Weekly',
            items: [ItemDraft(name: 'Milk')],
          ),
        ),
      );
      ok(await phone.shopping.startSession(listId));
      final done = ok<String>(
        await phone.shopping.saveList(
          const ListDraft(
            name: 'Done',
            items: [ItemDraft(name: 'Rice')],
          ),
        ),
      );
      ok(
        await phone.shopping.complete(
          done,
          Completion(totalPaise: 50000, purchasedOn: DateTime(2026, 11, 2)),
        ),
      );
      ok(await phone.budget.setBudget(const BudgetMonth(2026, 11), 1000000));
      final file = await backup({
        BackupCategory.shopping,
        BackupCategory.budget,
      });

      final b = otherPhone('b');
      addTearDown(b.db.close);
      // B has its own session running and its own November budget.
      final mine = ok<String>(
        await b.shopping.saveList(
          const ListDraft(
            name: 'Mine',
            items: [ItemDraft(name: 'Eggs')],
          ),
        ),
      );
      ok(await b.shopping.startSession(mine));
      clock.advance(const Duration(minutes: 1));
      ok(await b.budget.setBudget(const BudgetMonth(2026, 11), 2000000));

      final preview = await inspect(b, file);
      for (var i = 0; i < 2; i++) {
        await b.service.restore(preview, {
          BackupCategory.shopping,
          BackupCategory.budget,
        }, RestoreStrategy.merge);
      }
      expect((await b.shopping.watchActive().first)?.id, mine);
      final drafts = await b.shopping.watchDrafts().first;
      expect(drafts.single.id, listId);
      final nov = await b.budget.watchMonth(const BudgetMonth(2026, 11)).first;
      // B's budget was set later, so it's kept; the trip counts once.
      expect(nov.budgetPaise, 2000000);
      expect(nov.expenses.single.amountPaise, 50000);
    },
  );

  test('preferences are backed up and restored', () async {
    final file = await backup({BackupCategory.preferences});
    final b = otherPhone('b');
    addTearDown(b.db.close);
    b.prefs.values = {};
    await b.service.restore(await inspect(b, file), {
      BackupCategory.preferences,
    }, RestoreStrategy.merge);
    expect(b.prefs.values, {
      'breathing': {'minutes': 5},
    });
  });

  group('validation', () {
    Future<BackupProblem?> problemOf(File f) async {
      try {
        await inspect(phone, f);
        return null;
      } on BackupInvalid catch (e) {
        return e.problem;
      }
    }

    /// Rewrites the zip, letting [edit] change entries.
    File rewrite(
      File src,
      Map<String, List<int>> Function(Map<String, List<int>>) edit,
    ) {
      final archive = ZipDecoder().decodeBytes(src.readAsBytesSync());
      final entries = {
        for (final f in archive.files) f.name: f.readBytes()!.toList(),
      };
      final out = Archive();
      for (final e in edit(entries).entries) {
        out.addFile(ArchiveFile.bytes(e.key, e.value));
      }
      return File(p.join(dir.path, 'edited.plmbackup'))
        ..writeAsBytesSync(ZipEncoder().encode(out));
    }

    test('not a zip, or not ours', () async {
      final junk = File(p.join(dir.path, 'junk.plmbackup'))
        ..writeAsStringSync('hello');
      expect(await problemOf(junk), BackupProblem.notABackup);
      final file = await backup({BackupCategory.notes});
      final foreign = rewrite(file, (e) {
        final m = jsonDecode(utf8.decode(e['manifest.json']!)) as Map;
        return {
          ...e,
          'manifest.json': utf8.encode(jsonEncode({...m, 'app': 'x'})),
        };
      });
      expect(await problemOf(foreign), BackupProblem.notABackup);
    });

    test('a changed byte fails its checksum; nothing is left staged', () async {
      await note(phone, 'Secret');
      final file = await backup({BackupCategory.notes});
      final tampered = rewrite(file, (e) {
        final data = [...e['data/notes.json']!];
        data[data.length - 3] ^= 1;
        return {...e, 'data/notes.json': data};
      });
      expect(await problemOf(tampered), BackupProblem.damaged);
      expect(phone.tmp.listSync().whereType<Directory>(), isEmpty);
    });

    test('a backup from a newer app is refused', () async {
      final file = await backup({BackupCategory.notes});
      final newer = rewrite(file, (e) {
        final m = jsonDecode(utf8.decode(e['manifest.json']!)) as Map;
        return {
          ...e,
          'manifest.json': utf8.encode(
            jsonEncode({...m, 'formatVersion': backupFormatVersion + 1}),
          ),
        };
      });
      expect(await problemOf(newer), BackupProblem.tooNew);
    });

    test('paths outside data/ and files/ are refused', () async {
      final file = await backup({BackupCategory.notes});
      final evil = rewrite(file, (e) {
        final m = jsonDecode(utf8.decode(e['manifest.json']!)) as Map;
        final bytes = utf8.encode('x');
        return {
          ...e,
          '../evil.txt': bytes,
          'manifest.json': utf8.encode(
            jsonEncode({
              ...m,
              'files': [
                ...m['files'] as List,
                {
                  'path': '../evil.txt',
                  'size': 1,
                  // Any well-formed hash: the path is refused first.
                  'sha256': 'ab' * 32,
                },
              ],
            }),
          ),
        };
      });
      expect(await problemOf(evil), BackupProblem.damaged);
      expect(File(p.join(phone.tmp.path, 'evil.txt')).existsSync(), isFalse);
    });
  });

  test('a cancelled backup leaves no file behind', () async {
    final token = CancelToken()..cancel();
    await expectLater(
      phone.service.create({BackupCategory.notes}, token: token),
      throwsA(isA<Cancelled>()),
    );
    expect(
      phone.tmp.existsSync() ? phone.tmp.listSync() : const <Object>[],
      isEmpty,
    );
  });
}

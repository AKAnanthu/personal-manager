import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/features/documents/data/documents_repository_impl.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';

import '../../helpers/fakes.dart';

T ok<T>(Result<T> r) => r.fold((f) => fail('unexpected $f'), (v) => v);

const _pdfHeader = [0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x37];
const _pngHeader = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

void main() {
  late AppDatabase db;
  late Directory dir;
  late Directory store;
  late TestClock clock;
  late DocumentsRepositoryImpl repo;
  late int replans;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dir = Directory.systemTemp.createTempSync('docs_repo');
    store = Directory(p.join(dir.path, 'store'))..createSync();
    clock = TestClock(DateTime(2026, 11, 3, 18));
    replans = 0;
    repo = DocumentsRepositoryImpl(
      db: db,
      files: FileStore(store),
      onScheduleChanged: () => replans++,
      clock: clock.call,
    );
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  File source(String name, List<int> header, {int size = 100}) =>
      File(p.join(dir.path, name))
        ..writeAsBytesSync([...header, ...List.filled(size, 0)]);

  int storedFiles() => store.listSync().length;

  Future<String> add(
    String title, {
    DocumentCategory category = DocumentCategory.personal,
    DateTime? expiry,
    bool reminder = true,
    String? file,
  }) async {
    clock.advance(const Duration(minutes: 1));
    final name = file ?? '${title.toLowerCase().replaceAll(' ', '_')}.pdf';
    return ok<String>(
      await repo.add(
        DocumentDraft(
          title: title,
          category: category,
          expiryDate: expiry,
          expiryReminder: reminder,
        ),
        source: source(name, _pdfHeader),
        originalName: name,
      ),
    );
  }

  Future<List<String>> titles([
    DocumentFilter filter = const DocumentFilter(),
  ]) async => [for (final d in await repo.watch(filter).first) d.title];

  test('add copies the file under a UUID name and keeps metadata', () async {
    final id = await add('Passport', file: 'passport_scan.pdf');
    final d = await repo.watchDocument(id).first;
    expect(d?.originalName, 'passport_scan.pdf');
    expect(d?.fileType, SupportedFileType.pdf);
    expect(d?.sizeBytes, 108);
    expect(d?.driveStatus, DriveStatus.notUploaded);
    expect(storedFiles(), 1);
    expect(store.listSync().single.path, isNot(contains('passport')));
    expect(ok(await repo.fileFor(d!)).existsSync(), isTrue);
  });

  test('a renamed file is rejected and nothing is stored', () async {
    final r = await repo.add(
      const DocumentDraft(title: 'X', category: DocumentCategory.others),
      source: source('fake.pdf', _pngHeader),
      originalName: 'fake.pdf',
    );
    expect(r.fold((f) => f, (_) => null), const UnsupportedFileFailure());
    expect(storedFiles(), 0);
    expect(await titles(), isEmpty);
  });

  test('newest first; filters by category, favourites and search', () async {
    final passport = await add('Passport', file: 'passport_scan.pdf');
    await add('Blood test', category: DocumentCategory.medical);
    await add('Car insurance', category: DocumentCategory.propertyVehicle);
    ok(await repo.setFavourite(passport, value: true));

    expect(await titles(), ['Car insurance', 'Blood test', 'Passport']);
    expect(
      await titles(const DocumentFilter(category: DocumentCategory.medical)),
      ['Blood test'],
    );
    expect(await titles(const DocumentFilter(favouritesOnly: true)), [
      'Passport',
    ]);
    // Original file names are searchable too.
    expect(await titles(const DocumentFilter(query: 'scan')), ['Passport']);
    expect(await titles(const DocumentFilter(query: 'insur')), [
      'Car insurance',
    ]);
  });

  test('expiring soon: today up to 30 days ahead, soonest first', () async {
    await add('Expired', expiry: DateTime(2026, 11, 2));
    await add('Today', expiry: DateTime(2026, 11, 3));
    await add('In 30 days', expiry: DateTime(2026, 12, 3));
    await add('In 31 days', expiry: DateTime(2026, 12, 4));
    await add('Next week', expiry: DateTime(2026, 11, 10));
    await add('No expiry');
    final soon = await repo.watchExpiringSoon(DateTime(2026, 11, 3, 18)).first;
    expect(soon.map((d) => d.title), ['Today', 'Next week', 'In 30 days']);
    expect(soon.first.daysToExpiry(DateTime(2026, 11, 3, 23)), 0);
  });

  test('replacing the file swaps it, removes the old one and resets the '
      'Drive status', () async {
    final id = await add('Licence');
    final oldKey = (await repo.watchDocument(id).first)?.fileKey;
    ok(
      await repo.update(
        DocumentDraft(
          id: id,
          title: 'Licence (renewed)',
          category: DocumentCategory.personal,
        ),
        replacement: source('new.png', _pngHeader),
        replacementName: 'new.png',
      ),
    );
    final d = await repo.watchDocument(id).first;
    expect(d?.title, 'Licence (renewed)');
    expect(d?.fileType, SupportedFileType.png);
    expect(d?.originalName, 'new.png');
    expect(d?.fileKey, isNot(oldKey));
    expect(storedFiles(), 1);
  });

  test('a rejected replacement leaves the document untouched', () async {
    final id = await add('Licence');
    final before = await repo.watchDocument(id).first;
    final r = await repo.update(
      DocumentDraft(id: id, title: 'Y', category: DocumentCategory.personal),
      replacement: source('bad.png', _pdfHeader),
      replacementName: 'bad.png',
    );
    expect(r.fold((f) => f, (_) => null), const UnsupportedFileFailure());
    expect(await repo.watchDocument(id).first, before);
    expect(storedFiles(), 1);
  });

  test('update of a missing document is not found', () async {
    final r = await repo.update(
      const DocumentDraft(
        id: 'nope',
        title: 'X',
        category: DocumentCategory.others,
      ),
    );
    expect(r.fold((f) => f, (_) => null), const NotFoundFailure());
  });

  test('delete removes the record and the file', () async {
    final id = await add('Old bill');
    ok(await repo.delete(id));
    expect(await repo.watchDocument(id).first, isNull);
    expect(storedFiles(), 0);
    // Deleting again is harmless.
    ok(await repo.delete(id));
  });

  test('expiry reminders: 9:00, 30 days before; off when switched off; '
      'schedule changes trigger a re-plan', () async {
    final passport = await add('Passport', expiry: DateTime(2031, 8, 14));
    await add('Insurance', expiry: DateTime(2027, 1, 5), reminder: false);
    await add('No expiry');
    expect(replans, 2);

    final sources = await repo.notificationSources(
      (d) => (title: '${d.title} expires soon', body: 'b'),
    );
    expect(sources, [
      ScheduleSource(
        kind: NotificationKind.documentExpiry,
        entityId: passport,
        title: 'Passport expires soon',
        body: 'b',
        route: '/documents/$passport',
        schedule: OneTimeSchedule(DateTime(2031, 7, 15, 9)),
      ),
    ]);
  });

  test('linked ids resolve in order and skip deleted documents', () async {
    final a = await add('A');
    final b = await add('B');
    final c = await add('C');
    ok(await repo.delete(b));
    final docs = await repo.watchByIds([c, b, a]).first;
    expect(docs.map((d) => d.title), ['C', 'A']);
  });
}

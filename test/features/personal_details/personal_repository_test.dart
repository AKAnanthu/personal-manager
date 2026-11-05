import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/personal_details/data/personal_details_repository_impl.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';

T ok<T>(Result<T> r) => r.fold((f) => fail('unexpected $f'), (v) => v);

void main() {
  late AppDatabase db;
  late PersonalDetailsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = PersonalDetailsRepositoryImpl(db: db);
  });
  tearDown(() => db.close());

  Future<String> addId(
    DetailKind kind,
    String number, {
    String title = '',
  }) async => ok<String>(
    await repo.save(
      PersonalEntryDraft(
        kind: kind,
        title: title,
        fields: [DetailField(key: 'number', value: number)],
      ),
    ),
  );

  test('there is only ever one profile', () async {
    ok(
      await repo.save(
        const PersonalEntryDraft(
          kind: DetailKind.profile,
          fields: [DetailField(key: 'fullName', value: 'Meera Nair')],
        ),
      ),
    );
    ok(
      await repo.save(
        const PersonalEntryDraft(
          kind: DetailKind.profile,
          fields: [DetailField(key: 'fullName', value: 'Meera N')],
        ),
      ),
    );

    final rows = await db.select(db.personalEntries).get();
    expect(rows, hasLength(1));
    expect((await repo.watchProfile().first)?.value('fullName'), 'Meera N');
  });

  test('ID numbers are marked sensitive by the template', () async {
    final id = await addId(DetailKind.aadhaar, '1234 5678 4821');
    final e = await repo.watchEntry(id).first;
    expect(e?.primary?.sensitive, isTrue);
    expect(e?.primary?.value, '1234 5678 4821');
  });

  test('empty template fields are dropped; custom fields are kept', () async {
    final id = ok<String>(
      await repo.save(
        const PersonalEntryDraft(
          kind: DetailKind.employment,
          fields: [
            DetailField(key: 'employer', value: ' Acme '),
            DetailField(key: 'role', value: ''),
            DetailField(key: 'c1', label: 'Manager', value: 'Ravi'),
          ],
        ),
      ),
    );
    final e = await repo.watchEntry(id).first;
    expect(e?.fields.map((f) => f.key), ['employer', 'c1']);
    expect(e?.value('employer'), 'Acme');
    expect(e?.title, '', reason: 'non-named kinds use the kind label');
  });

  test('entries are grouped by category', () async {
    await addId(DetailKind.pan, 'ABCDE1234F');
    await addId(DetailKind.passport, 'X1234542');
    ok(
      await repo.save(
        const PersonalEntryDraft(
          kind: DetailKind.familyMember,
          title: 'Amma',
          fields: [DetailField(key: 'relationship', value: 'Mother')],
        ),
      ),
    );

    final ids = await repo.watchCategory(DetailCategory.identification).first;
    expect(ids.map((e) => e.kind), [DetailKind.pan, DetailKind.passport]);
    final family = await repo.watchCategory(DetailCategory.family).first;
    expect(family.single.title, 'Amma');
  });

  test('search finds by title, values and custom labels', () async {
    await addId(DetailKind.drivingLicence, 'KL07 2019 0001318');
    ok(
      await repo.save(
        const PersonalEntryDraft(
          kind: DetailKind.custom,
          title: 'Gym membership',
          fields: [DetailField(key: 'c', label: 'Locker', value: '42')],
        ),
      ),
    );

    expect(
      (await repo.search('KL07').first).single.kind,
      DetailKind.drivingLicence,
    );
    expect((await repo.search('gym').first).single.title, 'Gym membership');
    expect(await repo.search('locker').first, hasLength(1));
    expect(await repo.search('').first, isEmpty);
  });

  test('delete removes the entry and its search row', () async {
    final id = await addId(DetailKind.voterId, 'XYZ1234567');
    ok(await repo.delete(id));
    expect(await repo.search('XYZ1234567').first, isEmpty);
  });

  test('masking keeps the last four characters and separators', () {
    expect(maskValue('1234 5678 4821'), '•••• •••• 4821');
    expect(maskValue('ABCDE1234F'), '••••••234F');
    expect(maskValue('12'), '••');
  });
}

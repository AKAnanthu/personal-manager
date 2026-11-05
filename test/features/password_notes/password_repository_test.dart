import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/password_notes/data/password_notes_repository_impl.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_note.dart';

T ok<T>(Result<T> r) => r.fold((f) => fail('unexpected $f'), (v) => v);

void main() {
  late AppDatabase db;
  late PasswordNotesRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = PasswordNotesRepositoryImpl(db: db);
    for (final d in const [
      PasswordNoteDraft(
        name: 'Office email',
        username: 'meera@work',
        password: 'S3cret!pass',
        category: 'Work',
      ),
      PasswordNoteDraft(
        name: 'Bank net banking',
        url: 'https://bank.example',
        username: 'meera.n92',
        password: 'hunter2',
        category: 'Banking',
        isFavourite: true,
      ),
      PasswordNoteDraft(name: 'electricity board', category: 'Bills'),
    ]) {
      ok(await repo.save(d));
    }
  });
  tearDown(() => db.close());

  Future<List<String>> names([
    PasswordFilter f = const PasswordFilter(),
  ]) async => [for (final n in await repo.watch(f).first) n.name];

  test('favourites first, then by name ignoring case', () async {
    expect(await names(), [
      'Bank net banking',
      'electricity board',
      'Office email',
    ]);
  });

  test('searches name, URL and username', () async {
    expect(await names(const PasswordFilter(query: 'offi')), ['Office email']);
    expect(await names(const PasswordFilter(query: 'bank.example')), [
      'Bank net banking',
    ]);
    expect(await names(const PasswordFilter(query: 'meera')), hasLength(2));
  });

  test('never searches the password column', () async {
    expect(await names(const PasswordFilter(query: 'hunter2')), isEmpty);
    expect(await names(const PasswordFilter(query: 'S3cret')), isEmpty);
    final ftsColumns = await db
        .customSelect(
          "SELECT name FROM pragma_table_info('password_notes_fts')",
        )
        .get();
    expect(
      ftsColumns.map((r) => r.read<String>('name')),
      isNot(contains('password')),
    );
  });

  test('filters by category and favourites; lists categories', () async {
    expect(await names(const PasswordFilter(category: 'Work')), [
      'Office email',
    ]);
    expect(await names(const PasswordFilter(favouritesOnly: true)), [
      'Bank net banking',
    ]);
    expect(await repo.watchCategories().first, ['Banking', 'Bills', 'Work']);
  });

  test('passwords are stored exactly as typed', () async {
    final id = ok<String>(
      await repo.save(
        const PasswordNoteDraft(name: 'x', password: '  spaced  '),
      ),
    );
    expect((await repo.watchNote(id).first)?.password, '  spaced  ');
  });

  test('favourite toggle and delete', () async {
    final id = (await repo.watch(const PasswordFilter(query: 'office')).first)
        .single
        .id;
    ok(await repo.setFavourite(id, value: true));
    expect((await names()).first, 'Bank net banking');
    expect(
      await names(const PasswordFilter(favouritesOnly: true)),
      hasLength(2),
    );
    ok(await repo.delete(id));
    expect(await names(const PasswordFilter(query: 'office')), isEmpty);
  });
}

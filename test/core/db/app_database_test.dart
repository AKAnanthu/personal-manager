import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/db/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('opens with foreign keys enforced', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });

  test('bundled SQLite supports FTS5 (needed for search)', () async {
    await db.customStatement('CREATE VIRTUAL TABLE fts_probe USING fts5(body)');
    await db.customStatement(
      "INSERT INTO fts_probe(body) VALUES ('weekly groceries')",
    );
    final rows = await db
        .customSelect(
          'SELECT body FROM fts_probe WHERE fts_probe MATCH ?',
          variables: [Variable.withString('grocer*')],
        )
        .get();
    expect(rows, hasLength(1));
  });
}

import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/db/db_guard.dart';
import 'package:personal_life_manager/core/db/fts_query.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_note.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_notes_repository.dart';
import 'package:uuid/uuid.dart';

final class PasswordNotesRepositoryImpl implements PasswordNotesRepository {
  PasswordNotesRepositoryImpl({
    required this._db,
    this._uuid = const Uuid(),
    this._clock = DateTime.now,
  });

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _clock;

  $PasswordNotesTable get _t => _db.passwordNotes;

  @override
  Stream<List<PasswordNote>> watch(PasswordFilter filter) {
    final where = <String>['1 = 1'];
    final vars = <Variable<Object>>[];
    final match = ftsPrefixQuery(filter.query);
    if (match != null) vars.add(Variable.withString(match));
    if (filter.favouritesOnly) where.add('p.is_favourite = 1');
    if (filter.category case final c?) {
      where.add('p.category = ?');
      vars.add(Variable.withString(c));
    }
    final join = match == null
        ? ''
        : 'JOIN password_notes_fts f ON f.rowid = p.rowid '
              'AND password_notes_fts MATCH ?';
    return _db
        .customSelect(
          'SELECT p.* FROM password_notes p $join WHERE ${where.join(' AND ')} '
          'ORDER BY p.is_favourite DESC, p.name COLLATE NOCASE',
          variables: vars,
          readsFrom: {_t},
        )
        .watch()
        .map((rows) => [for (final r in rows) _map(_t.map(r.data))]);
  }

  @override
  Stream<List<String>> watchCategories() =>
      (_db.selectOnly(_t, distinct: true)
            ..addColumns([_t.category])
            ..where(_t.category.isNotValue('')))
          .watch()
          .map(
            (rows) =>
                [for (final r in rows) ?r.read(_t.category)]
                  ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
          );

  @override
  Stream<PasswordNote?> watchNote(String id) =>
      (_db.select(_t)..where((p) => p.id.equals(id))).watchSingleOrNull().map(
        (r) => r == null ? null : _map(r),
      );

  @override
  Future<Result<String>> save(PasswordNoteDraft d) => dbGuard(() async {
    final now = _clock();
    final id = d.id ?? _uuid.v4();
    final companion = PasswordNotesCompanion(
      id: Value(id),
      name: Value(d.name.trim()),
      url: Value(d.url.trim()),
      username: Value(d.username.trim()),
      // Kept exactly as typed (spaces can be part of a password).
      password: Value(d.password),
      notes: Value(d.notes.trim()),
      category: Value(d.category.trim()),
      isFavourite: Value(d.isFavourite),
      updatedAt: Value(now),
    );
    if (d.id == null) {
      await _db.into(_t).insert(companion.copyWith(createdAt: Value(now)));
    } else {
      final n = await (_db.update(
        _t,
      )..where((p) => p.id.equals(id))).write(companion);
      if (n == 0) throw const RecordNotFound();
    }
    return id;
  });

  @override
  Future<Result<void>> setFavourite(String id, {required bool value}) =>
      dbGuard(() async {
        final n = await (_db.update(_t)..where((p) => p.id.equals(id))).write(
          PasswordNotesCompanion(
            isFavourite: Value(value),
            updatedAt: Value(_clock()),
          ),
        );
        if (n == 0) throw const RecordNotFound();
      });

  @override
  Future<Result<void>> delete(String id) => dbGuard(() async {
    await (_db.delete(_t)..where((p) => p.id.equals(id))).go();
  });

  static PasswordNote _map(PasswordNoteRow r) => PasswordNote(
    id: r.id,
    name: r.name,
    url: r.url,
    username: r.username,
    password: r.password,
    notes: r.notes,
    category: r.category,
    isFavourite: r.isFavourite,
  );
}

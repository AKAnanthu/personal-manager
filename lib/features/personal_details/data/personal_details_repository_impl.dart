import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/db/db_guard.dart';
import 'package:personal_life_manager/core/db/fts_query.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_details_repository.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';
import 'package:uuid/uuid.dart';

final class PersonalDetailsRepositoryImpl implements PersonalDetailsRepository {
  PersonalDetailsRepositoryImpl({
    required this._db,
    this._uuid = const Uuid(),
    this._clock = DateTime.now,
  });

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _clock;

  $PersonalEntriesTable get _t => _db.personalEntries;

  @override
  Stream<PersonalEntry?> watchProfile() =>
      (_db.select(_t)
            ..where((e) => e.kind.equalsValue(DetailKind.profile))
            ..limit(1))
          .watchSingleOrNull()
          .map((r) => r == null ? null : _map(r));

  @override
  Stream<List<PersonalEntry>> watchCategory(DetailCategory category) {
    final kinds = DetailKind.of(category).map((k) => k.name).toList();
    return (_db.select(_t)
          ..where((e) => e.kind.isIn(kinds))
          ..orderBy([
            (e) => OrderingTerm.asc(e.kind),
            (e) => OrderingTerm.asc(e.title),
            (e) => OrderingTerm.asc(e.createdAt),
          ]))
        .watch()
        .map((rows) => rows.map(_map).toList());
  }

  @override
  Stream<List<PersonalEntry>> search(String query) {
    final match = ftsPrefixQuery(query);
    if (match == null) return Stream.value(const []);
    return _db
        .customSelect(
          'SELECT e.* FROM personal_entries e '
          'JOIN personal_entries_fts f ON f.rowid = e.rowid '
          'WHERE personal_entries_fts MATCH ? ORDER BY rank',
          variables: [Variable.withString(match)],
          readsFrom: {_t},
        )
        .watch()
        .map((rows) => [for (final r in rows) _map(_t.map(r.data))]);
  }

  @override
  Stream<PersonalEntry?> watchEntry(String id) =>
      (_db.select(_t)..where((e) => e.id.equals(id))).watchSingleOrNull().map(
        (r) => r == null ? null : _map(r),
      );

  @override
  Future<Result<String>> save(PersonalEntryDraft draft) => dbGuard(() async {
    final now = _clock();
    var id = draft.id;
    if (id == null && draft.kind == DetailKind.profile) {
      // Only one profile: update it if it exists.
      id =
          await (_db.selectOnly(_t)
                ..addColumns([_t.id])
                ..where(_t.kind.equalsValue(DetailKind.profile))
                ..limit(1))
              .map((r) => r.read(_t.id))
              .getSingleOrNull();
    }
    final fields =
        [
              for (final f in draft.fields)
                if (f.value.trim().isNotEmpty || f.isCustom)
                  DetailField(
                    key: f.key,
                    label: f.label?.trim(),
                    value: f.value.trim(),
                    // Template fields take their sensitivity from the spec.
                    sensitive: draft.kind.spec(f.key)?.sensitive ?? f.sensitive,
                  ),
            ]
            .where((f) => f.value.isNotEmpty || (f.label?.isNotEmpty ?? false))
            .toList();
    final companion = PersonalEntriesCompanion(
      kind: Value(draft.kind),
      title: Value(draft.kind.namedByUser ? draft.title.trim() : ''),
      fieldsJson: Value(fields),
      searchText: Value(
        [
          for (final f in fields) ...[?f.label, f.value],
        ].join(' '),
      ),
      linkedDocumentIds: Value(draft.linkedDocumentIds),
      updatedAt: Value(now),
    );
    if (id == null) {
      id = _uuid.v4();
      await _db
          .into(_t)
          .insert(companion.copyWith(id: Value(id), createdAt: Value(now)));
    } else {
      final target = id;
      final n = await (_db.update(
        _t,
      )..where((e) => e.id.equals(target))).write(companion);
      if (n == 0) throw const RecordNotFound();
    }
    return id;
  });

  @override
  Future<Result<void>> delete(String id) => dbGuard(() async {
    await (_db.delete(_t)..where((e) => e.id.equals(id))).go();
  });

  static PersonalEntry _map(PersonalEntryRow r) => PersonalEntry(
    id: r.id,
    kind: r.kind,
    title: r.title,
    fields: r.fieldsJson,
    linkedDocumentIds: r.linkedDocumentIds,
    updatedAt: r.updatedAt,
  );
}

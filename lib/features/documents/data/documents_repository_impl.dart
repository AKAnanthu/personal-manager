import 'dart:io';

import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/db/columns.dart';
import 'package:personal_life_manager/core/db/db_guard.dart';
import 'package:personal_life_manager/core/db/fts_query.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/storage/validated_import.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/domain/documents_repository.dart';
import 'package:uuid/uuid.dart';

/// Text for the expiry notification; supplied by the app so the data layer
/// stays free of l10n.
typedef ExpiryText = ({String title, String body}) Function(
  AppDocument document,
);

final class DocumentsRepositoryImpl implements DocumentsRepository {
  DocumentsRepositoryImpl({
    required this._db,
    required this._files,
    required this._onScheduleChanged,
    this._uuid = const Uuid(),
    this._clock = DateTime.now,
  });

  final AppDatabase _db;
  final FileStore _files;
  final void Function() _onScheduleChanged;
  final Uuid _uuid;
  final DateTime Function() _clock;

  $DocumentsTable get _t => _db.documents;

  @override
  Stream<List<AppDocument>> watch(DocumentFilter filter) {
    final where = <String>['1 = 1'];
    final vars = <Variable<Object>>[];
    final match = ftsPrefixQuery(filter.query);
    if (match != null) vars.add(Variable.withString(match));
    if (filter.favouritesOnly) where.add('d.is_favourite = 1');
    if (filter.category case final c?) {
      where.add('d.category = ?');
      vars.add(Variable.withString(c.name));
    }
    final join = match == null
        ? ''
        : 'JOIN documents_fts f ON f.rowid = d.rowid '
              'AND documents_fts MATCH ?';
    return _db
        .customSelect(
          'SELECT d.* FROM documents d $join WHERE ${where.join(' AND ')} '
          'ORDER BY d.created_at DESC',
          variables: vars,
          readsFrom: {_t},
        )
        .watch()
        .map((rows) => [for (final r in rows) _map(_t.map(r.data))]);
  }

  @override
  Stream<List<AppDocument>> watchExpiringSoon(DateTime today) {
    const dates = DateOnlyConverter();
    final from = DateTime(today.year, today.month, today.day);
    final to = DateTime(
      from.year,
      from.month,
      from.day + expirySoonWindow.inDays,
    );
    // ISO dates compare correctly as text.
    return (_db.select(_t)
          ..where(
            (d) =>
                d.expiryDate.isBiggerOrEqualValue(dates.toSql(from)) &
                d.expiryDate.isSmallerOrEqualValue(dates.toSql(to)),
          )
          ..orderBy([(d) => OrderingTerm.asc(d.expiryDate)]))
        .watch()
        .map((rows) => rows.map(_map).toList());
  }

  @override
  Stream<AppDocument?> watchDocument(String id) =>
      (_db.select(_t)..where((d) => d.id.equals(id))).watchSingleOrNull().map(
        (r) => r == null ? null : _map(r),
      );

  @override
  Stream<List<AppDocument>> watchByIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value(const []);
    return (_db.select(_t)..where((d) => d.id.isIn(ids))).watch().map((rows) {
      final byId = {for (final r in rows) r.id: _map(r)};
      return [for (final id in ids) ?byId[id]];
    });
  }

  @override
  Future<Result<String>> add(
    DocumentDraft draft, {
    required File source,
    required String originalName,
  }) async {
    final ImportedFile file;
    switch (await _files.importValidated(source, originalName: originalName)) {
      case Ok(:final value):
        file = value;
      case Err(:final failure):
        return Err(failure);
    }
    final now = _clock();
    final id = draft.id ?? _uuid.v4();
    final saved = await dbGuard(
      () => _db
          .into(_t)
          .insert(
            _details(draft, now).copyWith(
              id: Value(id),
              createdAt: Value(now),
              fileKey: Value(file.key),
              originalName: Value(originalName),
              fileType: Value(file.type),
              sizeBytes: Value(file.sizeBytes),
            ),
          ),
    );
    if (saved case Err(:final failure)) {
      await _files.delete(file.key);
      return Err(failure);
    }
    _changed(draft.expiryDate != null);
    return Ok(id);
  }

  @override
  Future<Result<void>> update(
    DocumentDraft draft, {
    File? replacement,
    String? replacementName,
  }) async {
    final id = draft.id;
    if (id == null) return const Err(ValidationFailure('update without id'));
    final before = await (_db.select(
      _t,
    )..where((d) => d.id.equals(id))).getSingleOrNull();
    if (before == null) return const Err(NotFoundFailure());

    var companion = _details(draft, _clock());
    ImportedFile? file;
    if (replacement != null) {
      final name = replacementName ?? '';
      switch (await _files.importValidated(replacement, originalName: name)) {
        case Ok(:final value):
          file = value;
          companion = companion.copyWith(
            fileKey: Value(value.key),
            originalName: Value(name),
            fileType: Value(value.type),
            sizeBytes: Value(value.sizeBytes),
            // The Drive copy (if any) is of the old file.
            driveStatus: const Value(DriveStatus.notUploaded),
            driveFileId: const Value(null),
          );
        case Err(:final failure):
          return Err(failure);
      }
    }
    final saved = await dbGuard(
      () => (_db.update(_t)..where((d) => d.id.equals(id))).write(companion),
    );
    switch (saved) {
      case Err(:final failure):
        if (file != null) await _files.delete(file.key);
        return Err(failure);
      case Ok():
        if (file != null) await _files.delete(before.fileKey);
    }
    _changed(before.expiryDate != null || draft.expiryDate != null);
    return const Ok(null);
  }

  @override
  Future<Result<void>> setFavourite(String id, {required bool value}) =>
      dbGuard(() async {
        final n = await (_db.update(_t)..where((d) => d.id.equals(id))).write(
          DocumentsCompanion(
            isFavourite: Value(value),
            updatedAt: Value(_clock()),
          ),
        );
        if (n == 0) throw const RecordNotFound();
      });

  @override
  Future<Result<void>> delete(String id) async {
    final row = await (_db.select(
      _t,
    )..where((d) => d.id.equals(id))).getSingleOrNull();
    if (row == null) return const Ok(null);
    final r = await dbGuard(
      () => (_db.delete(_t)..where((d) => d.id.equals(id))).go(),
    );
    if (r case Err(:final failure)) return Err(failure);
    // A leftover file is harmless; the record is what the user sees.
    await _files.delete(row.fileKey);
    _changed(row.expiryDate != null);
    return const Ok(null);
  }

  @override
  Future<Result<File>> fileFor(AppDocument document) =>
      _files.resolve(document.fileKey);

  /// Expiry reminders (one per document, [expiryReminderLead] ahead).
  Future<List<ScheduleSource>> notificationSources(ExpiryText text) async {
    final rows = await (_db.select(
      _t,
    )..where((d) => d.expiryDate.isNotNull() & d.expiryReminder)).get();
    final sources = <ScheduleSource>[];
    for (final doc in rows.map(_map)) {
      final at = doc.reminderAt;
      if (at == null) continue;
      final t = text(doc);
      sources.add(
        ScheduleSource(
          kind: NotificationKind.documentExpiry,
          entityId: doc.id,
          title: t.title,
          body: t.body,
          route: '/documents/${doc.id}',
          schedule: OneTimeSchedule(at),
        ),
      );
    }
    return sources;
  }

  void _changed(bool affectsSchedule) {
    if (affectsSchedule) _onScheduleChanged();
  }

  static DocumentsCompanion _details(DocumentDraft d, DateTime now) =>
      DocumentsCompanion(
        title: Value(d.title.trim()),
        description: Value(d.description.trim()),
        category: Value(d.category),
        expiryDate: Value(d.expiryDate),
        expiryReminder: Value(d.expiryReminder),
        isFavourite: Value(d.isFavourite),
        updatedAt: Value(now),
      );

  static AppDocument _map(DocumentRow r) => AppDocument(
    id: r.id,
    title: r.title,
    description: r.description,
    category: r.category,
    fileKey: r.fileKey,
    originalName: r.originalName,
    fileType: r.fileType,
    sizeBytes: r.sizeBytes,
    expiryDate: r.expiryDate,
    expiryReminder: r.expiryReminder,
    isFavourite: r.isFavourite,
    driveStatus: r.driveStatus,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  );
}

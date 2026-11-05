import 'dart:io';

import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/db/db_guard.dart';
import 'package:personal_life_manager/core/db/fts_query.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/storage/validated_import.dart';
import 'package:personal_life_manager/features/notes/domain/note.dart';
import 'package:personal_life_manager/features/notes/domain/notes_repository.dart';
import 'package:uuid/uuid.dart';

final class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl({
    required this._db,
    required this._files,
    this._uuid = const Uuid(),
    this._clock = DateTime.now,
  });

  final AppDatabase _db;
  final FileStore _files;
  final Uuid _uuid;
  final DateTime Function() _clock;

  @override
  Stream<List<Note>> watchNotes(NotesFilter filter) {
    final where = <String>[];
    final vars = <Variable<Object>>[];
    switch (filter.view) {
      case NotesView.all:
        where.add('n.is_archived = 0');
      case NotesView.favourites:
        where.add('n.is_archived = 0 AND n.is_favourite = 1');
      case NotesView.archived:
        where.add('n.is_archived = 1');
    }
    if (filter.tag case final tag?) {
      where.add("(' ' || n.tags || ' ') LIKE ?");
      vars.add(Variable.withString('% ${_escapeLike(tag)} %'));
    }
    final match = ftsPrefixQuery(filter.query);
    final join = match == null
        ? ''
        : 'JOIN notes_fts f ON f.rowid = n.rowid AND notes_fts MATCH ?';
    if (match != null) vars.insert(0, Variable.withString(match));

    final sql =
        'SELECT n.* FROM notes n $join WHERE ${where.join(' AND ')} '
        'ORDER BY n.is_pinned DESC, n.updated_at DESC';
    return _db
        .customSelect(
          sql,
          variables: vars,
          readsFrom: {_db.notes, _db.noteAttachments},
        )
        .watch()
        .asyncMap(
          (rows) =>
              _withAttachments([for (final r in rows) _db.notes.map(r.data)]),
        );
  }

  @override
  Stream<List<String>> watchTags() =>
      (_db.selectOnly(_db.notes)
            ..addColumns([_db.notes.tags])
            ..where(_db.notes.isArchived.equals(false)))
          .watch()
          .map((rows) {
            final tags = <String>{
              for (final r in rows)
                ...?r
                    .read(_db.notes.tags)
                    ?.split(' ')
                    .where((t) => t.isNotEmpty),
            };
            return tags.toList()..sort();
          });

  @override
  Stream<Note?> watchNote(String id) =>
      (_db.select(_db.notes)..where((n) => n.id.equals(id)))
          .watchSingleOrNull()
          .asyncMap((row) async {
            if (row == null) return null;
            return (await _withAttachments([row])).first;
          });

  @override
  Future<Result<String>> save(NoteDraft draft) => _guard(() async {
    final now = _clock();
    final id = draft.id ?? _uuid.v4();
    final companion = NotesCompanion(
      id: Value(id),
      title: Value(draft.title.trim()),
      contentJson: Value(draft.contentJson),
      plainText: Value(draft.plainText.trim()),
      tags: Value(normaliseTags(draft.tags).join(' ')),
      isPinned: Value(draft.isPinned),
      isFavourite: Value(draft.isFavourite),
      updatedAt: Value(now),
    );
    if (draft.id == null) {
      await _db
          .into(_db.notes)
          .insert(companion.copyWith(createdAt: Value(now)));
    } else {
      final updated = await (_db.update(
        _db.notes,
      )..where((n) => n.id.equals(id))).write(companion);
      if (updated == 0) throw const RecordNotFound();
    }
    return id;
  });

  @override
  Future<Result<void>> setPinned(String id, {required bool value}) =>
      _patch(id, NotesCompanion(isPinned: Value(value)));

  @override
  Future<Result<void>> setFavourite(String id, {required bool value}) =>
      _patch(id, NotesCompanion(isFavourite: Value(value)));

  @override
  Future<Result<void>> setArchived(String id, {required bool value}) => _patch(
    id,
    // Archived notes leave the pinned section.
    NotesCompanion(
      isArchived: Value(value),
      isPinned: value ? const Value(false) : const Value.absent(),
    ),
  );

  @override
  Future<Result<void>> delete(String id) => _guard(() async {
    final keys = await _db.transaction(() async {
      final atts = await (_db.select(
        _db.noteAttachments,
      )..where((a) => a.noteId.equals(id))).get();
      await (_db.delete(_db.notes)..where((n) => n.id.equals(id))).go();
      return [for (final a in atts) a.fileKey];
    });
    // Files go after the rows are gone; an orphaned file is harmless,
    // a row pointing at a missing file is not.
    for (final k in keys) {
      await _files.delete(k);
    }
  });

  @override
  Future<Result<NoteAttachment>> addAttachment(
    String noteId,
    File source, {
    required String originalName,
  }) async {
    final ImportedFile imported;
    switch (await _files.importValidated(source, originalName: originalName)) {
      case Ok(:final value):
        imported = value;
      case Err(:final failure):
        return Err(failure);
    }
    final key = imported.key;
    final now = _clock();
    final row = NoteAttachmentRow(
      id: _uuid.v4(),
      noteId: noteId,
      fileKey: key,
      originalName: originalName,
      mimeType: imported.type.mimeType,
      sizeBytes: imported.sizeBytes,
      createdAt: now,
      updatedAt: now,
    );
    final saved = await _guard(() async {
      await _db.into(_db.noteAttachments).insert(row);
      await _touch(noteId);
    });
    if (saved case Err(:final failure)) {
      await _files.delete(key);
      return Err(failure);
    }
    return Ok(_attachment(row));
  }

  @override
  Future<Result<void>> removeAttachment(NoteAttachment attachment) =>
      _guard(() async {
        await (_db.delete(
          _db.noteAttachments,
        )..where((a) => a.id.equals(attachment.id))).go();
        await _touch(attachment.noteId);
        await _files.delete(attachment.fileKey);
      });

  @override
  Future<Result<File>> attachmentFile(NoteAttachment attachment) =>
      _files.resolve(attachment.fileKey);

  Future<void> _touch(String noteId) =>
      (_db.update(_db.notes)..where((n) => n.id.equals(noteId))).write(
        NotesCompanion(updatedAt: Value(_clock())),
      );

  Future<Result<void>> _patch(String id, NotesCompanion patch) =>
      _guard(() async {
        final n = await (_db.update(_db.notes)..where((n) => n.id.equals(id)))
            .write(patch.copyWith(updatedAt: Value(_clock())));
        if (n == 0) throw const RecordNotFound();
      });

  Future<List<Note>> _withAttachments(List<NoteRow> rows) async {
    if (rows.isEmpty) return const [];
    final ids = [for (final r in rows) r.id];
    final atts =
        await (_db.select(_db.noteAttachments)
              ..where((a) => a.noteId.isIn(ids))
              ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
            .get();
    final byNote = <String, List<NoteAttachment>>{};
    for (final a in atts) {
      (byNote[a.noteId] ??= []).add(_attachment(a));
    }
    return [for (final r in rows) _note(r, byNote[r.id] ?? const [])];
  }

  static Note _note(NoteRow r, List<NoteAttachment> atts) => Note(
    id: r.id,
    title: r.title,
    contentJson: r.contentJson,
    plainText: r.plainText,
    tags: r.tags.split(' ').where((t) => t.isNotEmpty).toList(),
    isPinned: r.isPinned,
    isFavourite: r.isFavourite,
    isArchived: r.isArchived,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
    attachments: atts,
  );

  static NoteAttachment _attachment(NoteAttachmentRow a) => NoteAttachment(
    id: a.id,
    noteId: a.noteId,
    fileKey: a.fileKey,
    originalName: a.originalName,
    mimeType: a.mimeType,
    sizeBytes: a.sizeBytes,
  );

  static String _escapeLike(String s) =>
      s.replaceAll('%', '').replaceAll('_', '');

  static Future<Result<T>> _guard<T>(Future<T> Function() body) =>
      dbGuard(body);
}

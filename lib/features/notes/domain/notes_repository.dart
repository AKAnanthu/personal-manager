import 'dart:io';

import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/notes/domain/note.dart';

abstract interface class NotesRepository {
  /// Pinned first, then most recently edited.
  Stream<List<Note>> watchNotes(NotesFilter filter);

  Stream<List<String>> watchTags();

  Stream<Note?> watchNote(String id);

  /// Inserts or updates; returns the note id.
  Future<Result<String>> save(NoteDraft draft);

  Future<Result<void>> setPinned(String id, {required bool value});

  Future<Result<void>> setFavourite(String id, {required bool value});

  Future<Result<void>> setArchived(String id, {required bool value});

  /// Deletes the note, its attachments and their files.
  Future<Result<void>> delete(String id);

  /// Validates and copies [source] into app storage.
  Future<Result<NoteAttachment>> addAttachment(
    String noteId,
    File source, {
    required String originalName,
  });

  Future<Result<void>> removeAttachment(NoteAttachment attachment);

  Future<Result<File>> attachmentFile(NoteAttachment attachment);
}

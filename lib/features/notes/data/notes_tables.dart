import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/columns.dart';

@DataClassName('NoteRow')
class Notes extends Table with RecordColumns {
  TextColumn get title => text().withDefault(const Constant(''))();

  /// Rich text as a Quill Delta (JSON).
  TextColumn get contentJson => text()();

  /// Plain-text projection of the content, indexed for search.
  TextColumn get plainText => text().withDefault(const Constant(''))();

  /// Lower-case tags separated by single spaces (also indexed).
  TextColumn get tags => text().withDefault(const Constant(''))();

  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

@DataClassName('NoteAttachmentRow')
class NoteAttachments extends Table with RecordColumns {
  TextColumn get noteId =>
      text().references(Notes, #id, onDelete: KeyAction.cascade)();

  /// Key in the app's FileStore (never the original file name).
  TextColumn get fileKey => text()();
  TextColumn get originalName => text()();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer()();
}

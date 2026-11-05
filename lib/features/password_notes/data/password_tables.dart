import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/columns.dart';

/// Stored without app-level encryption (PRD §6, V1 decision).
@DataClassName('PasswordNoteRow')
class PasswordNotes extends Table with RecordColumns {
  TextColumn get name => text()();
  TextColumn get url => text().withDefault(const Constant(''))();
  TextColumn get username => text().withDefault(const Constant(''))();

  /// Never indexed for search.
  TextColumn get password => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant(''))();
  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();
}

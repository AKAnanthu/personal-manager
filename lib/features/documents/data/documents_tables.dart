import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/columns.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';

@DataClassName('DocumentRow')
class Documents extends Table with RecordColumns {
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get category => textEnum<DocumentCategory>()();

  /// Key in the app's FileStore (never the original file name).
  TextColumn get fileKey => text()();
  TextColumn get originalName => text()();
  TextColumn get fileType => textEnum<SupportedFileType>()();
  IntColumn get sizeBytes => integer()();
  TextColumn get expiryDate =>
      text().map(const DateOnlyConverter()).nullable()();
  BoolColumn get expiryReminder =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();
  TextColumn get driveStatus => textEnum<DriveStatus>().withDefault(
    Constant(DriveStatus.notUploaded.name),
  )();

  /// Drive file id once uploaded (Drive milestone).
  TextColumn get driveFileId => text().nullable()();
}

import 'dart:io';

import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';

typedef ImportedFile = ({String key, SupportedFileType type, int sizeBytes});

extension ValidatedImport on FileStore {
  /// Checks type (extension and signature) and size, then copies [source]
  /// into the store.
  Future<Result<ImportedFile>> importValidated(
    File source, {
    required String originalName,
  }) async {
    final check = await FileTypeValidator.check(
      source,
      originalName: originalName,
    );
    switch (check) {
      case FileUnsupported():
        return const Err(UnsupportedFileFailure());
      case FileTooLarge(:final maxBytes):
        return Err(FileTooLargeFailure(maxBytes));
      case FileAccepted(:final type, :final sizeBytes):
        final imported = await importFile(source);
        return imported.fold<Result<ImportedFile>>(
          Err.new,
          (key) => Ok((key: key, type: type, sizeBytes: sizeBytes)),
        );
    }
  }
}

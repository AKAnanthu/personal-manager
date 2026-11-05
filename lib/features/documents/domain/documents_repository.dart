import 'dart:io';

import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';

abstract interface class DocumentsRepository {
  /// Newest first.
  Stream<List<AppDocument>> watch(DocumentFilter filter);

  /// Not yet expired, expiring within [expirySoonWindow] of [today];
  /// soonest first.
  Stream<List<AppDocument>> watchExpiringSoon(DateTime today);

  Stream<AppDocument?> watchDocument(String id);

  /// In the order of [ids]; missing ones are skipped.
  Stream<List<AppDocument>> watchByIds(List<String> ids);

  /// Validates [source] (type and size), copies it into app storage and
  /// saves the record. Nothing is left behind on failure.
  Future<Result<String>> add(
    DocumentDraft draft, {
    required File source,
    required String originalName,
  });

  /// Saves details; with [replacement] the stored file is swapped too (the
  /// old file is removed only after the new one is saved).
  Future<Result<void>> update(
    DocumentDraft draft, {
    File? replacement,
    String? replacementName,
  });

  Future<Result<void>> setFavourite(String id, {required bool value});

  /// Removes the record and the local file. Never touches a Drive copy.
  Future<Result<void>> delete(String id);

  Future<Result<File>> fileFor(AppDocument document);
}

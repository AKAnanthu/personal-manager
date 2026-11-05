import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_note.dart';

abstract interface class PasswordNotesRepository {
  /// Favourites first, then by name.
  Stream<List<PasswordNote>> watch(PasswordFilter filter);

  /// Categories in use (sorted).
  Stream<List<String>> watchCategories();

  Stream<PasswordNote?> watchNote(String id);

  Future<Result<String>> save(PasswordNoteDraft draft);

  Future<Result<void>> setFavourite(String id, {required bool value});

  Future<Result<void>> delete(String id);
}

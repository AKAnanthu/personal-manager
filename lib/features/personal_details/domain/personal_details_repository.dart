import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';

abstract interface class PersonalDetailsRepository {
  /// The single profile entry (personal information), if saved.
  Stream<PersonalEntry?> watchProfile();

  Stream<List<PersonalEntry>> watchCategory(DetailCategory category);

  /// Full-text search over titles and all values.
  Stream<List<PersonalEntry>> search(String query);

  Stream<PersonalEntry?> watchEntry(String id);

  /// Saving a profile without an id updates the existing profile.
  Future<Result<String>> save(PersonalEntryDraft draft);

  Future<Result<void>> delete(String id);
}

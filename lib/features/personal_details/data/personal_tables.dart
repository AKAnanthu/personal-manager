import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/columns.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';

@DataClassName('PersonalEntryRow')
class PersonalEntries extends Table with RecordColumns {
  TextColumn get kind => textEnum<DetailKind>()();
  TextColumn get title => text().withDefault(const Constant(''))();

  /// Ordered fields as JSON.
  TextColumn get fieldsJson => text().map(const DetailFieldsConverter())();

  /// Plain text of every value, indexed for search.
  TextColumn get searchText => text().withDefault(const Constant(''))();

  /// Ids of linked documents (no file duplication).
  TextColumn get linkedDocumentIds => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
}

final class DetailFieldsConverter
    extends TypeConverter<List<DetailField>, String> {
  const DetailFieldsConverter();

  @override
  List<DetailField> fromSql(String fromDb) {
    final data = jsonDecode(fromDb);
    if (data is! List) return const [];
    return [for (final f in data) ?DetailField.fromJson(f)];
  }

  @override
  String toSql(List<DetailField> value) =>
      jsonEncode([for (final f in value) f.toJson()]);
}

final class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    final data = jsonDecode(fromDb);
    return data is List
        ? [
            for (final s in data)
              if (s is String) s,
          ]
        : const [];
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

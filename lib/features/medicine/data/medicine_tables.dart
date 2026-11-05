import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/columns.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';

/// "08:00,21:00".
final class TimesConverter
    extends TypeConverter<List<TimeOfDayMinutes>, String> {
  const TimesConverter();

  @override
  List<TimeOfDayMinutes> fromSql(String fromDb) => [
    for (final part in fromDb.split(','))
      if (RegExp(r'^(\d{2}):(\d{2})$').firstMatch(part.trim()) case final m?)
        TimeOfDayMinutes(int.parse(m[1] ?? '0'), int.parse(m[2] ?? '0')),
  ];

  @override
  String toSql(List<TimeOfDayMinutes> value) =>
      [for (final t in value) '${_two(t.hour)}:${_two(t.minute)}'].join(',');

  static String _two(int n) => n.toString().padLeft(2, '0');
}

/// "1,2,3" (ISO weekdays); empty = every day.
final class WeekdaysConverter extends TypeConverter<Set<int>, String> {
  const WeekdaysConverter();

  @override
  Set<int> fromSql(String fromDb) => {
    for (final p in fromDb.split(','))
      if (int.tryParse(p.trim()) case final d? when d >= 1 && d <= 7) d,
  };

  @override
  String toSql(Set<int> value) => (value.toList()..sort()).join(',');
}

@DataClassName('MedicineRow')
class Medicines extends Table with RecordColumns {
  TextColumn get name => text()();
  TextColumn get times => text().map(const TimesConverter())();
  TextColumn get weekdays =>
      text().map(const WeekdaysConverter()).withDefault(const Constant(''))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

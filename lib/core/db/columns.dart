import 'package:drift/drift.dart';

/// Columns every record has: a stable UUID (for backup merge and restore
/// dedup) and audit timestamps (instants, stored as epoch).
mixin RecordColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Stores a local wall-clock date-time (`2026-11-04T10:00`) without a zone,
/// so "10:00" stays 10:00 if the device timezone changes.
final class WallClockConverter extends TypeConverter<DateTime, String> {
  const WallClockConverter();

  @override
  DateTime fromSql(String fromDb) {
    final m = _pattern.firstMatch(fromDb);
    if (m == null) throw FormatException('bad wall-clock value', fromDb);
    int g(int i) => int.parse(m.group(i) ?? '0');
    return DateTime(g(1), g(2), g(3), g(4), g(5));
  }

  @override
  String toSql(DateTime value) =>
      '${_four(value.year)}-${_two(value.month)}-${_two(value.day)}'
      'T${_two(value.hour)}:${_two(value.minute)}';

  static final _pattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})$');
  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _four(int n) => n.toString().padLeft(4, '0');
}

/// Stores a calendar date (`2026-11-12`) without time or zone.
final class DateOnlyConverter extends TypeConverter<DateTime, String> {
  const DateOnlyConverter();

  @override
  DateTime fromSql(String fromDb) {
    final parts = fromDb.split('-');
    if (parts.length != 3) throw FormatException('bad date', fromDb);
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  @override
  String toSql(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

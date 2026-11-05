import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/columns.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';

@DataClassName('ReminderRow')
class Reminders extends Table with RecordColumns {
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();

  /// First occurrence; repeats are computed from it (keeps month-end and
  /// leap-day clamping exact).
  TextColumn get anchorAt => text().map(const WallClockConverter())();

  /// The occurrence currently waiting to be marked done.
  TextColumn get dueAt => text().map(const WallClockConverter())();
  TextColumn get repeat => textEnum<RepeatFrequency>()();

  /// In-app snooze of a repeating reminder (one extra notification).
  TextColumn get snoozedUntil =>
      text().map(const WallClockConverter()).nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

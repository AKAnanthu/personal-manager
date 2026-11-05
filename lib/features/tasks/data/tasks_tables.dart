import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/columns.dart';

@DataClassName('TaskRow')
class Tasks extends Table with RecordColumns {
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get dueDate => text().map(const DateOnlyConverter()).nullable()();

  /// Optional reminder (local wall-clock time).
  TextColumn get reminderAt =>
      text().map(const WallClockConverter()).nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

@DataClassName('ChecklistItemRow')
class TaskChecklistItems extends Table with RecordColumns {
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer()();
}

import 'package:equatable/equatable.dart';

final class ChecklistItem extends Equatable {
  const ChecklistItem({
    required this.id,
    required this.label,
    required this.isDone,
  });

  final String id;
  final String label;
  final bool isDone;

  ChecklistItem copyWith({String? label, bool? isDone}) => ChecklistItem(
    id: id,
    label: label ?? this.label,
    isDone: isDone ?? this.isDone,
  );

  @override
  List<Object?> get props => [id, label, isDone];
}

final class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.updatedAt,
    this.dueDate,
    this.reminderAt,
    this.completedAt,
    this.checklist = const [],
  });

  final String id;
  final String title;
  final String description;

  /// Calendar date (time ignored).
  final DateTime? dueDate;

  /// Local wall-clock reminder time.
  final DateTime? reminderAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime updatedAt;
  final List<ChecklistItem> checklist;

  int get checklistDone => checklist.where((i) => i.isDone).length;

  /// Due before [today] and not completed.
  bool isOverdue(DateTime today) {
    final due = dueDate;
    if (due == null || isCompleted) return false;
    return due.isBefore(DateTime(today.year, today.month, today.day));
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dueDate,
    reminderAt,
    isCompleted,
    completedAt,
    updatedAt,
    checklist,
  ];
}

final class TaskDraft extends Equatable {
  const TaskDraft({
    required this.title,
    this.id,
    this.description = '',
    this.dueDate,
    this.reminderAt,
    this.checklist = const [],
  });

  final String? id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final DateTime? reminderAt;

  /// Items without an id are new.
  final List<({String? id, String label, bool isDone})> checklist;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dueDate,
    reminderAt,
    checklist,
  ];
}

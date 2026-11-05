import 'package:equatable/equatable.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';

final class Reminder extends Equatable {
  const Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.anchorAt,
    required this.dueAt,
    required this.repeat,
    required this.isCompleted,
    this.snoozedUntil,
  });

  final String id;
  final String title;
  final String description;

  /// First occurrence; repeats are derived from it.
  final DateTime anchorAt;

  /// Occurrence currently waiting to be marked done.
  final DateTime dueAt;
  final RepeatFrequency repeat;
  final DateTime? snoozedUntil;
  final bool isCompleted;

  /// When it next needs attention (a snooze pushes it back).
  DateTime get effectiveAt {
    final snooze = snoozedUntil;
    return snooze != null && snooze.isAfter(dueAt) ? snooze : dueAt;
  }

  bool isOverdue(DateTime now) => !isCompleted && effectiveAt.isBefore(now);

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    anchorAt,
    dueAt,
    repeat,
    snoozedUntil,
    isCompleted,
  ];
}

final class ReminderDraft extends Equatable {
  const ReminderDraft({
    required this.title,
    required this.at,
    required this.repeat,
    this.id,
    this.description = '',
  });

  final String? id;
  final String title;
  final String description;

  /// Date and time of the first occurrence.
  final DateTime at;
  final RepeatFrequency repeat;

  @override
  List<Object?> get props => [id, title, description, at, repeat];
}

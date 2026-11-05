import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/reminders/domain/reminder.dart';

abstract interface class RemindersRepository {
  /// Open (not completed) reminders, soonest first.
  Stream<List<Reminder>> watchOpen();

  Stream<Reminder?> watchReminder(String id);

  Future<Result<String>> save(ReminderDraft draft);

  /// One-time: completes it. Repeating: moves to the next occurrence.
  Future<Result<void>> markDone(String id);

  Future<Result<void>> snooze(String id, Duration duration);

  Future<Result<void>> delete(String id);
}

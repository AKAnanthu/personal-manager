import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/tasks/domain/task.dart';

abstract interface class TasksRepository {
  /// Pending: by due date (undated last). Completed: most recent first.
  Stream<List<Task>> watchTasks({required bool completed, String query = ''});

  Stream<({int pending, int completed})> watchCounts();

  Stream<Task?> watchTask(String id);

  Future<Result<String>> save(TaskDraft draft);

  Future<Result<void>> setCompleted(String id, {required bool value});

  Future<Result<void>> setChecklistItemDone(
    String itemId, {
    required bool value,
  });

  Future<Result<void>> delete(String id);
}

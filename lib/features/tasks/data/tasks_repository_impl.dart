import 'package:drift/drift.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/db/db_guard.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/features/tasks/domain/task.dart';
import 'package:personal_life_manager/features/tasks/domain/tasks_repository.dart';
import 'package:uuid/uuid.dart';

final class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl({
    required this._db,
    required this._onScheduleChanged,
    this._uuid = const Uuid(),
    this._clock = DateTime.now,
  });

  final AppDatabase _db;

  /// Re-plans notifications after a change that affects reminders.
  final void Function() _onScheduleChanged;
  final Uuid _uuid;
  final DateTime Function() _clock;

  @override
  Stream<List<Task>> watchTasks({required bool completed, String query = ''}) {
    final q = _db.select(_db.tasks)
      ..where((t) => t.isCompleted.equals(completed));
    final term = query.trim();
    if (term.isNotEmpty) {
      final like = '%${term.replaceAll('%', '').replaceAll('_', '')}%';
      q.where((t) => t.title.like(like) | t.description.like(like));
    }
    q.orderBy(
      completed
          ? [(t) => OrderingTerm.desc(t.completedAt)]
          : [
              // Undated tasks sort last.
              (t) => OrderingTerm.asc(t.dueDate.isNull()),
              (t) => OrderingTerm.asc(t.dueDate),
              (t) => OrderingTerm.desc(t.updatedAt),
            ],
    );
    // Checklist changes touch the parent task, so this re-emits for them.
    return q.watch().asyncMap((rows) async {
      final ids = [for (final r in rows) r.id];
      final items = ids.isEmpty
          ? const <ChecklistItemRow>[]
          : await (_db.select(_db.taskChecklistItems)
                  ..where((i) => i.taskId.isIn(ids))
                  ..orderBy([(i) => OrderingTerm.asc(i.position)]))
                .get();
      return _assemble(rows, items);
    });
  }

  @override
  Stream<({int pending, int completed})> watchCounts() {
    final done = _db.tasks.isCompleted;
    final count = _db.tasks.id.count();
    return (_db.selectOnly(_db.tasks)
          ..addColumns([done, count])
          ..groupBy([done]))
        .watch()
        .map((rows) {
          var pending = 0;
          var completed = 0;
          for (final r in rows) {
            final n = r.read(count) ?? 0;
            if (r.read(done) ?? false) {
              completed = n;
            } else {
              pending = n;
            }
          }
          return (pending: pending, completed: completed);
        });
  }

  @override
  Stream<Task?> watchTask(String id) =>
      (_db.select(_db.tasks)..where((t) => t.id.equals(id)))
          .watchSingleOrNull()
          .asyncMap((row) async {
            if (row == null) return null;
            final items =
                await (_db.select(_db.taskChecklistItems)
                      ..where((i) => i.taskId.equals(id))
                      ..orderBy([(i) => OrderingTerm.asc(i.position)]))
                    .get();
            return _assemble([row], items).first;
          });

  @override
  Future<Result<String>> save(TaskDraft draft) async {
    final result = await dbGuard(
      () => _db.transaction(() async {
        final now = _clock();
        final id = draft.id ?? _uuid.v4();
        final companion = TasksCompanion(
          id: Value(id),
          title: Value(draft.title.trim()),
          description: Value(draft.description.trim()),
          dueDate: Value(draft.dueDate),
          reminderAt: Value(draft.reminderAt),
          updatedAt: Value(now),
        );
        if (draft.id == null) {
          await _db
              .into(_db.tasks)
              .insert(companion.copyWith(createdAt: Value(now)));
        } else {
          final n = await (_db.update(
            _db.tasks,
          )..where((t) => t.id.equals(id))).write(companion);
          if (n == 0) throw const RecordNotFound();
        }

        // Replace the checklist, keeping ids (and createdAt) of kept items.
        final existing = {
          for (final r in await (_db.select(
            _db.taskChecklistItems,
          )..where((i) => i.taskId.equals(id))).get())
            r.id: r,
        };
        final keep = <String>{};
        var position = 0;
        for (final item in draft.checklist) {
          final label = item.label.trim();
          if (label.isEmpty) continue;
          final itemId = item.id ?? _uuid.v4();
          keep.add(itemId);
          await _db
              .into(_db.taskChecklistItems)
              .insertOnConflictUpdate(
                ChecklistItemRow(
                  id: itemId,
                  taskId: id,
                  label: label,
                  isDone: item.isDone,
                  position: position++,
                  createdAt: existing[itemId]?.createdAt ?? now,
                  updatedAt: now,
                ),
              );
        }
        await (_db.delete(_db.taskChecklistItems)
              ..where((i) => i.taskId.equals(id) & i.id.isNotIn(keep.toList())))
            .go();
        return id;
      }),
    );
    if (result.isSuccess) _onScheduleChanged();
    return result;
  }

  @override
  Future<Result<void>> setCompleted(String id, {required bool value}) async {
    final now = _clock();
    final result = await dbGuard(() async {
      final n = await (_db.update(_db.tasks)..where((t) => t.id.equals(id)))
          .write(
            TasksCompanion(
              isCompleted: Value(value),
              completedAt: Value(value ? now : null),
              updatedAt: Value(now),
            ),
          );
      if (n == 0) throw const RecordNotFound();
    });
    if (result.isSuccess) _onScheduleChanged();
    return result;
  }

  @override
  Future<Result<void>> setChecklistItemDone(
    String itemId, {
    required bool value,
  }) => dbGuard(
    () => _db.transaction(() async {
      final now = _clock();
      final item = await (_db.select(
        _db.taskChecklistItems,
      )..where((i) => i.id.equals(itemId))).getSingleOrNull();
      if (item == null) throw const RecordNotFound();
      await (_db.update(
        _db.taskChecklistItems,
      )..where((i) => i.id.equals(itemId))).write(
        TaskChecklistItemsCompanion(
          isDone: Value(value),
          updatedAt: Value(now),
        ),
      );
      await (_db.update(_db.tasks)..where((t) => t.id.equals(item.taskId)))
          .write(TasksCompanion(updatedAt: Value(now)));
    }),
  );

  @override
  Future<Result<void>> delete(String id) async {
    final result = await dbGuard(
      () => (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go(),
    );
    if (result.isSuccess) _onScheduleChanged();
    return result;
  }

  /// Pending tasks with a reminder, for the notification scheduler.
  Future<List<ScheduleSource>> notificationSources() async {
    final rows =
        await (_db.select(_db.tasks)..where(
              (t) => t.isCompleted.equals(false) & t.reminderAt.isNotNull(),
            ))
            .get();
    return [
      for (final r in rows)
        if (r.reminderAt case final at?)
          ScheduleSource(
            kind: NotificationKind.task,
            entityId: r.id,
            title: r.title,
            body: r.description,
            route: '/tasks/${r.id}',
            schedule: OneTimeSchedule(at),
          ),
    ];
  }

  static List<Task> _assemble(
    List<TaskRow> rows,
    List<ChecklistItemRow> items,
  ) {
    final byTask = <String, List<ChecklistItem>>{};
    for (final i in items) {
      (byTask[i.taskId] ??= []).add(
        ChecklistItem(id: i.id, label: i.label, isDone: i.isDone),
      );
    }
    return [
      for (final r in rows)
        Task(
          id: r.id,
          title: r.title,
          description: r.description,
          dueDate: r.dueDate,
          reminderAt: r.reminderAt,
          isCompleted: r.isCompleted,
          completedAt: r.completedAt,
          updatedAt: r.updatedAt,
          checklist: byTask[r.id] ?? const [],
        ),
    ];
  }
}

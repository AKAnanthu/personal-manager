import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/features/tasks/data/tasks_repository_impl.dart';
import 'package:personal_life_manager/features/tasks/domain/task.dart';

import '../../helpers/fakes.dart';

T ok<T>(Result<T> r) => r.fold((f) => fail('unexpected $f'), (v) => v);

void main() {
  late AppDatabase db;
  late TasksRepositoryImpl repo;
  late int replans;
  late TestClock clock;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    replans = 0;
    clock = TestClock();
    repo = TasksRepositoryImpl(
      db: db,
      onScheduleChanged: () => replans++,
      clock: clock.call,
    );
  });
  tearDown(() => db.close());

  Future<List<String>> pending() async => [
    for (final t in await repo.watchTasks(completed: false).first) t.title,
  ];

  test('pending sorted by due date, undated last', () async {
    ok(await repo.save(const TaskDraft(title: 'No date')));
    ok(
      await repo.save(
        TaskDraft(title: 'Later', dueDate: DateTime(2026, 11, 20)),
      ),
    );
    ok(
      await repo.save(TaskDraft(title: 'Soon', dueDate: DateTime(2026, 11, 5))),
    );

    expect(await pending(), ['Soon', 'Later', 'No date']);
  });

  test('complete / reopen moves between tabs and updates counts', () async {
    final id = ok(await repo.save(const TaskDraft(title: 'A')));
    ok(await repo.save(const TaskDraft(title: 'B')));

    ok(await repo.setCompleted(id, value: true));
    expect(await pending(), ['B']);
    final done = await repo.watchTasks(completed: true).first;
    expect(done.single.completedAt, clock.now);
    expect(await repo.watchCounts().first, (pending: 1, completed: 1));

    ok(await repo.setCompleted(id, value: false));
    expect(await repo.watchCounts().first, (pending: 2, completed: 0));
  });

  test(
    'checklist is saved in order, edited in place, blanks dropped',
    () async {
      final id = ok(
        await repo.save(
          const TaskDraft(
            title: 'Renew insurance',
            checklist: [
              (id: null, label: 'Compare quotes', isDone: true),
              (id: null, label: '  ', isDone: false),
              (id: null, label: 'Pay', isDone: false),
            ],
          ),
        ),
      );
      var task = await repo.watchTask(id).first;
      expect(task?.checklist.map((i) => i.label), ['Compare quotes', 'Pay']);
      expect(task?.checklistDone, 1);

      final keep = task!.checklist.first;
      ok(
        await repo.save(
          TaskDraft(
            id: id,
            title: 'Renew insurance',
            checklist: [
              (id: null, label: 'Check RC', isDone: false),
              (id: keep.id, label: keep.label, isDone: keep.isDone),
            ],
          ),
        ),
      );
      task = await repo.watchTask(id).first;
      expect(task?.checklist.map((i) => i.label), [
        'Check RC',
        'Compare quotes',
      ]);
      expect(task?.checklist.last.id, keep.id);
    },
  );

  test('ticking an item re-emits the list', () async {
    final id = ok(
      await repo.save(
        const TaskDraft(
          title: 'T',
          checklist: [(id: null, label: 'x', isDone: false)],
        ),
      ),
    );
    final item = (await repo.watchTask(id).first)!.checklist.single;
    final emissions = repo.watchTasks(completed: false).take(2).toList();
    await Future<void>.delayed(Duration.zero);

    ok(await repo.setChecklistItemDone(item.id, value: true));

    final lists = await emissions;
    expect(lists.last.single.checklist.single.isDone, isTrue);
  });

  test('search matches title or description', () async {
    ok(
      await repo.save(
        const TaskDraft(title: 'Dentist', description: 'call clinic'),
      ),
    );
    ok(await repo.save(const TaskDraft(title: 'Library')));

    final r = await repo.watchTasks(completed: false, query: 'clinic').first;
    expect(r.single.title, 'Dentist');
  });

  test('overdue only for past due dates on pending tasks', () {
    final today = DateTime(2026, 11, 3, 18);
    Task t({DateTime? due, bool done = false}) => Task(
      id: 'x',
      title: 'x',
      description: '',
      dueDate: due,
      isCompleted: done,
      updatedAt: today,
    );
    expect(t(due: DateTime(2026, 11, 2)).isOverdue(today), isTrue);
    expect(t(due: DateTime(2026, 11, 3)).isOverdue(today), isFalse);
    expect(t(due: DateTime(2026, 11, 2), done: true).isOverdue(today), isFalse);
    expect(t().isOverdue(today), isFalse);
  });

  test('reminders become notification sources and changes re-plan', () async {
    final id = ok(
      await repo.save(
        TaskDraft(title: 'Call CA', reminderAt: DateTime(2026, 11, 9, 10)),
      ),
    );
    ok(await repo.save(const TaskDraft(title: 'No reminder')));
    expect(replans, 2);

    final sources = await repo.notificationSources();
    expect(sources.single.kind, NotificationKind.task);
    expect(sources.single.route, '/tasks/$id');
    expect(sources.single.schedule, OneTimeSchedule(DateTime(2026, 11, 9, 10)));

    ok(await repo.setCompleted(id, value: true));
    expect(await repo.notificationSources(), isEmpty);
    expect(replans, 3);
  });

  test('deleting a task removes its checklist', () async {
    final id = ok(
      await repo.save(
        const TaskDraft(
          title: 'T',
          checklist: [(id: null, label: 'x', isDone: false)],
        ),
      ),
    );
    ok(await repo.delete(id));
    expect(await db.select(db.taskChecklistItems).get(), isEmpty);
  });
}

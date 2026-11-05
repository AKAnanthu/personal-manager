import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/tasks/domain/task.dart';
import 'package:personal_life_manager/features/tasks/domain/tasks_repository.dart';
import 'package:personal_life_manager/features/tasks/presentation/task_editor_cubit.dart';

import '../../helpers/fakes.dart';

class _Repo extends Mock implements TasksRepository;

class _Perms extends Mock implements NotificationPermissions;

void main() {
  late _Repo repo;
  late _Perms perms;
  final clock = TestClock(DateTime(2026, 11, 3, 18));

  setUpAll(() => registerFallbackValue(const TaskDraft(title: '')));

  setUp(() {
    repo = _Repo();
    perms = _Perms();
    when(() => repo.save(any())).thenAnswer((_) async => const Ok('t'));
    when(perms.ensurePermission).thenAnswer((_) async => true);
  });

  TaskEditorCubit build() =>
      TaskEditorCubit(repository: repo, permissions: perms, clock: clock.call);

  blocTest<TaskEditorCubit, TaskEditorState>(
    'requires a title',
    build: build,
    act: (c) async {
      await c.load();
      await c.save();
    },
    verify: (c) {
      expect(c.state.showErrors, isTrue);
      verifyNever(() => repo.save(any()));
    },
  );

  blocTest<TaskEditorCubit, TaskEditorState>(
    'rejects a reminder in the past',
    build: build,
    act: (c) async {
      await c.load();
      c
        ..titleChanged('Call')
        ..reminderChanged(DateTime(2026, 11, 3, 9));
      await c.save();
    },
    verify: (_) => verifyNever(() => repo.save(any())),
  );

  blocTest<TaskEditorCubit, TaskEditorState>(
    'saves checklist in order and asks permission only with a reminder',
    build: build,
    act: (c) async {
      await c.load();
      c
        ..titleChanged('Renew insurance')
        ..addItem()
        ..addItem();
      final keys = c.state.items.map((i) => i.key).toList();
      c
        ..itemChanged(keys[0], 'Compare quotes')
        ..itemChanged(keys[1], 'Pay')
        ..itemToggled(keys[0], done: true);
      await c.save();
    },
    verify: (c) {
      final draft =
          verify(() => repo.save(captureAny())).captured.single as TaskDraft;
      expect(draft.checklist.map((i) => i.label), ['Compare quotes', 'Pay']);
      expect(draft.checklist.first.isDone, isTrue);
      verifyNever(perms.ensurePermission);
      expect(c.state.outcome, EditorOutcome.saved);
    },
  );

  blocTest<TaskEditorCubit, TaskEditorState>(
    'with a reminder, requests permission and flags a denial',
    setUp: () => when(perms.ensurePermission).thenAnswer((_) async => false),
    build: build,
    act: (c) async {
      await c.load();
      c
        ..titleChanged('Call CA')
        ..reminderChanged(DateTime(2026, 11, 4, 10));
      await c.save();
    },
    verify: (c) => expect(c.state.notificationsBlocked, isTrue),
  );
}

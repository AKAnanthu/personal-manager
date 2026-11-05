import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/reminders/domain/reminder.dart';
import 'package:personal_life_manager/features/reminders/domain/reminders_repository.dart';
import 'package:personal_life_manager/features/reminders/presentation/reminder_form_cubit.dart';

import '../../helpers/fakes.dart';

class _Repo extends Mock implements RemindersRepository;

class _Perms extends Mock implements NotificationPermissions;

void main() {
  late _Repo repo;
  late _Perms perms;
  final clock = TestClock(DateTime(2026, 11, 3, 18, 20));

  setUpAll(() {
    registerFallbackValue(
      ReminderDraft(
        title: '',
        at: DateTime(2026),
        repeat: RepeatFrequency.none,
      ),
    );
  });

  setUp(() {
    repo = _Repo();
    perms = _Perms();
    when(() => repo.save(any())).thenAnswer((_) async => const Ok('id'));
    when(perms.ensurePermission).thenAnswer((_) async => true);
  });

  ReminderFormCubit build({String? id}) => ReminderFormCubit(
    repository: repo,
    permissions: perms,
    reminderId: id,
    clock: clock.call,
  );

  test('new reminder defaults to the next full hour', () async {
    final c = build();
    addTearDown(c.close);
    await c.load();
    expect(c.state.at, DateTime(2026, 11, 3, 19));
  });

  blocTest<ReminderFormCubit, ReminderFormState>(
    'title is required',
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

  blocTest<ReminderFormCubit, ReminderFormState>(
    'a one-time reminder in the past is rejected; repeating is allowed',
    build: build,
    act: (c) async {
      await c.load();
      c
        ..titleChanged('Pay bill')
        ..dateChanged(DateTime(2026, 11, 3))
        ..timeChanged(9, 0);
      await c.save();
      expect(c.timeInvalid, isTrue);
      c.repeatChanged(RepeatFrequency.monthly);
      await c.save();
    },
    verify: (_) {
      final draft =
          verify(() => repo.save(captureAny())).captured.single
              as ReminderDraft;
      expect(draft.repeat, RepeatFrequency.monthly);
      expect(draft.at, DateTime(2026, 11, 3, 9));
    },
  );

  blocTest<ReminderFormCubit, ReminderFormState>(
    'saving asks for notification permission and reports a denial',
    setUp: () => when(perms.ensurePermission).thenAnswer((_) async => false),
    build: build,
    act: (c) async {
      await c.load();
      c.titleChanged('Water plants');
      await c.save();
    },
    verify: (c) {
      expect(c.state.outcome, EditorOutcome.saved);
      expect(c.state.notificationsBlocked, isTrue);
    },
  );

  blocTest<ReminderFormCubit, ReminderFormState>(
    'an unchanged overdue one-time reminder can still be edited',
    setUp: () => when(() => repo.watchReminder('r1')).thenAnswer(
      (_) => Stream.value(
        Reminder(
          id: 'r1',
          title: 'Old',
          description: '',
          anchorAt: DateTime(2026, 11, 2, 9),
          dueAt: DateTime(2026, 11, 2, 9),
          repeat: RepeatFrequency.none,
          isCompleted: false,
        ),
      ),
    ),
    build: () => build(id: 'r1'),
    act: (c) async {
      await c.load();
      c.titleChanged('Renamed');
      await c.save();
    },
    verify: (c) => expect(c.state.outcome, EditorOutcome.saved),
  );

  blocTest<ReminderFormCubit, ReminderFormState>(
    'save failure stays on the form with the failure',
    setUp: () =>
        when(() => repo.save(any()))
            .thenAnswer((_) async => const Err(DatabaseFailure())),
    build: build,
    act: (c) async {
      await c.load();
      c.titleChanged('x');
      await c.save();
    },
    verify: (c) {
      expect(c.state.failure, isA<DatabaseFailure>());
      expect(c.state.outcome, EditorOutcome.none);
      verifyNever(perms.ensurePermission);
    },
  );
}

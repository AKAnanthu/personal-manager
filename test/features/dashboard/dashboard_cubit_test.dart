import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/features/dashboard/domain/upcoming_item.dart';
import 'package:personal_life_manager/features/dashboard/presentation/dashboard_cubit.dart';

import '../../helpers/fakes.dart';

void main() {
  UpcomingItem item(
    String t,
    int day, [
    UpcomingKind k = UpcomingKind.reminder,
  ]) => UpcomingItem(
    kind: k,
    title: t,
    at: DateTime(2026, 11, day, 9),
    route: '/x',
  );

  test('merges sources, sorts soonest first and limits', () async {
    final a = StreamController<List<UpcomingItem>>();
    final b = StreamController<List<UpcomingItem>>();
    final cubit = DashboardCubit(
      [() => a.stream, () => b.stream],
      clock: TestClock().call,
      limit: 3,
    )..start();
    addTearDown(cubit.close);

    a.add([item('r10', 10), item('r4', 4)]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.loaded, isFalse, reason: 'waits for every source');

    b.add([
      item('t5', 5, UpcomingKind.task),
      item('t20', 20, UpcomingKind.task),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.loaded, isTrue);
    expect(cubit.state.upcoming.map((i) => i.title), ['r4', 't5', 'r10']);
  });

  test(
    'a failing source contributes nothing instead of breaking the list',
    () async {
      final cubit = DashboardCubit([
        () => Stream.value([item('ok', 4)]),
        () => Stream<List<UpcomingItem>>.error(StateError('boom')),
      ], clock: TestClock().call)..start();
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.loaded, isTrue);
      expect(cubit.state.upcoming.single.title, 'ok');
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/app/app.dart';
import 'package:personal_life_manager/app/di.dart';
import 'package:personal_life_manager/app/router.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/features/dashboard/domain/upcoming_item.dart';
import 'package:personal_life_manager/features/shopping/data/instruction_sharer.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';

class _Shopping extends Mock implements ShoppingRepository;

class _Sharer extends Mock implements InstructionSharer;

void main() {
  late AppLock lock;

  setUp(() {
    lock = AppLock(initialStatus: LockStatus.unlocked);
    final shopping = _Shopping();
    when(shopping.watchActive).thenAnswer((_) => Stream.value(null));
    when(shopping.watchDrafts).thenAnswer((_) => Stream.value(const []));
    when(shopping.watchHistory).thenAnswer((_) => Stream.value(const []));
    sl
      ..registerSingleton<List<UpcomingSource>>(const [])
      ..registerSingleton<ShoppingRepository>(shopping)
      ..registerSingleton<InstructionSharer>(_Sharer());
  });
  tearDown(() async {
    lock.dispose();
    await sl.reset();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(PlmApp(lock: lock));
    await tester.pumpAndSettle();
  }

  String location(WidgetTester tester) => GoRouterLocation.of(tester);

  testWidgets('shell shows four tabs and switches between them', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(location(tester), AppRoutes.home);

    await tester.tap(find.text('Shopping'));
    await tester.pumpAndSettle();
    expect(location(tester), AppRoutes.shopping);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(location(tester), AppRoutes.more);
  });

  testWidgets('shell does not overflow at 200% text scale on a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    await pumpApp(tester);

    expect(tester.takeException(), isNull);
  });
}

/// Reads the current router location from the widget tree.
abstract final class GoRouterLocation {
  static String of(WidgetTester tester) {
    final context = tester.element(find.byType(NavigationBar));
    return GoRouter.of(context).state.matchedLocation;
  }
}

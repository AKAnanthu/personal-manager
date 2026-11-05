import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/features/shopping/data/instruction_sharer.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';
import 'package:personal_life_manager/features/shopping/presentation/import_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/import_page.dart';
import 'package:personal_life_manager/features/shopping/presentation/session_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/session_page.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_home_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_home_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';
import 'package:personal_life_manager/l10n/locales.dart';

class _Repo extends Mock implements ShoppingRepository;

final class _Sharer implements InstructionSharer {
  final languages = <String>[];

  @override
  Future<void> share({
    required String languageCode,
    Rect? origin,
    String? text,
  }) async => languages.add(languageCode);
}

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  localizationsDelegates: const [
    ...AppLocalizations.localizationsDelegates,
    GlobalMaterialLocalizations.delegate,
  ],
  supportedLocales: appSupportedLocales,
  locale: const Locale('en', 'IN'),
  home: child,
);

ShoppingList _list(
  ShoppingListStatus status, {
  List<ShoppingItem> items = const [
    ShoppingItem(id: 'a', name: 'Milk', quantity: '2'),
    ShoppingItem(id: 'b', name: 'Rice', quantity: '5', unit: 'kg'),
    ShoppingItem(id: 'c', name: 'Eggs', quantity: '12', isPurchased: true),
  ],
}) => ShoppingList(
  id: status.name,
  name: status == ShoppingListStatus.completed ? 'Monthly' : 'Weekly',
  status: status,
  items: items,
  purchasedOn: status == ShoppingListStatus.completed
      ? DateTime(2026, 10, 27)
      : null,
  totalPaise: status == ShoppingListStatus.completed ? 184600 : null,
  receipt: status == ShoppingListStatus.completed
      ? const Receipt(
          fileKey: 'k',
          originalName: 'r.jpg',
          fileType: SupportedFileType.jpeg,
        )
      : null,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

/// The design's phone size (390 x 844 logical pixels).
void _phone(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1170, 2532)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() => registerFallbackValue(const ListDraft(name: '', items: [])));

  testWidgets('import review: unclear quantity blocks import until fixed', (
    tester,
  ) async {
    _phone(tester);
    final repo = _Repo();
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) => ImportCubit(repo),
          child: ImportPage(now: () => DateTime(2026, 11, 3)),
        ),
      ),
    );
    expect(find.textContaining('never opens WhatsApp'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'Milk 2\nTomatoes\nRice 5 kg',
    );
    await tester.tap(find.text('Review items'));
    await tester.pumpAndSettle();

    expect(find.text('REVIEW 3 ITEMS'), findsOneWidget);
    expect(
      find.text('No quantity found — enter one to confirm.'),
      findsOneWidget,
    );
    final button = find.widgetWithText(
      FilledButton,
      'Confirm 1 item to import',
    );
    expect(button, findsOneWidget);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);

    // The tomatoes row is the 2nd; its quantity is the 2nd field in it.
    final qtyFields = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '?',
    );
    await tester.enterText(qtyFields.at(1), '1');
    await tester.pumpAndSettle();
    expect(
      find.text('No quantity found — enter one to confirm.'),
      findsNothing,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Import 3 items'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('session: tap to tick; leaving asks continue later or finish', (
    tester,
  ) async {
    _phone(tester);
    final repo = _Repo();
    when(repo.watchActive)
        .thenAnswer((_) => Stream.value(_list(ShoppingListStatus.active)));
    when(() => repo.setPurchased(any(), value: any(named: 'value')))
        .thenAnswer((_) async => const Ok(null));
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) => SessionCubit(repo)..start(),
          child: const SessionPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('TO PICK · 2'), findsOneWidget);
    expect(find.text('IN THE CART · 1'), findsOneWidget);
    expect(find.text('5 kg'), findsOneWidget);

    await tester.tap(find.text('Milk'));
    await tester.pump();
    verify(() => repo.setPurchased('a', value: true)).called(1);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('2 items still to pick'), findsOneWidget);
    expect(find.text('Continue later'), findsWidgets);
    await tester.tap(find.text('Keep shopping'));
    await tester.pumpAndSettle();
    expect(find.text('2 items still to pick'), findsNothing);
  });

  testWidgets('home: session card, history line, share instructions', (
    tester,
  ) async {
    _phone(tester);
    final repo = _Repo();
    final sharer = _Sharer();
    when(repo.watchActive)
        .thenAnswer((_) => Stream.value(_list(ShoppingListStatus.active)));
    when(repo.watchDrafts).thenAnswer((_) => Stream.value(const []));
    when(repo.watchHistory)
        .thenAnswer((_) => Stream.value([_list(ShoppingListStatus.completed)]));
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) => ShoppingHomeCubit(repo)..start(),
          child: ShoppingHomePage(
            sharer: sharer,
            now: () => DateTime(2026, 11, 3, 18),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('1 of 3'), findsOneWidget);
    expect(find.text('Resume shopping'), findsOneWidget);
    expect(find.text('27 Oct · 3 items · ₹1,846 · receipt'), findsOneWidget);
    expect(find.text('Reuse'), findsOneWidget);

    await tester.tap(find.textContaining('how to send a list'));
    await tester.pump();
    expect(sharer.languages, ['en']);
  });
}

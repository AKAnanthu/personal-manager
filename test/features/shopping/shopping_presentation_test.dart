import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_access.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/utils/money.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';
import 'package:personal_life_manager/features/shopping/presentation/completion_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/import_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/list_editor_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/session_cubit.dart';

class _Repo extends Mock implements ShoppingRepository;

class _Pickers extends Mock implements FilePickers;

ShoppingList _list({
  String id = 'l1',
  ShoppingListStatus status = ShoppingListStatus.completed,
  List<ShoppingItem> items = const [
    ShoppingItem(id: 'i1', name: 'Milk', quantity: '2'),
    ShoppingItem(id: 'i2', name: 'Rice', quantity: '5', unit: 'kg'),
  ],
  DateTime? pausedAt,
  int? total,
}) => ShoppingList(
  id: id,
  name: 'Weekly',
  status: status,
  items: items,
  pausedAt: pausedAt,
  totalPaise: total,
  purchasedOn: status == ShoppingListStatus.completed
      ? DateTime(2026, 10, 27)
      : null,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late _Repo repo;

  setUpAll(() {
    registerFallbackValue(const ListDraft(name: '', items: []));
    registerFallbackValue(const ItemDraft(name: ''));
    registerFallbackValue(
      Completion(totalPaise: 1, purchasedOn: DateTime(2026)),
    );
  });

  setUp(() {
    repo = _Repo();
    when(() => repo.saveList(any())).thenAnswer((_) async => const Ok('new'));
    when(() => repo.startSession(any()))
        .thenAnswer((_) async => const Ok(null));
  });

  group('Money', () {
    test('parses rupees to paise', () {
      expect(Money.parseRupees('1,846'), 184600);
      expect(Money.parseRupees('₹ 1846.5'), 184650);
      expect(Money.parseRupees('0.05'), 5);
      for (final bad in ['', 'abc', '-5', '1.234', '1.2.3']) {
        expect(Money.parseRupees(bad), isNull, reason: bad);
      }
    });

    test('formats with Indian grouping', () {
      expect(Money.format(184600), '₹1,846');
      expect(Money.format(12345650), '₹1,23,456.50');
      expect(Money.toInput(184650), '1846.50');
      expect(Money.toInput(184600), '1846');
    });
  });

  group('ImportCubit', () {
    const msg = 'Milk 2\nTomatoes\nmilk 3\nRice 5 kg';

    blocTest<ImportCubit, ImportState>(
      'unclear quantities block the import until confirmed',
      build: () => ImportCubit(repo),
      act: (c) {
        c.textPasted(msg);
        expect(c.state.unresolved, 1);
        expect(c.state.canImport, isFalse);
        final tomatoes = c.state.rows.firstWhere((r) => r.name == 'Tomatoes');
        expect(tomatoes.flagged, isTrue);
        c.rowChanged(tomatoes.key, quantity: 'one');
        expect(c.state.canImport, isFalse);
        c.rowChanged(tomatoes.key, quantity: '1', unit: 'kg');
      },
      verify: (c) => expect(c.state.canImport, isTrue),
    );

    blocTest<ImportCubit, ImportState>(
      'duplicates are offered for merging, not merged automatically',
      build: () => ImportCubit(repo),
      act: (c) {
        c.textPasted(msg);
        expect(
          c.state.rows.where((r) => r.name.toLowerCase() == 'milk'),
          hasLength(2),
        );
        final g = c.state.duplicates.single;
        expect((g.name, g.keys.length, g.mergeable), ('Milk', 2, true));
        c.merge(g);
      },
      verify: (c) {
        final milk = c.state.rows.where((r) => r.name.toLowerCase() == 'milk');
        expect(milk.single.quantity, '5');
        expect(c.state.duplicates, isEmpty);
      },
    );

    blocTest<ImportCubit, ImportState>(
      'different units are not mergeable',
      build: () => ImportCubit(repo),
      act: (c) => c.textPasted('Rice 5 kg\nRice 2 pkt'),
      verify: (c) => expect(c.state.duplicates.single.mergeable, isFalse),
    );

    blocTest<ImportCubit, ImportState>(
      'confirm saves the reviewed items as a new list',
      build: () => ImportCubit(repo),
      act: (c) async {
        c
          ..textPasted('Milk 2\nRice 5kg\nSoap')
          ..removeRow(c.state.rows.last.key);
        await c.confirm(listName: 'Shopping 3 Nov');
      },
      verify: (c) {
        expect(c.state.savedListId, 'new');
        verify(
          () => repo.saveList(
            const ListDraft(
              name: 'Shopping 3 Nov',
              items: [
                ItemDraft(name: 'Milk', quantity: '2'),
                ItemDraft(name: 'Rice', quantity: '5', unit: 'kg'),
              ],
            ),
          ),
        ).called(1);
      },
    );
  });

  group('ListEditorCubit', () {
    blocTest<ListEditorCubit, ListEditorState>(
      'reuse: copies items without their ids and remembers the source',
      setUp: () =>
          when(() => repo.watchList('old'))
              .thenAnswer((_) => Stream.value(_list(id: 'old'))),
      build: () => ListEditorCubit(repository: repo, copyFromId: 'old'),
      act: (c) async {
        await c.load();
        await c.saveForLater();
      },
      verify: (c) {
        expect(c.state.copiedFrom?.id, 'old');
        expect(c.state.outcome, ListEditorOutcome.saved);
        verify(
          () => repo.saveList(
            const ListDraft(
              name: 'Weekly',
              copiedFromId: 'old',
              items: [
                ItemDraft(name: 'Milk', quantity: '2'),
                ItemDraft(name: 'Rice', quantity: '5', unit: 'kg'),
              ],
            ),
          ),
        ).called(1);
      },
    );

    blocTest<ListEditorCubit, ListEditorState>(
      'the add row splits pasted lines and "rice 5 kg"; bad quantities '
      'block saving',
      build: () => ListEditorCubit(repository: repo),
      act: (c) async {
        await c.load(defaultName: 'Shopping 3 Nov');
        c
          ..addFromInput('Milk 2\nBread 1')
          ..addFromInput('rice 5 kg')
          ..addFromInput('Curd', quantity: '1,5')
          ..addFromInput('   ');
        expect(c.state.rows.map((r) => (r.name, r.quantity, r.unit)), [
          ('Milk', '2', ''),
          ('Bread', '1', ''),
          ('Rice', '5', 'kg'),
          ('Curd', '1.5', ''),
        ]);
        c.rowChanged(c.state.rows.first.key, quantity: 'two');
        await c.startShopping();
      },
      verify: (c) {
        expect(c.state.showErrors, isTrue);
        verifyNever(() => repo.saveList(any()));
      },
    );

    blocTest<ListEditorCubit, ListEditorState>(
      'start shopping while another list is active: saved, not started',
      setUp: () =>
          when(() => repo.startSession('new'))
              .thenAnswer((_) async => const Err(ConflictFailure('other'))),
      build: () => ListEditorCubit(repository: repo),
      act: (c) async {
        await c.load(defaultName: 'Shopping');
        c.addFromInput('Milk 2');
        await c.startShopping();
      },
      verify: (c) {
        expect(c.state.failure, const ConflictFailure('other'));
        expect(c.state.outcome, ListEditorOutcome.none);
        expect(c.state.listId, 'new');
      },
    );
  });

  group('SessionCubit', () {
    test('opening a paused session resumes it', () async {
      when(repo.watchActive).thenAnswer(
        (_) => Stream.value(
          _list(
            status: ShoppingListStatus.active,
            pausedAt: DateTime(2026, 11, 3),
          ),
        ),
      );
      when(() => repo.resumeSession('l1'))
          .thenAnswer((_) async => const Ok(null));
      final c = SessionCubit(repo)..start();
      await Future<void>.delayed(Duration.zero);
      verify(() => repo.resumeSession('l1')).called(1);
      await c.close();
    });

    test('continue later pauses and closes', () async {
      when(repo.watchActive).thenAnswer(
        (_) => Stream.value(_list(status: ShoppingListStatus.active)),
      );
      when(() => repo.pauseSession('l1'))
          .thenAnswer((_) async => const Ok(null));
      when(() => repo.setPurchased('i1', value: true))
          .thenAnswer((_) async => const Ok(null));
      final c = SessionCubit(repo)..start();
      await Future<void>.delayed(Duration.zero);
      await c.toggle(c.state.list!.items.first);
      await c.continueLater();
      expect(c.state.paused, isTrue);
      verify(() => repo.setPurchased('i1', value: true)).called(1);
      verifyNever(() => repo.resumeSession(any()));
      await c.close();
    });
  });

  group('CompletionCubit', () {
    late _Pickers pickers;
    late Directory dir;

    setUp(() {
      pickers = _Pickers();
      dir = Directory.systemTemp.createTempSync('shop_done');
      when(() => repo.watchList('l1')).thenAnswer(
        (_) => Stream.value(_list(status: ShoppingListStatus.active)),
      );
      when(
        () => repo.complete(
          any(),
          any(),
          receipt: any(named: 'receipt'),
          receiptName: any(named: 'receiptName'),
        ),
      ).thenAnswer((_) async => const Ok(null));
    });
    tearDown(() => dir.deleteSync(recursive: true));

    CompletionCubit build() => CompletionCubit(
      repository: repo,
      pickers: pickers,
      listId: 'l1',
      clock: () => DateTime(2026, 11, 3, 18),
    );

    blocTest<CompletionCubit, CompletionState>(
      'needs a total above zero',
      build: build,
      act: (c) async {
        await c.load();
        c.totalChanged('0');
        await c.save();
      },
      verify: (c) {
        expect(c.state.showErrors, isTrue);
        verifyNever(
          () => repo.complete(
            any(),
            any(),
            receipt: any(named: 'receipt'),
            receiptName: any(named: 'receiptName'),
          ),
        );
      },
    );

    blocTest<CompletionCubit, CompletionState>(
      'a Word file is not accepted as a receipt',
      setUp: () => when(pickers.chooseDocument).thenAnswer((_) async {
        final f = File(p.join(dir.path, 'bill.docx'))
          ..writeAsBytesSync([0x50, 0x4B, 0x03, 0x04, 0]);
        return PickedFile(f, 'bill.docx');
      }),
      build: build,
      act: (c) async {
        await c.load();
        await c.chooseFile();
      },
      verify: (c) {
        expect(c.state.failure, isA<UnsupportedFileFailure>());
        expect(c.state.receipt, isNull);
      },
    );

    blocTest<CompletionCubit, CompletionState>(
      'saves total in paise, the date and the payment method',
      build: build,
      act: (c) async {
        await c.load();
        c
          ..totalChanged('1,846.50')
          ..storeChanged('Corner shop')
          ..paymentToggled(PaymentMethod.upi);
        await c.save();
      },
      verify: (c) {
        expect(c.state.outcome, EditorOutcome.saved);
        verify(
          () => repo.complete(
            'l1',
            Completion(
              totalPaise: 184650,
              purchasedOn: DateTime(2026, 11, 3),
              store: 'Corner shop',
              paymentMethod: PaymentMethod.upi,
            ),
          ),
        ).called(1);
      },
    );
  });
}

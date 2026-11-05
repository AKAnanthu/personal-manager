import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/db/app_database.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';
import 'package:personal_life_manager/features/shopping/data/shopping_repository_impl.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';

import '../../helpers/fakes.dart';

T ok<T>(Result<T> r) => r.fold((f) => fail('unexpected $f'), (v) => v);
Failure? failureOf<T>(Result<T> r) => r.fold((f) => f, (_) => null);

/// Records what the repository asks for: (event, listId, pending names).
final class _Notice implements PendingShoppingNotice {
  final events = <(String, String, String)>[];

  @override
  Future<void> show(ShoppingList list) async =>
      events.add(('show', list.id, list.pending.map((i) => i.name).join(',')));

  @override
  Future<void> clear(String listId) async => events.add(('clear', listId, ''));
}

void main() {
  late AppDatabase db;
  late Directory dir;
  late Directory store;
  late _Notice notice;
  late ShoppingRepositoryImpl repo;
  final clock = TestClock(DateTime(2026, 11, 3, 18));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dir = Directory.systemTemp.createTempSync('shop_repo');
    store = Directory(p.join(dir.path, 'store'))..createSync();
    notice = _Notice();
    repo = ShoppingRepositoryImpl(
      db: db,
      files: FileStore(store),
      notice: notice,
      clock: clock.call,
    );
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  Future<String> list(String name, List<String> items) async => ok<String>(
    await repo.saveList(
      ListDraft(
        name: name,
        items: [for (final i in items) ItemDraft(name: i, quantity: '1')],
      ),
    ),
  );

  Future<List<ExpenseRow>> expenses() => db.select(db.expenses).get();

  final nov3 = DateTime(2026, 11, 3);
  final completion = Completion(
    totalPaise: 184600,
    purchasedOn: nov3,
    store: 'Corner shop',
    paymentMethod: PaymentMethod.upi,
  );

  test('saving keeps item order and ids; empty names are dropped', () async {
    final id = await list('Weekly', ['Milk', 'Bread', '  ', 'Eggs']);
    final l = (await repo.watchList(id).first)!;
    expect(l.items.map((i) => i.name), ['Milk', 'Bread', 'Eggs']);
    expect(l.status, ShoppingListStatus.draft);

    ok(
      await repo.saveList(
        ListDraft(
          id: id,
          name: 'Weekly groceries',
          items: [
            ItemDraft(id: l.items[2].id, name: 'Eggs', quantity: '12'),
            ItemDraft(id: l.items[0].id, name: 'Milk', quantity: '2'),
            const ItemDraft(name: 'Rice', quantity: '5', unit: 'kg'),
          ],
        ),
      ),
    );
    final after = (await repo.watchList(id).first)!;
    expect(after.name, 'Weekly groceries');
    expect(after.items.map((i) => i.amountLabel), ['12', '2', '5 kg']);
    expect(after.items[0].id, l.items[2].id);
  });

  test('only one session at a time', () async {
    final a = await list('A', ['Milk']);
    final b = await list('B', ['Bread']);
    ok(await repo.startSession(a));
    expect(failureOf(await repo.startSession(b)), ConflictFailure(a));
    // Starting the active one again is fine.
    ok(await repo.startSession(a));
    expect((await repo.watchActive().first)?.id, a);
  });

  test('continue later shows one notice with what is left; resume and '
      'picking the last item clear it', () async {
    final id = await list('Weekly', ['Milk', 'Bread']);
    ok(await repo.startSession(id));
    final items = (await repo.watchList(id).first)!.items;
    ok(await repo.setPurchased(items[0].id, value: true));
    notice.events.clear();

    ok(await repo.pauseSession(id));
    expect(notice.events, [('show', id, 'Bread')]);
    expect((await repo.watchActive().first)?.pausedAt, clock.now);

    notice.events.clear();
    ok(await repo.resumeSession(id));
    expect(notice.events, [('clear', id, '')]);

    ok(await repo.pauseSession(id));
    notice.events.clear();
    ok(await repo.setPurchased(items[1].id, value: true));
    expect(notice.events, [('clear', id, '')]);
  });

  test('continue later with nothing left sends no notice', () async {
    final id = await list('Weekly', ['Milk']);
    ok(await repo.startSession(id));
    final item = (await repo.watchList(id).first)!.items.single;
    ok(await repo.setPurchased(item.id, value: true));
    notice.events.clear();
    ok(await repo.pauseSession(id));
    expect(notice.events.map((e) => e.$1), ['clear']);
  });

  test('items can be added, edited and removed during a session', () async {
    final id = await list('Weekly', ['Milk']);
    ok(await repo.startSession(id));
    ok(await repo.addItem(id, const ItemDraft(name: 'Curd', quantity: '1')));
    final l = (await repo.watchList(id).first)!;
    expect(l.items.map((i) => i.name), ['Milk', 'Curd']);
    ok(
      await repo.updateItem(
        l.items[1].id,
        const ItemDraft(name: 'Curd', quantity: '500', unit: 'g'),
      ),
    );
    ok(await repo.removeItem(l.items[0].id));
    final after = (await repo.watchList(id).first)!;
    expect(after.items.single.amountLabel, '500 g');
    expect(
      failureOf(await repo.updateItem('nope', const ItemDraft(name: 'X'))),
      const NotFoundFailure(),
    );
  });

  test('completion saves to history and adds exactly one expense, '
      'however often it is saved', () async {
    final id = await list('Weekly', ['Milk']);
    ok(await repo.startSession(id));
    ok(await repo.complete(id, completion));

    final l = (await repo.watchList(id).first)!;
    expect(l.status, ShoppingListStatus.completed);
    expect(l.totalPaise, 184600);
    expect(l.paymentMethod, PaymentMethod.upi);
    expect(await repo.watchActive().first, isNull);
    expect((await repo.watchHistory().first).single.id, id);
    expect(notice.events.last, ('clear', id, ''));

    var e = await expenses();
    expect(e, hasLength(1));
    expect(
      (e.single.amountPaise, e.single.source, e.single.sourceId),
      (184600, ExpenseSource.shopping, id),
    );

    // Editing the total later updates the same expense.
    ok(
      await repo.updateCompletion(
        id,
        Completion(totalPaise: 190000, purchasedOn: nov3),
      ),
    );
    e = await expenses();
    expect(e, hasLength(1));
    expect(e.single.amountPaise, 190000);
    expect((await repo.watchList(id).first)?.totalPaise, 190000);
  });

  test('the database itself refuses a second expense for one trip', () async {
    final id = await list('Weekly', ['Milk']);
    ok(await repo.complete(id, completion));
    final row = (await expenses()).single;
    await expectLater(
      db
          .into(db.expenses)
          .insert(row.copyWith(id: 'another').toCompanion(true)),
      throwsA(anything),
    );
  });

  test('a zero total is rejected and nothing changes', () async {
    final id = await list('Weekly', ['Milk']);
    ok(await repo.startSession(id));
    final r = await repo.complete(
      id,
      Completion(totalPaise: 0, purchasedOn: nov3),
    );
    expect(failureOf(r), isA<ValidationFailure>());
    expect(await expenses(), isEmpty);
    expect((await repo.watchActive().first)?.id, id);
  });

  test('receipt: stored on completion, replaced or removed on edit', () async {
    final id = await list('Weekly', ['Milk']);
    final jpg = File(p.join(dir.path, 'r.jpg'))
      ..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, 1, 2]);
    final pdf = File(p.join(dir.path, 'r.pdf'))
      ..writeAsBytesSync([0x25, 0x50, 0x44, 0x46, 1, 2]);
    ok(await repo.complete(id, completion, receipt: jpg, receiptName: 'r.jpg'));
    expect((await repo.watchList(id).first)?.receipt?.originalName, 'r.jpg');
    expect(store.listSync(), hasLength(1));

    ok(
      await repo.updateCompletion(
        id,
        completion,
        receipt: pdf,
        receiptName: 'r.pdf',
      ),
    );
    expect((await repo.watchList(id).first)?.receipt?.originalName, 'r.pdf');
    expect(store.listSync(), hasLength(1));

    ok(await repo.updateCompletion(id, completion, removeReceipt: true));
    expect((await repo.watchList(id).first)?.receipt, isNull);
    expect(store.listSync(), isEmpty);
  });

  test(
    'deleting history: keep the expense as manual, or delete both',
    () async {
      final a = await list('A', ['Milk']);
      final b = await list('B', ['Bread']);
      ok(await repo.complete(a, completion));
      ok(await repo.complete(b, completion));

      ok(await repo.deleteList(a));
      var e = await expenses();
      expect(e, hasLength(2));
      final kept = e.firstWhere((x) => x.source == ExpenseSource.manual);
      expect((kept.sourceId, kept.description), (null, 'A'));

      ok(await repo.deleteList(b, deleteExpense: true));
      e = await expenses();
      expect(e.single.id, kept.id);
      expect(await repo.watchHistory().first, isEmpty);
    },
  );
}

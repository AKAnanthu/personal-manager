import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_store.dart';

void main() {
  late Directory root;
  late FileStore store;

  setUp(() {
    root = Directory.systemTemp.createTempSync('file_store_test');
    store = FileStore(root);
  });

  tearDown(() => root.deleteSync(recursive: true));

  String keyOf(Result<String> r) =>
      r.fold((f) => fail('unexpected $f'), (k) => k);

  test('importFile copies under a UUID key, never the original name', () async {
    final source = File(p.join(root.path, 'My Passport.PDF'))
      ..writeAsBytesSync([1, 2, 3]);

    final key = keyOf(await store.importFile(source));

    expect(FileStore.isValidKey(key), isTrue);
    expect(key, endsWith('.pdf'));
    expect(key, isNot(contains('Passport')));
    final resolved = await store.resolve(key);
    expect(resolved.fold((_) => null, (f) => f.readAsBytesSync()), [1, 2, 3]);
  });

  test('writeBytes normalises extension and leaves no .part file', () async {
    final key = keyOf(await store.writeBytes([9], ext: 'JPG'));

    expect(key, endsWith('.jpg'));
    expect(root.listSync().where((e) => e.path.endsWith('.part')), isEmpty);
  });

  test('importFile maps a missing source to StorageFailure', () async {
    final result = await store.importFile(File(p.join(root.path, 'nope.pdf')));

    expect(result.fold((f) => f, (_) => null), isA<StorageFailure>());
    expect(root.listSync(), isEmpty);
  });

  test('resolve returns NotFoundFailure for a missing file', () async {
    final result = await store.resolve('00000000-0000-0000-0000-000000000000');

    expect(result.fold((f) => f, (_) => null), isA<NotFoundFailure>());
  });

  test('rejects keys that could escape the store directory', () async {
    for (final key in ['../secret', 'a/b', '', r'..\x.pdf']) {
      expect(
        (await store.resolve(key)).fold((f) => f, (_) => null),
        isA<ValidationFailure>(),
        reason: key,
      );
      expect(
        (await store.delete(key)).fold((f) => f, (_) => null),
        isA<ValidationFailure>(),
        reason: key,
      );
    }
  });

  test('delete removes the file and is idempotent', () async {
    final key = keyOf(await store.writeBytes([1], ext: 'png'));

    expect((await store.delete(key)).isSuccess, isTrue);
    expect((await store.delete(key)).isSuccess, isTrue);
    expect((await store.resolve(key)).isSuccess, isFalse);
  });
}

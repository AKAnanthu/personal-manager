import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';

void main() {
  group('guard', () {
    test('wraps a value in Ok', () async {
      final r = await guard<int, FormatException>(
        () async => 42,
        (_) => const ValidationFailure(),
      );
      expect(r.fold((_) => null, (v) => v), 42);
    });

    test('maps the declared exception type to a Failure', () async {
      final r = await guard<int, FormatException>(
        () async => throw const FormatException('bad'),
        (_) => const ValidationFailure('mapped'),
      );
      expect(r.fold((f) => f, (_) => null), const ValidationFailure('mapped'));
    });

    test('does not swallow other exception types', () {
      expect(
        guard<int, FormatException>(
          () async => throw StateError('boom'),
          (_) => const ValidationFailure(),
        ),
        throwsStateError,
      );
    });
  });
}

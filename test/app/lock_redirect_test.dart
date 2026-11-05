import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/app/router.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';

void main() {
  String? go(LockStatus s, String location) =>
      lockRedirect(s, Uri.parse(location));

  group('not set up', () {
    test('everything goes to setup', () {
      expect(go(LockStatus.notSetUp, '/home'), '/setup');
      expect(go(LockStatus.notSetUp, '/unlock'), '/setup');
      expect(go(LockStatus.notSetUp, '/setup'), isNull);
    });
  });

  group('locked', () {
    test('keeps the requested location for after unlock', () {
      final target = go(LockStatus.locked, '/documents?id=abc');
      final uri = Uri.parse(target ?? '');

      expect(uri.path, '/unlock');
      expect(uri.queryParameters['from'], '/documents?id=abc');
    });

    test('stays on unlock; setup is not reachable once set up', () {
      expect(go(LockStatus.locked, '/unlock?from=%2Fhome'), isNull);
      expect(go(LockStatus.locked, '/setup'), '/unlock');
    });
  });

  group('unlocked', () {
    test('continues to the saved location', () {
      expect(
        go(LockStatus.unlocked, '/unlock?from=%2Fdocuments%3Fid%3Dabc'),
        '/documents?id=abc',
      );
    });

    test('falls back to home without a usable target', () {
      expect(go(LockStatus.unlocked, '/unlock'), '/home');
      expect(go(LockStatus.unlocked, '/setup'), '/home');
      for (final bad in [
        'https://evil.example/x',
        '//evil.example/x',
        'home',
        '/unlock',
        '/setup?from=%2Fhome',
      ]) {
        expect(
          go(
            LockStatus.unlocked,
            Uri(path: '/unlock', queryParameters: {'from': bad}).toString(),
          ),
          '/home',
          reason: bad,
        );
      }
    });

    test('leaves normal routes alone', () {
      expect(go(LockStatus.unlocked, '/shopping'), isNull);
    });
  });
}

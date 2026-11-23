import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/app/router.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';

void main() {
  String? go(LockStatus s, String location) =>
      lockRedirect(s, Uri.parse(location));

  group('not set up', () {
    test('everything goes to sign-in', () {
      expect(go(LockStatus.notSetUp, '/home'), '/sign-in');
      expect(go(LockStatus.notSetUp, '/unlock'), '/sign-in');
      expect(go(LockStatus.notSetUp, '/sign-in'), isNull);
    });
  });

  group('locked', () {
    test('keeps the requested location for after unlock', () {
      final target = go(LockStatus.locked, '/documents?id=abc');
      final uri = Uri.parse(target ?? '');

      expect(uri.path, '/unlock');
      expect(uri.queryParameters['from'], '/documents?id=abc');
    });

    test('stays on unlock; sign-in is not reachable once signed in', () {
      expect(go(LockStatus.locked, '/unlock?from=%2Fhome'), isNull);
      expect(go(LockStatus.locked, '/sign-in'), '/unlock');
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
      expect(go(LockStatus.unlocked, '/sign-in'), '/home');
      for (final bad in [
        'https://evil.example/x',
        '//evil.example/x',
        'home',
        '/unlock',
        '/sign-in?from=%2Fhome',
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

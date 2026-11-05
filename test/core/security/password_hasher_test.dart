import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/security/password_hasher.dart';

void main() {
  // Low cost keeps the suite fast; the algorithm is the same.
  const hasher = PasswordHasher(iterations: 1000);

  test('verifies the correct password and rejects others', () async {
    final encoded = await hasher.hash('correct horse');

    expect(await hasher.verify('correct horse', encoded), isTrue);
    expect(await hasher.verify('correct hors', encoded), isFalse);
    expect(await hasher.verify('', encoded), isFalse);
  });

  test('encodes scheme and cost, never the password', () async {
    final encoded = await hasher.hash('secret-value');

    expect(encoded, startsWith(r'pbkdf2-sha256$1000$'));
    expect(encoded.split(r'$'), hasLength(4));
    expect(encoded, isNot(contains('secret-value')));
  });

  test('uses a fresh salt per hash', () async {
    expect(await hasher.hash('same'), isNot(await hasher.hash('same')));
  });

  test('verifies using the cost stored in the hash', () async {
    final old = await const PasswordHasher(iterations: 500).hash('pw123456');

    expect(await hasher.verify('pw123456', old), isTrue);
  });

  test('treats malformed hashes as a failed match', () async {
    for (final bad in [
      '',
      'garbage',
      r'md5$1$abc$def',
      r'pbkdf2-sha256$x$AAAA$AAAA',
      r'pbkdf2-sha256$0$AAAA$AAAA',
      r'pbkdf2-sha256$10$!!!$AAAA',
      r'pbkdf2-sha256$10$AAAA$',
    ]) {
      expect(await hasher.verify('pw', bad), isFalse, reason: bad);
    }
  });

  test('production default meets OWASP PBKDF2-SHA256 guidance', () {
    expect(PasswordHasher.defaultIterations, greaterThanOrEqualTo(600000));
  });
}

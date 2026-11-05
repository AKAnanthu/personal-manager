import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Salted PBKDF2-HMAC-SHA256 hash of the app password, used **only** to check
/// the password at unlock. Nothing is encrypted with it.
///
/// Encoded as `pbkdf2-sha256$<iterations>$<salt b64>$<hash b64>` so the cost
/// can be raised later without breaking existing hashes.
class PasswordHasher {
  const PasswordHasher({this.iterations = defaultIterations});

  /// OWASP 2023 guidance for PBKDF2-HMAC-SHA256.
  static const defaultIterations = 600000;
  static const _scheme = 'pbkdf2-sha256';
  static const _saltBytes = 16;

  final int iterations;

  Future<String> hash(String password) async {
    final rng = Random.secure();
    final salt = List<int>.generate(_saltBytes, (_) => rng.nextInt(256));
    final derived = await _derive(password, salt, iterations, 32);
    return [
      _scheme,
      '$iterations',
      base64Encode(salt),
      base64Encode(derived),
    ].join(r'$');
  }

  /// Returns false for a wrong password or a malformed [encoded] value.
  Future<bool> verify(String password, String encoded) async {
    final parts = encoded.split(r'$');
    if (parts.length != 4 || parts[0] != _scheme) return false;
    final iter = int.tryParse(parts[1]);
    final List<int> salt;
    final List<int> expected;
    try {
      salt = base64Decode(parts[2]);
      expected = base64Decode(parts[3]);
    } on FormatException {
      return false;
    }
    if (iter == null || iter < 1 || expected.isEmpty) return false;
    final actual = await _derive(password, salt, iter, expected.length);
    return _constantTimeEquals(actual, expected);
  }

  /// Runs off the UI isolate: 600k iterations take noticeable time.
  static Future<List<int>> _derive(
    String password,
    List<int> salt,
    int iterations,
    int lengthBytes,
  ) => Isolate.run(() async {
    final kdf = Pbkdf2.hmacSha256(
      iterations: iterations,
      bits: lengthBytes * 8,
    );
    final key = await kdf.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return await key.extractBytes();
  });

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/features/auth/domain/password_strength.dart';

void main() {
  test('rates passwords', () {
    const cases = {
      '': PasswordStrength.tooShort,
      'abc1234': PasswordStrength.tooShort,
      'abcdefgh': PasswordStrength.fair,
      'abcdefg1': PasswordStrength.fair,
      'Abcdefg1': PasswordStrength.good,
      'Abcdefg1!': PasswordStrength.strong,
      'a long passphrase': PasswordStrength.good,
    };
    for (final MapEntry(key: pw, value: expected) in cases.entries) {
      expect(PasswordStrength.evaluate(pw), expected, reason: pw);
    }
  });

  test('only too-short passwords are rejected', () {
    expect(PasswordStrength.tooShort.isAcceptable, isFalse);
    expect(PasswordStrength.fair.isAcceptable, isTrue);
  });

  test('meter score matches the design (good = 3 of 4)', () {
    expect(PasswordStrength.good.score, 3);
    expect(PasswordStrength.strong.score, 4);
  });
}

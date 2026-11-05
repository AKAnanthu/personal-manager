import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/security/lockout_policy.dart';

void main() {
  const policy = LockoutPolicy();

  test('first four failures are free, fifth starts a 30 s wait', () {
    for (var f = 0; f < 5; f++) {
      expect(policy.lockoutAfter(f), Duration.zero, reason: '$f');
    }
    expect(policy.lockoutAfter(5), const Duration(seconds: 30));
  });

  test('doubles each further failure and caps at 15 minutes', () {
    expect(policy.lockoutAfter(6), const Duration(minutes: 1));
    expect(policy.lockoutAfter(7), const Duration(minutes: 2));
    expect(policy.lockoutAfter(9), const Duration(minutes: 8));
    expect(policy.lockoutAfter(10), const Duration(minutes: 15));
    expect(policy.lockoutAfter(1000), const Duration(minutes: 15));
  });

  test('counts attempts left before lockout', () {
    expect(policy.attemptsBeforeLockout(0), 5);
    expect(policy.attemptsBeforeLockout(4), 1);
    expect(policy.attemptsBeforeLockout(5), 0);
    expect(policy.attemptsBeforeLockout(9), 0);
  });
}

/// Backoff after failed password attempts: the first [freeAttempts] failures
/// are free, then each further failure doubles the wait from [base], capped
/// at [max].
final class LockoutPolicy {
  const LockoutPolicy({
    this.freeAttempts = 5,
    this.base = const Duration(seconds: 30),
    this.max = const Duration(minutes: 15),
  });

  final int freeAttempts;
  final Duration base;
  final Duration max;

  Duration lockoutAfter(int failures) {
    if (failures < freeAttempts) return Duration.zero;
    final exponent = failures - freeAttempts;
    // Clamp before shifting so large counts can't overflow.
    if (exponent >= 20) return max;
    final wait = base * (1 << exponent);
    return wait > max ? max : wait;
  }

  /// Failures left before the next attempt triggers a lockout.
  int attemptsBeforeLockout(int failures) =>
      failures < freeAttempts ? freeAttempts - failures : 0;
}

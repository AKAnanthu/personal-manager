import 'package:equatable/equatable.dart';
import 'package:personal_life_manager/core/error/result.dart';

sealed class UnlockOutcome extends Equatable {
  const UnlockOutcome();

  @override
  List<Object?> get props => [];
}

final class UnlockSucceeded extends UnlockOutcome {
  const UnlockSucceeded();
}

final class WrongPassword extends UnlockOutcome {
  const WrongPassword({required this.attemptsBeforeLockout, this.lockedUntil});

  /// 0 once every further failure triggers a lockout.
  final int attemptsBeforeLockout;

  /// Set when this failure started a lockout.
  final DateTime? lockedUntil;

  @override
  List<Object?> get props => [attemptsBeforeLockout, lockedUntil];
}

final class LockedOut extends UnlockOutcome {
  const LockedOut(this.until);

  final DateTime until;

  @override
  List<Object?> get props => [until];
}

/// App password and biometric preference. The password is an access-control
/// check only; it never encrypts data.
abstract interface class AuthRepository {
  Future<Result<bool>> isSetUp();

  Future<Result<void>> createPassword(String password);

  Future<Result<UnlockOutcome>> unlockWithPassword(String password);

  /// Checks [current] exactly like unlocking (same attempt limit and
  /// lockout), and only on success stores [replacement].
  Future<Result<UnlockOutcome>> changePassword({
    required String current,
    required String replacement,
  });

  /// Clears the failed-attempt counter (after a successful biometric unlock).
  Future<Result<void>> recordBiometricUnlock();

  /// Non-null while a lockout is in force.
  Future<Result<DateTime?>> lockedUntil();

  Future<Result<bool>> isBiometricEnabled();

  Future<Result<void>> setBiometricEnabled({required bool enabled});
}

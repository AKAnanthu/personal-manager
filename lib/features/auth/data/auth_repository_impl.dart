import 'package:flutter/services.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/security/lockout_policy.dart';
import 'package:personal_life_manager/core/security/password_hasher.dart';
import 'package:personal_life_manager/core/storage/secure_store.dart';
import 'package:personal_life_manager/features/auth/domain/auth_repository.dart';

/// Keys in secure storage. Failure counters live there too so killing the
/// app doesn't reset the backoff.
abstract final class AuthKeys {
  static const passwordHash = 'auth.passwordHash';
  static const failedAttempts = 'auth.failedAttempts';
  static const lockedUntil = 'auth.lockedUntil';
  static const biometricEnabled = 'auth.biometricEnabled';
}

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._store,
    this._hasher = const PasswordHasher(),
    this._policy = const LockoutPolicy(),
    this._clock = DateTime.now,
  });

  final SecureStore _store;
  final PasswordHasher _hasher;
  final LockoutPolicy _policy;
  final DateTime Function() _clock;

  @override
  Future<Result<bool>> isSetUp() =>
      _guard(() async => await _store.read(AuthKeys.passwordHash) != null);

  @override
  Future<Result<void>> createPassword(String password) => _guard(() async {
    await _store.write(AuthKeys.passwordHash, await _hasher.hash(password));
    await _clearFailures();
  });

  @override
  Future<Result<UnlockOutcome>> unlockWithPassword(String password) =>
      _guard(() async {
        final until = await _readLockedUntil();
        if (until != null) return LockedOut(until);

        final hash = await _store.read(AuthKeys.passwordHash);
        if (hash != null && await _hasher.verify(password, hash)) {
          await _clearFailures();
          return const UnlockSucceeded();
        }

        final failures = await _readFailures() + 1;
        await _store.write(AuthKeys.failedAttempts, '$failures');
        final wait = _policy.lockoutAfter(failures);
        DateTime? lockedUntil;
        if (wait > Duration.zero) {
          lockedUntil = _clock().add(wait);
          await _store.write(
            AuthKeys.lockedUntil,
            lockedUntil.toUtc().toIso8601String(),
          );
        }
        return WrongPassword(
          attemptsBeforeLockout: _policy.attemptsBeforeLockout(failures),
          lockedUntil: lockedUntil,
        );
      });

  @override
  Future<Result<UnlockOutcome>> changePassword({
    required String current,
    required String replacement,
  }) async {
    final check = await unlockWithPassword(current);
    if (check case Ok(value: UnlockSucceeded())) {
      final saved = await createPassword(replacement);
      if (saved case Err(:final failure)) return Err(failure);
    }
    return check;
  }

  @override
  Future<Result<void>> recordBiometricUnlock() => _guard(_clearFailures);

  @override
  Future<Result<DateTime?>> lockedUntil() => _guard(_readLockedUntil);

  @override
  Future<Result<bool>> isBiometricEnabled() => _guard(
    () async => await _store.read(AuthKeys.biometricEnabled) == 'true',
  );

  @override
  Future<Result<void>> setBiometricEnabled({required bool enabled}) =>
      _guard(() => _store.write(AuthKeys.biometricEnabled, '$enabled'));

  Future<int> _readFailures() async =>
      int.tryParse(await _store.read(AuthKeys.failedAttempts) ?? '') ?? 0;

  Future<DateTime?> _readLockedUntil() async {
    final raw = await _store.read(AuthKeys.lockedUntil);
    final until = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
    if (until == null || !until.isAfter(_clock())) return null;
    return until;
  }

  Future<void> _clearFailures() async {
    await _store.delete(AuthKeys.failedAttempts);
    await _store.delete(AuthKeys.lockedUntil);
  }

  static Future<Result<T>> _guard<T>(Future<T> Function() body) =>
      guard<T, PlatformException>(
        body,
        (e) => StorageFailure('secure storage: ${e.code}'),
      );
}

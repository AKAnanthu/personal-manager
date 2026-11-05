import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/security/biometric_auth.dart';
import 'package:personal_life_manager/features/auth/domain/auth_repository.dart';

sealed class UnlockError extends Equatable {
  const UnlockError();

  @override
  List<Object?> get props => [];
}

final class WrongPasswordError extends UnlockError {
  const WrongPasswordError(this.attemptsBeforeLockout);

  final int attemptsBeforeLockout;

  @override
  List<Object?> get props => [attemptsBeforeLockout];
}

final class BiometricFailedError extends UnlockError {
  const BiometricFailedError();
}

final class StorageError extends UnlockError {
  const StorageError();
}

final class UnlockState extends Equatable {
  const UnlockState({
    this.busy = false,
    this.error,
    this.lockedUntil,
    this.now,
    this.biometricKind,
  });

  final bool busy;
  final UnlockError? error;
  final DateTime? lockedUntil;

  /// Last clock tick, so the lockout countdown re-renders.
  final DateTime? now;

  /// Non-null when biometric unlock is enabled and available.
  final BiometricKind? biometricKind;

  Duration? get lockoutRemaining {
    final until = lockedUntil;
    final at = now;
    if (until == null || at == null) return null;
    final left = until.difference(at);
    return left > Duration.zero ? left : null;
  }

  bool get isLockedOut => lockoutRemaining != null;

  UnlockState copyWith({
    bool? busy,
    UnlockError? error,
    bool clearError = false,
    DateTime? lockedUntil,
    bool clearLockout = false,
    DateTime? now,
    BiometricKind? biometricKind,
  }) => UnlockState(
    busy: busy ?? this.busy,
    error: clearError ? null : (error ?? this.error),
    lockedUntil: clearLockout ? null : (lockedUntil ?? this.lockedUntil),
    now: now ?? this.now,
    biometricKind: biometricKind ?? this.biometricKind,
  );

  @override
  List<Object?> get props => [busy, error, lockedUntil, now, biometricKind];
}

/// Password unlock with persistent backoff, plus optional biometrics. A
/// biometric failure or cancel always leaves the password route open.
class UnlockCubit extends Cubit<UnlockState> {
  UnlockCubit({
    required this._repository,
    required this._biometrics,
    required this._lock,
    this._clock = DateTime.now,
  }) : super(const UnlockState());

  final AuthRepository _repository;
  final BiometricAuth _biometrics;
  final AppLock _lock;
  final DateTime Function() _clock;
  Timer? _ticker;

  /// Loads lockout and biometric state; prompts for biometrics once if on.
  Future<void> init({required String biometricReason}) async {
    final until = await _repository.lockedUntil();
    final enabled = await _repository.isBiometricEnabled();
    final kind = enabled.fold((_) => false, (on) => on)
        ? await _biometrics.availableKind()
        : null;
    if (isClosed) return;
    emit(
      UnlockState(
        lockedUntil: until.fold((_) => null, (u) => u),
        now: _clock(),
        biometricKind: kind,
      ),
    );
    _syncTicker();
    if (kind != null) await unlockWithBiometrics(reason: biometricReason);
  }

  Future<void> unlockWithPassword(String password) async {
    if (state.busy || state.isLockedOut || password.isEmpty) return;
    emit(state.copyWith(busy: true, clearError: true));
    final result = await _repository.unlockWithPassword(password);
    if (isClosed) return;
    result.fold(
      (_) => emit(state.copyWith(busy: false, error: const StorageError())),
      (outcome) => switch (outcome) {
        UnlockSucceeded() => _lock.markUnlocked(),
        WrongPassword(:final attemptsBeforeLockout, :final lockedUntil) => emit(
          state.copyWith(
            busy: false,
            error: WrongPasswordError(attemptsBeforeLockout),
            lockedUntil: lockedUntil,
            now: _clock(),
          ),
        ),
        LockedOut(:final until) => emit(
          state.copyWith(busy: false, lockedUntil: until, now: _clock()),
        ),
      },
    );
    _syncTicker();
  }

  Future<void> unlockWithBiometrics({required String reason}) async {
    if (state.busy || state.biometricKind == null) return;
    emit(state.copyWith(busy: true, clearError: true));
    final ok = await _biometrics.authenticate(reason: reason);
    if (isClosed) return;
    if (!ok) {
      emit(state.copyWith(busy: false, error: const BiometricFailedError()));
      return;
    }
    // Clearing the counter is best effort; unlocking doesn't depend on it.
    await _repository.recordBiometricUnlock();
    if (isClosed) return;
    _lock.markUnlocked();
  }

  void _syncTicker() {
    if (isClosed) return;
    if (state.lockedUntil == null) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      final now = _clock();
      final until = state.lockedUntil;
      if (until == null || !until.isAfter(now)) {
        emit(state.copyWith(clearLockout: true, clearError: true, now: now));
        _ticker?.cancel();
        _ticker = null;
      } else {
        emit(state.copyWith(now: now));
      }
    });
  }

  @override
  Future<void> close() async {
    _ticker?.cancel();
    await super.close();
  }
}

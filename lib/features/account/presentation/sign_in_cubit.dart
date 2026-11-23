import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/platform/device_settings.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/security/device_lock.dart';
import 'package:personal_life_manager/core/sync/sync_engine.dart';
import 'package:personal_life_manager/features/account/data/account_session.dart';

enum SignInStep {
  /// "Continue with Google".
  welcome,

  /// The Google account picker is open.
  signingIn,

  /// Getting this account's data from Drive.
  downloading,

  /// Couldn't get it: try again, or continue and sync later.
  syncFailed,

  /// Confirming the phone's screen lock once before going in.
  unlock,
}

final class SignInState extends Equatable {
  const SignInState({
    this.step = SignInStep.welcome,
    this.failure,
    this.done = 0,
    this.total = 0,
    this.noScreenLock = false,
    this.clockAutomatic = true,
  });

  final SignInStep step;
  final Failure? failure;
  final int done;
  final int total;

  /// The phone has no screen lock; the app can't be protected until it has.
  final bool noScreenLock;

  /// Date & time and time zone are set automatically.
  final bool clockAutomatic;

  SignInState copyWith({
    SignInStep? step,
    Failure? Function()? failure,
    int? done,
    int? total,
    bool? noScreenLock,
    bool? clockAutomatic,
  }) => SignInState(
    step: step ?? this.step,
    failure: failure != null ? failure() : this.failure,
    done: done ?? this.done,
    total: total ?? this.total,
    noScreenLock: noScreenLock ?? this.noScreenLock,
    clockAutomatic: clockAutomatic ?? this.clockAutomatic,
  );

  @override
  List<Object?> get props => [
    step,
    failure,
    done,
    total,
    noScreenLock,
    clockAutomatic,
  ];
}

class SignInCubit extends Cubit<SignInState> {
  SignInCubit({
    required this._session,
    required this._sync,
    required this._deviceLock,
    required this._settings,
    required this._lock,
  }) : super(const SignInState());

  final AccountSession _session;
  final SyncEngine _sync;
  final DeviceLock _deviceLock;
  final DeviceSettings _settings;
  final AppLock _lock;

  Future<void> checkClock() async {
    final t = await _settings.automaticTime();
    if (!isClosed) emit(state.copyWith(clockAutomatic: t.time && t.zone));
  }

  Future<void> openDateSettings() =>
      _lock.runExternal(_settings.openDateSettings);

  Future<void> openSecuritySettings() =>
      _lock.runExternal(_settings.openSecuritySettings);

  Future<void> signIn() async {
    if (state.step != SignInStep.welcome) return;
    emit(state.copyWith(step: SignInStep.signingIn, failure: () => null));
    final r = await _session.signIn();
    if (isClosed) return;
    switch (r) {
      case Ok(value: null):
        emit(state.copyWith(step: SignInStep.welcome));
      case Err(:final failure):
        emit(state.copyWith(step: SignInStep.welcome, failure: () => failure));
      case Ok():
        await _download();
    }
  }

  Future<void> retrySync() async {
    if (state.step != SignInStep.syncFailed) return;
    await _download();
  }

  /// Into the app without the data from Drive; "Sync now" gets it later.
  void continueWithoutSync() {
    if (state.step != SignInStep.syncFailed) return;
    emit(state.copyWith(step: SignInStep.unlock, failure: () => null));
  }

  Future<void> _download() async {
    emit(
      state.copyWith(
        step: SignInStep.downloading,
        failure: () => null,
        done: 0,
        total: 0,
      ),
    );
    void progress() {
      final s = _sync.status.value;
      if (!isClosed && state.step == SignInStep.downloading) {
        emit(state.copyWith(done: s.done, total: s.total));
      }
    }

    _sync.status.addListener(progress);
    final Result<SyncReport> r;
    try {
      r = await _session.firstSync();
    } finally {
      _sync.status.removeListener(progress);
    }
    if (isClosed) return;
    switch (r) {
      case Ok():
        emit(state.copyWith(step: SignInStep.unlock));
      case Err(:final failure):
        emit(
          state.copyWith(step: SignInStep.syncFailed, failure: () => failure),
        );
    }
  }

  /// Confirms the phone's screen lock works, then opens the app.
  Future<void> unlock({required String reason}) async {
    if (state.step != SignInStep.unlock) return;
    final r = await _lock.runExternal(() => _deviceLock.unlock(reason: reason));
    if (isClosed) return;
    switch (r) {
      case DeviceUnlock.unlocked:
        emit(state.copyWith(noScreenLock: false));
        _lock.markUnlocked();
      case DeviceUnlock.noScreenLock:
        emit(state.copyWith(noScreenLock: true));
      case DeviceUnlock.cancelled || DeviceUnlock.unavailable:
        break;
    }
  }
}

// ---- Unlock (app start, return from background) ----------------------------

final class UnlockState extends Equatable {
  const UnlockState({this.busy = false, this.noScreenLock = false});

  final bool busy;
  final bool noScreenLock;

  @override
  List<Object?> get props => [busy, noScreenLock];
}

class UnlockCubit extends Cubit<UnlockState> {
  UnlockCubit({
    required this._deviceLock,
    required this._settings,
    required this._lock,
  }) : super(const UnlockState());

  final DeviceLock _deviceLock;
  final DeviceSettings _settings;
  final AppLock _lock;

  Future<void> unlock({required String reason}) async {
    if (state.busy) return;
    emit(const UnlockState(busy: true));
    final r = await _lock.runExternal(() => _deviceLock.unlock(reason: reason));
    if (isClosed) return;
    emit(UnlockState(noScreenLock: r == DeviceUnlock.noScreenLock));
    if (r == DeviceUnlock.unlocked) _lock.markUnlocked();
  }

  Future<void> openSecuritySettings() =>
      _lock.runExternal(_settings.openSecuritySettings);
}

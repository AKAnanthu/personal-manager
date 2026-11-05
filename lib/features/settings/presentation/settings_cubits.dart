import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/security/biometric_auth.dart';
import 'package:personal_life_manager/features/auth/domain/auth_repository.dart';
import 'package:personal_life_manager/features/auth/domain/password_strength.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_platform.dart';
import 'package:personal_life_manager/features/backup_restore/domain/backup.dart';
import 'package:personal_life_manager/features/settings/data/app_settings.dart';
import 'package:personal_life_manager/features/settings/data/data_eraser.dart';

// ---- Settings ---------------------------------------------------------------

final class SettingsState extends Equatable {
  const SettingsState({
    this.loading = true,
    this.biometricKind,
    this.biometricEnabled = false,
    this.notificationsAllowed = true,
    this.exactAlarms = true,
    this.lastBackup,
    this.themeMode = ThemeMode.system,
    this.autoLock = AutoLock.immediately,
    this.biometricFailed = false,
  });

  final bool loading;

  /// Null when the phone has no usable fingerprint/face unlock.
  final BiometricKind? biometricKind;
  final bool biometricEnabled;
  final bool notificationsAllowed;
  final bool exactAlarms;
  final LastBackup? lastBackup;
  final ThemeMode themeMode;
  final AutoLock autoLock;

  /// Turning biometrics on needs one successful scan (shown once).
  final bool biometricFailed;

  SettingsState copyWith({
    bool? loading,
    BiometricKind? Function()? biometricKind,
    bool? biometricEnabled,
    bool? notificationsAllowed,
    bool? exactAlarms,
    LastBackup? lastBackup,
    ThemeMode? themeMode,
    AutoLock? autoLock,
    bool? biometricFailed,
  }) => SettingsState(
    loading: loading ?? this.loading,
    biometricKind: biometricKind != null ? biometricKind() : this.biometricKind,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    notificationsAllowed: notificationsAllowed ?? this.notificationsAllowed,
    exactAlarms: exactAlarms ?? this.exactAlarms,
    lastBackup: lastBackup ?? this.lastBackup,
    themeMode: themeMode ?? this.themeMode,
    autoLock: autoLock ?? this.autoLock,
    biometricFailed: biometricFailed ?? false,
  );

  @override
  List<Object?> get props => [
    loading,
    biometricKind,
    biometricEnabled,
    notificationsAllowed,
    exactAlarms,
    lastBackup,
    themeMode,
    autoLock,
    biometricFailed,
  ];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this._auth,
    required this._biometrics,
    required this._permissions,
    required this._settings,
    required this._lastBackup,
    required this._eraser,
  }) : super(const SettingsState());

  final AuthRepository _auth;
  final BiometricAuth _biometrics;
  final NotificationPermissions _permissions;
  final AppSettings _settings;
  final LastBackupStore _lastBackup;
  final DataEraser _eraser;
  AppLifecycleListener? _lifecycle;

  Future<void> load() async {
    // Permission changes happen in system settings; refresh on return.
    _lifecycle ??= AppLifecycleListener(onResume: () => unawaited(refresh()));
    final kind = await _biometrics.availableKind();
    final enabled = (await _auth.isBiometricEnabled()).fold(
      (_) => false,
      (v) => v,
    );
    final last = await _lastBackup.load();
    if (isClosed) return;
    emit(
      state.copyWith(
        loading: false,
        biometricKind: () => kind,
        biometricEnabled: enabled && kind != null,
        lastBackup: last,
        themeMode: _settings.themeMode.value,
        autoLock: _settings.autoLock,
      ),
    );
    await refresh();
  }

  Future<void> refresh() async {
    final allowed = await _permissions.areEnabled();
    if (isClosed) return;
    emit(
      state.copyWith(
        notificationsAllowed: allowed,
        exactAlarms: _permissions.exactAlarmsAvailable,
      ),
    );
  }

  /// Turning it on asks for one successful scan first.
  Future<void> setBiometric({
    required bool enabled,
    required String reason,
  }) async {
    if (enabled && !await _biometrics.authenticate(reason: reason)) {
      if (!isClosed) emit(state.copyWith(biometricFailed: true));
      return;
    }
    final r = await _auth.setBiometricEnabled(enabled: enabled);
    if (isClosed) return;
    if (r.isSuccess) emit(state.copyWith(biometricEnabled: enabled));
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _settings.setTheme(mode);
    if (!isClosed) emit(state.copyWith(themeMode: mode));
  }

  Future<void> setAutoLock(AutoLock value) async {
    await _settings.setAutoLock(value);
    if (!isClosed) emit(state.copyWith(autoLock: value));
  }

  Future<void> openNotificationSettings() => _permissions.openSettings();

  Future<void> allowExactAlarms() async {
    await _permissions.requestExactAlarms();
    await refresh();
  }

  /// Wipes this phone; the router then shows first-time setup.
  Future<void> eraseEverything() => _eraser.eraseEverything();

  @override
  Future<void> close() async {
    _lifecycle?.dispose();
    await super.close();
  }
}

// ---- Change password -------------------------------------------------------

enum ChangePasswordOutcome { none, changed }

final class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.current = '',
    this.replacement = '',
    this.confirm = '',
    this.busy = false,
    this.showErrors = false,
    this.attemptsLeft,
    this.lockedUntil,
    this.storageError = false,
    this.outcome = ChangePasswordOutcome.none,
  });

  final String current;
  final String replacement;
  final String confirm;
  final bool busy;
  final bool showErrors;

  /// Set after a wrong current password.
  final int? attemptsLeft;
  final DateTime? lockedUntil;
  final bool storageError;
  final ChangePasswordOutcome outcome;

  PasswordStrength get strength => PasswordStrength.evaluate(replacement);
  bool get mismatch => confirm != replacement;
  bool get sameAsCurrent => replacement.isNotEmpty && replacement == current;
  bool get hasErrors =>
      current.isEmpty || !strength.isAcceptable || mismatch || sameAsCurrent;

  ChangePasswordState copyWith({
    String? current,
    String? replacement,
    String? confirm,
    bool? busy,
    bool? showErrors,
    int? Function()? attemptsLeft,
    DateTime? Function()? lockedUntil,
    bool? storageError,
    ChangePasswordOutcome? outcome,
  }) => ChangePasswordState(
    current: current ?? this.current,
    replacement: replacement ?? this.replacement,
    confirm: confirm ?? this.confirm,
    busy: busy ?? this.busy,
    showErrors: showErrors ?? this.showErrors,
    attemptsLeft: attemptsLeft != null ? attemptsLeft() : this.attemptsLeft,
    lockedUntil: lockedUntil != null ? lockedUntil() : this.lockedUntil,
    storageError: storageError ?? false,
    outcome: outcome ?? this.outcome,
  );

  @override
  List<Object?> get props => [
    current,
    replacement,
    confirm,
    busy,
    showErrors,
    attemptsLeft,
    lockedUntil,
    storageError,
    outcome,
  ];
}

/// Needs the current password, checked with the same attempt limit and
/// lockout as the Unlock screen.
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._auth) : super(const ChangePasswordState());

  final AuthRepository _auth;

  void currentChanged(String v) =>
      emit(state.copyWith(current: v, attemptsLeft: () => null));
  void replacementChanged(String v) => emit(state.copyWith(replacement: v));
  void confirmChanged(String v) => emit(state.copyWith(confirm: v));

  Future<void> submit() async {
    if (state.busy) return;
    if (state.hasErrors) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(busy: true));
    final r = await _auth.changePassword(
      current: state.current,
      replacement: state.replacement,
    );
    if (isClosed) return;
    switch (r) {
      case Err():
        emit(state.copyWith(busy: false, storageError: true));
      case Ok(value: UnlockSucceeded()):
        emit(
          state.copyWith(busy: false, outcome: ChangePasswordOutcome.changed),
        );
      case Ok(
        value: WrongPassword(:final attemptsBeforeLockout, :final lockedUntil),
      ):
        emit(
          state.copyWith(
            busy: false,
            attemptsLeft: () => attemptsBeforeLockout,
            lockedUntil: () => lockedUntil,
          ),
        );
      case Ok(value: LockedOut(:final until)):
        emit(state.copyWith(busy: false, lockedUntil: () => until));
    }
  }
}

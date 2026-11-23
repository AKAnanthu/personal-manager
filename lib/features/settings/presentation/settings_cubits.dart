import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_platform.dart';
import 'package:personal_life_manager/features/backup_restore/domain/backup.dart';
import 'package:personal_life_manager/features/settings/data/app_settings.dart';

// ---- Settings ---------------------------------------------------------------

final class SettingsState extends Equatable {
  const SettingsState({
    this.loading = true,
    this.notificationsAllowed = true,
    this.exactAlarms = true,
    this.lastBackup,
    this.themeMode = ThemeMode.system,
    this.autoLock = AutoLock.immediately,
  });

  final bool loading;

  final bool notificationsAllowed;
  final bool exactAlarms;
  final LastBackup? lastBackup;
  final ThemeMode themeMode;
  final AutoLock autoLock;

  SettingsState copyWith({
    bool? loading,
    bool? notificationsAllowed,
    bool? exactAlarms,
    LastBackup? lastBackup,
    ThemeMode? themeMode,
    AutoLock? autoLock,
  }) => SettingsState(
    loading: loading ?? this.loading,
    notificationsAllowed: notificationsAllowed ?? this.notificationsAllowed,
    exactAlarms: exactAlarms ?? this.exactAlarms,
    lastBackup: lastBackup ?? this.lastBackup,
    themeMode: themeMode ?? this.themeMode,
    autoLock: autoLock ?? this.autoLock,
  );

  @override
  List<Object?> get props => [
    loading,
    notificationsAllowed,
    exactAlarms,
    lastBackup,
    themeMode,
    autoLock,
  ];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this._permissions,
    required this._settings,
    required this._lastBackup,
  }) : super(const SettingsState());

  final NotificationPermissions _permissions;
  final AppSettings _settings;
  final LastBackupStore _lastBackup;
  AppLifecycleListener? _lifecycle;

  Future<void> load() async {
    // Permission changes happen in system settings; refresh on return.
    _lifecycle ??= AppLifecycleListener(onResume: () => unawaited(refresh()));
    final last = await _lastBackup.load();
    if (isClosed) return;
    emit(
      state.copyWith(
        loading: false,
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

  @override
  Future<void> close() async {
    _lifecycle?.dispose();
    await super.close();
  }
}

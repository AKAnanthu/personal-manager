import 'package:flutter/material.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How long the app may stay in the background before it locks again.
enum AutoLock {
  immediately(Duration.zero),
  after30s(Duration(seconds: 30)),
  after1min(Duration(minutes: 1)),
  after5min(Duration(minutes: 5));

  AutoLock(this.duration);

  final Duration duration;
}

/// App-wide preferences (theme, auto-lock), stored on this device and
/// applied immediately. Not secret: the lock itself lives in secure
/// storage.
class AppSettings {
  AppSettings(this._lock, [SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  final AppLock _lock;
  final SharedPreferencesAsync _prefs;

  static const _themeKey = 'settings.theme';
  static const _autoLockKey = 'settings.autoLock';

  /// The app widget listens to this.
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  AutoLock _autoLock = AutoLock.immediately;
  AutoLock get autoLock => _autoLock;

  Future<void> load() async {
    final theme = await _prefs.getString(_themeKey);
    themeMode.value =
        ThemeMode.values.where((m) => m.name == theme).firstOrNull ??
        ThemeMode.system;
    final lock = await _prefs.getString(_autoLockKey);
    _applyAutoLock(
      AutoLock.values.where((a) => a.name == lock).firstOrNull ??
          AutoLock.immediately,
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    themeMode.value = mode;
    await _prefs.setString(_themeKey, mode.name);
  }

  Future<void> setAutoLock(AutoLock value) async {
    _applyAutoLock(value);
    await _prefs.setString(_autoLockKey, value.name);
  }

  void _applyAutoLock(AutoLock value) {
    _autoLock = value;
    _lock.timeout = value.duration;
  }

  /// For backups ("Relevant application preferences").
  Map<String, Object?> export() => {
    'theme': themeMode.value.name,
    'autoLock': _autoLock.name,
  };

  Future<void> import(Map<String, Object?> values) async {
    final theme = ThemeMode.values
        .where((m) => m.name == values['theme'])
        .firstOrNull;
    if (theme != null) await setTheme(theme);
    final lock = AutoLock.values
        .where((a) => a.name == values['autoLock'])
        .firstOrNull;
    if (lock != null) await setAutoLock(lock);
  }

  /// Back to defaults (erasing all data).
  Future<void> reset() async {
    themeMode.value = ThemeMode.system;
    _applyAutoLock(AutoLock.immediately);
    await _prefs.clear();
  }

  void dispose() => themeMode.dispose();
}

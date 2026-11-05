/// What forms need to know about notification permission state.
abstract interface class NotificationPermissions {
  /// Prompts if needed. True when notifications can be shown.
  Future<bool> ensurePermission();

  /// Whether notifications are allowed right now (no prompt).
  Future<bool> areEnabled();

  /// False on Android 12+ without the exact-alarm permission.
  bool get exactAlarmsAvailable;

  Future<void> requestExactAlarms();

  Future<void> openSettings();
}

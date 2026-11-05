import 'package:flutter/widgets.dart';

enum LockStatus { notSetUp, locked, unlocked }

/// Single source of truth for whether the app content may be shown. Drives
/// the router's redirect guard via [ChangeNotifier].
///
/// The app starts locked (cold start). When it returns from the background
/// after at least [timeout] (default: immediately), it locks again.
class AppLock extends ChangeNotifier {
  AppLock({
    required LockStatus initialStatus,
    this.timeout = Duration.zero,
    this._clock = DateTime.now,
  }) : _status = initialStatus;

  final DateTime Function() _clock;
  LockStatus _status;
  DateTime? _backgroundedAt;
  int _externalActivities = 0;
  AppLifecycleListener? _lifecycle;

  /// How long the app may stay in the background before it locks.
  Duration timeout;

  LockStatus get status => _status;

  void attachLifecycle() {
    _lifecycle ??= AppLifecycleListener(
      onHide: onBackgrounded,
      onShow: onForegrounded,
    );
  }

  /// Called after setup completes or the user authenticates.
  void markUnlocked() => _setStatus(LockStatus.unlocked);

  /// After all data was erased: the router returns to first-time setup.
  void markNotSetUp() => _setStatus(LockStatus.notSetUp);

  /// "Lock now", or an automatic lock after the timeout.
  void lock() {
    if (_status == LockStatus.unlocked) _setStatus(LockStatus.locked);
  }

  @visibleForTesting
  void onBackgrounded() {
    if (_externalActivities > 0) return;
    _backgroundedAt = _clock();
  }

  @visibleForTesting
  void onForegrounded() {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since != null && _clock().difference(since) >= timeout) lock();
  }

  /// Runs [action] (file picker, camera, share sheet, OS settings…) without
  /// the resulting trip to another app triggering an auto-lock.
  Future<T> runExternal<T>(Future<T> Function() action) async {
    _externalActivities++;
    try {
      return await action();
    } finally {
      _externalActivities--;
    }
  }

  void _setStatus(LockStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }
}

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum DeviceUnlock {
  unlocked,

  /// Backed out, or the system stopped it (try again).
  cancelled,

  /// The phone has no PIN, pattern, password or biometrics set up.
  noScreenLock,

  /// The prompt couldn't be shown.
  unavailable,
}

/// The phone's own screen lock (fingerprint, face, PIN, pattern or
/// password) guards the app; the app has no password of its own.
abstract interface class DeviceLock {
  Future<DeviceUnlock> unlock({required String reason});
}

final class LocalDeviceLock implements DeviceLock {
  LocalDeviceLock([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<DeviceUnlock> unlock({required String reason}) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
      return ok ? DeviceUnlock.unlocked : DeviceUnlock.cancelled;
    } on LocalAuthException catch (e) {
      return switch (e.code) {
        LocalAuthExceptionCode.noCredentialsSet => DeviceUnlock.noScreenLock,
        LocalAuthExceptionCode.uiUnavailable => DeviceUnlock.unavailable,
        _ => DeviceUnlock.cancelled,
      };
    } on PlatformException {
      return DeviceUnlock.unavailable;
    }
  }
}

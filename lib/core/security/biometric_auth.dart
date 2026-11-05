import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricKind { face, fingerprint, generic }

/// Device biometrics. Any failure, cancel or error returns false so callers
/// always fall back to the password.
abstract interface class BiometricAuth {
  /// The enrolled biometric type, or null if none is available.
  Future<BiometricKind?> availableKind();

  Future<bool> authenticate({required String reason});
}

final class LocalBiometricAuth implements BiometricAuth {
  LocalBiometricAuth([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<BiometricKind?> availableKind() async {
    try {
      if (!await _auth.isDeviceSupported()) return null;
      final types = await _auth.getAvailableBiometrics();
      if (types.isEmpty) return null;
      if (types.contains(BiometricType.face)) return BiometricKind.face;
      if (types.contains(BiometricType.fingerprint)) {
        return BiometricKind.fingerprint;
      }
      return BiometricKind.generic;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
    } on LocalAuthException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}

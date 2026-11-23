import 'dart:io';

import 'package:flutter/services.dart';

/// Phone settings sync relies on, and shortcuts to change them.
abstract interface class DeviceSettings {
  /// Whether date & time and time zone are set automatically. True when
  /// it can't be told (other platforms).
  Future<({bool time, bool zone})> automaticTime();

  Future<void> openDateSettings();

  Future<void> openSecuritySettings();
}

final class PlatformDeviceSettings implements DeviceSettings {
  const PlatformDeviceSettings();

  static const _channel = MethodChannel('app.plm/platform');

  @override
  Future<({bool time, bool zone})> automaticTime() async {
    if (!Platform.isAndroid) return (time: true, zone: true);
    try {
      final r = await _channel.invokeMapMethod<String, bool>('automaticTime');
      return (time: r?['time'] ?? true, zone: r?['zone'] ?? true);
    } on PlatformException {
      return (time: true, zone: true);
    }
  }

  @override
  Future<void> openDateSettings() => _open('openDateSettings');

  @override
  Future<void> openSecuritySettings() => _open('openSecuritySettings');

  Future<void> _open(String method) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>(method);
    } on PlatformException {
      // No settings screen to open.
    }
  }
}

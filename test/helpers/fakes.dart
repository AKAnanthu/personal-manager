import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/platform/device_settings.dart';
import 'package:personal_life_manager/core/security/device_lock.dart';
import 'package:personal_life_manager/core/storage/secure_store.dart';

final class InMemorySecureStore implements SecureStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> deleteAll() async => values.clear();
}

/// A screen lock that answers [result].
final class FakeDeviceLock implements DeviceLock {
  FakeDeviceLock([this.result = DeviceUnlock.unlocked]);

  DeviceUnlock result;
  int prompts = 0;

  @override
  Future<DeviceUnlock> unlock({required String reason}) async {
    prompts++;
    return result;
  }
}

final class FakeDeviceSettings implements DeviceSettings {
  bool automatic = true;
  int opened = 0;

  @override
  Future<({bool time, bool zone})> automaticTime() async =>
      (time: automatic, zone: automatic);

  @override
  Future<void> openDateSettings() async => opened++;

  @override
  Future<void> openSecuritySettings() async => opened++;
}

class MockSecureStore extends Mock implements SecureStore;

/// Mutable clock for time-dependent tests.
final class TestClock {
  TestClock([DateTime? start]) : now = start ?? DateTime(2026, 11, 3, 18);

  DateTime now;

  DateTime call() => now;

  void advance(Duration d) => now = now.add(d);
}

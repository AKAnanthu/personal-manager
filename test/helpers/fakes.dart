import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/security/biometric_auth.dart';
import 'package:personal_life_manager/core/storage/secure_store.dart';
import 'package:personal_life_manager/features/auth/domain/auth_repository.dart';

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

class MockAuthRepository extends Mock implements AuthRepository;

class MockBiometricAuth extends Mock implements BiometricAuth;

class MockSecureStore extends Mock implements SecureStore;

/// Mutable clock for time-dependent tests.
final class TestClock {
  TestClock([DateTime? start]) : now = start ?? DateTime(2026, 11, 3, 18);

  DateTime now;

  DateTime call() => now;

  void advance(Duration d) => now = now.add(d);
}

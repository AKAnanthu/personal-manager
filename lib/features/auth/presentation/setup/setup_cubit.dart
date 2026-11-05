import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/security/biometric_auth.dart';
import 'package:personal_life_manager/features/auth/domain/auth_repository.dart';
import 'package:personal_life_manager/features/auth/domain/password_strength.dart';

enum SetupStep { welcome, password, biometric }

enum SetupError { storage, biometricFailed }

final class SetupState extends Equatable {
  const SetupState({
    this.step = SetupStep.welcome,
    this.password = '',
    this.confirmation = '',
    this.acknowledged = false,
    this.busy = false,
    this.error,
    this.biometricKind,
  });

  final SetupStep step;
  final String password;
  final String confirmation;
  final bool acknowledged;
  final bool busy;
  final SetupError? error;
  final BiometricKind? biometricKind;

  PasswordStrength get strength => PasswordStrength.evaluate(password);

  bool get confirmationMismatch =>
      confirmation.isNotEmpty && confirmation != password;

  bool get canSubmitPassword =>
      strength.isAcceptable &&
      confirmation == password &&
      acknowledged &&
      !busy;

  SetupState copyWith({
    SetupStep? step,
    String? password,
    String? confirmation,
    bool? acknowledged,
    bool? busy,
    SetupError? error,
    bool clearError = false,
    BiometricKind? biometricKind,
  }) => SetupState(
    step: step ?? this.step,
    password: password ?? this.password,
    confirmation: confirmation ?? this.confirmation,
    acknowledged: acknowledged ?? this.acknowledged,
    busy: busy ?? this.busy,
    error: clearError ? null : (error ?? this.error),
    biometricKind: biometricKind ?? this.biometricKind,
  );

  @override
  List<Object?> get props => [
    step,
    password,
    confirmation,
    acknowledged,
    busy,
    error,
    biometricKind,
  ];
}

/// First-run flow: welcome → password + data-storage disclosure (must be
/// acknowledged) → optional biometric enrolment. Notification permission is
/// requested later, when the first reminder is created.
class SetupCubit extends Cubit<SetupState> {
  SetupCubit({
    required this._repository,
    required this._biometrics,
    required this._lock,
  }) : super(const SetupState());

  final AuthRepository _repository;
  final BiometricAuth _biometrics;
  final AppLock _lock;

  void start() => emit(state.copyWith(step: SetupStep.password));

  void passwordChanged(String value) =>
      emit(state.copyWith(password: value, clearError: true));

  void confirmationChanged(String value) =>
      emit(state.copyWith(confirmation: value, clearError: true));

  void acknowledgedChanged({required bool value}) =>
      emit(state.copyWith(acknowledged: value));

  Future<void> submitPassword() async {
    if (!state.canSubmitPassword) return;
    emit(state.copyWith(busy: true, clearError: true));

    final saved = await _repository.createPassword(state.password);
    if (isClosed) return;
    if (!saved.isSuccess) {
      emit(state.copyWith(busy: false, error: SetupError.storage));
      return;
    }

    final kind = await _biometrics.availableKind();
    if (isClosed) return;
    if (kind == null) return _finish();
    // Drop the plaintext from state once it has been hashed.
    emit(
      SetupState(
        step: SetupStep.biometric,
        acknowledged: true,
        biometricKind: kind,
      ),
    );
  }

  /// Confirms the sensor works before turning biometric unlock on.
  Future<void> enableBiometric({required String reason}) async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, clearError: true));
    final ok = await _biometrics.authenticate(reason: reason);
    if (isClosed) return;
    if (!ok) {
      emit(state.copyWith(busy: false, error: SetupError.biometricFailed));
      return;
    }
    final saved = await _repository.setBiometricEnabled(enabled: true);
    if (isClosed) return;
    if (!saved.isSuccess) {
      emit(state.copyWith(busy: false, error: SetupError.storage));
      return;
    }
    _finish();
  }

  void skipBiometric() => _finish();

  void _finish() => _lock.markUnlocked();
}

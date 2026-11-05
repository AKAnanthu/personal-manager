import 'package:personal_life_manager/core/error/failure.dart';

/// Success-or-failure value returned by repositories.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Ok<T>;

  R fold<R>(R Function(Failure failure) onFailure, R Function(T value) onOk) =>
      switch (this) {
        Ok<T>(:final value) => onOk(value),
        Err<T>(:final failure) => onFailure(failure),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

/// Runs [body], mapping exceptions of type [E] to a [Failure] via [onError].
/// Errors of other types propagate (no catch-all swallowing).
Future<Result<T>> guard<T, E extends Object>(
  Future<T> Function() body,
  Failure Function(E error) onError,
) async {
  try {
    return Ok(await body());
  } on E catch (e) {
    return Err(onError(e));
  }
}

import 'package:drift/drift.dart';
import 'package:drift/native.dart' show SqliteException;
// Errors from the background database isolate arrive wrapped in this type;
// it's only imported for catching.
// ignore: experimental_member_use
import 'package:drift/remote.dart' show DriftRemoteException;
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';

/// Thrown inside a [dbGuard] body when the target row doesn't exist.
final class RecordNotFound implements Exception {
  const RecordNotFound();
}

/// Thrown inside a [dbGuard] body to return an already-typed failure.
final class FailWith implements Exception {
  const FailWith(this.failure);

  final Failure failure;
}

/// Maps database exceptions to typed failures. Only the error *type* is
/// kept; messages can contain record contents.
Future<Result<T>> dbGuard<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on RecordNotFound {
    return const Err(NotFoundFailure());
  } on FailWith catch (e) {
    return Err(e.failure);
  } on SqliteException catch (e) {
    return Err(DatabaseFailure('sqlite ${e.extendedResultCode}'));
  } on DriftRemoteException {
    return const Err(DatabaseFailure('remote'));
  } on DriftWrappedException {
    return const Err(DatabaseFailure('wrapped'));
  } on InvalidDataException {
    return const Err(DatabaseFailure('invalid data'));
  } on CouldNotRollBackException {
    return const Err(DatabaseFailure('rollback'));
  }
}

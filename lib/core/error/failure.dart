import 'package:equatable/equatable.dart';

/// Typed failures returned from repositories. Exceptions are mapped to these
/// in the data layer only; presentation never sees raw exceptions.
sealed class Failure extends Equatable {
  const Failure([this.debugMessage]);

  /// Developer-facing detail. Must never contain record contents, passwords,
  /// ID numbers, personal file names or tokens.
  final String? debugMessage;

  @override
  List<Object?> get props => [debugMessage];
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure([super.debugMessage]);
}

final class StorageFailure extends Failure {
  const StorageFailure([super.debugMessage]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.debugMessage]);
}

final class ValidationFailure extends Failure {
  const ValidationFailure([super.debugMessage]);
}

/// File type not accepted (by extension or content signature).
final class UnsupportedFileFailure extends Failure {
  const UnsupportedFileFailure([super.debugMessage]);
}

final class FileTooLargeFailure extends Failure {
  const FileTooLargeFailure(this.maxBytes);

  final int maxBytes;

  @override
  List<Object?> get props => [maxBytes];
}

/// The action clashes with existing state (e.g. a second shopping session
/// while one is in progress). [conflictingId] names the blocking record.
final class ConflictFailure extends Failure {
  const ConflictFailure(this.conflictingId);

  final String conflictingId;

  @override
  List<Object?> get props => [conflictingId];
}

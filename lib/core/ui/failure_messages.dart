import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// User-facing text for a [Failure]. Never includes debug detail.
extension FailureMessage on Failure {
  String message(AppLocalizations l10n) => switch (this) {
    NotFoundFailure() => l10n.errorNotFound,
    UnsupportedFileFailure() => l10n.errorUnsupportedFile,
    FileTooLargeFailure(:final maxBytes) => l10n.errorFileTooLarge(
      maxBytes ~/ (1024 * 1024),
    ),
    StorageFailure() => l10n.errorFileStorage,
    ConflictFailure() => l10n.errorConflict,
    DatabaseFailure() || ValidationFailure() => l10n.errorGeneric,
  };
}

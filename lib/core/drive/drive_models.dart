import 'package:equatable/equatable.dart';
import 'package:personal_life_manager/core/error/failure.dart';

/// Thrown inside the Drive layer; mapped to a `DriveFailure` before it
/// leaves it.
final class DriveException implements Exception {
  const DriveException(this.problem);

  final DriveProblem problem;

  @override
  String toString() => 'DriveException($problem)';
}

/// A file or folder in the app's Drive folder.
final class DriveItem extends Equatable {
  const DriveItem({
    required this.id,
    required this.name,
    required this.mimeType,
    this.sizeBytes,
    this.modifiedAt,
  });

  static const folderMimeType = 'application/vnd.google-apps.folder';

  final String id;
  final String name;
  final String mimeType;

  /// Null for folders.
  final int? sizeBytes;
  final DateTime? modifiedAt;

  bool get isFolder => mimeType == folderMimeType;

  @override
  List<Object?> get props => [id, name, mimeType, sizeBytes, modifiedAt];
}

/// One page of a folder listing.
final class DrivePage extends Equatable {
  const DrivePage(this.items, {this.nextPageToken});

  final List<DriveItem> items;

  /// Null on the last page.
  final String? nextPageToken;

  @override
  List<Object?> get props => [items, nextPageToken];
}

/// Bytes moved so far out of [total].
typedef DriveProgress = void Function(int done, int total);

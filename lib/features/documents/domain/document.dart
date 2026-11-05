import 'package:equatable/equatable.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';

/// PRD §7.3. Mapping to Drive folders is decided with the Drive milestone.
enum DocumentCategory {
  personal,
  financial,
  medical,
  employment,
  educational,
  propertyVehicle,
  others,
}

/// Drive copy state (PRD §7.5). Changed only by user-started uploads.
enum DriveStatus { notUploaded, uploading, uploaded, failed }

/// How long before expiry the reminder rings (owner decision: 30 days).
const expiryReminderLead = Duration(days: 30);

/// The expiry banner lists documents expiring within this window.
const expirySoonWindow = Duration(days: 30);

final class AppDocument extends Equatable {
  const AppDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.fileKey,
    required this.originalName,
    required this.fileType,
    required this.sizeBytes,
    required this.isFavourite,
    required this.createdAt,
    required this.updatedAt,
    this.expiryDate,
    this.expiryReminder = true,
    this.driveStatus = DriveStatus.notUploaded,
  });

  final String id;
  final String title;
  final String description;
  final DocumentCategory category;

  /// FileStore key; never shown to the user.
  final String fileKey;
  final String originalName;
  final SupportedFileType fileType;
  final int sizeBytes;

  /// Calendar date (no time).
  final DateTime? expiryDate;
  final bool expiryReminder;
  final bool isFavourite;
  final DriveStatus driveStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Whole days from [today] to the expiry date (negative once expired).
  int? daysToExpiry(DateTime today) {
    final e = expiryDate;
    if (e == null) return null;
    final t = DateTime(today.year, today.month, today.day);
    // Calendar dates in UTC so DST changes can't shift the count.
    return DateTime.utc(
      e.year,
      e.month,
      e.day,
    ).difference(DateTime.utc(t.year, t.month, t.day)).inDays;
  }

  /// When the expiry reminder rings: 9:00 local, [expiryReminderLead]
  /// before the expiry date.
  DateTime? get reminderAt {
    final e = expiryDate;
    if (e == null || !expiryReminder) return null;
    return DateTime(e.year, e.month, e.day - expiryReminderLead.inDays, 9);
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    fileKey,
    originalName,
    fileType,
    sizeBytes,
    expiryDate,
    expiryReminder,
    isFavourite,
    driveStatus,
    createdAt,
    updatedAt,
  ];
}

/// Editable details. The file itself is passed separately on add/replace.
final class DocumentDraft extends Equatable {
  const DocumentDraft({
    required this.title,
    required this.category,
    this.id,
    this.description = '',
    this.expiryDate,
    this.expiryReminder = true,
    this.isFavourite = false,
  });

  final String? id;
  final String title;
  final String description;
  final DocumentCategory category;
  final DateTime? expiryDate;
  final bool expiryReminder;
  final bool isFavourite;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    expiryDate,
    expiryReminder,
    isFavourite,
  ];
}

final class DocumentFilter extends Equatable {
  const DocumentFilter({
    this.query = '',
    this.category,
    this.favouritesOnly = false,
  });

  final String query;
  final DocumentCategory? category;
  final bool favouritesOnly;

  @override
  List<Object?> get props => [query, category, favouritesOnly];
}

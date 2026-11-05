import 'dart:io';

import 'package:flutter/material.dart';
import 'package:personal_life_manager/core/security/secure_screen.dart';
import 'package:personal_life_manager/core/storage/file_access.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/file_badge.dart';
import 'package:personal_life_manager/core/ui/widgets/image_viewer_page.dart';
import 'package:personal_life_manager/core/ui/widgets/pdf_viewer_page.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

abstract final class DocumentRoutes {
  static const root = '/documents';
  static const add = '/documents/new';
  static String view(String id) => '/documents/$id';
  static String edit(String id) => '/documents/$id/edit';
}

/// PDFs and images open in the app (on a secure screen: they are often ID
/// scans); Word and Excel files open in another app.
Future<void> openDocumentFile(
  BuildContext context, {
  required AppDocument document,
  required File file,
  required FileOpener opener,
}) async {
  final type = document.fileType;
  if (type.hasInAppPreview) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SecureScreen(
          child: type.isImage
              ? ImageViewerPage(file: file, title: document.title)
              : PdfViewerPage(file: file, title: document.title),
        ),
      ),
    );
  } else if (!await opener.openExternally(file) && context.mounted) {
    showSnack(context, AppLocalizations.of(context).errorNoAppToOpen);
  }
}

/// "Personal · 1.2 MB · Exp. Aug 2031".
String documentMeta(BuildContext context, AppDocument d) {
  final l10n = AppLocalizations.of(context);
  final fmt = AppFormats.of(context);
  final expiry = d.expiryDate;
  return [
    l10n.documentCategory(d.category.name),
    fmt.fileSize(d.sizeBytes),
    if (expiry != null) l10n.documentExpiryShort(fmt.monthYear(expiry)),
  ].join(' · ');
}

/// A document row: type badge, title, details, Drive status.
class DocumentTile extends StatelessWidget {
  const DocumentTile({
    required this.document,
    required this.onTap,
    super.key,
    this.trailing,
  });

  final AppDocument document;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final d = document;
    final (driveColor, driveText) = switch (d.driveStatus) {
      DriveStatus.uploaded => (
        theme.colorScheme.primary,
        l10n.driveCopyOnDrive,
      ),
      DriveStatus.failed => (theme.colorScheme.error, l10n.driveUploadFailed),
      DriveStatus.uploading => (theme.colorScheme.primary, l10n.driveUploading),
      DriveStatus.notUploaded => (
        theme.colorScheme.onSurfaceVariant,
        l10n.driveDeviceOnly,
      ),
    };
    // Own Material so the ripple shows above a decorated list background.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.rowPadding, 12, 8, 12),
          child: Row(
            spacing: 12,
            children: [
              FileTypeBadge(d.fileType),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(d.title, style: theme.textTheme.titleSmall),
                    Text(
                      documentMeta(context, d),
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      driveText,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: driveColor,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/storage/file_access.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/file_badge.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/presentation/document_view_cubit.dart';
import 'package:personal_life_manager/features/documents/presentation/document_widgets.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// One document: preview/open, details, favourite, edit and delete.
class DocumentViewPage extends StatelessWidget {
  const DocumentViewPage({
    required this.opener,
    super.key,
    this.now = DateTime.now,
  });

  final FileOpener opener;
  final DateTime Function() now;

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DocumentViewCubit>();
    final ok = await confirmDialog(
      context,
      title: l10n.deleteDocumentTitle,
      message: l10n.deleteDocumentBody,
      confirmLabel: l10n.deleteAction,
    );
    if (ok) await cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DocumentViewCubit>();
    return BlocConsumer<DocumentViewCubit, DocumentViewState>(
      listenWhen: (a, b) =>
          (b.deleted && !a.deleted) ||
          (b.failure != null && a.failure != b.failure && b.document != null),
      listener: (context, s) {
        if (s.deleted) {
          showSnack(context, l10n.documentDeletedSnack);
          AppBackButton.popOrHome(context);
        } else if (s.failure case final f?) {
          showSnack(context, f.message(l10n));
          cubit.clearFailure();
        }
      },
      builder: (context, s) {
        final d = s.document;
        final palette = context.palette;
        return Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(),
            title: Text(d?.title ?? ''),
            actions: [
              if (d != null) ...[
                IconButton(
                  tooltip: d.isFavourite
                      ? l10n.noteUnfavourite
                      : l10n.noteFavourite,
                  color: d.isFavourite ? palette.favourite : null,
                  icon: Icon(LucideIcons.star, fill: d.isFavourite ? 1 : 0),
                  onPressed: cubit.toggleFavourite,
                ),
                IconButton(
                  tooltip: l10n.editAction,
                  icon: const Icon(LucideIcons.pencil),
                  onPressed: () => context.push(DocumentRoutes.edit(d.id)),
                ),
                IconButton(
                  tooltip: l10n.deleteAction,
                  icon: const Icon(LucideIcons.trash2),
                  onPressed: s.busy ? null : () => _confirmDelete(context),
                ),
              ],
            ],
          ),
          body: switch ((s.status, d)) {
            (LoadStatus.loading, _) => const Center(
              child: CircularProgressIndicator(),
            ),
            (_, final doc?) => _Details(
              document: doc,
              state: s,
              opener: opener,
              now: now(),
            ),
            _ => EmptyState(
              icon: LucideIcons.circleAlert,
              title: s.failure?.message(l10n) ?? l10n.errorGeneric,
            ),
          },
        );
      },
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.document,
    required this.state,
    required this.opener,
    required this.now,
  });

  final AppDocument document;
  final DocumentViewState state;
  final FileOpener opener;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = AppFormats.of(context);
    final d = document;
    final file = state.file;
    final expiry = d.expiryDate;
    final days = d.daysToExpiry(now);

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.rowPadding,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        8,
        AppSpacing.gutter,
        32,
      ),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: file != null && d.fileType.isImage
              ? InkWell(
                  onTap: () => openDocumentFile(
                    context,
                    document: d,
                    file: file,
                    opener: opener,
                  ),
                  child: Image.file(
                    file,
                    height: 220,
                    fit: BoxFit.cover,
                    // Decoded at preview size, not full camera resolution.
                    cacheHeight: 660,
                    semanticLabel: l10n.previewAction,
                    errorBuilder: (_, _, _) => const SizedBox(
                      height: 120,
                      child: Icon(LucideIcons.imageOff),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    spacing: 12,
                    children: [
                      FileTypeBadge(d.fileType, width: 48),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              d.originalName,
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              fmt.fileSize(d.sizeBytes),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 10),
        if (file == null)
          NoticeBanner(
            message: l10n.documentFileMissing,
            tone: NoticeTone.warning,
          )
        else
          FilledButton.icon(
            onPressed: () => openDocumentFile(
              context,
              document: d,
              file: file,
              opener: opener,
            ),
            icon: Icon(
              d.fileType.hasInAppPreview
                  ? LucideIcons.eye
                  : LucideIcons.externalLink,
            ),
            label: Text(
              d.fileType.hasInAppPreview
                  ? l10n.previewAction
                  : l10n.openInOtherAppAction,
            ),
          ),
        const SizedBox(height: AppSpacing.section),
        GroupCard(
          children: [
            row(l10n.categoryLabel, l10n.documentCategory(d.category.name)),
            if (d.description.isNotEmpty)
              row(l10n.descriptionLabel, d.description),
            if (expiry != null)
              row(
                l10n.expiryDateLabel,
                [
                  fmt.fullDate(expiry),
                  if (days != null && days < 0)
                    l10n.documentExpired
                  else if (days != null)
                    l10n.daysLeft(days),
                  if (d.expiryReminder)
                    l10n.expiryReminderOn
                  else
                    l10n.expiryReminderOff,
                ].join(' · '),
              ),
            row(
              l10n.documentFileLabel,
              '${d.originalName} · ${fmt.fileSize(d.sizeBytes)}',
            ),
            row(l10n.documentAddedLabel, fmt.fullDate(d.createdAt)),
            row(l10n.driveLabel, switch (d.driveStatus) {
              DriveStatus.notUploaded => l10n.driveDeviceOnly,
              DriveStatus.uploading => l10n.driveUploading,
              DriveStatus.uploaded => l10n.driveCopyOnDrive,
              DriveStatus.failed => l10n.driveUploadFailed,
            }),
          ],
        ),
      ],
    );
  }
}

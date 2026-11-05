import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/button_progress.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/file_badge.dart';
import 'package:personal_life_manager/core/ui/widgets/form_page.dart';
import 'package:personal_life_manager/core/ui/widgets/pickers.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/presentation/document_form_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class DocumentFormPage extends StatelessWidget {
  const DocumentFormPage({required this.permissions, super.key});

  final NotificationPermissions permissions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DocumentFormCubit>();
    return BlocConsumer<DocumentFormCubit, DocumentFormState>(
      listenWhen: (a, b) => a.outcome != b.outcome || a.failure != b.failure,
      listener: (context, s) {
        if (s.outcome != EditorOutcome.none) {
          if (s.notificationsBlocked) {
            showNotificationsBlocked(context, permissions);
          }
          AppBackButton.popOrHome(context);
        } else if (s.failure case final f?) {
          showSnack(context, f.message(l10n));
          cubit.clearFailure();
        }
      },
      buildWhen: (a, b) => a.loading != b.loading,
      builder: (context, s) => s.loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : const _Form(),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final DocumentFormCubit _cubit = context.read<DocumentFormCubit>();
  late final _title = TextEditingController(text: _cubit.state.title);
  late final _description = TextEditingController(
    text: _cubit.state.description,
  );

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = AppFormats.of(context);
    return BlocConsumer<DocumentFormCubit, DocumentFormState>(
      // A picked file can fill in the title.
      listenWhen: (a, b) => a.title != b.title && b.title != _title.text,
      listener: (_, s) => _title.text = s.title,
      builder: (context, s) {
        final file = s.file;
        final expiry = s.expiryDate;
        return FormPage(
          title: s.isNew ? l10n.addDocumentAction : l10n.editDocumentTitle,
          dirty: s.dirty,
          saving: s.busy,
          onSave: _cubit.save,
          children: [
            if (file != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    spacing: 12,
                    children: [
                      FileTypeBadge(file.type, width: 48),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(file.name, style: theme.textTheme.titleSmall),
                            Text(
                              l10n.fileSavedOnDevice(
                                fmt.fileSize(file.sizeBytes),
                              ),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (file != null) const SizedBox(height: 10),
            Row(
              spacing: AppSpacing.gap,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: s.picking ? null : _cubit.scanWithCamera,
                    icon: const Icon(LucideIcons.camera),
                    label: Text(l10n.scanWithCamera),
                  ),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: s.picking ? null : _cubit.pickFile,
                    icon: s.picking
                        ? const ButtonProgress()
                        : const Icon(LucideIcons.folderOpen),
                    label: Text(
                      file == null
                          ? l10n.pickFromFiles
                          : l10n.replaceFileAction,
                    ),
                  ),
                ),
              ],
            ),
            if (s.showErrors && s.fileMissing)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.documentFileRequired,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            LabeledField(
              label: l10n.titleLabel,
              child: TextField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                onChanged: _cubit.titleChanged,
                decoration: InputDecoration(
                  errorText: s.showErrors && s.titleMissing
                      ? l10n.fieldRequired
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: l10n.descriptionLabel,
              optional: true,
              child: TextField(
                controller: _description,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                onChanged: _cubit.descriptionChanged,
                decoration: InputDecoration(
                  hintText: l10n.documentDescriptionHint,
                ),
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: l10n.categoryLabel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Wrap(
                    spacing: AppSpacing.gap,
                    runSpacing: AppSpacing.gap,
                    children: [
                      for (final c in DocumentCategory.values)
                        ChoiceChip(
                          label: Text(l10n.documentCategory(c.name)),
                          selected: s.category == c,
                          onSelected: (_) => _cubit.categoryChanged(c),
                        ),
                    ],
                  ),
                  if (s.showErrors && s.categoryMissing)
                    Text(
                      l10n.fieldRequired,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PickerField(
              label: l10n.expiryDateLabel,
              optional: true,
              hint: l10n.pickDateHint,
              icon: LucideIcons.calendar,
              value: expiry == null ? null : fmt.fullDate(expiry),
              onTap: () async {
                final d = await pickDate(context, initial: expiry);
                if (d != null) _cubit.expiryChanged(d);
              },
              onClear: () => _cubit.expiryChanged(null),
            ),
            const SizedBox(height: 14),
            Card(
              child: Column(
                children: [
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: s.isFavourite,
                    onChanged: (v) =>
                        _cubit.favouriteChanged(value: v ?? false),
                    title: Text(
                      l10n.markFavourite,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  if (expiry != null) ...[
                    const Divider(),
                    SwitchListTile(
                      value: s.expiryReminder,
                      onChanged: (v) => _cubit.expiryReminderChanged(value: v),
                      title: Text(
                        l10n.expiryReminderLabel,
                        style: theme.textTheme.titleSmall,
                      ),
                      subtitle: Text(l10n.expiryReminderHelp),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

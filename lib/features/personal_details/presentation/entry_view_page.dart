import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/security/sensitive_clipboard.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/value_row.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/presentation/document_widgets.dart';
import 'package:personal_life_manager/features/documents/presentation/linked_documents.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';
import 'package:personal_life_manager/features/personal_details/presentation/detail_text.dart';
import 'package:personal_life_manager/features/personal_details/presentation/entry_view_cubit.dart';
import 'package:personal_life_manager/features/personal_details/presentation/personal_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// One entry in full: every field with copy (and reveal for ID numbers),
/// plus edit and delete.
class EntryViewPage extends StatelessWidget {
  const EntryViewPage({required this.clipboard, super.key});

  final SensitiveClipboard clipboard;

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<EntryViewCubit>();
    final ok = await confirmDialog(
      context,
      title: l10n.deleteEntryTitle,
      message: l10n.cannotUndoBody,
      confirmLabel: l10n.deleteAction,
    );
    if (ok) await cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<EntryViewCubit, EntryViewState>(
      // Linked documents follow the entry (also after an edit).
      listenWhen: (a, b) =>
          a.entry?.linkedDocumentIds != b.entry?.linkedDocumentIds,
      listener: (context, s) => context.read<LinkedDocumentsCubit>().setIds(
        s.entry?.linkedDocumentIds ?? const [],
      ),
      child: BlocConsumer<EntryViewCubit, EntryViewState>(
        listenWhen: (a, b) =>
            (b.deleted && !a.deleted) ||
            (b.failure != null && a.failure != b.failure && b.entry != null),
        listener: (context, s) {
          if (s.deleted) {
            showSnack(context, l10n.entryDeletedSnack);
            AppBackButton.popOrHome(context);
          } else if (s.failure case final f?) {
            showSnack(context, f.message(l10n));
          }
        },
        builder: (context, s) {
          final entry = s.entry;
          return Scaffold(
            appBar: AppBar(
              leading: const AppBackButton(),
              title: Text(entry == null ? '' : l10n.entryName(entry)),
              actions: [
                if (entry != null) ...[
                  IconButton(
                    tooltip: l10n.editAction,
                    icon: const Icon(LucideIcons.pencil),
                    onPressed: () =>
                        context.push(PersonalRoutes.edit(entry.id)),
                  ),
                  IconButton(
                    tooltip: l10n.deleteAction,
                    icon: const Icon(LucideIcons.trash2),
                    onPressed: s.busy ? null : () => _confirmDelete(context),
                  ),
                ],
              ],
            ),
            body: switch ((s.status, entry)) {
              (LoadStatus.loading, _) => const Center(
                child: CircularProgressIndicator(),
              ),
              (_, final e?) => _Fields(entry: e, clipboard: clipboard),
              _ => EmptyState(
                icon: LucideIcons.circleAlert,
                title: s.failure?.message(l10n) ?? l10n.errorGeneric,
              ),
            },
          );
        },
      ),
    );
  }
}

class _Fields extends StatelessWidget {
  const _Fields({required this.entry, required this.clipboard});

  final PersonalEntry entry;
  final SensitiveClipboard clipboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = AppFormats.of(context);
    final fields = entry.fields.where((f) => f.value.isNotEmpty).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        8,
        AppSpacing.gutter,
        32,
      ),
      children: [
        SectionLabel(l10n.detailKind(entry.kind.name)),
        if (fields.isEmpty)
          EmptyState(icon: LucideIcons.inbox, title: l10n.personalTabEmpty)
        else
          GroupCard(
            children: [
              for (final f in fields)
                ValueRow(
                  label: l10n.fieldLabel(f),
                  value: displayValue(fmt, entry.kind, f),
                  masked: f.sensitive ? maskValue(f.value) : null,
                  monospace: f.sensitive,
                  onCopy: () => copyValue(
                    context,
                    clipboard,
                    label: l10n.fieldLabel(f),
                    value: f.value,
                    sensitive: f.sensitive,
                  ),
                ),
            ],
          ),
        BlocBuilder<LinkedDocumentsCubit, List<AppDocument>>(
          builder: (context, docs) => docs.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.section),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionLabel(l10n.linkedDocumentsLabel),
                      GroupCard(
                        children: [
                          for (final d in docs)
                            DocumentTile(
                              document: d,
                              onTap: () =>
                                  context.push(DocumentRoutes.view(d.id)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

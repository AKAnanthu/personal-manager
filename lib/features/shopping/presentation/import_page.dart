import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/button_progress.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/shopping/presentation/import_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/list_editor_page.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_routes.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Import from message: paste → review → saved list (opened for editing).
/// Only text the user pastes here is read.
class ImportPage extends StatefulWidget {
  const ImportPage({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final _manual = TextEditingController();

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text ?? '';
    if (text.trim().isEmpty) {
      showSnack(context, AppLocalizations.of(context).shoppingClipboardEmpty);
      return;
    }
    context.read<ImportCubit>().textPasted(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ImportCubit>();
    return BlocConsumer<ImportCubit, ImportState>(
      listenWhen: (a, b) =>
          a.savedListId != b.savedListId || a.failure != b.failure,
      listener: (context, s) {
        if (s.savedListId case final id?) {
          context.pushReplacement(ShoppingRoutes.edit(id));
        } else if (s.failure case final f?) {
          showSnack(context, f.message(l10n));
        }
      },
      builder: (context, s) => Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(icon: LucideIcons.x),
          title: Text(l10n.shoppingImportTitle),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              8,
              AppSpacing.gutter,
              32,
            ),
            children: [
              if (!s.parsed) ...[
                FilledButton.icon(
                  onPressed: _paste,
                  icon: const Icon(LucideIcons.clipboardPaste),
                  label: Text(l10n.shoppingPasteMessage),
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: l10n.shoppingOrTypeHere,
                  child: TextField(
                    controller: _manual,
                    minLines: 5,
                    maxLines: 12,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: l10n.shoppingMessageExample,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => cubit.textPasted(_manual.text),
                  child: Text(l10n.shoppingReviewAction),
                ),
              ] else
                ..._review(context, s),
              const SizedBox(height: 16),
              Text(
                l10n.shoppingPrivacyNote,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _review(BuildContext context, ImportState s) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<ImportCubit>();
    final palette = context.palette;
    return [
      Row(
        children: [
          Expanded(child: SectionLabel(l10n.shoppingPastedMessage)),
          TextButton.icon(
            onPressed: _paste,
            icon: const Icon(LucideIcons.clipboardPaste, size: 18),
            label: Text(l10n.shoppingPasteAgain),
          ),
        ],
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            s.text.trim(),
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.section),
      SectionLabel(l10n.shoppingReviewCount(s.rows.length)),
      if (s.rows.isEmpty)
        EmptyState(icon: LucideIcons.listX, title: l10n.shoppingNothingFound),
      for (final g in s.duplicates)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.gap),
          child: Row(
            children: [
              Expanded(
                child: NoticeBanner(
                  message: g.mergeable
                      ? l10n.shoppingDuplicate(g.name, g.keys.length)
                      : l10n.shoppingDuplicateNoMerge(g.name, g.keys.length),
                ),
              ),
              if (g.mergeable)
                TextButton(
                  onPressed: () => cubit.merge(g),
                  child: Text(l10n.shoppingMergeAction),
                ),
            ],
          ),
        ),
      for (final r in s.rows) ...[
        ItemRowFields(
          key: ValueKey(r.key),
          name: r.name,
          quantity: r.quantity,
          unit: r.unit,
          highlight: !r.ready,
          quantityHint: '?',
          onChanged: ({name, quantity, unit}) => cubit.rowChanged(
            r.key,
            name: name,
            quantity: quantity,
            unit: unit,
          ),
          onRemove: () => cubit.removeRow(r.key),
        ),
        if (!r.ready)
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 4),
            child: Text(
              r.name.trim().isEmpty
                  ? l10n.shoppingNameMissing
                  : r.quantity.trim().isEmpty
                  ? l10n.shoppingNoQuantityFound
                  : l10n.shoppingQuantityInvalid,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.warningText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
      const SizedBox(height: 12),
      FilledButton(
        onPressed: s.canImport && !s.busy
            ? () => cubit.confirm(
                listName: l10n.shoppingDefaultListName(
                  AppFormats.of(context).shortDate(widget.now()),
                ),
              )
            : null,
        child: s.busy
            ? const ButtonProgress()
            : Text(
                s.canImport
                    ? l10n.shoppingImportItems(s.rows.length)
                    : l10n.shoppingConfirmToImport(s.unresolved),
              ),
      ),
    ];
  }
}

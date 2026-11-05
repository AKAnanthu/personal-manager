import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/security/secure_screen.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/file_badge.dart';
import 'package:personal_life_manager/core/ui/widgets/image_viewer_page.dart';
import 'package:personal_life_manager/core/ui/widgets/pdf_viewer_page.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/core/utils/money.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/presentation/history_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_routes.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// A completed list: what was bought, the total, receipt; reuse, edit,
/// delete.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<HistoryCubit>();
    final choice = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.shoppingDeleteListTitle),
        content: Text(l10n.shoppingDeleteListBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.shoppingDeleteKeepExpense),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.shoppingDeleteWithExpense),
          ),
        ],
      ),
    );
    if (choice != null) await cubit.delete(deleteExpense: choice);
  }

  Future<void> _openReceipt(BuildContext context, ShoppingList list) async {
    final l10n = AppLocalizations.of(context);
    final receipt = list.receipt;
    if (receipt == null) return;
    final r = await context.read<HistoryCubit>().receiptFile(receipt);
    if (!context.mounted) return;
    switch (r) {
      case Err(:final failure):
        showSnack(context, failure.message(l10n));
      case Ok(value: final file):
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SecureScreen(
              child: receipt.fileType.isImage
                  ? ImageViewerPage(file: file, title: l10n.shoppingReceipt)
                  : PdfViewerPage(file: file, title: l10n.shoppingReceipt),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<HistoryCubit, HistoryState>(
      listenWhen: (a, b) =>
          (b.deleted && !a.deleted) ||
          (b.failure != null && a.failure != b.failure && b.list != null),
      listener: (context, s) {
        if (s.deleted) {
          showSnack(context, l10n.shoppingListDeleted);
          AppBackButton.popOrHome(context);
        } else if (s.failure case final f?) {
          showSnack(context, f.message(l10n));
        }
      },
      builder: (context, s) {
        final list = s.list;
        return Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(),
            title: Text(list?.name ?? ''),
            actions: [
              if (list != null) ...[
                IconButton(
                  tooltip: l10n.editAction,
                  icon: const Icon(LucideIcons.pencil),
                  onPressed: () =>
                      context.push(ShoppingRoutes.historyEdit(list.id)),
                ),
                IconButton(
                  tooltip: l10n.deleteAction,
                  icon: const Icon(LucideIcons.trash2),
                  onPressed: () => _delete(context),
                ),
              ],
            ],
          ),
          body: s.loading
              ? const Center(child: CircularProgressIndicator())
              : list == null
              ? EmptyState(
                  icon: LucideIcons.circleAlert,
                  title: l10n.errorNotFound,
                )
              : _Details(
                  list: list,
                  onReceipt: () => _openReceipt(context, list),
                ),
        );
      },
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.list, required this.onReceipt});

  final ShoppingList list;
  final VoidCallback onReceipt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = AppFormats.of(context);
    final total = list.totalPaise;
    final date = list.purchasedOn;
    final payment = list.paymentMethod;
    final receipt = list.receipt;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        8,
        AppSpacing.gutter,
        32,
      ),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                if (total != null)
                  Text(
                    Money.format(total),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                Text(
                  [
                    if (date != null) fmt.fullDate(date),
                    if (list.store.isNotEmpty) list.store,
                    if (payment != null) l10n.paymentMethod(payment.name),
                  ].join(' · '),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        if (receipt != null) ...[
          const SizedBox(height: 10),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: FileTypeBadge(receipt.fileType, width: 32),
              title: Text(l10n.shoppingReceipt),
              subtitle: Text(receipt.originalName),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: onReceipt,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.section),
        SectionLabel(
          l10n.shoppingProgress(list.purchasedCount, list.items.length),
        ),
        GroupCard(
          children: [
            for (final i in list.items)
              ListTile(
                leading: Icon(
                  i.isPurchased
                      ? LucideIcons.squareCheckBig
                      : LucideIcons.square,
                  color: i.isPurchased
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  semanticLabel: i.isPurchased
                      ? l10n.shoppingBought
                      : l10n.shoppingNotBought,
                ),
                title: Text(i.name),
                trailing: Text(i.amountLabel),
              ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () => context.push(ShoppingRoutes.copy(list.id)),
          icon: const Icon(LucideIcons.copy),
          label: Text(l10n.shoppingReuseList),
        ),
      ],
    );
  }
}

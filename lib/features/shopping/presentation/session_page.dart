import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_parser.dart';
import 'package:personal_life_manager/features/shopping/presentation/session_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_routes.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

enum _LeaveChoice { continueLater, finish }

/// The in-store screen: big rows to tick off, usable one-handed.
class SessionPage extends StatelessWidget {
  const SessionPage({super.key});

  Future<void> _leave(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SessionCubit>();
    final list = cubit.state.list;
    if (list == null) {
      AppBackButton.popOrHome(context);
      return;
    }
    final pending = list.pending.length;
    final choice = await showDialog<_LeaveChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          pending == 0
              ? l10n.shoppingAllPickedTitle
              : l10n.shoppingLeaveTitle(pending),
        ),
        content: Text(
          pending == 0 ? l10n.shoppingAllPickedBody : l10n.shoppingLeaveBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.shoppingKeepShopping),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_LeaveChoice.continueLater),
            child: Text(l10n.shoppingContinueLater),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_LeaveChoice.finish),
            child: Text(l10n.shoppingFinishAction),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case _LeaveChoice.continueLater:
        await cubit.continueLater();
      case _LeaveChoice.finish:
        await context.push(ShoppingRoutes.finish(list.id));
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<SessionCubit, SessionState>(
      listenWhen: (a, b) =>
          (b.paused && !a.paused) ||
          (b.failure != null && a.failure != b.failure),
      listener: (context, s) {
        if (s.paused) {
          final left = s.list?.pending.length ?? 0;
          if (left > 0) showSnack(context, l10n.shoppingPausedSnack(left));
          context.go(ShoppingRoutes.root);
        } else if (s.failure case final f?) {
          showSnack(context, f.message(l10n));
        }
      },
      builder: (context, s) {
        final list = s.list;
        return PopScope(
          canPop: list == null,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) unawaited(_leave(context));
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () => _leave(context),
              ),
              title: Text(list?.name ?? l10n.navShopping),
            ),
            body: s.loading
                ? const Center(child: CircularProgressIndicator())
                : list == null
                ? EmptyState(
                    icon: LucideIcons.shoppingCart,
                    title: l10n.shoppingNoSession,
                  )
                : _Items(list: list),
            bottomNavigationBar: list == null
                ? null
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.gutter,
                        8,
                        AppSpacing.gutter,
                        12,
                      ),
                      child: Row(
                        spacing: AppSpacing.gap,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: context
                                  .read<SessionCubit>()
                                  .continueLater,
                              child: Text(l10n.shoppingContinueLater),
                            ),
                          ),
                          Expanded(
                            child: FilledButton(
                              onPressed: () =>
                                  context.push(ShoppingRoutes.finish(list.id)),
                              child: Text(l10n.shoppingFinishShopping),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _Items extends StatelessWidget {
  const _Items({required this.list});

  final ShoppingList list;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<SessionCubit>();
    final pending = list.pending;
    final done = list.items.where((i) => i.isPurchased).toList();
    final total = list.items.length;

    Widget label(String text) => SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.section,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(child: SectionLabel(text)),
    );

    Widget items(List<ShoppingItem> items) => SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.gap),
        itemBuilder: (context, i) => _ItemTile(item: items[i]),
      ),
    );

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            4,
            AppSpacing.gutter,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Text(
                  l10n.shoppingProgressShort(list.purchasedCount, total),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : list.purchasedCount / total,
                    minHeight: 8,
                    semanticsLabel: l10n.shoppingProgress(
                      list.purchasedCount,
                      total,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (pending.isNotEmpty) ...[
          label(l10n.shoppingToPick(pending.length)),
          items(pending),
        ],
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.gap,
            AppSpacing.gutter,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: OutlinedButton.icon(
              onPressed: () async {
                final r = await _showItemDialog(context);
                if (r case _Saved(:final item)) await cubit.addItem(item);
              },
              icon: const Icon(LucideIcons.plus),
              label: Text(l10n.shoppingAddItemAction),
            ),
          ),
        ),
        if (done.isNotEmpty) ...[
          label(l10n.shoppingInCart(done.length)),
          items(done),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});

  final ShoppingItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final cubit = context.read<SessionCubit>();
    final done = item.isPurchased;
    return Semantics(
      button: true,
      checked: done,
      label: item.amountLabel.isEmpty
          ? item.name
          : '${item.name}, ${item.amountLabel}',
      onLongPressHint: l10n.editAction,
      excludeSemantics: true,
      child: Material(
        color: done
            ? palette.mutedTile
            : theme.colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: palette.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => cubit.toggle(item),
          onLongPress: () async {
            final r = await _showItemDialog(context, initial: item);
            switch (r) {
              case _Saved(item: final edited):
                await cubit.updateItem(item.id, edited);
              case _Deleted():
                await cubit.removeItem(item.id);
              case null:
                break;
            }
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                spacing: 14,
                children: [
                  Icon(
                    done ? LucideIcons.squareCheckBig : LucideIcons.square,
                    size: 30,
                    color: done
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  Expanded(
                    child: Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done ? theme.colorScheme.onSurfaceVariant : null,
                      ),
                    ),
                  ),
                  if (item.amountLabel.isNotEmpty)
                    Text(
                      item.amountLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

sealed class _ItemDialogResult {
  const _ItemDialogResult();
}

final class _Saved extends _ItemDialogResult {
  const _Saved(this.item);
  final ItemDraft item;
}

final class _Deleted extends _ItemDialogResult {
  const _Deleted();
}

/// Add (no [initial]) or edit an item during shopping.
Future<_ItemDialogResult?> _showItemDialog(
  BuildContext context, {
  ShoppingItem? initial,
}) => showDialog<_ItemDialogResult>(
  context: context,
  builder: (_) => _ItemDialog(initial: initial),
);

class _ItemDialog extends StatefulWidget {
  const _ItemDialog({this.initial});

  final ShoppingItem? initial;

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _qty = TextEditingController(text: widget.initial?.quantity);
  late final _unit = TextEditingController(text: widget.initial?.unit);
  bool _showErrors = false;

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    _unit.dispose();
    super.dispose();
  }

  bool get _qtyInvalid =>
      _qty.text.trim().isNotEmpty &&
      ShoppingParser.quantityValue(_qty.text) == null;

  void _save() {
    if (_name.text.trim().isEmpty || _qtyInvalid) {
      setState(() => _showErrors = true);
      return;
    }
    Navigator.of(context).pop(
      _Saved(
        ItemDraft(
          name: _name.text,
          quantity: ShoppingParser.normaliseQuantity(_qty.text) ?? '',
          unit: _unit.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editing = widget.initial != null;
    return AlertDialog(
      title: Text(editing ? l10n.shoppingEditItem : l10n.shoppingAddItemAction),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          TextField(
            controller: _name,
            autofocus: !editing,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.shoppingItemNameLabel,
              errorText: _showErrors && _name.text.trim().isEmpty
                  ? l10n.fieldRequired
                  : null,
            ),
          ),
          Row(
            spacing: AppSpacing.gap,
            children: [
              Expanded(
                child: TextField(
                  controller: _qty,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.shoppingQtyHeader,
                    errorText: _showErrors && _qtyInvalid
                        ? l10n.shoppingQuantityInvalid
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _unit,
                  decoration: InputDecoration(
                    labelText: l10n.shoppingUnitHeader,
                  ),
                  onSubmitted: (_) => _save(),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (editing)
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(const _Deleted()),
            child: Text(l10n.removeAction),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.saveAction)),
      ],
    );
  }
}

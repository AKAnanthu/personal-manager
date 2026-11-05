import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/form_page.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/shopping/presentation/list_editor_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_routes.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class ListEditorPage extends StatelessWidget {
  const ListEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ListEditorCubit>();
    return BlocConsumer<ListEditorCubit, ListEditorState>(
      listenWhen: (a, b) => a.outcome != b.outcome || a.failure != b.failure,
      listener: (context, s) {
        switch (s.outcome) {
          case ListEditorOutcome.started:
            context.pushReplacement(ShoppingRoutes.session);
          case ListEditorOutcome.saved:
            showSnack(context, l10n.shoppingSavedSnack);
            AppBackButton.popOrHome(context);
          case ListEditorOutcome.none:
            if (s.failure is ConflictFailure) {
              cubit.clearFailure();
              unawaited(showSessionInProgress(context));
            } else if (s.failure case final f?) {
              showSnack(context, f.message(l10n));
              cubit.clearFailure();
            }
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
  late final ListEditorCubit _cubit = context.read<ListEditorCubit>();
  late final _name = TextEditingController(text: _cubit.state.name);
  final _draft = TextEditingController();
  final _draftQty = TextEditingController();
  final _draftFocus = FocusNode();

  @override
  void dispose() {
    _name.dispose();
    _draft.dispose();
    _draftQty.dispose();
    _draftFocus.dispose();
    super.dispose();
  }

  void _add() {
    _cubit.addFromInput(_draft.text, quantity: _draftQty.text);
    _draft.clear();
    _draftQty.clear();
    _draftFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<ListEditorCubit, ListEditorState>(
      builder: (context, s) {
        final copied = s.copiedFrom;
        final copiedDate = copied?.purchasedOn ?? copied?.updatedAt;
        return FormPage(
          title: s.listId == null
              ? l10n.shoppingNewList
              : l10n.shoppingEditList,
          dirty: s.dirty,
          saving: s.busy,
          onSave: _cubit.saveForLater,
          children: [
            LabeledField(
              label: l10n.shoppingListName,
              child: TextField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                onChanged: _cubit.nameChanged,
                decoration: InputDecoration(
                  errorText: s.showErrors && s.nameMissing
                      ? l10n.fieldRequired
                      : null,
                ),
              ),
            ),
            if (copiedDate != null) ...[
              const SizedBox(height: 10),
              NoticeBanner(
                message: l10n.shoppingCopiedFrom(
                  AppFormats.of(context).shortDate(copiedDate),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.section),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                spacing: AppSpacing.gap,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      l10n.shoppingItemsHeader(s.filledRows.length),
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      l10n.shoppingQtyHeader,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      l10n.shoppingUnitHeader,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            for (final r in s.rows)
              ItemRowFields(
                key: ValueKey(r.key),
                name: r.name,
                quantity: r.quantity,
                unit: r.unit,
                quantityError: s.showErrors && r.quantityInvalid,
                onChanged: ({name, quantity, unit}) => _cubit.rowChanged(
                  r.key,
                  name: name,
                  quantity: quantity,
                  unit: unit,
                ),
                onRemove: () => _cubit.removeRow(r.key),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.gap,
              children: [
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: _draft,
                    focusNode: _draftFocus,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _add(),
                    decoration: InputDecoration(
                      hintText: l10n.shoppingAddItemHint,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _draftQty,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onSubmitted: (_) => _add(),
                    decoration: InputDecoration(hintText: l10n.shoppingQtyHint),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: l10n.shoppingAddItemTooltip,
                  icon: const Icon(LucideIcons.plus),
                  onPressed: _add,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                s.showErrors && s.itemsMissing
                    ? l10n.shoppingNoItemsError
                    : l10n.shoppingPasteTip,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: s.showErrors && s.itemsMissing
                      ? theme.colorScheme.error
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: s.busy ? null : _cubit.startShopping,
              icon: const Icon(LucideIcons.shoppingCart),
              label: Text(l10n.shoppingStartShopping),
            ),
          ],
        );
      },
    );
  }
}

typedef RowChanged = void Function({
  String? name,
  String? quantity,
  String? unit,
});

/// Name / quantity / unit fields for one item, with remove.
class ItemRowFields extends StatefulWidget {
  const ItemRowFields({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.onChanged,
    required this.onRemove,
    super.key,
    this.quantityError = false,
    this.highlight = false,
    this.quantityHint,
  });

  final String name;
  final String quantity;
  final String unit;
  final RowChanged onChanged;
  final VoidCallback onRemove;
  final bool quantityError;

  /// Draws attention to the quantity (import review).
  final bool highlight;
  final String? quantityHint;

  @override
  State<ItemRowFields> createState() => _ItemRowFieldsState();
}

class _ItemRowFieldsState extends State<ItemRowFields> {
  late final _name = TextEditingController(text: widget.name);
  late final _qty = TextEditingController(text: widget.quantity);
  late final _unit = TextEditingController(text: widget.unit);

  @override
  void didUpdateWidget(ItemRowFields old) {
    super.didUpdateWidget(old);
    // Merging duplicates changes the quantity from outside.
    if (widget.quantity != _qty.text && widget.quantity != old.quantity) {
      _qty.text = widget.quantity;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    _unit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final attention = widget.highlight || widget.quantityError;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.gap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.gap,
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (v) => widget.onChanged(name: v),
              decoration: InputDecoration(
                isDense: true,
                hintText: l10n.shoppingItemNameLabel,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Semantics(
              label: attention
                  ? l10n.shoppingQuantityRequired
                  : l10n.shoppingQtyHeader,
              child: TextField(
                controller: _qty,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) => widget.onChanged(quantity: v),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.quantityHint ?? '—',
                  enabledBorder: attention
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.control),
                          borderSide: BorderSide(color: scheme.error, width: 2),
                        )
                      : null,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _unit,
              onChanged: (v) => widget.onChanged(unit: v),
              decoration: const InputDecoration(isDense: true, hintText: '—'),
            ),
          ),
          IconButton(
            tooltip: l10n.shoppingRemoveItem(widget.name),
            icon: const Icon(LucideIcons.x),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}

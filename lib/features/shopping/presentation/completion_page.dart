import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/file_badge.dart';
import 'package:personal_life_manager/core/ui/widgets/form_page.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/ui/widgets/pickers.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/core/utils/money.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/presentation/completion_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_routes.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// "Finish shopping" (or edit a purchase in history).
class CompletionPage extends StatelessWidget {
  const CompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<CompletionCubit>();
    return BlocConsumer<CompletionCubit, CompletionState>(
      listenWhen: (a, b) => a.outcome != b.outcome || a.failure != b.failure,
      listener: (context, s) {
        if (s.outcome == EditorOutcome.saved) {
          if (s.editing) {
            AppBackButton.popOrHome(context);
          } else {
            showSnack(context, l10n.shoppingSavedToHistory);
            context.go(ShoppingRoutes.root);
          }
        } else if (s.failure case final f?) {
          showSnack(context, f.message(l10n));
          cubit.clearFailure();
        }
      },
      buildWhen: (a, b) => a.loading != b.loading || a.list != b.list,
      builder: (context, s) => s.loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : s.list == null
          ? Scaffold(
              appBar: AppBar(leading: const AppBackButton()),
              body: EmptyState(
                icon: LucideIcons.circleAlert,
                title: l10n.errorNotFound,
              ),
            )
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
  late final CompletionCubit _cubit = context.read<CompletionCubit>();
  late final _total = TextEditingController(text: _cubit.state.totalText);
  late final _store = TextEditingController(text: _cubit.state.store);

  @override
  void dispose() {
    _total.dispose();
    _store.dispose();
    super.dispose();
  }

  Future<void> _photo() async {
    final l10n = AppLocalizations.of(context);
    final camera = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: Text(l10n.attachTakePhoto),
              onTap: () => Navigator.of(context).pop(true),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: Text(l10n.attachChoosePhoto),
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
    if (camera == null) return;
    await (camera ? _cubit.takePhoto() : _cubit.choosePhoto());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = AppFormats.of(context);
    return BlocBuilder<CompletionCubit, CompletionState>(
      builder: (context, s) {
        final list = s.list;
        if (list == null) return const SizedBox.shrink();
        final date = s.purchasedOn;
        final receipt = s.receipt;
        final total = list.items.length;
        final picked = list.purchasedCount;
        return FormPage(
          title: s.editing
              ? l10n.shoppingEditPurchase
              : l10n.shoppingFinishShopping,
          dirty: s.dirty,
          saving: s.busy,
          onSave: _cubit.save,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  spacing: 12,
                  children: [
                    Icon(
                      picked == total
                          ? LucideIcons.circleCheck
                          : LucideIcons.circleDashed,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            picked == total
                                ? l10n.shoppingAllItemsPicked(total)
                                : l10n.shoppingSomeItemsPicked(picked, total),
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            [
                              list.name,
                              if (date != null) fmt.weekdayDate(date),
                            ].join(' · '),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            LabeledField(
              label: l10n.shoppingTotalAmount,
              child: TextField(
                controller: _total,
                autofocus: !s.editing,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                ],
                style: theme.textTheme.headlineSmall,
                onChanged: _cubit.totalChanged,
                decoration: InputDecoration(
                  prefixText: '${Money.currencySymbol} ',
                  errorText: s.showErrors && s.totalPaise == null
                      ? l10n.shoppingTotalRequired
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: l10n.shoppingStore,
              optional: true,
              child: TextField(
                controller: _store,
                textCapitalization: TextCapitalization.words,
                onChanged: _cubit.storeChanged,
                decoration: InputDecoration(hintText: l10n.shoppingStoreHint),
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: l10n.shoppingPaidWith,
              optional: true,
              child: Wrap(
                spacing: AppSpacing.gap,
                runSpacing: AppSpacing.gap,
                children: [
                  for (final m in PaymentMethod.values)
                    ChoiceChip(
                      label: Text(l10n.paymentMethod(m.name)),
                      selected: s.payment == m,
                      onSelected: (_) => _cubit.paymentToggled(m),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PickerField(
              label: l10n.dateLabel,
              hint: l10n.pickDateHint,
              icon: LucideIcons.calendar,
              value: date == null ? null : fmt.fullDate(date),
              onTap: () async {
                final d = await pickDate(context, initial: date);
                if (d != null) _cubit.dateChanged(d);
              },
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: l10n.shoppingReceipt,
              optional: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  if (receipt != null)
                    Card(
                      child: ListTile(
                        leading: FileTypeBadge(receipt.type, width: 32),
                        title: Text(receipt.name),
                        trailing: IconButton(
                          tooltip: l10n.removeAttachmentTooltip(receipt.name),
                          icon: const Icon(LucideIcons.x),
                          onPressed: _cubit.removeReceipt,
                        ),
                      ),
                    ),
                  Row(
                    spacing: AppSpacing.gap,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: s.picking ? null : _photo,
                          icon: const Icon(LucideIcons.camera),
                          label: Text(l10n.shoppingReceiptPhoto),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: s.picking ? null : _cubit.chooseFile,
                          icon: const Icon(LucideIcons.fileText),
                          label: Text(l10n.shoppingReceiptPdf),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            NoticeBanner(message: l10n.shoppingBudgetNote),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: s.busy ? null : _cubit.save,
              child: Text(
                s.editing ? l10n.saveAction : l10n.shoppingSaveToHistory,
              ),
            ),
          ],
        );
      },
    );
  }
}

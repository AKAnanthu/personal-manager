import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/amount_field.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/form_page.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/ui/widgets/pickers.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/core/utils/money.dart';
import 'package:personal_life_manager/features/budget/presentation/expense_form_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class ExpenseFormPage extends StatelessWidget {
  const ExpenseFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ExpenseFormCubit>();
    return BlocConsumer<ExpenseFormCubit, ExpenseFormState>(
      listenWhen: (a, b) => a.outcome != b.outcome || a.failure != b.failure,
      listener: (context, s) {
        if (s.outcome != EditorOutcome.none) {
          if (s.outcome == EditorOutcome.deleted) {
            showSnack(context, l10n.expenseDeletedSnack);
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
  late final ExpenseFormCubit _cubit = context.read<ExpenseFormCubit>();
  late final _amount = TextEditingController(text: _cubit.state.amountText);
  late final _description = TextEditingController(
    text: _cubit.state.description,
  );

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l10n.deleteExpenseTitle,
      message: l10n.cannotUndoBody,
      confirmLabel: l10n.deleteAction,
    );
    if (ok) await _cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = AppFormats.of(context);
    return BlocBuilder<ExpenseFormCubit, ExpenseFormState>(
      builder: (context, s) {
        final date = s.spentOn;
        final leaves = s.leaves;
        final budget = s.month?.budgetPaise;
        return FormPage(
          title: s.isNew ? l10n.addExpenseAction : l10n.editExpenseTitle,
          dirty: s.dirty,
          saving: s.busy,
          onSave: _cubit.save,
          actions: [
            if (!s.isNew)
              IconButton(
                tooltip: l10n.deleteAction,
                icon: const Icon(LucideIcons.trash2),
                onPressed: _confirmDelete,
              ),
          ],
          children: [
            LabeledField(
              label: l10n.amountLabel,
              child: AmountField(
                controller: _amount,
                autofocus: s.isNew,
                large: true,
                onChanged: _cubit.amountChanged,
                errorText: s.showErrors && s.amountPaise == null
                    ? l10n.amountRequired
                    : null,
              ),
            ),
            if (leaves != null && budget != null && s.amountPaise != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  leaves < 0
                      ? l10n.expenseGoesOver(
                          Money.format(-leaves),
                          Money.format(budget),
                        )
                      : l10n.expenseLeaves(
                          Money.format(leaves),
                          Money.format(budget),
                        ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: leaves < 0 ? theme.colorScheme.error : null,
                  ),
                ),
              ),
            const SizedBox(height: 14),
            LabeledField(
              label: l10n.descriptionLabel,
              optional: true,
              child: TextField(
                controller: _description,
                textCapitalization: TextCapitalization.sentences,
                onChanged: _cubit.descriptionChanged,
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
            const SizedBox(height: AppSpacing.section),
            NoticeBanner(message: l10n.expenseShoppingNote),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: s.busy ? null : _cubit.save,
              child: Text(l10n.saveExpenseAction),
            ),
          ],
        );
      },
    );
  }
}

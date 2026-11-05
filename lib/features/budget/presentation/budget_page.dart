import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/amount_field.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/core/utils/money.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';
import 'package:personal_life_manager/features/budget/presentation/budget_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

abstract final class BudgetRoutes {
  static const root = '/budget';
  static const add = '/budget/expenses/new';
  static String edit(String id) => '/budget/expenses/$id';
}

/// Total budget, total spent, remaining, and the month's expenses. Nothing
/// more (no categories or charts), and never shown on the dashboard.
class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<BudgetCubit>();
    return BlocListener<BudgetCubit, BudgetState>(
      listenWhen: (a, b) =>
          (b.failure != null && a.failure != b.failure) ||
          (b.deleted != null && a.deleted != b.deleted),
      listener: (context, s) {
        if (s.failure case final f?) {
          showSnack(context, f.message(l10n));
        } else if (s.deleted != null) {
          showSnack(
            context,
            l10n.expenseDeletedSnack,
            actionLabel: l10n.undoAction,
            onAction: cubit.undoDelete,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text(l10n.moduleName('budget')),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(BudgetRoutes.add),
          icon: const Icon(LucideIcons.plus),
          label: Text(l10n.addExpenseAction),
        ),
        body: BlocBuilder<BudgetCubit, BudgetState>(
          builder: (context, s) => _Body(state: s),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final BudgetState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<BudgetCubit>();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final summary = state.loading ? null : state.summary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        96,
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: l10n.previousMonth,
              icon: const Icon(LucideIcons.chevronLeft),
              onPressed: cubit.previousMonth,
            ),
            Flexible(
              child: Text(
                DateFormat.yMMMM(locale).format(state.month.first),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: l10n.nextMonth,
              icon: const Icon(LucideIcons.chevronRight),
              onPressed: state.isCurrentMonth ? null : cubit.nextMonth,
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (summary == null)
          const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          _SummaryCard(summary: summary),
          const SizedBox(height: AppSpacing.section),
          SectionLabel(l10n.expensesLabel),
          if (summary.expenses.isEmpty)
            EmptyState(
              icon: LucideIcons.receipt,
              title: l10n.expensesEmpty,
              message: l10n.expensesEmptyBody,
            )
          else
            GroupCard(
              children: [
                for (final e in summary.expenses) _ExpenseRow(expense: e),
              ],
            ),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final cubit = context.read<BudgetCubit>();
    final budget = summary.budgetPaise;
    final remaining = summary.remainingPaise;
    final on = palette.onHeroCard;
    final over = remaining != null && remaining < 0;

    Future<void> editBudget() async {
      final v = await askAmount(
        context,
        title: l10n.monthlyBudgetTitle,
        initialPaise: budget,
      );
      if (v != null) await cubit.setBudget(v);
    }

    Widget figure(String label, String value, {Widget? trailing}) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: on.withValues(alpha: 0.8),
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: on,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.heroCard,
        borderRadius: BorderRadius.circular(AppRadii.hero),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          if (remaining == null) ...[
            Text(
              l10n.budgetNotSet,
              style: theme.textTheme.titleMedium?.copyWith(color: on),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: on,
                foregroundColor: palette.heroCard,
              ),
              onPressed: editBudget,
              child: Text(l10n.setBudgetAction),
            ),
          ] else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  over ? l10n.budgetOverBy : l10n.budgetRemaining,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: on.withValues(alpha: 0.8),
                  ),
                ),
                Row(
                  spacing: 8,
                  children: [
                    if (over)
                      Icon(
                        LucideIcons.triangleAlert,
                        color: palette.reminder.background,
                      ),
                    // Large text: big amounts shrink rather than overflow.
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          Money.format(remaining.abs()),
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: over ? palette.reminder.background : on,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          Row(
            spacing: 12,
            children: [
              figure(
                l10n.totalBudget,
                budget == null ? '—' : Money.format(budget),
                trailing: budget == null
                    ? null
                    : SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          color: on,
                          tooltip: l10n.editBudgetTooltip,
                          icon: const Icon(LucideIcons.pencil),
                          onPressed: editBudget,
                        ),
                      ),
              ),
              figure(l10n.totalSpent, Money.format(summary.spentPaise)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = AppFormats.of(context);
    final e = expense;
    final title = e.description.isEmpty ? l10n.expenseUntitled : e.description;
    final row = ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(
        [
          fmt.shortDate(e.spentOn),
          if (e.fromShopping) l10n.expenseFromShopping,
        ].join(' · '),
      ),
      // Capped so large text can't push the description out of the row.
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 110),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            Money.format(e.amountPaise),
            style: theme.textTheme.titleSmall,
          ),
        ),
      ),
      onTap: () {
        final shoppingId = e.sourceId;
        // A shopping total is edited from its shopping list, so it stays
        // in one place and is never counted twice.
        if (e.fromShopping && shoppingId != null) {
          unawaited(context.push('/shopping/history/$shoppingId'));
        } else {
          unawaited(context.push(BudgetRoutes.edit(e.id)));
        }
      },
    );
    if (e.fromShopping) return row;
    return Dismissible(
      key: ValueKey(e.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.errorContainer,
        child: Icon(
          LucideIcons.trash2,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (_) => context.read<BudgetCubit>().deleteExpense(e),
      child: row,
    );
  }
}

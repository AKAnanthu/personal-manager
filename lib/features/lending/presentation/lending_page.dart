import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/core/utils/money.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';
import 'package:personal_life_manager/features/lending/presentation/lending_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

abstract final class LendingRoutes {
  static const root = '/lending';
  static String add(LendingDirection d) => '/lending/new?dir=${d.name}';
  static String edit(String id) => '/lending/$id';
}

class LendingPage extends StatelessWidget {
  const LendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<LendingCubit>();
    return BlocConsumer<LendingCubit, LendingState>(
      listenWhen: (a, b) => b.failure != null && a.failure != b.failure,
      listener: (context, s) {
        if (s.failure case final f?) showSnack(context, f.message(l10n));
      },
      builder: (context, s) => Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text(l10n.moduleName('lending')),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(LendingRoutes.add(s.direction)),
          icon: const Icon(LucideIcons.plus),
          label: Text(l10n.addLendingRecord),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            4,
            AppSpacing.gutter,
            96,
          ),
          children: [
            SegmentedButton<LendingDirection>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: LendingDirection.lent,
                  label: Text(l10n.moneyLentTab),
                ),
                ButtonSegment(
                  value: LendingDirection.borrowed,
                  label: Text(l10n.moneyBorrowedTab),
                ),
              ],
              selected: {s.direction},
              onSelectionChanged: (v) => cubit.select(v.first),
            ),
            const SizedBox(height: AppSpacing.section),
            if (s.tab case final tab?) ...[
              _TotalCard(direction: s.direction, tab: tab),
              const SizedBox(height: AppSpacing.section),
              if (tab.records.isEmpty)
                EmptyState(
                  icon: LucideIcons.arrowLeftRight,
                  title: s.direction == LendingDirection.lent
                      ? l10n.lentEmpty
                      : l10n.borrowedEmpty,
                  message: l10n.lendingEmptyBody,
                )
              else
                for (final r in tab.records)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.gap),
                    child: _RecordCard(record: r),
                  ),
            ] else
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.direction, required this.tab});

  final LendingDirection direction;
  final LendingTab tab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final fmt = AppFormats.of(context);
    final on = palette.onHeroCard;
    final next = tab.nextDue;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.heroCard,
        borderRadius: BorderRadius.circular(AppRadii.hero),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            direction == LendingDirection.lent
                ? l10n.totalLentPending
                : l10n.totalBorrowedPending,
            style: theme.textTheme.labelLarge?.copyWith(
              color: on.withValues(alpha: 0.8),
            ),
          ),
          Text(
            Money.format(tab.pendingTotalPaise),
            style: theme.textTheme.displaySmall?.copyWith(
              color: on,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            [
              l10n.lendingPeople(tab.pendingPeople),
              if (next != null) l10n.lendingNextDue(fmt.shortDate(next)),
            ].join(' · '),
            style: theme.textTheme.bodyMedium?.copyWith(color: on),
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final LendingRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final fmt = AppFormats.of(context);
    final cubit = context.read<LendingCubit>();
    final r = record;
    final due = r.dueOn;
    final done = r.completedOn;
    final reminder = r.reminderAt;
    final lent = r.direction == LendingDirection.lent;
    final status = r.isPending
        ? (palette.reminder, l10n.lendingStatus(LendingStatus.pending.name))
        : (palette.task, l10n.lendingStatus(LendingStatus.completed.name));
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(LendingRoutes.edit(r.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Row(
                spacing: 12,
                children: [
                  ExcludeSemantics(
                    child: CircleAvatar(
                      backgroundColor: palette.task.background,
                      foregroundColor: palette.task.foreground,
                      child: Text(
                        r.person.trim().isEmpty
                            ? '?'
                            : r.person.trim().characters.first.toUpperCase(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(r.person, style: theme.textTheme.titleSmall),
                        Text(
                          r.isPending
                              ? [
                                  if (lent)
                                    l10n.lendingGivenOn(
                                      fmt.shortDate(r.givenOn),
                                    )
                                  else
                                    l10n.lendingBorrowedOn(
                                      fmt.shortDate(r.givenOn),
                                    ),
                                  if (due != null)
                                    l10n.lendingDueOn(fmt.shortDate(due)),
                                ].join(' · ')
                              : l10n.lendingRepaidOn(
                                  fmt.shortDate(done ?? r.givenOn),
                                ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 4,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            Money.format(r.amountPaise),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: status.$1.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.$2,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: status.$1.foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (reminder != null)
                Row(
                  spacing: 6,
                  children: [
                    Icon(
                      LucideIcons.bell,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    Flexible(
                      child: Text(
                        l10n.lendingReminderAt(
                          fmt.shortDate(reminder),
                          fmt.time(reminder),
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              if (r.notes.isNotEmpty)
                Text(r.notes, style: theme.textTheme.bodyMedium),
              if (r.isPending)
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: () =>
                        cubit.setStatus(r, LendingStatus.completed),
                    child: Text(
                      lent ? l10n.markRepaidAction : l10n.markPaidBackAction,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

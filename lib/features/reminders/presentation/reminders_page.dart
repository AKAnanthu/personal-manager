import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/reminders/domain/reminder.dart';
import 'package:personal_life_manager/features/reminders/presentation/reminders_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<RemindersCubit, RemindersState>(
      listenWhen: (a, b) =>
          (b.failure != null && a.failure != b.failure) ||
          (b.lastAction != null && a.lastAction != b.lastAction),
      listener: (context, s) => showSnack(
        context,
        s.failure?.message(l10n) ??
            (s.lastAction == ReminderAction.done
                ? l10n.reminderDoneSnack
                : l10n.reminderSnoozedSnack),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text(l10n.moduleName('reminders')),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/reminders/new'),
          icon: const Icon(LucideIcons.plus),
          label: Text(l10n.newReminderAction),
        ),
        body: BlocBuilder<RemindersCubit, RemindersState>(
          builder: (context, s) {
            if (s.status == LoadStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final overdue = s.overdue;
            final upcoming = s.upcoming;
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                4,
                AppSpacing.gutter,
                96,
              ),
              children: [
                if (s.reminders.isEmpty)
                  EmptyState(
                    icon: LucideIcons.bell,
                    title: l10n.remindersEmptyTitle,
                    message: l10n.remindersEmptyBody,
                  ),
                if (overdue.isNotEmpty) ...[
                  SectionLabel(l10n.remindersOverdue(overdue.length)),
                  for (final r in overdue) ...[
                    _OverdueCard(reminder: r, now: s.now),
                    const SizedBox(height: AppSpacing.gap),
                  ],
                  const SizedBox(height: AppSpacing.section - AppSpacing.gap),
                ],
                if (upcoming.isNotEmpty) ...[
                  SectionLabel(l10n.remindersUpcoming),
                  GroupCard(
                    children: [
                      for (final r in upcoming)
                        _UpcomingRow(reminder: r, now: s.now),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.section),
                ],
                NoticeBanner(message: l10n.remindersOffline),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _repeatSuffix(AppLocalizations l10n, Reminder r) =>
    l10n.repeatName(r.repeat.name);

class _OverdueCard extends StatelessWidget {
  const _OverdueCard({required this.reminder, required this.now});

  final Reminder reminder;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final cubit = context.read<RemindersCubit>();
    final when = AppFormats.of(context)
        .relativeDateTime(reminder.effectiveAt, now);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/reminders/${reminder.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.rowPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Row(
                spacing: 12,
                children: [
                  IconTile(
                    icon: LucideIcons.bellRing,
                    colors: palette.reminder,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(reminder.title, style: theme.textTheme.titleSmall),
                        Text(
                          '$when · ${_repeatSuffix(l10n, reminder)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: AppSpacing.gap,
                runSpacing: AppSpacing.gap,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: () => cubit.markDone(reminder.id),
                    child: Text(l10n.reminderMarkDone),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: () => cubit.snoozeHour(reminder.id),
                    child: Text(l10n.reminderSnoozeHour),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.reminder, required this.now});

  final Reminder reminder;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = AppFormats.of(context);
    final at = reminder.effectiveAt;
    return InkWell(
      onTap: () => context.push('/reminders/${reminder.id}'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.rowPadding - 2),
        child: Row(
          spacing: 12,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.iconTile),
                ),
                child: Column(
                  children: [
                    Text(
                      (at.year == now.year
                              ? fmt.weekdayShort(at)
                              : fmt.monthShort(at))
                          .toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '${at.day}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(reminder.title, style: theme.textTheme.titleSmall),
                  Text(
                    [
                      fmt.relativeDateTime(at, now),
                      _repeatSuffix(l10n, reminder),
                    ].join(' · '),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/app/modules.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/dashboard/domain/upcoming_item.dart';
import 'package:personal_life_manager/features/dashboard/presentation/dashboard_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Home: quick add, coming up, quick access. Deliberately shows no budget
/// figures (PRD §4).
class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.onLock, super.key});

  final VoidCallback onLock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, s) {
          final hour = s.now.hour;
          final greeting = hour < 12
              ? l10n.greetingMorning
              : hour < 17
              ? l10n.greetingAfternoon
              : l10n.greetingEvening;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              12,
              AppSpacing.gutter,
              24,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            AppFormats.of(context).longDate(s.now),
                            style: theme.textTheme.bodySmall,
                          ),
                          Semantics(
                            header: true,
                            child: Text(
                              greeting,
                              style: theme.textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.searchNotesTooltip,
                    icon: const Icon(LucideIcons.search),
                    onPressed: () => context.push(AppModule.notes.route),
                  ),
                  IconButton(
                    tooltip: l10n.lockAppAction,
                    icon: const Icon(LucideIcons.lock),
                    onPressed: onLock,
                  ),
                  IconButton(
                    tooltip: l10n.moduleName('settings'),
                    icon: const Icon(LucideIcons.settings),
                    onPressed: () => context.push(AppModule.settings.route),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              Row(
                spacing: AppSpacing.gap,
                children: [
                  _QuickAdd(
                    label: l10n.quickAddNote,
                    semantics: l10n.newNoteAction,
                    route: '/notes/new',
                  ),
                  _QuickAdd(
                    label: l10n.quickAddTask,
                    semantics: l10n.newTaskAction,
                    route: '/tasks/new',
                  ),
                  _QuickAdd(
                    label: l10n.quickAddReminder,
                    semantics: l10n.newReminderAction,
                    route: '/reminders/new',
                  ),
                ],
              ),
              // Active shopping card is added by the Shopping milestone.
              const SizedBox(height: AppSpacing.section),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        l10n.comingUpTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppModule.reminders.route),
                    child: Text(l10n.seeAllAction),
                  ),
                ],
              ),
              if (!s.loaded)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (s.upcoming.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.rowPadding),
                    child: Text(
                      l10n.comingUpEmpty,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                )
              else
                GroupCard(
                  children: [
                    for (final item in s.upcoming)
                      _UpcomingRow(item: item, now: s.now),
                  ],
                ),
              const SizedBox(height: AppSpacing.section),
              Semantics(
                header: true,
                child: Text(
                  l10n.quickAccessTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.gap),
              const ModuleGrid(modules: AppModule.quickAccess, short: true),
            ],
          );
        },
      ),
    );
  }
}

class _QuickAdd extends StatelessWidget {
  const _QuickAdd({
    required this.label,
    required this.semantics,
    required this.route,
  });

  final String label;
  final String semantics;
  final String route;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Semantics(
        button: true,
        label: semantics,
        excludeSemantics: true,
        child: FilledButton.tonalIcon(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
          ),
          onPressed: () => context.push(route),
          icon: const Icon(LucideIcons.plus, size: 18),
          label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.item, required this.now});

  final UpcomingItem item;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final fmt = AppFormats.of(context);
    final (icon, colors) = switch (item.kind) {
      UpcomingKind.medicine => (LucideIcons.pill, palette.medicine),
      UpcomingKind.reminder => (LucideIcons.bell, palette.reminder),
      UpcomingKind.task => (LucideIcons.squareCheck, palette.task),
      UpcomingKind.lending => (LucideIcons.arrowLeftRight, palette.task),
      UpcomingKind.documentExpiry => (LucideIcons.fileClock, palette.reminder),
    };
    final when = item.hasTime
        ? fmt.relativeDateTime(item.at, now)
        : l10n.dueOn(fmt.shortDate(item.at, now: now));
    final overdue = item.hasTime
        ? item.at.isBefore(now)
        : item.at.isBefore(DateUtils.dateOnly(now));
    return InkWell(
      onTap: () => context.push(item.route),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.rowPadding - 2),
        child: Row(
          spacing: 12,
          children: [
            IconTile(icon: icon, colors: colors),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(item.title, style: theme.textTheme.titleSmall),
                  Text(
                    l10n.upcomingLine(item.kind.name, when),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: overdue ? theme.colorScheme.error : null,
                    ),
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

/// Tile grid of modules (dashboard quick access, More tab).
class ModuleGrid extends StatelessWidget {
  const ModuleGrid({required this.modules, super.key, this.short = false});

  final List<AppModule> modules;
  final bool short;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    // Fewer columns as text grows, so labels never clip.
    final columns = scale > 1.6 ? 2 : (scale > 1.2 ? 3 : 4);
    return LayoutBuilder(
      builder: (context, c) {
        final width = (c.maxWidth - AppSpacing.gap * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.gap,
          runSpacing: AppSpacing.gap,
          children: [
            for (final m in modules)
              SizedBox(
                width: width,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.control),
                    side: BorderSide(color: context.palette.cardBorder),
                  ),
                  child: InkWell(
                    onTap: () => context.push(m.route),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
                      child: Column(
                        spacing: 6,
                        children: [
                          Icon(m.icon, color: theme.colorScheme.primary),
                          Text(
                            short
                                ? l10n.moduleShortName(m.name)
                                : l10n.moduleName(m.name),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

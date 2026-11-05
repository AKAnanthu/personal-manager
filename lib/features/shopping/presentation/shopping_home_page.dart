import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/shopping/data/instruction_sharer.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_home_cubit.dart';
import 'package:personal_life_manager/features/shopping/presentation/shopping_routes.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Shopping tab: the session in progress, ways to start a list, saved and
/// previous lists.
class ShoppingHomePage extends StatelessWidget {
  const ShoppingHomePage({
    required this.sharer,
    super.key,
    this.now = DateTime.now,
  });

  final InstructionSharer sharer;
  final DateTime Function() now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ShoppingHomeCubit>();
    return BlocListener<ShoppingHomeCubit, ShoppingHomeState>(
      listenWhen: (a, b) =>
          (b.failure != null && a.failure != b.failure) ||
          (b.started != null && a.started != b.started),
      listener: (context, s) {
        cubit.clearTransient();
        if (s.started != null) {
          unawaited(context.push(ShoppingRoutes.session));
        } else if (s.failure is ConflictFailure) {
          unawaited(showSessionInProgress(context));
        } else if (s.failure case final f?) {
          showSnack(context, f.message(l10n));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.navShopping)),
        body: BlocBuilder<ShoppingHomeCubit, ShoppingHomeState>(
          builder: (context, s) => s.loading
              ? const Center(child: CircularProgressIndicator())
              : _Body(state: s, sharer: sharer, now: now()),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.sharer, required this.now});

  final ShoppingHomeState state;
  final InstructionSharer sharer;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<ShoppingHomeCubit>();
    final fmt = AppFormats.of(context);
    final active = state.active;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        4,
        AppSpacing.gutter,
        32,
      ),
      children: [
        if (active != null) ...[
          _ActiveCard(list: active, now: now),
          const SizedBox(height: AppSpacing.section),
        ],
        SectionLabel(l10n.shoppingStartNew),
        Row(
          spacing: AppSpacing.gap,
          children: [
            Expanded(
              child: _StartTile(
                icon: LucideIcons.pencilLine,
                title: l10n.shoppingTypeItems,
                subtitle: l10n.shoppingTypeItemsHint,
                onTap: () => context.push(ShoppingRoutes.newList),
              ),
            ),
            Expanded(
              child: _StartTile(
                icon: LucideIcons.clipboardPaste,
                title: l10n.shoppingPasteMessage,
                subtitle: l10n.shoppingPasteMessageHint,
                onTap: () => context.push(ShoppingRoutes.import),
              ),
            ),
          ],
        ),
        Builder(
          builder: (context) => TextButton.icon(
            onPressed: () {
              final box = context.findRenderObject() as RenderBox?;
              unawaited(
                sharer.share(
                  languageCode: Localizations.localeOf(context).languageCode,
                  origin: box == null
                      ? null
                      : box.localToGlobal(Offset.zero) & box.size,
                  text: l10n.shoppingShareText,
                ),
              );
            },
            icon: const Icon(LucideIcons.share2),
            label: Text(l10n.shoppingShareInstructions),
          ),
        ),
        if (state.drafts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.section),
          SectionLabel(l10n.shoppingSavedLists),
          GroupCard(
            children: [
              for (final d in state.drafts)
                ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                  title: Text(d.name, style: theme.textTheme.titleSmall),
                  subtitle: Text(
                    '${l10n.shoppingItemCount(d.items.length)} · '
                    '${fmt.shortDate(d.updatedAt, now: now)}',
                  ),
                  onTap: () => context.push(ShoppingRoutes.edit(d.id)),
                  trailing: FilledButton.tonal(
                    onPressed: () => cubit.startDraft(d.id),
                    child: Text(l10n.shoppingStartAction),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.section),
        SectionLabel(l10n.shoppingPreviousLists),
        if (state.history.isEmpty)
          EmptyState(
            icon: LucideIcons.history,
            title: l10n.shoppingHistoryEmpty,
          )
        else
          GroupCard(
            children: [
              for (final h in state.history)
                ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                  title: Text(h.name, style: theme.textTheme.titleSmall),
                  subtitle: Text(historyLine(context, h)),
                  onTap: () => context.push(ShoppingRoutes.history(h.id)),
                  trailing: OutlinedButton(
                    onPressed: () => context.push(ShoppingRoutes.copy(h.id)),
                    child: Text(l10n.shoppingReuseAction),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.list, required this.now});

  final ShoppingList list;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final fmt = AppFormats.of(context);
    final cubit = context.read<ShoppingHomeCubit>();
    final on = palette.onHeroCard;
    final paused = list.pausedAt;
    final total = list.items.length;
    final done = list.purchasedCount;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.heroCard,
        borderRadius: BorderRadius.circular(AppRadii.hero),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Text(
            paused == null
                ? l10n.shoppingInProgress
                : l10n.shoppingPausedAt(fmt.relativeDateTime(paused, now)),
            style: theme.textTheme.labelLarge?.copyWith(
              color: on.withValues(alpha: 0.8),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  list.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: on,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                l10n.shoppingProgress(done, total),
                style: theme.textTheme.titleMedium?.copyWith(color: on),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 6,
              color: on,
              backgroundColor: on.withValues(alpha: 0.25),
              semanticsLabel: l10n.shoppingProgress(done, total),
            ),
          ),
          Row(
            spacing: AppSpacing.gap,
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: on,
                    foregroundColor: palette.heroCard,
                  ),
                  onPressed: cubit.resume,
                  child: Text(l10n.shoppingResumeAction),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: on,
                    side: BorderSide(color: on.withValues(alpha: 0.6)),
                  ),
                  onPressed: () => context.push(ShoppingRoutes.finish(list.id)),
                  child: Text(l10n.shoppingFinishAction),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartTile extends StatelessWidget {
  const _StartTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              IconTile(icon: icon, colors: context.palette.task),
              Text(title, style: theme.textTheme.titleSmall),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

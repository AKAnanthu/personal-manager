import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/security/sensitive_clipboard.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/ui/widgets/value_row.dart';
import 'package:personal_life_manager/features/password_notes/domain/password_note.dart';
import 'package:personal_life_manager/features/password_notes/presentation/passwords_bloc.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class PasswordsPage extends StatelessWidget {
  const PasswordsPage({required this.clipboard, super.key});

  final SensitiveClipboard clipboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<PasswordsBloc, PasswordsState>(
      listenWhen: (a, b) => b.failure != null && a.failure != b.failure,
      listener: (context, s) {
        if (s.failure case final f?) showSnack(context, f.message(l10n));
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text(l10n.moduleName('passwords')),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: l10n.addPasswordNoteTooltip,
          onPressed: () => context.push('/passwords/new'),
          child: const Icon(LucideIcons.plus),
        ),
        body: BlocBuilder<PasswordsBloc, PasswordsState>(
          builder: (context, s) => _Body(state: s, clipboard: clipboard),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.clipboard});

  final PasswordsState state;
  final SensitiveClipboard clipboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<PasswordsBloc>();
    final f = state.filter;
    final expanded = state.notes
        .where((n) => n.id == state.expandedId)
        .firstOrNull;
    final rest = state.notes.where((n) => n.id != state.expandedId).toList();

    Widget pad(Widget child, {double bottom = 14}) => SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        bottom,
      ),
      sliver: SliverToBoxAdapter(child: child),
    );

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 4)),
        if (!state.warningDismissed)
          pad(
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 36),
                  child: NoticeBanner(
                    message: l10n.passwordsWarning,
                    tone: NoticeTone.warning,
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      tooltip: l10n.dismissAction,
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () =>
                          bloc.add(const PasswordsWarningDismissed()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        pad(
          SearchBar(
            hintText: l10n.passwordsSearchHint,
            leading: const Icon(LucideIcons.search),
            elevation: const WidgetStatePropertyAll(0),
            onChanged: (q) => bloc.add(PasswordsQueryChanged(q)),
          ),
        ),
        pad(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: AppSpacing.gap,
              children: [
                ChoiceChip(
                  label: Text(l10n.filterAll),
                  selected: f.category == null && !f.favouritesOnly,
                  onSelected: (_) => bloc.add(const PasswordsFilterSelected()),
                ),
                ChoiceChip(
                  label: Text(l10n.filterFavourites),
                  selected: f.favouritesOnly,
                  onSelected: (_) =>
                      bloc.add(const PasswordsFilterSelected(favourites: true)),
                ),
                for (final c in state.categories)
                  ChoiceChip(
                    label: Text(c),
                    selected: f.category == c,
                    onSelected: (_) =>
                        bloc.add(PasswordsFilterSelected(category: c)),
                  ),
              ],
            ),
          ),
        ),
        if (state.status == LoadStatus.loading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (state.notes.isEmpty)
          SliverToBoxAdapter(
            child: state.isFiltered
                ? EmptyState(icon: LucideIcons.search, title: l10n.noMatches)
                : EmptyState(
                    icon: LucideIcons.keyRound,
                    title: l10n.passwordsEmptyTitle,
                    message: l10n.passwordsEmptyBody,
                  ),
          )
        else ...[
          if (expanded != null)
            pad(_ExpandedCard(note: expanded, clipboard: clipboard)),
          if (rest.isNotEmpty)
            pad(
              GroupCard(
                children: [
                  for (final n in rest) _Row(note: n, clipboard: clipboard),
                ],
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ],
    );
  }
}

/// Letter tile; the colour is stable per name.
class _InitialTile extends StatelessWidget {
  const _InitialTile(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final pairs = [p.medicine, p.task, p.reminder, p.pdfFile, p.sheetFile];
    final colors =
        pairs[name.toLowerCase().codeUnits.fold(0, (a, b) => a + b) %
            pairs.length];
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().characters.first.toUpperCase();
    return ExcludeSemantics(
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppRadii.iconTile),
        ),
        child: Text(
          initial,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: colors.foreground, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// "example.com · Banking" (URL, else username; then the category).
String _subtitle(PasswordNote n) => [
  if (n.url.isNotEmpty) n.url else n.username,
  n.category,
].where((s) => s.isNotEmpty).join(' · ');

class _Row extends StatelessWidget {
  const _Row({required this.note, required this.clipboard});

  final PasswordNote note;
  final SensitiveClipboard clipboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final subtitle = _subtitle(note);
    return InkWell(
      onTap: () => context.read<PasswordsBloc>().add(PasswordExpanded(note.id)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
        child: Row(
          spacing: 12,
          children: [
            _InitialTile(note.name),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 6,
                    children: [
                      Flexible(
                        child: Text(
                          note.name,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (note.isFavourite)
                        Icon(
                          LucideIcons.star,
                          size: 14,
                          color: context.palette.favourite,
                          semanticLabel: l10n.filterFavourites,
                        ),
                    ],
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            if (note.password.isNotEmpty)
              IconButton(
                tooltip: l10n.copyPasswordFor(note.name),
                color: theme.colorScheme.primary,
                icon: const Icon(LucideIcons.copy),
                onPressed: () => copyValue(
                  context,
                  clipboard,
                  label: l10n.passwordLabel,
                  value: note.password,
                  sensitive: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedCard extends StatelessWidget {
  const _ExpandedCard({required this.note, required this.clipboard});

  final PasswordNote note;
  final SensitiveClipboard clipboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final bloc = context.read<PasswordsBloc>();
    final subtitle = _subtitle(note);
    const rowPadding = EdgeInsets.fromLTRB(12, 4, 4, 4);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              spacing: 12,
              children: [
                _InitialTile(note.name),
                Expanded(
                  child: InkWell(
                    onTap: () => bloc.add(const PasswordExpanded(null)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(subtitle, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: note.isFavourite
                      ? l10n.noteUnfavourite
                      : l10n.noteFavourite,
                  color: note.isFavourite
                      ? palette.favourite
                      : theme.colorScheme.onSurfaceVariant,
                  icon: Icon(LucideIcons.star, fill: note.isFavourite ? 1 : 0),
                  onPressed: () => bloc.add(
                    PasswordFavouriteToggled(note.id, value: !note.isFavourite),
                  ),
                ),
                IconButton(
                  tooltip: l10n.editAction,
                  icon: const Icon(LucideIcons.pencil),
                  onPressed: () => context.push('/passwords/${note.id}'),
                ),
              ],
            ),
            if (note.username.isNotEmpty)
              ValueRow(
                label: l10n.usernameLabel,
                value: note.username,
                padding: rowPadding,
                background: palette.mutedTile,
                onCopy: () => copyValue(
                  context,
                  clipboard,
                  label: l10n.usernameLabel,
                  value: note.username,
                ),
              ),
            if (note.password.isNotEmpty)
              ValueRow(
                label: l10n.passwordLabel,
                value: note.password,
                masked: '•' * 10,
                monospace: true,
                padding: rowPadding,
                background: palette.mutedTile,
                onCopy: () => copyValue(
                  context,
                  clipboard,
                  label: l10n.passwordLabel,
                  value: note.password,
                  sensitive: true,
                ),
              ),
            if (note.notes.isNotEmpty)
              Text(
                note.notes,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

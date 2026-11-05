import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/security/sensitive_clipboard.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/value_row.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';
import 'package:personal_life_manager/features/personal_details/presentation/detail_text.dart';
import 'package:personal_life_manager/features/personal_details/presentation/personal_bloc.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

abstract final class PersonalRoutes {
  static const root = '/personal';
  static const profile = '/personal/profile';
  static String add(DetailKind kind) => '/personal/new/${kind.name}';
  static String view(String id) => '/personal/$id';
  static String edit(String id) => '/personal/$id/edit';
}

class PersonalPage extends StatefulWidget {
  const PersonalPage({required this.clipboard, super.key});

  final SensitiveClipboard clipboard;

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  bool _searching = false;

  /// One kind opens its form directly; several ask which first.
  Future<void> _add(DetailCategory category) async {
    final kinds = DetailKind.of(category);
    final kind = kinds.length == 1
        ? kinds.first
        : await showModalBottomSheet<DetailKind>(
            context: context,
            showDragHandle: true,
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return SafeArea(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                      child: Text(
                        l10n.chooseTypeLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    for (final k in kinds)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        title: Text(l10n.detailKind(k.name)),
                        onTap: () => Navigator.of(context).pop(k),
                      ),
                  ],
                ),
              );
            },
          );
    if (kind != null && mounted) {
      unawaited(context.push(PersonalRoutes.add(kind)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<PersonalBloc>();
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: _searching
            ? TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.personalSearchHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
                onChanged: (q) => bloc.add(PersonalQueryChanged(q)),
              )
            : Text(l10n.moduleName('personal')),
        actions: [
          IconButton(
            tooltip: _searching ? l10n.closeAction : l10n.personalSearchHint,
            icon: Icon(_searching ? LucideIcons.x : LucideIcons.search),
            onPressed: () {
              if (_searching) bloc.add(const PersonalQueryChanged(''));
              setState(() => _searching = !_searching);
            },
          ),
        ],
      ),
      floatingActionButton:
          BlocSelector<PersonalBloc, PersonalState, (DetailCategory, bool)>(
            selector: (s) => (s.category, s.searching),
            builder: (context, sel) {
              final (category, searching) = sel;
              if (searching || category == DetailCategory.personal) {
                return const SizedBox.shrink();
              }
              return FloatingActionButton.extended(
                onPressed: () => _add(category),
                icon: const Icon(LucideIcons.plus),
                label: Text(switch (category) {
                  DetailCategory.family => l10n.addFamilyMember,
                  DetailCategory.identification => l10n.addIdAction,
                  _ => l10n.addEntryAction,
                }),
              );
            },
          ),
      body: BlocBuilder<PersonalBloc, PersonalState>(
        builder: (context, s) => _Body(state: s, clipboard: widget.clipboard),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.clipboard});

  final PersonalState state;
  final SensitiveClipboard clipboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<PersonalBloc>();
    final theme = Theme.of(context);
    final profile = state.profile;

    final Widget content;
    if (state.status == LoadStatus.loading ||
        (!state.searching &&
            state.category == DetailCategory.personal &&
            !state.profileLoaded)) {
      content = const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (!state.searching && state.category == DetailCategory.personal) {
      content = profile == null || profile.fields.isEmpty
          ? EmptyState(
              icon: LucideIcons.user,
              title: l10n.profileEmptyTitle,
              message: l10n.profileEmptyBody,
            )
          : _FieldsCard(entry: profile, clipboard: clipboard);
    } else if (state.entries.isEmpty) {
      content = state.searching
          ? EmptyState(icon: LucideIcons.search, title: l10n.noMatches)
          : EmptyState(icon: LucideIcons.inbox, title: l10n.personalTabEmpty);
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          GroupCard(
            children: [
              for (final e in state.entries)
                _EntryRow(
                  entry: e,
                  clipboard: clipboard,
                  showCategory: state.searching,
                ),
            ],
          ),
          Text(
            l10n.personalCardHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        8,
        AppSpacing.gutter,
        96,
      ),
      children: [
        if (!state.searching) ...[
          _ProfileCard(profile: profile),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: AppSpacing.gap,
              children: [
                for (final c in DetailCategory.values)
                  ChoiceChip(
                    label: Text(l10n.detailCategory(c.name)),
                    selected: state.category == c,
                    onSelected: (_) => bloc.add(PersonalCategorySelected(c)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        content,
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final PersonalEntry? profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = AppFormats.of(context);
    final p = profile;
    final name = p?.value('fullName') ?? '';
    final born = decodeDetailDate(p?.value('dateOfBirth') ?? '');
    final phone = p?.value('phone') ?? '';
    final subtitle = [
      if (born != null) l10n.personalBorn(fmt.fullDate(born)),
      if (phone.isNotEmpty) phone,
    ].join(' · ');
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w.characters.first.toUpperCase())
        .join();
    final accent = context.palette.task;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.hero),
        side: BorderSide(color: context.palette.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.hero),
        onTap: () => context.push(PersonalRoutes.profile),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 14,
            children: [
              ExcludeSemantics(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: accent.background,
                  foregroundColor: accent.foreground,
                  child: initials.isEmpty
                      ? const Icon(LucideIcons.user)
                      : Text(
                          initials,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: accent.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      name.isEmpty ? l10n.profileEmptyTitle : name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: l10n.editProfileTooltip,
                icon: const Icon(LucideIcons.pencil),
                onPressed: () => context.push(PersonalRoutes.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The profile's fields, each copyable (Personal tab).
class _FieldsCard extends StatelessWidget {
  const _FieldsCard({required this.entry, required this.clipboard});

  final PersonalEntry entry;
  final SensitiveClipboard clipboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = AppFormats.of(context);
    return GroupCard(
      children: [
        for (final f in entry.fields)
          if (f.value.isNotEmpty)
            ValueRow(
              label: l10n.fieldLabel(f),
              value: displayValue(fmt, entry.kind, f),
              masked: f.sensitive ? maskValue(f.value) : null,
              onCopy: () => copyValue(
                context,
                clipboard,
                label: l10n.fieldLabel(f),
                value: f.value,
                sensitive: f.sensitive,
              ),
            ),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.clipboard,
    this.showCategory = false,
  });

  final PersonalEntry entry;
  final SensitiveClipboard clipboard;
  final bool showCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = AppFormats.of(context);
    final name = l10n.entryName(entry);
    final primary = entry.primary;
    final expiry = decodeDetailDate(entry.value('expiryDate'));
    final label = showCategory
        ? '$name · ${l10n.detailCategory(entry.kind.category.name)}'
        : name;
    final shown = primary == null
        ? null
        : primary.sensitive
        ? maskValue(primary.value)
        : displayValue(fmt, entry.kind, primary);
    return InkWell(
      onTap: () => context.push(PersonalRoutes.view(entry.id)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (shown != null)
                    Semantics(
                      label: primary?.sensitive ?? false
                          ? l10n.hiddenValueSemantics
                          : null,
                      excludeSemantics: primary?.sensitive ?? false,
                      child: Text(
                        shown,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: primary?.sensitive ?? false
                              ? 0.6
                              : null,
                        ),
                      ),
                    ),
                  if (expiry != null)
                    Text(
                      l10n.idExpires(fmt.fullDate(expiry)),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            if (primary != null)
              IconButton(
                tooltip: l10n.copyTooltip(name),
                color: theme.colorScheme.primary,
                icon: const Icon(LucideIcons.copy),
                onPressed: () => copyValue(
                  context,
                  clipboard,
                  label: l10n.fieldLabel(primary),
                  value: primary.value,
                  sensitive: primary.sensitive,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

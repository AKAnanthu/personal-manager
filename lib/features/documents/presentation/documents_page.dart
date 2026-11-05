import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/app/modules.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/presentation/document_widgets.dart';
import 'package:personal_life_manager/features/documents/presentation/documents_bloc.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Documents tab.
class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<DocumentsBloc>();
    return BlocListener<DocumentsBloc, DocumentsState>(
      listenWhen: (a, b) => b.failure != null && a.failure != b.failure,
      listener: (context, s) {
        if (s.failure case final f?) showSnack(context, f.message(l10n));
      },
      child: Scaffold(
        appBar: AppBar(
          title: _searching
              ? TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.documentsSearchHint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                  onChanged: (q) => bloc.add(DocumentsQueryChanged(q)),
                )
              : Text(l10n.navDocuments),
          actions: [
            IconButton(
              tooltip: _searching ? l10n.closeAction : l10n.documentsSearchHint,
              icon: Icon(_searching ? LucideIcons.x : LucideIcons.search),
              onPressed: () {
                if (_searching) bloc.add(const DocumentsQueryChanged(''));
                setState(() => _searching = !_searching);
              },
            ),
            IconButton(
              tooltip: l10n.openDriveTooltip,
              icon: const Icon(LucideIcons.cloud),
              onPressed: () => context.push(AppModule.drive.route),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(DocumentRoutes.add),
          icon: const Icon(LucideIcons.plus),
          label: Text(l10n.addDocumentAction),
        ),
        body: BlocBuilder<DocumentsBloc, DocumentsState>(
          builder: (context, s) => _Body(state: s, now: widget.now()),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.now});

  final DocumentsState state;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<DocumentsBloc>();
    final f = state.filter;

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
        pad(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: AppSpacing.gap,
              children: [
                ChoiceChip(
                  label: Text(l10n.filterAll),
                  selected: f.category == null && !f.favouritesOnly,
                  onSelected: (_) => bloc.add(const DocumentsFilterSelected()),
                ),
                ChoiceChip(
                  label: Text(l10n.filterFavourites),
                  selected: f.favouritesOnly,
                  onSelected: (_) =>
                      bloc.add(const DocumentsFilterSelected(favourites: true)),
                ),
                for (final c in DocumentCategory.values)
                  ChoiceChip(
                    label: Text(l10n.documentCategoryShort(c.name)),
                    selected: f.category == c,
                    onSelected: (_) =>
                        bloc.add(DocumentsFilterSelected(category: c)),
                  ),
              ],
            ),
          ),
        ),
        if (!state.isFiltered)
          for (final d in state.expiringSoon.take(3))
            pad(_ExpiryBanner(document: d, now: now), bottom: 10),
        if (state.status == LoadStatus.loading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (state.documents.isEmpty)
          SliverToBoxAdapter(
            child: state.isFiltered
                ? EmptyState(icon: LucideIcons.search, title: l10n.noMatches)
                : EmptyState(
                    icon: LucideIcons.fileText,
                    title: l10n.documentsEmptyTitle,
                    message: l10n.documentsEmptyBody,
                  ),
          )
        else ...[
          if (!state.isFiltered)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                4,
                AppSpacing.gutter,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: SectionLabel(l10n.documentsRecent),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            sliver: DecoratedSliver(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                border: Border.all(color: context.palette.cardBorder),
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              sliver: SliverList.separated(
                itemCount: state.documents.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, i) {
                  final d = state.documents[i];
                  return DocumentTile(
                    document: d,
                    onTap: () => context.push(DocumentRoutes.view(d.id)),
                    trailing: d.isFavourite
                        ? Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              LucideIcons.star,
                              size: 18,
                              fill: 1,
                              color: context.palette.favourite,
                              semanticLabel: l10n.filterFavourites,
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ],
    );
  }
}

class _ExpiryBanner extends StatelessWidget {
  const _ExpiryBanner({required this.document, required this.now});

  final AppDocument document;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final fmt = AppFormats.of(context);
    final days = document.daysToExpiry(now) ?? 0;
    final expiry = document.expiryDate ?? now;
    return Material(
      color: palette.reminder.background,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: () => context.push(DocumentRoutes.view(document.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            spacing: 12,
            children: [
              Icon(
                LucideIcons.calendarClock,
                color: palette.reminder.foreground,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.documentExpiresOn(
                        document.title,
                        fmt.shortDate(expiry, now: now),
                      ),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: palette.warningText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${l10n.documentCategory(document.category.name)} · '
                      '${l10n.daysLeft(days)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.warningText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

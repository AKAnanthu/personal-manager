import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/notes/domain/note.dart';
import 'package:personal_life_manager/features/notes/presentation/notes_list_bloc.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<NotesListBloc>();
    return BlocBuilder<NotesListBloc, NotesListState>(
      buildWhen: (a, b) => a.filter.view != b.filter.view,
      builder: (context, state) {
        final archived = state.filter.view == NotesView.archived;
        return Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(),
            title: Text(
              archived ? l10n.archivedNotesTitle : l10n.moduleName('notes'),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  archived ? LucideIcons.notebookPen : LucideIcons.archive,
                ),
                tooltip: archived
                    ? l10n.moduleName('notes')
                    : l10n.archivedNotesTitle,
                onPressed: () => bloc.add(
                  NotesViewChanged(
                    archived ? NotesView.all : NotesView.archived,
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: archived
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => context.push('/notes/new'),
                  icon: const Icon(LucideIcons.plus),
                  label: Text(l10n.newNoteAction),
                ),
          body: const _NotesBody(),
        );
      },
    );
  }
}

class _NotesBody extends StatelessWidget {
  const _NotesBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<NotesListBloc>();
    return BlocBuilder<NotesListBloc, NotesListState>(
      builder: (context, state) {
        final archived = state.filter.view == NotesView.archived;
        final hasQuery = state.filter.query.trim().isNotEmpty;
        final filtered =
            hasQuery ||
            state.filter.tag != null ||
            state.filter.view == NotesView.favourites;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                4,
                AppSpacing.gutter,
                0,
              ),
              sliver: SliverList.list(
                children: [
                  SearchBar(
                    hintText: l10n.notesSearchHint,
                    leading: const Icon(LucideIcons.search),
                    onChanged: (q) => bloc.add(NotesQueryChanged(q)),
                  ),
                  if (!archived) ...[
                    const SizedBox(height: 12),
                    _FilterChips(state: state),
                  ],
                  const SizedBox(height: 14),
                ],
              ),
            ),
            if (state.status == LoadStatus.loading && state.notes.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.status == LoadStatus.failure)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: LucideIcons.fileX,
                  title: l10n.errorGeneric,
                ),
              )
            else if (state.notes.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: archived
                      ? LucideIcons.archive
                      : LucideIcons.notebookPen,
                  title: archived
                      ? l10n.notesArchiveEmpty
                      : filtered
                      ? l10n.notesNoResults
                      : l10n.notesEmptyTitle,
                  message: archived || filtered ? null : l10n.notesEmptyBody,
                ),
              )
            else ...[
              ..._section(l10n.notesPinned, state.pinned),
              ..._section(
                state.pinned.isEmpty ? null : l10n.notesOthers,
                state.others,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _section(String? label, List<Note> notes) {
    if (notes.isEmpty) return const [];
    return [
      if (label != null)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          sliver: SliverToBoxAdapter(child: SectionLabel(label)),
        ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.section,
        ),
        sliver: SliverList.separated(
          itemCount: notes.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.gap),
          itemBuilder: (context, i) => _NoteCard(note: notes[i]),
        ),
      ),
    ];
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.state});

  final NotesListState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<NotesListBloc>();
    final f = state.filter;
    Widget chip(
      String label, {
      required bool selected,
      required VoidCallback onTap,
    }) => Padding(
      padding: const EdgeInsets.only(right: AppSpacing.gap),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(
            l10n.notesFilterAll,
            selected: f.view == NotesView.all && f.tag == null,
            onTap: () => bloc.add(const NotesViewChanged(NotesView.all)),
          ),
          chip(
            l10n.notesFilterFavourites,
            selected: f.view == NotesView.favourites,
            onTap: () => bloc.add(const NotesViewChanged(NotesView.favourites)),
          ),
          for (final tag in state.tags)
            chip(
              '#$tag',
              selected: f.tag == tag,
              onTap: () => bloc.add(NotesViewChanged(NotesView.all, tag: tag)),
            ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final photos = note.attachments.where((a) => a.isImage).length;
    final files = note.attachments.length - photos;
    final footer = [
      l10n.noteEdited(AppFormats.of(context).shortDate(note.updatedAt)),
      if (photos > 0) l10n.notePhotoCount(photos),
      if (files > 0) l10n.noteFileCount(files),
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/notes/${note.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.rowPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Row(
                spacing: 6,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty
                          ? note.plainText.split('\n').first
                          : note.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  if (note.isFavourite)
                    Icon(
                      LucideIcons.star,
                      size: 18,
                      color: palette.favourite,
                      semanticLabel: l10n.notesFilterFavourites,
                    ),
                ],
              ),
              if (note.title.isNotEmpty && note.plainText.isNotEmpty)
                Text(
                  note.plainText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                ),
              if (note.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final t in note.tags)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '#$t',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              Text(
                footer,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

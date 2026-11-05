import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_access.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/form_page.dart';
import 'package:personal_life_manager/core/ui/widgets/image_viewer_page.dart';
import 'package:personal_life_manager/features/notes/domain/note.dart';
import 'package:personal_life_manager/features/notes/presentation/note_editor_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({required this.opener, super.key});

  final FileOpener opener;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  QuillController? _quill;
  StreamSubscription<DocChange>? _changes;
  final _title = TextEditingController();
  final _tag = TextEditingController();

  NoteEditorCubit get _cubit => context.read<NoteEditorCubit>();

  NoteContent get _content {
    final q = _quill;
    if (q == null) return NoteContent.empty;
    return NoteContent(
      jsonEncode(q.document.toDelta().toJson()),
      q.document.toPlainText().trim(),
    );
  }

  /// Created once the note has loaded (synchronously for a new note).
  QuillController? _editorFor(NoteEditorState s) {
    if (_quill != null || s.loading) return _quill;
    _title.text = s.title;
    final q = QuillController(
      document: _parse(s.initialContent.json),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _changes = q.document.changes.listen((_) => _cubit.contentChanged());
    return _quill = q;
  }

  static Document _parse(String json) {
    try {
      final data = jsonDecode(json);
      if (data is List && data.isNotEmpty) return Document.fromJson(data);
    } on FormatException {
      // Fall through to an empty document.
    }
    return Document();
  }

  @override
  void dispose() {
    unawaited(_changes?.cancel());
    _quill?.dispose();
    _title.dispose();
    _tag.dispose();
    super.dispose();
  }

  Future<void> _openAttachment(NoteAttachment a) async {
    final l10n = AppLocalizations.of(context);
    final r = await _cubit.fileFor(a);
    if (!mounted) return;
    switch (r) {
      case Err(:final failure):
        showSnack(context, failure.message(l10n));
      case Ok(value: final file):
        if (a.isImage) {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  ImageViewerPage(file: file, title: a.originalName),
            ),
          );
        } else if (!await widget.opener.openExternally(file) && mounted) {
          showSnack(context, l10n.errorNoAppToOpen);
        }
    }
  }

  Future<void> _addAttachment() async {
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: Text(l10n.attachTakePhoto),
              onTap: () => Navigator.pop(context, 0),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: Text(l10n.attachChoosePhoto),
              onTap: () => Navigator.pop(context, 1),
            ),
            ListTile(
              leading: const Icon(LucideIcons.file),
              title: Text(l10n.attachChooseFile),
              onTap: () => Navigator.pop(context, 2),
            ),
          ],
        ),
      ),
    );
    final content = _content;
    switch (choice) {
      case 0:
        await _cubit.attachFromCamera(content);
      case 1:
        await _cubit.attachFromGallery(content);
      case 2:
        await _cubit.attachDocument(content);
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l10n.deleteNoteTitle,
      message: l10n.deleteNoteBody,
      confirmLabel: l10n.deleteAction,
    );
    if (ok) await _cubit.delete();
  }

  void _onOutcome(BuildContext context, NoteEditorState s) {
    final l10n = AppLocalizations.of(context);
    final message = switch (s.outcome) {
      EditorOutcome.archived => s.isArchived ? null : l10n.noteArchivedSnack,
      EditorOutcome.deleted => l10n.noteDeletedSnack,
      _ => null,
    };
    if (message != null) showSnack(context, message);
    AppBackButton.popOrHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<NoteEditorCubit, NoteEditorState>(
      listenWhen: (a, b) => a.outcome != b.outcome || a.failure != b.failure,
      listener: (context, s) {
        if (s.outcome != EditorOutcome.none) return _onOutcome(context, s);
        if (s.failure case final f?) {
          showSnack(context, f.message(l10n));
          _cubit.clearFailure();
        }
      },
      builder: (context, s) {
        final quill = _editorFor(s);
        return FormPage(
          title: s.isNew ? l10n.newNoteTitle : l10n.editNoteTitle,
          dirty: s.dirty,
          saving: s.busy,
          onSave: quill == null ? null : () => _cubit.save(_content),
          actions: [
            IconButton(
              tooltip: s.isPinned ? l10n.noteUnpin : l10n.notePin,
              isSelected: s.isPinned,
              icon: const Icon(LucideIcons.pin),
              selectedIcon: const Icon(LucideIcons.pinOff),
              onPressed: _cubit.togglePinned,
            ),
            IconButton(
              tooltip: s.isFavourite
                  ? l10n.noteUnfavourite
                  : l10n.noteFavourite,
              icon: Icon(
                LucideIcons.star,
                color: s.isFavourite ? context.palette.favourite : null,
              ),
              onPressed: _cubit.toggleFavourite,
            ),
            PopupMenuButton<int>(
              tooltip: l10n.moreOptions,
              icon: const Icon(LucideIcons.ellipsisVertical),
              onSelected: (v) =>
                  v == 0 ? _cubit.archive(_content) : _confirmDelete(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 0,
                  child: Text(
                    s.isArchived ? l10n.noteUnarchive : l10n.noteArchive,
                  ),
                ),
                PopupMenuItem(value: 1, child: Text(l10n.deleteAction)),
              ],
            ),
          ],
          children: [
            if (s.loading || quill == null)
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              TextField(
                controller: _title,
                onChanged: _cubit.titleChanged,
                textCapitalization: TextCapitalization.sentences,
                style: Theme.of(context).textTheme.titleLarge,
                decoration: InputDecoration(
                  hintText: l10n.noteTitleHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 8),
              QuillSimpleToolbar(
                controller: quill,
                config: const QuillSimpleToolbarConfig(
                  multiRowsDisplay: false,
                  showDividers: false,
                  showFontFamily: false,
                  showFontSize: false,
                  showUnderLineButton: false,
                  showInlineCode: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showClearFormat: false,
                  showHeaderStyle: false,
                  showCodeBlock: false,
                  showQuote: false,
                  showIndent: false,
                  showLink: false,
                  showSearchButton: false,
                  showSubscript: false,
                  showSuperscript: false,
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              QuillEditor.basic(
                controller: quill,
                config: QuillEditorConfig(
                  scrollable: false,
                  placeholder: l10n.noteBodyHint,
                  minHeight: 200,
                  autoFocus: s.isNew,
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              _TagsEditor(tags: s.tags, controller: _tag),
              const SizedBox(height: AppSpacing.section),
              _AttachmentsSection(
                attachments: s.attachments,
                onAdd: s.busy ? null : _addAttachment,
                onOpen: _openAttachment,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TagsEditor extends StatelessWidget {
  const _TagsEditor({required this.tags, required this.controller});

  final List<String> tags;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<NoteEditorCubit>();
    void submit(String v) {
      if (v.trim().isEmpty) return;
      cubit.addTag(v);
      controller.clear();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        SectionLabel(l10n.noteTagsLabel),
        if (tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in tags)
                InputChip(
                  label: Text('#$t'),
                  onDeleted: () => cubit.removeTag(t),
                  deleteButtonTooltipMessage: l10n.removeTagTooltip(t),
                ),
            ],
          ),
        TextField(
          controller: controller,
          onSubmitted: submit,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: l10n.noteTagHint,
            prefixIcon: const Icon(LucideIcons.tag, size: 20),
          ),
        ),
      ],
    );
  }
}

class _AttachmentsSection extends StatelessWidget {
  const _AttachmentsSection({
    required this.attachments,
    required this.onAdd,
    required this.onOpen,
  });

  final List<NoteAttachment> attachments;
  final VoidCallback? onAdd;
  final void Function(NoteAttachment) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<NoteEditorCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(l10n.attachmentsLabel),
        if (attachments.isNotEmpty) ...[
          GroupCard(
            children: [
              for (final a in attachments)
                ListTile(
                  leading: Icon(
                    a.isImage ? LucideIcons.image : LucideIcons.file,
                  ),
                  title: Text(
                    a.originalName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => onOpen(a),
                  trailing: IconButton(
                    tooltip: l10n.removeAttachmentTooltip(a.originalName),
                    icon: const Icon(LucideIcons.x),
                    onPressed: () async {
                      final ok = await confirmDialog(
                        context,
                        title: l10n.removeAttachmentTitle,
                        confirmLabel: l10n.removeAction,
                      );
                      if (ok) await cubit.removeAttachment(a);
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.gap),
        ],
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(LucideIcons.paperclip),
          label: Text(l10n.addAttachmentAction),
        ),
      ],
    );
  }
}

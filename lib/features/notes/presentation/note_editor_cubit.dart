import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_access.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/notes/domain/note.dart';
import 'package:personal_life_manager/features/notes/domain/notes_repository.dart';

/// The note's rich-text body lives in the page's Quill controller; the page
/// passes its JSON and plain text in on save.
final class NoteContent extends Equatable {
  const NoteContent(this.json, this.plainText);

  static const empty = NoteContent('[]', '');

  final String json;
  final String plainText;

  @override
  List<Object?> get props => [json, plainText];
}

final class NoteEditorState extends Equatable {
  const NoteEditorState({
    this.loading = true,
    this.noteId,
    this.title = '',
    this.initialContent = NoteContent.empty,
    this.tags = const [],
    this.isPinned = false,
    this.isFavourite = false,
    this.isArchived = false,
    this.attachments = const [],
    this.dirty = false,
    this.busy = false,
    this.failure,
    this.outcome = EditorOutcome.none,
  });

  final bool loading;
  final String? noteId;
  final String title;

  /// Content the editor starts with (not updated while typing).
  final NoteContent initialContent;
  final List<String> tags;
  final bool isPinned;
  final bool isFavourite;
  final bool isArchived;
  final List<NoteAttachment> attachments;
  final bool dirty;
  final bool busy;
  final Failure? failure;
  final EditorOutcome outcome;

  bool get isNew => noteId == null;

  NoteEditorState copyWith({
    bool? loading,
    String? noteId,
    String? title,
    NoteContent? initialContent,
    List<String>? tags,
    bool? isPinned,
    bool? isFavourite,
    bool? isArchived,
    List<NoteAttachment>? attachments,
    bool? dirty,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
    EditorOutcome? outcome,
  }) => NoteEditorState(
    loading: loading ?? this.loading,
    noteId: noteId ?? this.noteId,
    title: title ?? this.title,
    initialContent: initialContent ?? this.initialContent,
    tags: tags ?? this.tags,
    isPinned: isPinned ?? this.isPinned,
    isFavourite: isFavourite ?? this.isFavourite,
    isArchived: isArchived ?? this.isArchived,
    attachments: attachments ?? this.attachments,
    dirty: dirty ?? this.dirty,
    busy: busy ?? this.busy,
    failure: clearFailure ? null : (failure ?? this.failure),
    outcome: outcome ?? this.outcome,
  );

  @override
  List<Object?> get props => [
    loading,
    noteId,
    title,
    initialContent,
    tags,
    isPinned,
    isFavourite,
    isArchived,
    attachments,
    dirty,
    busy,
    failure,
    outcome,
  ];
}

class NoteEditorCubit extends Cubit<NoteEditorState> {
  NoteEditorCubit({
    required this._repository,
    required this._pickers,
    this.noteId,
  }) : super(const NoteEditorState());

  final NotesRepository _repository;
  final FilePickers _pickers;
  final String? noteId;
  StreamSubscription<Note?>? _sub;

  Future<void> load() async {
    final id = noteId;
    if (id == null) {
      emit(state.copyWith(loading: false));
      return;
    }
    _watch(id);
  }

  void _watch(String id) {
    var first = true;
    _sub = _repository.watchNote(id).listen((note) {
      if (isClosed) return;
      if (note == null) {
        if (first) {
          emit(
            state.copyWith(loading: false, failure: const NotFoundFailure()),
          );
        }
        return;
      }
      if (first) {
        first = false;
        emit(
          state.copyWith(
            loading: false,
            noteId: note.id,
            title: note.title,
            initialContent: NoteContent(note.contentJson, note.plainText),
            tags: note.tags,
            isPinned: note.isPinned,
            isFavourite: note.isFavourite,
            isArchived: note.isArchived,
            attachments: note.attachments,
          ),
        );
      } else {
        // Later emissions only refresh attachments; don't clobber edits.
        emit(state.copyWith(attachments: note.attachments));
      }
    });
  }

  void titleChanged(String v) => emit(state.copyWith(title: v, dirty: true));

  void contentChanged() {
    if (!state.dirty) emit(state.copyWith(dirty: true));
  }

  void addTag(String raw) {
    final tags = normaliseTags([...state.tags, raw]);
    if (tags.length != state.tags.length) {
      emit(state.copyWith(tags: tags, dirty: true));
    }
  }

  void removeTag(String tag) =>
      emit(state.copyWith(tags: [...state.tags]..remove(tag), dirty: true));

  void togglePinned() =>
      emit(state.copyWith(isPinned: !state.isPinned, dirty: true));

  void toggleFavourite() =>
      emit(state.copyWith(isFavourite: !state.isFavourite, dirty: true));

  Future<void> save(NoteContent content) async {
    if (state.busy) return;
    final draft = _draft(content);
    if (state.isNew && draft.isEmpty && state.attachments.isEmpty) {
      emit(state.copyWith(outcome: EditorOutcome.discarded));
      return;
    }
    emit(state.copyWith(busy: true, clearFailure: true));
    final r = await _repository.save(draft);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(busy: false, failure: f),
        (_) => state.copyWith(
          busy: false,
          dirty: false,
          outcome: EditorOutcome.saved,
        ),
      ),
    );
  }

  Future<void> archive(NoteContent content) async {
    final id = await _ensureSaved(content);
    if (id == null) return;
    final r = await _repository.setArchived(id, value: !state.isArchived);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(busy: false, failure: f),
        (_) => state.copyWith(busy: false, outcome: EditorOutcome.archived),
      ),
    );
  }

  Future<void> delete() async {
    final id = state.noteId;
    if (id == null) {
      emit(state.copyWith(outcome: EditorOutcome.discarded));
      return;
    }
    emit(state.copyWith(busy: true));
    final r = await _repository.delete(id);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(busy: false, failure: f),
        (_) => state.copyWith(busy: false, outcome: EditorOutcome.deleted),
      ),
    );
  }

  Future<void> attachFromCamera(NoteContent c) =>
      _attach(_pickers.takePhoto, c);

  Future<void> attachFromGallery(NoteContent c) =>
      _attach(_pickers.choosePhoto, c);

  Future<void> attachDocument(NoteContent c) =>
      _attach(_pickers.chooseDocument, c);

  Future<void> _attach(
    Future<PickedFile?> Function() pick,
    NoteContent content,
  ) async {
    if (state.busy) return;
    final picked = await pick();
    if (picked == null || isClosed) return;
    final id = await _ensureSaved(content);
    if (id == null) return;
    final r = await _repository.addAttachment(
      id,
      picked.file,
      originalName: picked.name,
    );
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(busy: false, failure: f),
        (a) =>
            state.copyWith(busy: false, attachments: [...state.attachments, a]),
      ),
    );
  }

  Future<void> removeAttachment(NoteAttachment a) async {
    final r = await _repository.removeAttachment(a);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(failure: f),
        (_) => state.copyWith(
          attachments: state.attachments.where((x) => x.id != a.id).toList(),
        ),
      ),
    );
  }

  Future<Result<File>> fileFor(NoteAttachment a) =>
      _repository.attachmentFile(a);

  void clearFailure() => emit(state.copyWith(clearFailure: true));

  /// Attachments and archive need a stored note; saves the draft first.
  Future<String?> _ensureSaved(NoteContent content) async {
    emit(state.copyWith(busy: true, clearFailure: true));
    final r = await _repository.save(_draft(content));
    if (isClosed) return null;
    return r.fold<String?>(
      (f) {
        emit(state.copyWith(busy: false, failure: f));
        return null;
      },
      (id) {
        final wasNew = state.isNew;
        emit(state.copyWith(noteId: id, dirty: false));
        if (wasNew) _watchAttachmentsOnly(id);
        return id;
      },
    );
  }

  void _watchAttachmentsOnly(String id) {
    unawaited(_sub?.cancel());
    _sub = _repository.watchNote(id).listen((note) {
      if (!isClosed && note != null) {
        emit(state.copyWith(attachments: note.attachments));
      }
    });
  }

  NoteDraft _draft(NoteContent content) => NoteDraft(
    id: state.noteId,
    title: state.title,
    contentJson: content.json,
    plainText: content.plainText,
    tags: state.tags,
    isPinned: state.isPinned,
    isFavourite: state.isFavourite,
  );

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await super.close();
  }
}

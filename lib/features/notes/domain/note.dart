import 'package:equatable/equatable.dart';

final class NoteAttachment extends Equatable {
  const NoteAttachment({
    required this.id,
    required this.noteId,
    required this.fileKey,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String id;
  final String noteId;
  final String fileKey;
  final String originalName;
  final String mimeType;
  final int sizeBytes;

  bool get isImage => mimeType.startsWith('image/');

  @override
  List<Object?> get props => [
    id,
    noteId,
    fileKey,
    originalName,
    mimeType,
    sizeBytes,
  ];
}

final class Note extends Equatable {
  const Note({
    required this.id,
    required this.title,
    required this.contentJson,
    required this.plainText,
    required this.tags,
    required this.isPinned,
    required this.isFavourite,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.attachments = const [],
  });

  final String id;
  final String title;

  /// Quill Delta JSON.
  final String contentJson;
  final String plainText;
  final List<String> tags;
  final bool isPinned;
  final bool isFavourite;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<NoteAttachment> attachments;

  @override
  List<Object?> get props => [
    id,
    title,
    contentJson,
    plainText,
    tags,
    isPinned,
    isFavourite,
    isArchived,
    createdAt,
    updatedAt,
    attachments,
  ];
}

/// Fields the editor saves. [id] null = new note.
final class NoteDraft extends Equatable {
  const NoteDraft({
    required this.title,
    required this.contentJson,
    required this.plainText,
    this.id,
    this.tags = const [],
    this.isPinned = false,
    this.isFavourite = false,
  });

  final String? id;
  final String title;
  final String contentJson;
  final String plainText;
  final List<String> tags;
  final bool isPinned;
  final bool isFavourite;

  bool get isEmpty => title.trim().isEmpty && plainText.trim().isEmpty;

  @override
  List<Object?> get props => [
    id,
    title,
    contentJson,
    plainText,
    tags,
    isPinned,
    isFavourite,
  ];
}

enum NotesView { all, favourites, archived }

final class NotesFilter extends Equatable {
  const NotesFilter({this.query = '', this.view = NotesView.all, this.tag});

  final String query;
  final NotesView view;
  final String? tag;

  @override
  List<Object?> get props => [query, view, tag];
}

/// Normalises user-typed tags: lower case, no `#`, no spaces, unique.
List<String> normaliseTags(Iterable<String> raw) => {
  for (final t in raw)
    if (t.trim().replaceAll('#', '').replaceAll(RegExp(r'\s+'), '-')
        case final clean when clean.isNotEmpty)
      clean.toLowerCase(),
}.toList();

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/storage/file_access.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/domain/documents_repository.dart';

/// The file shown on the form: the stored one, or a newly picked one.
final class FormFile extends Equatable {
  const FormFile({
    required this.name,
    required this.type,
    required this.sizeBytes,
    this.picked,
  });

  final String name;
  final SupportedFileType type;
  final int sizeBytes;

  /// Set when the user picked a new file (not yet saved).
  final PickedFile? picked;

  @override
  List<Object?> get props => [name, type, sizeBytes, picked?.file.path];
}

final class DocumentFormState extends Equatable {
  const DocumentFormState({
    this.loading = true,
    this.documentId,
    this.file,
    this.title = '',
    this.description = '',
    this.category,
    this.expiryDate,
    this.expiryReminder = true,
    this.isFavourite = false,
    this.dirty = false,
    this.busy = false,
    this.picking = false,
    this.showErrors = false,
    this.failure,
    this.outcome = EditorOutcome.none,
    this.notificationsBlocked = false,
  });

  final bool loading;
  final String? documentId;
  final FormFile? file;
  final String title;
  final String description;
  final DocumentCategory? category;
  final DateTime? expiryDate;
  final bool expiryReminder;
  final bool isFavourite;
  final bool dirty;
  final bool busy;
  final bool picking;
  final bool showErrors;
  final Failure? failure;
  final EditorOutcome outcome;

  /// Saved with an expiry reminder but notifications are not allowed.
  final bool notificationsBlocked;

  /// The expiry reminder will be scheduled.
  bool get remindsOfExpiry => expiryDate != null && expiryReminder;

  bool get isNew => documentId == null;
  bool get fileMissing => file == null;
  bool get titleMissing => title.trim().isEmpty;
  bool get categoryMissing => category == null;
  bool get hasErrors => fileMissing || titleMissing || categoryMissing;

  DocumentFormState copyWith({
    bool? loading,
    String? documentId,
    FormFile? file,
    String? title,
    String? description,
    DocumentCategory? category,
    DateTime? Function()? expiryDate,
    bool? expiryReminder,
    bool? isFavourite,
    bool? dirty,
    bool? busy,
    bool? picking,
    bool? showErrors,
    Failure? failure,
    bool clearFailure = false,
    EditorOutcome? outcome,
    bool? notificationsBlocked,
  }) => DocumentFormState(
    loading: loading ?? this.loading,
    documentId: documentId ?? this.documentId,
    file: file ?? this.file,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    expiryDate: expiryDate != null ? expiryDate() : this.expiryDate,
    expiryReminder: expiryReminder ?? this.expiryReminder,
    isFavourite: isFavourite ?? this.isFavourite,
    dirty: dirty ?? this.dirty,
    busy: busy ?? this.busy,
    picking: picking ?? this.picking,
    showErrors: showErrors ?? this.showErrors,
    failure: clearFailure ? null : (failure ?? this.failure),
    outcome: outcome ?? this.outcome,
    notificationsBlocked: notificationsBlocked ?? this.notificationsBlocked,
  );

  @override
  List<Object?> get props => [
    loading,
    documentId,
    file,
    title,
    description,
    category,
    expiryDate,
    expiryReminder,
    isFavourite,
    dirty,
    busy,
    picking,
    showErrors,
    failure,
    outcome,
    notificationsBlocked,
  ];
}

class DocumentFormCubit extends Cubit<DocumentFormState> {
  DocumentFormCubit({
    required this._repository,
    required this._pickers,
    required this._permissions,
    this.documentId,
  }) : super(const DocumentFormState());

  final DocumentsRepository _repository;
  final FilePickers _pickers;
  final NotificationPermissions _permissions;
  final String? documentId;

  /// The title we filled in from a file name; replaced on the next pick
  /// unless the user has typed their own.
  String? _autoTitle;

  Future<void> load() async {
    final id = documentId;
    if (id == null) {
      emit(state.copyWith(loading: false));
      return;
    }
    final d = await _repository.watchDocument(id).first;
    if (isClosed) return;
    if (d == null) {
      emit(state.copyWith(loading: false, failure: const NotFoundFailure()));
      return;
    }
    emit(
      state.copyWith(
        loading: false,
        documentId: d.id,
        file: FormFile(
          name: d.originalName,
          type: d.fileType,
          sizeBytes: d.sizeBytes,
        ),
        title: d.title,
        description: d.description,
        category: d.category,
        expiryDate: () => d.expiryDate,
        expiryReminder: d.expiryReminder,
        isFavourite: d.isFavourite,
      ),
    );
  }

  Future<void> scanWithCamera() => _pick(_pickers.takePhoto);

  Future<void> pickFile() => _pick(_pickers.chooseDocument);

  /// Checks the file right away so a wrong type is reported on pick, not
  /// on save. The repository checks again when saving.
  Future<void> _pick(Future<PickedFile?> Function() pick) async {
    if (state.picking || state.busy) return;
    emit(state.copyWith(picking: true, clearFailure: true));
    final picked = await pick();
    if (isClosed) return;
    if (picked == null) {
      emit(state.copyWith(picking: false));
      return;
    }
    final check = await FileTypeValidator.check(
      picked.file,
      originalName: picked.name,
    );
    if (isClosed) return;
    switch (check) {
      case FileUnsupported():
        emit(
          state.copyWith(
            picking: false,
            failure: const UnsupportedFileFailure(),
          ),
        );
      case FileTooLarge(:final maxBytes):
        emit(
          state.copyWith(
            picking: false,
            failure: FileTooLargeFailure(maxBytes),
          ),
        );
      case FileAccepted(:final type, :final sizeBytes):
        final suggested = p.basenameWithoutExtension(picked.name).trim();
        final useSuggestion = state.titleMissing || state.title == _autoTitle;
        if (useSuggestion) _autoTitle = suggested;
        emit(
          state.copyWith(
            picking: false,
            dirty: true,
            file: FormFile(
              name: picked.name,
              type: type,
              sizeBytes: sizeBytes,
              picked: picked,
            ),
            title: useSuggestion ? suggested : null,
          ),
        );
    }
  }

  void titleChanged(String v) {
    _autoTitle = null;
    emit(state.copyWith(title: v, dirty: true));
  }

  void descriptionChanged(String v) =>
      emit(state.copyWith(description: v, dirty: true));

  void categoryChanged(DocumentCategory c) =>
      emit(state.copyWith(category: c, dirty: true));

  void expiryChanged(DateTime? d) =>
      emit(state.copyWith(expiryDate: () => d, dirty: true));

  void expiryReminderChanged({required bool value}) =>
      emit(state.copyWith(expiryReminder: value, dirty: true));

  void favouriteChanged({required bool value}) =>
      emit(state.copyWith(isFavourite: value, dirty: true));

  Future<void> save() async {
    if (state.busy || state.picking) return;
    final category = state.category;
    final file = state.file;
    if (state.hasErrors || category == null || file == null) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(busy: true, clearFailure: true));
    final draft = DocumentDraft(
      id: state.documentId,
      title: state.title,
      description: state.description,
      category: category,
      expiryDate: state.expiryDate,
      expiryReminder: state.expiryReminder,
      isFavourite: state.isFavourite,
    );
    final picked = file.picked;
    final Result<void> r;
    if (state.isNew && picked != null) {
      r = await _repository.add(
        draft,
        source: picked.file,
        originalName: picked.name,
      );
    } else {
      r = await _repository.update(
        draft,
        replacement: picked?.file,
        replacementName: picked?.name,
      );
    }
    if (isClosed) return;
    if (r case Err(:final failure)) {
      emit(state.copyWith(busy: false, failure: failure));
      return;
    }
    final blocked =
        state.remindsOfExpiry && !await _permissions.ensurePermission();
    if (isClosed) return;
    emit(
      state.copyWith(
        busy: false,
        dirty: false,
        notificationsBlocked: blocked,
        outcome: EditorOutcome.saved,
      ),
    );
  }

  void clearFailure() => emit(state.copyWith(clearFailure: true));
}

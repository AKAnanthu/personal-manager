import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_details_repository.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';

/// A user-added label/value row. [localKey] is stable for list rendering.
final class CustomFieldDraft extends Equatable {
  const CustomFieldDraft({
    required this.localKey,
    required this.key,
    this.label = '',
    this.value = '',
  });

  final int localKey;

  /// Stored field key (kept across edits).
  final String key;
  final String label;
  final String value;

  CustomFieldDraft copyWith({String? label, String? value}) => CustomFieldDraft(
    localKey: localKey,
    key: key,
    label: label ?? this.label,
    value: value ?? this.value,
  );

  @override
  List<Object?> get props => [localKey, key, label, value];
}

final class EntryEditorState extends Equatable {
  const EntryEditorState({
    required this.kind,
    this.loading = true,
    this.entryId,
    this.title = '',
    this.values = const {},
    this.custom = const [],
    this.linkedDocumentIds = const [],
    this.dirty = false,
    this.busy = false,
    this.showErrors = false,
    this.failure,
    this.outcome = EditorOutcome.none,
  });

  final DetailKind kind;
  final bool loading;
  final String? entryId;
  final String title;

  /// Template field values by key.
  final Map<String, String> values;
  final List<CustomFieldDraft> custom;

  /// Linked Document Manager entries (ids only; files aren't copied).
  final List<String> linkedDocumentIds;
  final bool dirty;
  final bool busy;
  final bool showErrors;
  final Failure? failure;
  final EditorOutcome outcome;

  bool get isNew => entryId == null;

  /// Named kinds need a title; the others need their first field (full
  /// name, ID number, institution, employer).
  String? get requiredKey =>
      kind.namedByUser ? null : kind.fields.firstOrNull?.key;

  bool get titleMissing => kind.namedByUser && title.trim().isEmpty;

  bool get requiredMissing {
    final k = requiredKey;
    return k != null && (values[k] ?? '').trim().isEmpty;
  }

  /// A custom row with a value but no label can't be shown sensibly.
  bool customLabelMissing(CustomFieldDraft c) =>
      c.label.trim().isEmpty && c.value.trim().isNotEmpty;

  bool get hasErrors =>
      titleMissing || requiredMissing || custom.any(customLabelMissing);

  EntryEditorState copyWith({
    DetailKind? kind,
    bool? loading,
    String? entryId,
    String? title,
    Map<String, String>? values,
    List<CustomFieldDraft>? custom,
    List<String>? linkedDocumentIds,
    bool? dirty,
    bool? busy,
    bool? showErrors,
    Failure? failure,
    bool clearFailure = false,
    EditorOutcome? outcome,
  }) => EntryEditorState(
    kind: kind ?? this.kind,
    loading: loading ?? this.loading,
    entryId: entryId ?? this.entryId,
    title: title ?? this.title,
    values: values ?? this.values,
    custom: custom ?? this.custom,
    linkedDocumentIds: linkedDocumentIds ?? this.linkedDocumentIds,
    dirty: dirty ?? this.dirty,
    busy: busy ?? this.busy,
    showErrors: showErrors ?? this.showErrors,
    failure: clearFailure ? null : (failure ?? this.failure),
    outcome: outcome ?? this.outcome,
  );

  @override
  List<Object?> get props => [
    kind,
    loading,
    entryId,
    title,
    values,
    custom,
    linkedDocumentIds,
    dirty,
    busy,
    showErrors,
    failure,
    outcome,
  ];
}

/// Add/edit one entry. With [entryId] the kind comes from the entry;
/// otherwise a new `kind` entry is added (for the profile, the existing one
/// is edited if there is one).
class EntryEditorCubit extends Cubit<EntryEditorState> {
  EntryEditorCubit({required this._repository, DetailKind? kind, this.entryId})
    : assert(kind != null || entryId != null, 'kind or entryId'),
      super(EntryEditorState(kind: kind ?? DetailKind.custom));

  final PersonalDetailsRepository _repository;
  final String? entryId;
  int _nextLocal = 0;
  int _nextCustom = 1;

  Future<void> load() async {
    final id = entryId;
    final entry = id != null
        ? await _repository.watchEntry(id).first
        : state.kind == DetailKind.profile
        ? await _repository.watchProfile().first
        : null;
    if (isClosed) return;
    if (id != null && entry == null) {
      emit(state.copyWith(loading: false, failure: const NotFoundFailure()));
      return;
    }
    if (entry == null) {
      emit(state.copyWith(loading: false));
      return;
    }
    final custom = [
      for (final f in entry.fields)
        if (f.isCustom)
          CustomFieldDraft(
            localKey: _nextLocal++,
            key: f.key,
            label: f.label ?? '',
            value: f.value,
          ),
    ];
    for (final c in custom) {
      final n = int.tryParse(c.key.replaceFirst('c', ''));
      if (n != null && n >= _nextCustom) _nextCustom = n + 1;
    }
    emit(
      state.copyWith(
        loading: false,
        kind: entry.kind,
        entryId: entry.id,
        title: entry.title,
        values: {
          for (final f in entry.fields)
            if (!f.isCustom) f.key: f.value,
        },
        custom: custom,
        linkedDocumentIds: entry.linkedDocumentIds,
      ),
    );
  }

  void titleChanged(String v) => emit(state.copyWith(title: v, dirty: true));

  void valueChanged(String key, String v) =>
      emit(state.copyWith(values: {...state.values, key: v}, dirty: true));

  void addCustomField() => emit(
    state.copyWith(
      custom: [
        ...state.custom,
        CustomFieldDraft(localKey: _nextLocal++, key: 'c${_nextCustom++}'),
      ],
      dirty: true,
    ),
  );

  void customChanged(int localKey, {String? label, String? value}) => emit(
    state.copyWith(
      custom: [
        for (final c in state.custom)
          if (c.localKey == localKey)
            c.copyWith(label: label, value: value)
          else
            c,
      ],
      dirty: true,
    ),
  );

  void removeCustomField(int localKey) => emit(
    state.copyWith(
      custom: state.custom.where((c) => c.localKey != localKey).toList(),
      dirty: true,
    ),
  );

  void linkDocument(String id) {
    if (state.linkedDocumentIds.contains(id)) return;
    emit(
      state.copyWith(
        linkedDocumentIds: [...state.linkedDocumentIds, id],
        dirty: true,
      ),
    );
  }

  void unlinkDocument(String id) => emit(
    state.copyWith(
      linkedDocumentIds: state.linkedDocumentIds.where((d) => d != id).toList(),
      dirty: true,
    ),
  );

  Future<void> save() async {
    if (state.busy) return;
    if (state.hasErrors) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(busy: true, clearFailure: true));
    final r = await _repository.save(
      PersonalEntryDraft(
        id: state.entryId,
        kind: state.kind,
        title: state.title,
        linkedDocumentIds: state.linkedDocumentIds,
        fields: [
          for (final spec in state.kind.fields)
            DetailField(key: spec.key, value: state.values[spec.key] ?? ''),
          for (final c in state.custom)
            // A row with neither label nor value is dropped.
            if (c.label.trim().isNotEmpty || c.value.trim().isNotEmpty)
              DetailField(key: c.key, label: c.label, value: c.value),
        ],
      ),
    );
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

  void clearFailure() => emit(state.copyWith(clearFailure: true));
}

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/tasks/domain/task.dart';
import 'package:personal_life_manager/features/tasks/domain/tasks_repository.dart';

/// Editable checklist row. [key] is local and stable for list rendering.
final class EditableItem extends Equatable {
  const EditableItem({
    required this.key,
    required this.label,
    this.id,
    this.isDone = false,
  });

  final int key;
  final String? id;
  final String label;
  final bool isDone;

  EditableItem copyWith({String? label, bool? isDone}) => EditableItem(
    key: key,
    id: id,
    label: label ?? this.label,
    isDone: isDone ?? this.isDone,
  );

  @override
  List<Object?> get props => [key, id, label, isDone];
}

final class TaskEditorState extends Equatable {
  const TaskEditorState({
    this.loading = true,
    this.taskId,
    this.title = '',
    this.description = '',
    this.dueDate,
    this.reminderAt,
    this.items = const [],
    this.dirty = false,
    this.busy = false,
    this.showErrors = false,
    this.failure,
    this.outcome = EditorOutcome.none,
    this.notificationsBlocked = false,
  });

  final bool loading;
  final String? taskId;
  final String title;
  final String description;
  final DateTime? dueDate;
  final DateTime? reminderAt;
  final List<EditableItem> items;
  final bool dirty;
  final bool busy;
  final bool showErrors;
  final Failure? failure;
  final EditorOutcome outcome;

  /// Saved with a reminder but notifications are not allowed.
  final bool notificationsBlocked;

  bool get isNew => taskId == null;
  bool get titleMissing => title.trim().isEmpty;

  /// Only a newly set/changed reminder must be in the future.
  bool reminderInPast(DateTime now) {
    final r = reminderAt;
    return r != null && !r.isAfter(now);
  }

  TaskEditorState copyWith({
    bool? loading,
    String? taskId,
    String? title,
    String? description,
    DateTime? Function()? dueDate,
    DateTime? Function()? reminderAt,
    List<EditableItem>? items,
    bool? dirty,
    bool? busy,
    bool? showErrors,
    Failure? failure,
    bool clearFailure = false,
    EditorOutcome? outcome,
    bool? notificationsBlocked,
  }) => TaskEditorState(
    loading: loading ?? this.loading,
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    description: description ?? this.description,
    dueDate: dueDate != null ? dueDate() : this.dueDate,
    reminderAt: reminderAt != null ? reminderAt() : this.reminderAt,
    items: items ?? this.items,
    dirty: dirty ?? this.dirty,
    busy: busy ?? this.busy,
    showErrors: showErrors ?? this.showErrors,
    failure: clearFailure ? null : (failure ?? this.failure),
    outcome: outcome ?? this.outcome,
    notificationsBlocked: notificationsBlocked ?? this.notificationsBlocked,
  );

  @override
  List<Object?> get props => [
    loading,
    taskId,
    title,
    description,
    dueDate,
    reminderAt,
    items,
    dirty,
    busy,
    showErrors,
    failure,
    outcome,
    notificationsBlocked,
  ];
}

class TaskEditorCubit extends Cubit<TaskEditorState> {
  TaskEditorCubit({
    required this._repository,
    required this._permissions,
    this.taskId,
    this._clock = DateTime.now,
  }) : super(const TaskEditorState());

  final TasksRepository _repository;
  final NotificationPermissions _permissions;
  final String? taskId;
  final DateTime Function() _clock;
  DateTime? _originalReminder;
  int _nextKey = 0;

  Future<void> load() async {
    final id = taskId;
    if (id == null) {
      emit(state.copyWith(loading: false));
      return;
    }
    final task = await _repository.watchTask(id).first;
    if (isClosed) return;
    if (task == null) {
      emit(state.copyWith(loading: false, failure: const NotFoundFailure()));
      return;
    }
    _originalReminder = task.reminderAt;
    emit(
      state.copyWith(
        loading: false,
        taskId: task.id,
        title: task.title,
        description: task.description,
        dueDate: () => task.dueDate,
        reminderAt: () => task.reminderAt,
        items: [
          for (final i in task.checklist)
            EditableItem(
              key: _nextKey++,
              id: i.id,
              label: i.label,
              isDone: i.isDone,
            ),
        ],
      ),
    );
  }

  void titleChanged(String v) => emit(state.copyWith(title: v, dirty: true));

  void descriptionChanged(String v) =>
      emit(state.copyWith(description: v, dirty: true));

  void dueDateChanged(DateTime? d) =>
      emit(state.copyWith(dueDate: () => d, dirty: true));

  void reminderChanged(DateTime? d) =>
      emit(state.copyWith(reminderAt: () => d, dirty: true));

  void addItem() => emit(
    state.copyWith(
      items: [
        ...state.items,
        EditableItem(key: _nextKey++, label: ''),
      ],
      dirty: true,
    ),
  );

  void itemChanged(int key, String label) =>
      _updateItem(key, (i) => i.copyWith(label: label));

  void itemToggled(int key, {required bool done}) =>
      _updateItem(key, (i) => i.copyWith(isDone: done));

  void removeItem(int key) => emit(
    state.copyWith(
      items: state.items.where((i) => i.key != key).toList(),
      dirty: true,
    ),
  );

  void _updateItem(int key, EditableItem Function(EditableItem) f) => emit(
    state.copyWith(
      items: [
        for (final i in state.items)
          if (i.key == key) f(i) else i,
      ],
      dirty: true,
    ),
  );

  bool _reminderInvalid() =>
      state.reminderAt != _originalReminder && state.reminderInPast(_clock());

  bool get reminderInvalid => _reminderInvalid();

  Future<void> save() async {
    if (state.busy) return;
    if (state.titleMissing || _reminderInvalid()) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(busy: true, clearFailure: true));
    final r = await _repository.save(
      TaskDraft(
        id: state.taskId,
        title: state.title,
        description: state.description,
        dueDate: state.dueDate,
        reminderAt: state.reminderAt,
        checklist: [
          for (final i in state.items)
            (id: i.id, label: i.label, isDone: i.isDone),
        ],
      ),
    );
    if (isClosed) return;
    if (!r.isSuccess) {
      emit(state.copyWith(busy: false, failure: r.fold((f) => f, (_) => null)));
      return;
    }
    final blocked =
        state.reminderAt != null && !await _permissions.ensurePermission();
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

  Future<void> delete() async {
    final id = state.taskId;
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

  void clearFailure() => emit(state.copyWith(clearFailure: true));
}

import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/utils/event_transformers.dart';
import 'package:personal_life_manager/features/tasks/domain/task.dart';
import 'package:personal_life_manager/features/tasks/domain/tasks_repository.dart';

sealed class TasksEvent {
  const TasksEvent();
}

final class TasksStarted extends TasksEvent {
  const TasksStarted();
}

final class TasksTabChanged extends TasksEvent {
  const TasksTabChanged({required this.completed});
  final bool completed;
}

final class TasksQueryChanged extends TasksEvent {
  const TasksQueryChanged(this.query);
  final String query;
}

final class TaskCompletionToggled extends TasksEvent {
  const TaskCompletionToggled(this.id, {required this.completed});
  final String id;
  final bool completed;
}

final class ChecklistItemToggled extends TasksEvent {
  const ChecklistItemToggled(this.itemId, {required this.done});
  final String itemId;
  final bool done;
}

final class _Subscribe extends TasksEvent {
  const _Subscribe();
}

final class _CountsUpdated extends TasksEvent {
  const _CountsUpdated(this.pending, this.completed);
  final int pending;
  final int completed;
}

final class TasksState extends Equatable {
  const TasksState({
    this.status = LoadStatus.loading,
    this.showCompleted = false,
    this.query = '',
    this.tasks = const [],
    this.pendingCount = 0,
    this.completedCount = 0,
    this.failure,
    this.justCompleted,
  });

  final LoadStatus status;
  final bool showCompleted;
  final String query;
  final List<Task> tasks;
  final int pendingCount;
  final int completedCount;
  final Failure? failure;

  /// Set after a task is completed, for the undo snackbar.
  final String? justCompleted;

  TasksState copyWith({
    LoadStatus? status,
    bool? showCompleted,
    String? query,
    List<Task>? tasks,
    int? pendingCount,
    int? completedCount,
    Failure? failure,
    String? justCompleted,
    bool clearTransient = false,
  }) => TasksState(
    status: status ?? this.status,
    showCompleted: showCompleted ?? this.showCompleted,
    query: query ?? this.query,
    tasks: tasks ?? this.tasks,
    pendingCount: pendingCount ?? this.pendingCount,
    completedCount: completedCount ?? this.completedCount,
    failure: clearTransient ? null : (failure ?? this.failure),
    justCompleted: clearTransient
        ? null
        : (justCompleted ?? this.justCompleted),
  );

  @override
  List<Object?> get props => [
    status,
    showCompleted,
    query,
    tasks,
    pendingCount,
    completedCount,
    failure,
    justCompleted,
  ];
}

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc(this._repository) : super(const TasksState()) {
    on<TasksStarted>((_, _) {
      _countSub ??= _repository.watchCounts().listen(
        (c) => add(_CountsUpdated(c.pending, c.completed)),
      );
      add(const _Subscribe());
    });
    on<TasksTabChanged>((e, emit) {
      emit(
        state.copyWith(
          showCompleted: e.completed,
          status: LoadStatus.loading,
          tasks: const [],
          clearTransient: true,
        ),
      );
      add(const _Subscribe());
    });
    on<TasksQueryChanged>((e, emit) {
      emit(state.copyWith(query: e.query));
      add(const _Subscribe());
    }, transformer: debounceRestartable());
    on<_Subscribe>(
      (_, emit) => emit.forEach<List<Task>>(
        _repository.watchTasks(
          completed: state.showCompleted,
          query: state.query,
        ),
        onData: (tasks) =>
            state.copyWith(tasks: tasks, status: LoadStatus.ready),
        onError: (_, _) => state.copyWith(status: LoadStatus.failure),
      ),
      transformer: restartable(),
    );
    on<_CountsUpdated>(
      (e, emit) => emit(
        state.copyWith(pendingCount: e.pending, completedCount: e.completed),
      ),
    );
    on<TaskCompletionToggled>((e, emit) async {
      emit(state.copyWith(clearTransient: true));
      final r = await _repository.setCompleted(e.id, value: e.completed);
      emit(
        r.fold(
          (f) => state.copyWith(failure: f),
          (_) => e.completed ? state.copyWith(justCompleted: e.id) : state,
        ),
      );
    });
    on<ChecklistItemToggled>((e, emit) async {
      final r = await _repository.setChecklistItemDone(e.itemId, value: e.done);
      if (r case Err(:final failure)) emit(state.copyWith(failure: failure));
    });
  }

  final TasksRepository _repository;
  StreamSubscription<({int pending, int completed})>? _countSub;

  @override
  Future<void> close() async {
    await _countSub?.cancel();
    await super.close();
  }
}

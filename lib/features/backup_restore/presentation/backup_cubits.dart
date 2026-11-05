import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_platform.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_service.dart';
import 'package:personal_life_manager/features/backup_restore/domain/backup.dart';

// ---- Back up --------------------------------------------------------------

enum BackupPhase { idle, estimating, confirming, building, built, done }

enum BackupDestination { device, share }

final class BackupState extends Equatable {
  const BackupState({
    this.selected = const {},
    this.phase = BackupPhase.idle,
    this.lastBackup,
    this.estimate,
    this.file,
    this.size,
    this.error = false,
  });

  final Set<BackupCategory> selected;
  final BackupPhase phase;
  final LastBackup? lastBackup;
  final BackupEstimate? estimate;

  /// The built backup, waiting for a destination.
  final File? file;
  final int? size;

  /// Something went wrong (shown once, then cleared).
  final bool error;

  bool get busy =>
      phase == BackupPhase.estimating || phase == BackupPhase.building;
  bool get includesSensitive => selected.any((c) => c.sensitive);

  BackupState copyWith({
    Set<BackupCategory>? selected,
    BackupPhase? phase,
    LastBackup? lastBackup,
    BackupEstimate? Function()? estimate,
    File? Function()? file,
    int? Function()? size,
    bool? error,
  }) => BackupState(
    selected: selected ?? this.selected,
    phase: phase ?? this.phase,
    lastBackup: lastBackup ?? this.lastBackup,
    estimate: estimate != null ? estimate() : this.estimate,
    file: file != null ? file() : this.file,
    size: size != null ? size() : this.size,
    error: error ?? false,
  );

  @override
  List<Object?> get props => [
    selected,
    phase,
    lastBackup,
    estimate,
    file?.path,
    size,
    error,
  ];
}

/// Manual backups only: choose → review the summary → build → choose where
/// it goes. Cancellable at every step; temp files are always removed.
class BackupCubit extends Cubit<BackupState> {
  BackupCubit({
    required this._service,
    required this._files,
    required this._last,
    this._clock = DateTime.now,
  }) : super(BackupState(selected: BackupCategory.defaults));

  final BackupService _service;
  final BackupFiles _files;
  final LastBackupStore _last;
  final DateTime Function() _clock;
  CancelToken? _token;

  Future<void> load() async {
    final last = await _last.load();
    if (!isClosed && last != null) emit(state.copyWith(lastBackup: last));
  }

  void toggle(BackupCategory c) {
    if (state.phase != BackupPhase.idle) return;
    final s = {...state.selected};
    if (!s.remove(c)) s.add(c);
    emit(state.copyWith(selected: s));
  }

  /// Step 1: counts and estimated size for the confirmation.
  Future<void> prepare() async {
    if (state.selected.isEmpty || state.phase != BackupPhase.idle) return;
    emit(state.copyWith(phase: BackupPhase.estimating));
    try {
      final e = await _service.estimate(state.selected);
      if (isClosed || state.phase != BackupPhase.estimating) return;
      emit(state.copyWith(phase: BackupPhase.confirming, estimate: () => e));
    } on Exception {
      if (!isClosed) emit(state.copyWith(phase: BackupPhase.idle, error: true));
    }
  }

  /// Step 2: the user confirmed; build the file.
  Future<void> build() async {
    if (state.phase != BackupPhase.confirming) return;
    final token = _token = CancelToken();
    emit(state.copyWith(phase: BackupPhase.building));
    try {
      final file = await _service.create(state.selected, token: token);
      final size = await file.length();
      if (isClosed || token.isCancelled) {
        await _service.discard(file.path);
        return;
      }
      emit(
        state.copyWith(
          phase: BackupPhase.built,
          file: () => file,
          size: () => size,
        ),
      );
    } on Cancelled {
      // cancel() already reset the state.
    } on Exception {
      if (!isClosed) _reset(error: true);
    }
  }

  /// Step 3: save it. Cancelling the save dialog keeps the file so the
  /// user can choose again.
  Future<void> deliver(BackupDestination d) async {
    final file = state.file;
    final size = state.size;
    if (state.phase != BackupPhase.built || file == null || size == null) {
      return;
    }
    try {
      switch (d) {
        case BackupDestination.device:
          if (!await _files.saveToDevice(file)) return;
        case BackupDestination.share:
          await _files.share(file);
      }
    } on Exception {
      if (!isClosed) emit(state.copyWith(error: true));
      return;
    }
    final last = LastBackup(at: _clock(), size: size);
    await _last.save(last);
    await _service.discard(file.path);
    if (isClosed) return;
    emit(
      state.copyWith(
        phase: BackupPhase.done,
        lastBackup: last,
        file: () => null,
      ),
    );
  }

  /// Stops whatever step is running and removes the temp file.
  Future<void> cancel() async {
    _token?.cancel();
    final file = state.file;
    if (file != null) await _service.discard(file.path);
    if (!isClosed) _reset();
  }

  void _reset({bool error = false}) => emit(
    state.copyWith(
      phase: BackupPhase.idle,
      estimate: () => null,
      file: () => null,
      size: () => null,
      error: error,
    ),
  );

  @override
  Future<void> close() async {
    _token?.cancel();
    final file = state.file;
    if (file != null) await _service.discard(file.path);
    await super.close();
  }
}

// ---- Restore --------------------------------------------------------------

enum RestorePhase { idle, checking, preview, restoring, done }

final class RestoreState extends Equatable {
  const RestoreState({
    this.phase = RestorePhase.idle,
    this.preview,
    this.selected = const {},
    this.strategy = RestoreStrategy.merge,
    this.restored = const {},
    this.problem,
    this.error = false,
  });

  final RestorePhase phase;
  final BackupPreview? preview;
  final Set<BackupCategory> selected;
  final RestoreStrategy strategy;
  final Map<BackupCategory, int> restored;

  /// Why the picked file can't be used (shown once).
  final BackupProblem? problem;
  final bool error;

  RestoreState copyWith({
    RestorePhase? phase,
    BackupPreview? Function()? preview,
    Set<BackupCategory>? selected,
    RestoreStrategy? strategy,
    Map<BackupCategory, int>? restored,
    BackupProblem? problem,
    bool? error,
  }) => RestoreState(
    phase: phase ?? this.phase,
    preview: preview != null ? preview() : this.preview,
    selected: selected ?? this.selected,
    strategy: strategy ?? this.strategy,
    restored: restored ?? this.restored,
    problem: problem,
    error: error ?? false,
  );

  @override
  List<Object?> get props => [
    phase,
    preview,
    selected,
    strategy,
    restored,
    problem,
    error,
  ];
}

/// Pick a file → it's checked and previewed → choose categories and how
/// to restore → restore. Unselected categories are never touched.
class RestoreCubit extends Cubit<RestoreState> {
  RestoreCubit({required this._service, required this._files})
    : super(const RestoreState());

  final BackupService _service;
  final BackupFiles _files;
  CancelToken? _token;

  Future<void> pick() async {
    if (state.phase == RestorePhase.checking ||
        state.phase == RestorePhase.restoring) {
      return;
    }
    final file = await _files.pickBackup();
    if (file == null || isClosed) return;
    await _discardPreview();
    final token = _token = CancelToken();
    emit(state.copyWith(phase: RestorePhase.checking, preview: () => null));
    try {
      final preview = await _service.inspect(file, token: token);
      if (isClosed || token.isCancelled) {
        await _service.discard(preview.stagingPath);
        return;
      }
      emit(
        state.copyWith(
          phase: RestorePhase.preview,
          preview: () => preview,
          selected: preview.manifest.categories.toSet(),
          strategy: RestoreStrategy.merge,
        ),
      );
    } on BackupInvalid catch (e) {
      if (!isClosed) {
        emit(state.copyWith(phase: RestorePhase.idle, problem: e.problem));
      }
    } on Cancelled {
      // cancel() reset the state.
    } on Exception {
      if (!isClosed) {
        emit(state.copyWith(phase: RestorePhase.idle, error: true));
      }
    }
  }

  void toggle(BackupCategory c) {
    if (state.phase != RestorePhase.preview) return;
    final s = {...state.selected};
    if (!s.remove(c)) s.add(c);
    emit(state.copyWith(selected: s));
  }

  void strategyChanged(RestoreStrategy s) => emit(state.copyWith(strategy: s));

  /// Call after the user confirmed.
  Future<void> restore() async {
    final preview = state.preview;
    if (state.phase != RestorePhase.preview ||
        preview == null ||
        state.selected.isEmpty) {
      return;
    }
    emit(state.copyWith(phase: RestorePhase.restoring));
    try {
      final restored = await _service.restore(
        preview,
        state.selected,
        state.strategy,
      );
      await _service.discard(preview.stagingPath);
      if (isClosed) return;
      emit(
        state.copyWith(
          phase: RestorePhase.done,
          preview: () => null,
          restored: restored,
        ),
      );
    } on BackupInvalid catch (e) {
      if (!isClosed) {
        emit(state.copyWith(phase: RestorePhase.preview, problem: e.problem));
      }
    } on Exception {
      // The failed category was rolled back; the user can try again.
      if (!isClosed) {
        emit(state.copyWith(phase: RestorePhase.preview, error: true));
      }
    }
  }

  Future<void> cancel() async {
    _token?.cancel();
    await _discardPreview();
    if (!isClosed) {
      emit(const RestoreState());
    }
  }

  Future<void> _discardPreview() async {
    final p = state.preview;
    if (p != null) await _service.discard(p.stagingPath);
  }

  @override
  Future<void> close() async {
    _token?.cancel();
    if (state.phase != RestorePhase.restoring) await _discardPreview();
    await super.close();
  }
}

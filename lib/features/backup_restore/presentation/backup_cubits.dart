import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/drive/drive_auth.dart';
import 'package:personal_life_manager/core/drive/drive_folders.dart';
import 'package:personal_life_manager/core/drive/drive_models.dart';
import 'package:personal_life_manager/core/drive/drive_service.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_platform.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_service.dart';
import 'package:personal_life_manager/features/backup_restore/domain/backup.dart';

// ---- Back up --------------------------------------------------------------

enum BackupPhase {
  idle,
  estimating,
  confirming,
  building,
  built,
  uploading,
  done,
}

enum BackupDestination { device, share, drive }

/// Drive pieces the backup screens use; absent when Drive isn't set up.
final class BackupDrive {
  const BackupDrive({
    required this.auth,
    required this.service,
    required this.folders,
  });

  final DriveAuth auth;
  final DriveService service;
  final DriveFolders folders;

  /// Connects first when needed. False when the user backed out or it
  /// failed ([onFailure] gets the reason).
  Future<bool> ensureConnected(void Function(Failure) onFailure) async {
    if (auth.account.value != null) return true;
    switch (await auth.connect()) {
      case Ok(value: final email):
        return email != null;
      case Err(:final failure):
        onFailure(failure);
        return false;
    }
  }
}

final class BackupState extends Equatable {
  const BackupState({
    this.selected = const {},
    this.phase = BackupPhase.idle,
    this.lastBackup,
    this.estimate,
    this.file,
    this.size,
    this.error = false,
    this.toDrive = false,
    this.uploadProgress = 0,
    this.failure,
    this.savedToDrive = false,
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

  /// Save to Drive's Backups folder rather than the phone.
  final bool toDrive;
  final double uploadProgress;

  /// Why the Drive upload failed (shown once).
  final Failure? failure;

  /// The finished backup went to Drive.
  final bool savedToDrive;

  bool get busy =>
      phase == BackupPhase.estimating ||
      phase == BackupPhase.building ||
      phase == BackupPhase.uploading;
  bool get includesSensitive => selected.any((c) => c.sensitive);

  BackupState copyWith({
    Set<BackupCategory>? selected,
    BackupPhase? phase,
    LastBackup? lastBackup,
    BackupEstimate? Function()? estimate,
    File? Function()? file,
    int? Function()? size,
    bool? error,
    bool? toDrive,
    double? uploadProgress,
    Failure? failure,
    bool? savedToDrive,
  }) => BackupState(
    toDrive: toDrive ?? this.toDrive,
    uploadProgress: uploadProgress ?? this.uploadProgress,
    failure: failure,
    savedToDrive: savedToDrive ?? this.savedToDrive,
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
    toDrive,
    uploadProgress,
    failure,
    savedToDrive,
  ];
}

/// Manual backups only: choose → review the summary → build → choose where
/// it goes. Cancellable at every step; temp files are always removed.
class BackupCubit extends Cubit<BackupState> {
  BackupCubit({
    required this._service,
    required this._files,
    required this._last,
    this._drive,
    this._clock = DateTime.now,
  }) : super(BackupState(selected: BackupCategory.defaults));

  final BackupService _service;
  final BackupFiles _files;
  final LastBackupStore _last;
  final BackupDrive? _drive;
  final DateTime Function() _clock;
  CancelToken? _token;

  bool get driveAvailable => _drive != null;

  /// The connected Drive account, if any.
  String? get driveAccount => _drive?.auth.account.value;

  void chooseDrive({required bool value}) {
    if (state.phase != BackupPhase.idle || (value && _drive == null)) return;
    emit(state.copyWith(toDrive: value));
  }

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
    if (d == BackupDestination.drive) {
      await _toDrive(file, size);
      return;
    }
    try {
      switch (d) {
        case BackupDestination.device:
          if (!await _files.saveToDevice(file)) return;
        case BackupDestination.share:
          await _files.share(file);
        case BackupDestination.drive:
          return;
      }
    } on Exception {
      if (!isClosed) emit(state.copyWith(error: true));
      return;
    }
    await _finish(file, size);
  }

  /// Uploads to `Backups/` on Drive. On failure the file is kept and the
  /// user is offered the phone instead.
  Future<void> _toDrive(File file, int size) async {
    final drive = _drive;
    if (drive == null) return;
    Failure? failure;
    final connected = await drive.ensureConnected((f) => failure = f);
    if (isClosed) return;
    if (!connected) {
      _driveFailed(failure);
      return;
    }
    final token = _token = CancelToken();
    emit(state.copyWith(phase: BackupPhase.uploading, uploadProgress: 0));
    final folder = await drive.folders.resolve(DriveLayout.backupsFolder);
    final r = switch (folder) {
      Err(:final failure) => Err<DriveItem>(failure),
      Ok(value: final parentId) => await drive.service.upload(
        file,
        name: p.basename(file.path),
        parentId: parentId,
        mimeType: 'application/zip',
        token: token,
        onProgress: (done, total) {
          if (!isClosed && total > 0) {
            emit(state.copyWith(uploadProgress: done / total));
          }
        },
      ),
    };
    if (isClosed) return;
    switch (r) {
      case Ok():
        await _finish(file, size, toDrive: true);
      case Err(failure: DriveFailure(problem: DriveProblem.cancelled)):
        // cancel() already cleaned up.
        break;
      case Err(:final failure):
        _driveFailed(failure);
    }
  }

  /// Back to "built", now offering the phone (no automatic retry loop).
  void _driveFailed(Failure? f) => emit(
    state.copyWith(phase: BackupPhase.built, toDrive: false, failure: f),
  );

  Future<void> _finish(File file, int size, {bool toDrive = false}) async {
    final last = LastBackup(at: _clock(), size: size);
    await _last.save(last);
    await _service.discard(file.path);
    if (isClosed) return;
    emit(
      state.copyWith(
        phase: BackupPhase.done,
        lastBackup: last,
        file: () => null,
        savedToDrive: toDrive,
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
      uploadProgress: 0,
      savedToDrive: false,
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
    this.failure,
  });

  final RestorePhase phase;
  final BackupPreview? preview;
  final Set<BackupCategory> selected;
  final RestoreStrategy strategy;
  final Map<BackupCategory, int> restored;

  /// Why the picked file can't be used (shown once).
  final BackupProblem? problem;
  final bool error;

  /// Why fetching from Drive failed (shown once).
  final Failure? failure;

  RestoreState copyWith({
    RestorePhase? phase,
    BackupPreview? Function()? preview,
    Set<BackupCategory>? selected,
    RestoreStrategy? strategy,
    Map<BackupCategory, int>? restored,
    BackupProblem? problem,
    bool? error,
    Failure? failure,
  }) => RestoreState(
    failure: failure,
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
    failure,
  ];
}

/// Pick a file → it's checked and previewed → choose categories and how
/// to restore → restore. Unselected categories are never touched.
class RestoreCubit extends Cubit<RestoreState> {
  RestoreCubit({
    required this._service,
    required this._files,
    this._drive,
    this._tempDir,
  }) : super(const RestoreState());

  final BackupService _service;
  final BackupFiles _files;
  final BackupDrive? _drive;

  /// Where a backup fetched from Drive is put while it's checked.
  final Directory? _tempDir;
  CancelToken? _token;

  bool get driveAvailable => _drive != null && _tempDir != null;

  bool get _busy =>
      state.phase == RestorePhase.checking ||
      state.phase == RestorePhase.restoring;

  Future<void> pick() async {
    if (_busy) return;
    final file = await _files.pickBackup();
    if (file == null || isClosed) return;
    await _inspect(file);
  }

  /// Backups in Drive's `Backups/` folder, newest first. Connects first
  /// when needed; Ok(null) when the user backed out.
  Future<Result<List<DriveItem>?>> driveBackups() async {
    final drive = _drive;
    if (drive == null) return const Ok(null);
    Failure? failure;
    if (!await drive.ensureConnected((f) => failure = f)) {
      final f = failure;
      return f == null ? const Ok(null) : Err(f);
    }
    final folder = await drive.folders.resolve(DriveLayout.backupsFolder);
    final String id;
    switch (folder) {
      case Ok(:final value):
        id = value;
      case Err(:final failure):
        return Err(failure);
    }
    final items = <DriveItem>[];
    String? page;
    do {
      switch (await drive.service.list(id, pageToken: page)) {
        case Ok(:final value):
          items.addAll(value.items.where((i) => !i.isFolder));
          page = value.nextPageToken;
        case Err(:final failure):
          return Err(failure);
      }
    } while (page != null && items.length < 500);
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    items.sort(
      (a, b) => (b.modifiedAt ?? epoch).compareTo(a.modifiedAt ?? epoch),
    );
    return Ok(items);
  }

  /// Downloads [item] from Drive, then checks it like a picked file.
  Future<void> pickFromDrive(DriveItem item) async {
    final drive = _drive;
    final temp = _tempDir;
    if (drive == null || temp == null || _busy) return;
    await _discardPreview();
    final token = _token = CancelToken();
    emit(state.copyWith(phase: RestorePhase.checking, preview: () => null));
    final dir = Directory(p.join(temp.path, 'restore_${item.id}'));
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, 'backup.plmbackup'));
    try {
      final r = await drive.service.download(item.id, file, token: token);
      if (isClosed || token.isCancelled) return;
      switch (r) {
        case Ok():
          await _inspect(file, fetched: token);
        case Err(:final failure):
          emit(state.copyWith(phase: RestorePhase.idle, failure: failure));
      }
    } finally {
      // The checked copy lives in the staging folder from here on.
      if (dir.existsSync()) await dir.delete(recursive: true);
    }
  }

  Future<void> _inspect(File file, {CancelToken? fetched}) async {
    var token = fetched;
    if (token == null) {
      await _discardPreview();
      token = _token = CancelToken();
      emit(state.copyWith(phase: RestorePhase.checking, preview: () => null));
    }
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

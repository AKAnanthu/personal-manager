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
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:uuid/uuid.dart';

/// Every folder the app creates on connect (PRD §16.2).
List<List<String>> standardDriveFolders() => [
  for (final c in DocumentCategory.values)
    DriveLayout.documentFolder(c.driveFolder),
  DriveLayout.backupsFolder,
  DriveLayout.receiptsFolder,
];

final class DriveCrumb extends Equatable {
  const DriveCrumb(this.id, this.name);

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// An upload started from this screen.
final class DriveUpload extends Equatable {
  const DriveUpload({
    required this.key,
    required this.name,
    required this.folderId,
    required this.source,
    this.progress = 0,
    this.failure,
  });

  final String key;
  final String name;
  final String folderId;
  final File source;
  final double progress;

  /// Set when it failed; the user may retry.
  final Failure? failure;

  DriveUpload copyWith({double? progress, Failure? Function()? failure}) =>
      DriveUpload(
        key: key,
        name: name,
        folderId: folderId,
        source: source,
        progress: progress ?? this.progress,
        failure: failure != null ? failure() : this.failure,
      );

  @override
  List<Object?> get props => [
    key,
    name,
    folderId,
    source.path,
    progress,
    failure,
  ];
}

enum DriveNotice { uploaded, deleted, saved, disconnected }

final class DriveBrowserState extends Equatable {
  const DriveBrowserState({
    this.account,
    this.status = LoadStatus.loading,
    this.problem,
    this.crumbs = const [],
    this.items = const [],
    this.nextPageToken,
    this.loadingMore = false,
    this.counts = const {},
    this.uploads = const [],
    this.busyItemId,
    this.connecting = false,
    this.failure,
    this.notice,
  });

  /// Connected account; null when not connected.
  final String? account;
  final LoadStatus status;

  /// Why the folder couldn't be shown.
  final DriveProblem? problem;
  final List<DriveCrumb> crumbs;
  final List<DriveItem> items;
  final String? nextPageToken;
  final bool loadingMore;

  /// Folder ID → number of items in it.
  final Map<String, int> counts;
  final List<DriveUpload> uploads;

  /// A file being fetched to open or save.
  final String? busyItemId;
  final bool connecting;

  /// One-off messages (shown, then cleared).
  final Failure? failure;
  final DriveNotice? notice;

  DriveCrumb? get current => crumbs.lastOrNull;
  List<DriveItem> get folders => [
    for (final i in items)
      if (i.isFolder) i,
  ];
  List<DriveItem> get files => [
    for (final i in items)
      if (!i.isFolder) i,
  ];
  List<DriveUpload> get uploadsHere => [
    for (final u in uploads)
      if (u.folderId == current?.id) u,
  ];

  DriveBrowserState copyWith({
    String? Function()? account,
    LoadStatus? status,
    DriveProblem? Function()? problem,
    List<DriveCrumb>? crumbs,
    List<DriveItem>? items,
    String? Function()? nextPageToken,
    bool? loadingMore,
    Map<String, int>? counts,
    List<DriveUpload>? uploads,
    String? Function()? busyItemId,
    bool? connecting,
    Failure? failure,
    DriveNotice? notice,
  }) => DriveBrowserState(
    account: account != null ? account() : this.account,
    status: status ?? this.status,
    problem: problem != null ? problem() : this.problem,
    crumbs: crumbs ?? this.crumbs,
    items: items ?? this.items,
    nextPageToken: nextPageToken != null ? nextPageToken() : this.nextPageToken,
    loadingMore: loadingMore ?? this.loadingMore,
    counts: counts ?? this.counts,
    uploads: uploads ?? this.uploads,
    busyItemId: busyItemId != null ? busyItemId() : this.busyItemId,
    connecting: connecting ?? this.connecting,
    failure: failure,
    notice: notice,
  );

  @override
  List<Object?> get props => [
    account,
    status,
    problem,
    crumbs,
    items,
    nextPageToken,
    loadingMore,
    counts,
    uploads,
    busyItemId,
    connecting,
    failure,
    notice,
  ];
}

/// Drive Storage (PRD §16.4): connect, browse the app's folder only,
/// open, download, upload and delete files.
class DriveBrowserCubit extends Cubit<DriveBrowserState> {
  DriveBrowserCubit({
    required this._auth,
    required this._drive,
    required this._folders,
    required this._tempDir,
    this._uuid = const Uuid(),
  }) : super(const DriveBrowserState());

  final DriveAuth _auth;
  final DriveService _drive;
  final DriveFolders _folders;
  final Directory _tempDir;
  final Uuid _uuid;
  final _tokens = <String, CancelToken>{};
  final _downloads = <String, CancelToken>{};

  /// Ignores answers for a folder the user already left.
  int _generation = 0;

  Future<void> start() async {
    _auth.account.addListener(_onAccount);
    await _accountChanged();
  }

  void _onAccount() => unawaited(_accountChanged());

  Future<void> _accountChanged() async {
    final account = _auth.account.value;
    if (isClosed || (account == state.account && state.crumbs.isNotEmpty)) {
      return;
    }
    if (account == null) {
      _generation++;
      emit(
        DriveBrowserState(
          status: LoadStatus.ready,
          uploads: state.uploads,
          notice: state.notice,
        ),
      );
      return;
    }
    emit(state.copyWith(account: () => account));
    await openRoot();
  }

  /// Makes sure the folder layout exists, then shows its top.
  Future<void> openRoot() async {
    final gen = ++_generation;
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        problem: () => null,
        items: const [],
      ),
    );
    final made = await _folders.bootstrap(standardDriveFolders());
    if (made case Err(:final failure)) {
      if (!isClosed && gen == _generation) _showProblem(failure);
      return;
    }
    final root = await _folders.resolve(const []);
    if (isClosed || gen != _generation) return;
    switch (root) {
      case Ok(:final value):
        emit(state.copyWith(crumbs: [DriveCrumb(value, DriveLayout.root)]));
        await _load();
      case Err(:final failure):
        _showProblem(failure);
    }
  }

  void _showProblem(Failure f) => emit(
    state.copyWith(
      status: LoadStatus.failure,
      problem: () => f is DriveFailure ? f.problem : DriveProblem.unknown,
    ),
  );

  Future<void> _load() async {
    final folder = state.current;
    if (folder == null) return;
    final gen = ++_generation;
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        problem: () => null,
        items: const [],
        nextPageToken: () => null,
      ),
    );
    final r = await _drive.list(folder.id);
    if (isClosed || gen != _generation) return;
    switch (r) {
      case Ok(:final value):
        emit(
          state.copyWith(
            status: LoadStatus.ready,
            items: value.items,
            nextPageToken: () => value.nextPageToken,
          ),
        );
        unawaited(_countFolders(value.items, gen));
      case Err(:final failure):
        _showProblem(failure);
    }
  }

  /// "6 files" under each folder tile; filled in as answers arrive.
  Future<void> _countFolders(List<DriveItem> items, int gen) async {
    for (final f in items.where((i) => i.isFolder)) {
      final r = await _drive.count(f.id);
      if (isClosed || gen != _generation) return;
      if (r case Ok(:final value)) {
        emit(state.copyWith(counts: {...state.counts, f.id: value}));
      }
    }
  }

  Future<void> loadMore() async {
    final token = state.nextPageToken;
    final folder = state.current;
    if (token == null || folder == null || state.loadingMore) return;
    final gen = _generation;
    emit(state.copyWith(loadingMore: true));
    final r = await _drive.list(folder.id, pageToken: token);
    if (isClosed || gen != _generation) return;
    emit(
      r.fold(
        (f) => state.copyWith(loadingMore: false, failure: f),
        (page) => state.copyWith(
          loadingMore: false,
          items: [...state.items, ...page.items],
          nextPageToken: () => page.nextPageToken,
        ),
      ),
    );
  }

  Future<void> openFolder(DriveItem folder) async {
    if (!folder.isFolder) return;
    final crumb = DriveCrumb(folder.id, folder.name);
    emit(state.copyWith(crumbs: [...state.crumbs, crumb]));
    await _load();
  }

  /// Back to a folder in the path.
  Future<void> openCrumb(int index) async {
    if (index < 0 || index >= state.crumbs.length - 1) return;
    emit(state.copyWith(crumbs: state.crumbs.sublist(0, index + 1)));
    await _load();
  }

  /// Back one level; false at the top (the page may close).
  bool up() {
    if (state.crumbs.length <= 1) return false;
    unawaited(openCrumb(state.crumbs.length - 2));
    return true;
  }

  Future<void> refresh() => state.crumbs.isEmpty ? openRoot() : _load();

  Future<void> connect() async {
    if (state.connecting) return;
    emit(state.copyWith(connecting: true));
    final r = await _auth.connect();
    if (isClosed) return;
    emit(
      state.copyWith(
        connecting: false,
        failure: r is Err<String?> ? r.failure : null,
      ),
    );
    // A successful connect arrives through the account listener.
  }

  /// After "access expired": ask again, then reload.
  Future<void> reconnect() async {
    try {
      final client = await _auth.client(prompt: true);
      client.close();
      await refresh();
    } on DriveException catch (e) {
      if (!isClosed && e.problem != DriveProblem.cancelled) {
        emit(state.copyWith(failure: DriveFailure(e.problem)));
      }
    }
  }

  Future<void> disconnect() async {
    for (final t in _tokens.values) {
      t.cancel();
    }
    await _auth.disconnect();
    await _folders.clear();
    if (!isClosed) emit(state.copyWith(notice: DriveNotice.disconnected));
  }

  // ---- Upload -------------------------------------------------------------

  /// Uploads [file] into the folder on screen.
  Future<void> upload(File file, String name) async {
    final folder = state.current;
    if (folder == null) return;
    final u = DriveUpload(
      key: _uuid.v4(),
      name: name,
      folderId: folder.id,
      source: file,
    );
    emit(state.copyWith(uploads: [...state.uploads, u]));
    await _send(u);
  }

  Future<void> retryUpload(String key) async {
    final u = state.uploads.where((x) => x.key == key).firstOrNull;
    if (u == null || u.failure == null) return;
    final fresh = u.copyWith(progress: 0, failure: () => null);
    _replaceUpload(fresh);
    await _send(fresh);
  }

  void cancelUpload(String key) => _tokens[key]?.cancel();

  void dismissUpload(String key) => emit(
    state.copyWith(
      uploads: [
        for (final x in state.uploads)
          if (x.key != key) x,
      ],
    ),
  );

  void _replaceUpload(DriveUpload u) => emit(
    state.copyWith(
      uploads: state.uploads.map((x) => x.key == u.key ? u : x).toList(),
    ),
  );

  DriveUpload? _upload(String key) =>
      state.uploads.where((x) => x.key == key).firstOrNull;

  Future<void> _send(DriveUpload u) async {
    final token = _tokens[u.key] = CancelToken();
    final r = await _drive.upload(
      u.source,
      name: u.name,
      parentId: u.folderId,
      mimeType:
          SupportedFileType.fromName(u.name)?.mimeType ??
          'application/octet-stream',
      token: token,
      onProgress: (done, total) {
        final now = _upload(u.key);
        if (isClosed || now == null || total == 0) return;
        final value = done / total;
        // Repaint at whole percents only.
        if ((value * 100).floor() != (now.progress * 100).floor()) {
          _replaceUpload(now.copyWith(progress: value));
        }
      },
    );
    _tokens.remove(u.key);
    if (isClosed) return;
    switch (r) {
      case Ok():
        dismissUpload(u.key);
        emit(state.copyWith(notice: DriveNotice.uploaded));
        if (state.current?.id == u.folderId) await _load();
      case Err(failure: DriveFailure(problem: DriveProblem.cancelled)):
        dismissUpload(u.key);
      case Err(:final failure):
        final now = _upload(u.key);
        if (now != null) _replaceUpload(now.copyWith(failure: () => failure));
    }
  }

  // ---- Files --------------------------------------------------------------

  /// Fetches [item] into the app's temp folder (to open or save).
  Future<File?> fetch(DriveItem item) async {
    if (state.busyItemId != null) return null;
    final token = _downloads[item.id] = CancelToken();
    emit(state.copyWith(busyItemId: () => item.id));
    final dir = Directory(p.join(_tempDir.path, 'drive', item.id));
    await dir.create(recursive: true);
    // Drive allows any name; keep only its last part.
    final target = File(p.join(dir.path, p.basename(item.name)));
    final r = await _drive.download(item.id, target, token: token);
    _downloads.remove(item.id);
    if (isClosed) return null;
    emit(
      state.copyWith(
        busyItemId: () => null,
        failure: r is Err<void> ? _unlessCancelled(r.failure) : null,
      ),
    );
    return r is Ok<void> ? target : null;
  }

  static Failure? _unlessCancelled(Failure f) =>
      f is DriveFailure && f.problem == DriveProblem.cancelled ? null : f;

  void cancelFetch() {
    for (final t in _downloads.values) {
      t.cancel();
    }
  }

  void saved() => emit(state.copyWith(notice: DriveNotice.saved));

  /// Moves a file to Drive's trash (after the user confirmed).
  Future<void> delete(DriveItem item) async {
    if (item.isFolder) return;
    final r = await _drive.trash(item.id);
    if (isClosed) return;
    switch (r) {
      case Ok():
        emit(
          state.copyWith(
            items: [
              for (final i in state.items)
                if (i.id != item.id) i,
            ],
            notice: DriveNotice.deleted,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(failure: failure));
    }
  }

  @override
  Future<void> close() async {
    _auth.account.removeListener(_onAccount);
    for (final t in [..._tokens.values, ..._downloads.values]) {
      t.cancel();
    }
    await super.close();
  }
}

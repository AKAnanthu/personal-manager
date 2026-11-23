import 'dart:async';
import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart'
    show AccessDeniedException;
import 'package:http/http.dart' as http;
import 'package:personal_life_manager/core/drive/drive_auth.dart';
import 'package:personal_life_manager/core/drive/drive_models.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';

/// Google Drive operations the app needs, limited to files it created.
/// Every method returns a typed [DriveFailure] instead of throwing.
abstract interface class DriveService {
  /// Folders first, then by name.
  Future<Result<DrivePage>> list(String folderId, {String? pageToken});

  /// Number of items directly in [folderId], up to [cap].
  Future<Result<int>> count(String folderId, {int cap = 999});

  /// A folder named [name] inside [parentId] (Drive's root when null).
  Future<Result<DriveItem?>> findFolder(String name, {String? parentId});

  Future<Result<DriveItem>> createFolder(String name, {String? parentId});

  /// False when the folder was deleted or trashed in Drive.
  Future<Result<bool>> folderExists(String id);

  Future<Result<DriveItem>> upload(
    File file, {
    required String name,
    required String parentId,
    required String mimeType,
    DriveProgress? onProgress,
    CancelToken? token,
  });

  /// Downloads [fileId] to [target], replacing it only when complete.
  Future<Result<void>> download(
    String fileId,
    File target, {
    DriveProgress? onProgress,
    CancelToken? token,
  });

  /// Moves the item to Drive's trash, where the user can still recover it.
  Future<Result<void>> trash(String id);
}

final class GoogleDriveService implements DriveService {
  GoogleDriveService(this._auth, {this._delay = Future<void>.delayed});

  final DriveAuth _auth;
  final Future<void> Function(Duration) _delay;

  static const String _itemFields = 'id,name,mimeType,size,modifiedTime';

  /// Larger files upload in resumable chunks.
  static const int _resumableFrom = 5 * 1024 * 1024;

  Future<Result<T>> _run<T>(
    Future<T> Function(drive.DriveApi api) op, {
    bool retry = false,
  }) => runDriveCall(_auth, op, retry: retry, delay: _delay);

  static bool isAuthRejected(Object e) =>
      (e is drive.DetailedApiRequestError && e.status == 401) ||
      e is AccessDeniedException;

  static bool isTemporary(Object e) => switch (e) {
    drive.DetailedApiRequestError(:final status?) =>
      status == 429 || status >= 500,
    TimeoutException() => true,
    _ => false,
  };

  /// Maps anything thrown by the Drive client to what the user is told.
  static DriveProblem problemOf(Object e) => switch (e) {
    DriveException(:final problem) => problem,
    Cancelled() => DriveProblem.cancelled,
    AccessDeniedException() => DriveProblem.authExpired,
    drive.DetailedApiRequestError(status: 401) => DriveProblem.authExpired,
    drive.DetailedApiRequestError(status: 404) => DriveProblem.notFound,
    drive.DetailedApiRequestError(status: 403, :final errors)
        when errors.any(
          (d) =>
              d.reason == 'storageQuotaExceeded' || d.reason == 'quotaExceeded',
        ) =>
      DriveProblem.quotaExceeded,
    SocketException() ||
    HandshakeException() ||
    TimeoutException() ||
    http.ClientException() => DriveProblem.offline,
    _ => DriveProblem.unknown,
  };

  static String _q(String value) => quote(value);

  /// Escapes [value] for a Drive query string literal.
  static String quote(String value) =>
      value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

  static DriveItem _item(drive.File f) => DriveItem(
    id: f.id ?? '',
    name: f.name ?? '',
    mimeType: f.mimeType ?? '',
    sizeBytes: int.tryParse(f.size ?? ''),
    modifiedAt: f.modifiedTime?.toLocal(),
  );

  @override
  Future<Result<DrivePage>> list(String folderId, {String? pageToken}) =>
      _run((api) async {
        final r = await api.files.list(
          q: "'${_q(folderId)}' in parents and trashed = false",
          orderBy: 'folder,name',
          pageSize: 100,
          pageToken: pageToken,
          spaces: 'drive',
          $fields: 'nextPageToken,files($_itemFields)',
        );
        return DrivePage([
          for (final f in r.files ?? <drive.File>[]) _item(f),
        ], nextPageToken: r.nextPageToken);
      }, retry: true);

  @override
  Future<Result<int>> count(String folderId, {int cap = 999}) =>
      _run((api) async {
        var n = 0;
        String? token;
        do {
          final r = await api.files.list(
            q: "'${_q(folderId)}' in parents and trashed = false",
            pageSize: 1000,
            pageToken: token,
            spaces: 'drive',
            $fields: 'nextPageToken,files(id)',
          );
          n += r.files?.length ?? 0;
          token = r.nextPageToken;
        } while (token != null && n < cap);
        return n > cap ? cap : n;
      }, retry: true);

  @override
  Future<Result<DriveItem?>> findFolder(String name, {String? parentId}) =>
      _run((api) async {
        final r = await api.files.list(
          q:
              "mimeType = '${DriveItem.folderMimeType}' and "
              "name = '${_q(name)}' and trashed = false and "
              "'${_q(parentId ?? 'root')}' in parents",
          pageSize: 1,
          spaces: 'drive',
          $fields: 'files($_itemFields)',
        );
        final f = r.files?.firstOrNull;
        return f == null ? null : _item(f);
      }, retry: true);

  @override
  Future<Result<DriveItem>> createFolder(String name, {String? parentId}) =>
      _run(
        (api) async => _item(
          await api.files.create(
            drive.File(
              name: name,
              mimeType: DriveItem.folderMimeType,
              parents: [?parentId],
            ),
            $fields: _itemFields,
          ),
        ),
      );

  @override
  Future<Result<bool>> folderExists(String id) async {
    final r = await _run((api) async {
      final f =
          await api.files.get(id, $fields: 'id,trashed,mimeType') as drive.File;
      return !(f.trashed ?? false) && f.mimeType == DriveItem.folderMimeType;
    }, retry: true);
    return switch (r) {
      Err(failure: DriveFailure(problem: DriveProblem.notFound)) => const Ok(
        false,
      ),
      _ => r,
    };
  }

  @override
  Future<Result<DriveItem>> upload(
    File file, {
    required String name,
    required String parentId,
    required String mimeType,
    DriveProgress? onProgress,
    CancelToken? token,
  }) async {
    if (token?.isCancelled ?? false) {
      return const Err(DriveFailure(DriveProblem.cancelled));
    }
    final int length;
    try {
      length = await file.length();
    } on FileSystemException {
      return const Err(StorageFailure('upload source missing'));
    }
    final r = await _run((api) async {
      final media = drive.Media(
        _watched(file.openRead(), length, onProgress, token),
        length,
        contentType: mimeType,
      );
      final created = await api.files.create(
        drive.File(name: name, parents: [parentId]),
        uploadMedia: media,
        uploadOptions: length >= _resumableFrom
            ? drive.UploadOptions.resumable
            : drive.UploadOptions.defaultOptions,
        $fields: _itemFields,
      );
      return _item(created);
    });
    // However the stream ended, a cancel is reported as a cancel.
    if ((token?.isCancelled ?? false) && r is Err<DriveItem>) {
      return const Err(DriveFailure(DriveProblem.cancelled));
    }
    return r;
  }

  @override
  Future<Result<void>> download(
    String fileId,
    File target, {
    DriveProgress? onProgress,
    CancelToken? token,
  }) async {
    final part = File('${target.path}.part');
    final r = await _run<void>((api) async {
      final media = await api.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      final sink = part.openWrite();
      try {
        await sink.addStream(
          _watched(media.stream, media.length ?? 0, onProgress, token),
        );
      } finally {
        await sink.close();
      }
    }, retry: true);
    if (r is Ok<void>) {
      try {
        await part.rename(target.path);
      } on FileSystemException {
        return const Err(StorageFailure('download move failed'));
      }
      return r;
    }
    if (part.existsSync()) await part.delete();
    if (token?.isCancelled ?? false) {
      return const Err(DriveFailure(DriveProblem.cancelled));
    }
    return r;
  }

  @override
  Future<Result<void>> trash(String id) => _run<void>(
    (api) => api.files.update(drive.File(trashed: true), id, $fields: 'id'),
  );

  /// Passes [source] through, reporting progress, and fails it with
  /// [Cancelled] as soon as [token] is cancelled.
  static Stream<List<int>> _watched(
    Stream<List<int>> source,
    int total,
    DriveProgress? onProgress,
    CancelToken? token,
  ) {
    late final StreamController<List<int>> out;
    StreamSubscription<List<int>>? sub;
    void Function()? unlisten;
    var done = 0;
    Future<void> finish() async {
      unlisten?.call();
      await sub?.cancel();
      if (!out.isClosed) await out.close();
    }

    out = StreamController<List<int>>(
      onListen: () {
        unlisten = token?.whenCancelled(() {
          if (out.isClosed) return;
          out.addError(const Cancelled());
          unawaited(finish());
        });
        sub = source.listen(
          (chunk) {
            done += chunk.length;
            out.add(chunk);
            onProgress?.call(done, total);
          },
          onError: out.addError,
          onDone: () => unawaited(finish()),
        );
      },
      onPause: () => sub?.pause(),
      onResume: () => sub?.resume(),
      onCancel: finish,
    );
    return out.stream;
  }
}

/// Runs [op] with an authorised client. A rejected token is refreshed
/// once. Reads ([retry]) are retried with backoff on temporary server
/// errors; uploads and deletes never are.
Future<Result<T>> runDriveCall<T>(
  DriveAuth auth,
  Future<T> Function(drive.DriveApi api) op, {
  bool retry = false,
  Future<void> Function(Duration) delay = Future<void>.delayed,
}) async {
  var refreshed = false;
  var attempt = 0;
  while (true) {
    http.Client? client;
    try {
      client = await auth.client();
      return Ok(await op(drive.DriveApi(client)));
    } on Object catch (e) {
      if (GoogleDriveService.isAuthRejected(e) && !refreshed) {
        refreshed = true;
        await auth.tokenRejected();
        continue;
      }
      if (retry && attempt < 2 && GoogleDriveService.isTemporary(e)) {
        await delay(Duration(milliseconds: 500 * (1 << attempt)));
        attempt++;
        continue;
      }
      return Err(
        DriveFailure(GoogleDriveService.problemOf(e), e.runtimeType.toString()),
      );
    } finally {
      client?.close();
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/drive/drive_auth.dart';
import 'package:personal_life_manager/core/drive/drive_models.dart';
import 'package:personal_life_manager/core/drive/drive_service.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/utils/cancellable.dart';

typedef _Handler = Future<http.StreamedResponse> Function(
  http.BaseRequest r,
  List<int> body,
);

/// Hands out a mock HTTP client; counts refreshed tokens.
final class _Auth implements DriveAuth {
  _Auth(this.handler);

  _Handler handler;
  bool connected = true;
  int rejected = 0;
  final requests = <http.BaseRequest>[];

  @override
  ValueListenable<String?> get account =>
      ValueNotifier(connected ? 'me@example.com' : null);

  @override
  Future<void> load() async {}

  @override
  Future<Result<String?>> connect() async => const Ok('me@example.com');

  @override
  Future<void> disconnect() async {}

  @override
  Future<http.Client> client({bool prompt = false}) async {
    if (!connected) throw const DriveException(DriveProblem.notConnected);
    return MockClient.streaming((r, bodyStream) async {
      requests.add(r);
      final body = await bodyStream.expand((c) => c).toList();
      return await handler(r, body);
    });
  }

  @override
  Future<void> tokenRejected() async => rejected++;
}

http.StreamedResponse _json(Object body, [int status = 200]) =>
    http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(body))),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

http.StreamedResponse _error(int status, [String reason = 'x']) => _json({
  'error': {
    'code': status,
    'message': 'nope',
    'errors': [
      {'reason': reason, 'message': 'nope'},
    ],
  },
}, status);

Map<String, Object?> _file(String id, String name, {String? mime, int? size}) =>
    {
      'id': id,
      'name': name,
      'mimeType': mime ?? 'application/pdf',
      'size': ?size?.toString(),
      'modifiedTime': '2026-10-28T10:00:00.000Z',
    };

void main() {
  late _Auth auth;
  late GoogleDriveService drive;
  late List<Duration> waits;

  setUp(() {
    waits = [];
    auth = _Auth((_, _) async => _json({'files': <Object>[]}));
    drive = GoogleDriveService(auth, delay: (d) async => waits.add(d));
  });

  DriveProblem? problem<T>(Result<T> r) => switch (r) {
    Err(failure: DriveFailure(:final problem)) => problem,
    _ => null,
  };

  test('lists a folder: only its live children, folders first', () async {
    auth.handler = (r, _) async => _json({
      'files': [
        _file('f1', 'Personal', mime: DriveItem.folderMimeType),
        _file('a', 'passport.pdf', size: 1200000),
      ],
      'nextPageToken': 'next',
    });
    final r = await drive.list('folder-1');
    final page = (r as Ok<DrivePage>).value;
    expect(page.items.first.isFolder, isTrue);
    expect(page.items.last.sizeBytes, 1200000);
    expect(page.nextPageToken, 'next');
    final q = auth.requests.single.url.queryParameters;
    expect(q['q'], "'folder-1' in parents and trashed = false");
    expect(q['orderBy'], 'folder,name');
  });

  test('quotes in names cannot break the search query', () async {
    await drive.findFolder("Dad's papers", parentId: 'p');
    expect(
      auth.requests.single.url.queryParameters['q'],
      contains(r"name = 'Dad\'s papers'"),
    );
  });

  test('errors become typed problems', () async {
    final cases = <http.StreamedResponse Function(), DriveProblem>{
      () => _error(404, 'notFound'): DriveProblem.notFound,
      () => _error(403, 'storageQuotaExceeded'): DriveProblem.quotaExceeded,
      () => _error(400, 'badRequest'): DriveProblem.unknown,
    };
    for (final MapEntry(key: respond, value: expected) in cases.entries) {
      auth.handler = (_, _) async => respond();
      expect(problem(await drive.list('x')), expected);
    }
    auth.handler = (_, _) async => throw const SocketException('down');
    expect(problem(await drive.list('x')), DriveProblem.offline);
    auth.connected = false;
    expect(problem(await drive.list('x')), DriveProblem.notConnected);
  });

  test('a rejected token is refreshed once, then reported', () async {
    var calls = 0;
    auth.handler = (_, _) async =>
        ++calls == 1 ? _error(401, 'authError') : _json({'files': <Object>[]});
    expect(await drive.list('x'), isA<Ok<DrivePage>>());
    expect(auth.rejected, 1);

    auth.handler = (_, _) async => _error(401, 'authError');
    // One refresh per call, never a loop.
    expect(problem(await drive.list('x')), DriveProblem.authExpired);
    expect(auth.rejected, 2);
  });

  test('reads retry temporary errors with backoff; uploads never', () async {
    var calls = 0;
    auth.handler = (_, _) async => ++calls < 3
        ? _error(503, 'backendError')
        : _json({'files': <Object>[]});
    expect(await drive.list('x'), isA<Ok<DrivePage>>());
    expect(calls, 3);
    expect(waits, [
      const Duration(milliseconds: 500),
      const Duration(milliseconds: 1000),
    ]);

    final dir = Directory.systemTemp.createTempSync('up');
    addTearDown(() => dir.deleteSync(recursive: true));
    final f = File(p.join(dir.path, 'a.pdf'))..writeAsBytesSync([1, 2, 3]);
    calls = 0;
    auth.handler = (_, _) async {
      calls++;
      return _error(503, 'backendError');
    };
    final r = await drive.upload(
      f,
      name: 'a.pdf',
      parentId: 'p',
      mimeType: 'application/pdf',
    );
    expect(problem(r), DriveProblem.unknown);
    expect(calls, 1);
  });

  group('upload', () {
    late Directory dir;
    late File file;
    final bytes = List<int>.generate(5000, (i) => i % 251);

    setUp(() {
      dir = Directory.systemTemp.createTempSync('up');
      file = File(p.join(dir.path, 'scan.pdf'))..writeAsBytesSync(bytes);
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('sends the bytes into the folder and reports progress', () async {
      late List<int> sent;
      late Uri url;
      auth.handler = (r, body) async {
        sent = body;
        url = r.url;
        return _json(_file('new', 'scan.pdf', size: bytes.length));
      };
      final progress = <(int, int)>[];
      final r = await drive.upload(
        file,
        name: 'scan.pdf',
        parentId: 'docs',
        mimeType: 'application/pdf',
        onProgress: (d, t) => progress.add((d, t)),
      );
      expect((r as Ok<DriveItem>).value.id, 'new');
      expect(url.path, '/upload/drive/v3/files');
      final text = latin1.decode(sent);
      expect(text, contains('"parents":["docs"]'));
      expect(text, contains('"name":"scan.pdf"'));
      expect(progress.last, (bytes.length, bytes.length));
    });

    test('cancelling stops it and says so', () async {
      final token = CancelToken()..cancel();
      final r = await drive.upload(
        file,
        name: 'scan.pdf',
        parentId: 'docs',
        mimeType: 'application/pdf',
        token: token,
      );
      expect(problem(r), DriveProblem.cancelled);
      expect(auth.requests, isEmpty);
    });

    test('a missing local file is a storage failure', () async {
      file.deleteSync();
      final r = await drive.upload(
        file,
        name: 'scan.pdf',
        parentId: 'docs',
        mimeType: 'application/pdf',
      );
      expect((r as Err).failure, isA<StorageFailure>());
    });
  });

  group('download', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('down'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('writes the whole file, then moves it into place', () async {
      auth.handler = (r, _) async {
        expect(r.url.queryParameters['alt'], 'media');
        return http.StreamedResponse(
          Stream.fromIterable([
            [1, 2],
            [3, 4, 5],
          ]),
          200,
          contentLength: 5,
          headers: {'content-type': 'application/pdf'},
        );
      };
      final target = File(p.join(dir.path, 'a.pdf'));
      final progress = <int>[];
      final r = await drive.download(
        'f',
        target,
        onProgress: (d, _) => progress.add(d),
      );
      expect(r, isA<Ok<void>>());
      expect(target.readAsBytesSync(), [1, 2, 3, 4, 5]);
      expect(progress, [2, 5]);
      expect(File('${target.path}.part').existsSync(), isFalse);
    });

    test('a failed download leaves nothing behind', () async {
      auth.handler = (_, _) async => _error(404, 'notFound');
      final target = File(p.join(dir.path, 'a.pdf'));
      expect(problem(await drive.download('f', target)), DriveProblem.notFound);
      expect(dir.listSync(), isEmpty);
    });
  });

  test('delete moves to Drive trash rather than erasing', () async {
    late http.BaseRequest req;
    late List<int> sent;
    auth.handler = (r, body) async {
      req = r;
      sent = body;
      return _json({'id': 'f'});
    };
    expect(await drive.trash('f'), isA<Ok<void>>());
    expect(req.method, 'PATCH');
    expect(jsonDecode(utf8.decode(sent)), {'trashed': true});
  });

  test('a deleted or trashed folder no longer exists', () async {
    auth.handler = (_, _) async => _error(404, 'notFound');
    expect((await drive.folderExists('a') as Ok<bool>).value, isFalse);
    auth.handler = (_, _) async => _json({
      'id': 'a',
      'trashed': true,
      'mimeType': DriveItem.folderMimeType,
    });
    expect((await drive.folderExists('a') as Ok<bool>).value, isFalse);
    auth.handler = (_, _) async => _json({
      'id': 'a',
      'trashed': false,
      'mimeType': DriveItem.folderMimeType,
    });
    expect((await drive.folderExists('a') as Ok<bool>).value, isTrue);
  });
}

import 'dart:async';
import 'dart:isolate';

/// Lets the UI stop a long-running step (backup, restore).
final class CancelToken {
  bool _cancelled = false;
  final _listeners = <void Function()>[];

  bool get isCancelled => _cancelled;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final l in List.of(_listeners)) {
      l();
    }
  }

  void _listen(void Function() l) => _listeners.add(l);
  void _unlisten(void Function() l) => _listeners.remove(l);
}

/// Thrown when work stops because its [CancelToken] was cancelled.
final class Cancelled implements Exception {
  const Cancelled();
}

/// Error from the background isolate, carried back as plain data.
final class IsolateFailure implements Exception {
  const IsolateFailure(this.code, this.detail);

  /// Set by the work itself via [IsolateError]; 'other' for anything else.
  final String code;
  final String detail;

  @override
  String toString() => 'IsolateFailure($code)';
}

/// Throw inside isolate work to report a known error by [code].
final class IsolateError implements Exception {
  const IsolateError(this.code);
  final String code;
}

/// Runs [work] in a new isolate; cancelling [token] kills it immediately
/// (unlike `Isolate.run`, which can't be stopped). The result must be
/// sendable between isolates.
Future<T> runCancellable<T>(
  FutureOr<T> Function() work, {
  required CancelToken token,
}) async {
  if (token.isCancelled) throw const Cancelled();
  final done = Completer<T>();
  final port = RawReceivePort();
  Isolate? isolate;

  void onCancel() {
    isolate?.kill(priority: Isolate.immediate);
    port.close();
    if (!done.isCompleted) done.completeError(const Cancelled());
  }

  void handle(Object? message) {
    port.close();
    if (done.isCompleted) return;
    switch (message) {
      case ['ok', final Object? value]:
        done.complete(value as T);
      case ['err', final String code, final String detail]:
        done.completeError(IsolateFailure(code, detail));
      default:
        // The isolate exited without a result (killed or crashed).
        done.completeError(const IsolateFailure('exited', ''));
    }
  }

  port.handler = handle;
  token._listen(onCancel);
  try {
    isolate = await Isolate.spawn<(FutureOr<T> Function(), SendPort)>(_entry, (
      work,
      port.sendPort,
    ), onExit: port.sendPort);
    if (token.isCancelled) onCancel();
    return await done.future;
  } finally {
    token._unlisten(onCancel);
  }
}

Future<void> _entry<T>((FutureOr<T> Function(), SendPort) args) async {
  final (work, reply) = args;
  try {
    reply.send(['ok', await work()]);
  } on IsolateError catch (e) {
    reply.send(['err', e.code, '']);
  } on Exception catch (e) {
    // Only the type: messages can contain file names or record contents.
    reply.send(['err', 'other', e.runtimeType.toString()]);
  }
}

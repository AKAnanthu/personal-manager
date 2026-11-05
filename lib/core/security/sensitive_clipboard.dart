import 'dart:io';

import 'package:flutter/services.dart';

/// Copies text the user shouldn't leave lying around (passwords, ID
/// numbers) and clears it after a delay (30 s by default) if it is still
/// on the clipboard.
///
/// Done natively: iOS sets a pasteboard expiration (local only, no
/// Universal Clipboard); Android marks the clip sensitive (hidden from the
/// clipboard preview on 13+) and clears it if it's still ours. A Dart timer
/// can't do this reliably: reading the clipboard shows a paste banner on iOS
/// and is blocked in the background on Android 10+.
abstract interface class SensitiveClipboard {
  Future<void> copy(String text, {bool sensitive = true});
}

final class PlatformSensitiveClipboard implements SensitiveClipboard {
  const PlatformSensitiveClipboard({
    this.clearAfter = const Duration(seconds: 30),
  });

  final Duration clearAfter;
  static const _channel = MethodChannel('app.plm/platform');

  @override
  Future<void> copy(String text, {bool sensitive = true}) async {
    if (!sensitive || !(Platform.isAndroid || Platform.isIOS)) {
      await Clipboard.setData(ClipboardData(text: text));
      return;
    }
    try {
      await _channel.invokeMethod<void>('copySensitive', {
        'text': text,
        'seconds': clearAfter.inSeconds,
      });
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: text));
    }
  }
}

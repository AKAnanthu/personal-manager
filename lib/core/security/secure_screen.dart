import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Wrap sensitive screens (Password Notes, identification numbers) in this.
/// On Android it sets `FLAG_SECURE` while mounted, which blocks screenshots,
/// screen recording and the Recents thumbnail. iOS is covered app-wide by the
/// blur overlay in `SceneDelegate`.
class SecureScreen extends StatefulWidget {
  const SecureScreen({required this.child, super.key});

  final Widget child;

  static const _channel = MethodChannel('app.plm/platform');
  static int _active = 0;

  static Future<void> _set({required bool secure}) async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('setSecure', secure);
  }

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  @override
  void initState() {
    super.initState();
    // Reference-counted so nested or overlapping secure screens don't clear
    // the flag early.
    if (SecureScreen._active++ == 0) unawaited(SecureScreen._set(secure: true));
  }

  @override
  void dispose() {
    if (--SecureScreen._active == 0) {
      unawaited(SecureScreen._set(secure: false));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

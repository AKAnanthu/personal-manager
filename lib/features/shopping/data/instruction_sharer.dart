import 'package:flutter/services.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:share_plus/share_plus.dart';

/// Shares the "how to send me a list" image through the system share sheet
/// (e.g. to WhatsApp). Nothing is read back from other apps.
abstract interface class InstructionSharer {
  /// [languageCode] picks the localised image (English fallback).
  /// [origin] anchors the iPad share popover.
  Future<void> share({
    required String languageCode,
    Rect? origin,
    String? text,
  });
}

final class PlatformInstructionSharer implements InstructionSharer {
  const PlatformInstructionSharer(this._lock, [this._bundle]);

  final AppLock _lock;
  final AssetBundle? _bundle;

  /// Languages with a rendered image (add one per translated card).
  static const languages = {'en'};

  static String assetFor(String languageCode) =>
      'assets/share/shopping_list_'
      '${languages.contains(languageCode) ? languageCode : 'en'}.png';

  @override
  Future<void> share({
    required String languageCode,
    Rect? origin,
    String? text,
  }) async {
    final bundle = _bundle ?? rootBundle;
    final data = await bundle.load(assetFor(languageCode));
    final file = XFile.fromData(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      mimeType: 'image/png',
      name: 'shopping_list.png',
    );
    await _lock.runExternal(
      () => SharePlus.instance.share(
        ShareParams(
          files: [file],
          text: text,
          fileNameOverrides: const ['shopping_list.png'],
          sharePositionOrigin: origin,
        ),
      ),
    );
  }
}

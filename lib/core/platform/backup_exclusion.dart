import 'dart:io';

import 'package:flutter/services.dart';

/// Excludes app data from OS cloud/device backups (iOS
/// `NSURLIsExcludedFromBackupKey`). Android is handled in the manifest
/// (`allowBackup=false` + data extraction rules), so this is a no-op there.
class BackupExclusion {
  const BackupExclusion();

  static const _channel = MethodChannel('app.plm/platform');

  Future<void> exclude(Directory directory) async {
    if (!Platform.isIOS) return;
    await _channel.invokeMethod<void>('excludeFromBackup', directory.path);
  }
}

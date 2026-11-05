import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/features/backup_restore/data/backup_service.dart';
import 'package:personal_life_manager/features/backup_restore/domain/backup.dart';
import 'package:personal_life_manager/features/breathing/data/breathing_services.dart';
import 'package:personal_life_manager/features/breathing/domain/breathing.dart';
import 'package:personal_life_manager/features/settings/data/app_settings.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where a finished backup goes, and how a backup file is picked for
/// restore. Every trip to the system UI runs under [AppLock.runExternal].
abstract interface class BackupFiles {
  /// System "save as" dialog. False if the user cancelled.
  Future<bool> saveToDevice(File backup);

  /// Share sheet (another app, Files, e-mail…).
  Future<void> share(File backup);

  /// Lets the user pick a backup file; null if cancelled.
  Future<File?> pickBackup();
}

final class PlatformBackupFiles implements BackupFiles {
  const PlatformBackupFiles(this._lock);

  final AppLock _lock;

  @override
  Future<bool> saveToDevice(File backup) => _lock.runExternal(() async {
    // The plugin needs the bytes; backups are read once, then released.
    final uri = await FilePicker.saveFile(
      fileName: backup.uri.pathSegments.last,
      bytes: await backup.readAsBytes(),
    );
    return uri != null;
  });

  @override
  Future<void> share(File backup) => _lock.runExternal(
    () => SharePlus.instance.share(
      ShareParams(files: [XFile(backup.path, mimeType: 'application/zip')]),
    ),
  );

  @override
  Future<File?> pickBackup() => _lock.runExternal(() async {
    // Custom extensions aren't filterable everywhere; the file is checked
    // thoroughly before anything is restored.
    final picked = await FilePicker.pickFiles();
    final path = picked.firstOrNull?.path;
    return path == null ? null : File(path);
  });
}

/// Remembers when the last backup was made (shown on the Backup tab).
abstract interface class LastBackupStore {
  Future<LastBackup?> load();
  Future<void> save(LastBackup value);
}

final class PrefsLastBackupStore implements LastBackupStore {
  PrefsLastBackupStore([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  @override
  Future<LastBackup?> load() async {
    final at = await _prefs.getInt('backup.lastAt');
    final size = await _prefs.getInt('backup.lastSize');
    if (at == null || size == null) return null;
    return LastBackup(at: DateTime.fromMillisecondsSinceEpoch(at), size: size);
  }

  @override
  Future<void> save(LastBackup value) async {
    await _prefs.setInt('backup.lastAt', value.at.millisecondsSinceEpoch);
    await _prefs.setInt('backup.lastSize', value.size);
  }
}

/// "Relevant application preferences": the breathing exercise settings
/// for now; Settings adds to this.
final class AppPreferencesBackup implements PreferencesBackup {
  const AppPreferencesBackup(this._breathing, [this._settings]);

  final BreathingSettingsStore _breathing;
  final AppSettings? _settings;

  @override
  Future<Map<String, Object?>> export() async {
    final b = await _breathing.load();
    return {
      'app': ?_settings?.export(),
      'breathing': {
        'minutes': b.minutes,
        'pace': b.pace.name,
        'sound': b.sound,
        'vibration': b.vibration,
      },
    };
  }

  @override
  Future<void> import(Map<String, Object?> values) async {
    if (values['app'] case final Map<String, Object?> app) {
      await _settings?.import(app);
    }
    if (values['breathing'] case final Map<String, Object?> b) {
      const d = BreathingSettings();
      await _breathing.save(
        BreathingSettings(
          minutes: switch (b['minutes']) {
            final int m when BreathingSettings.durations.contains(m) => m,
            _ => d.minutes,
          },
          pace:
              BreathingPace.values
                  .where((p) => p.name == b['pace'])
                  .firstOrNull ??
              d.pace,
          sound: b['sound'] is bool ? b['sound']! as bool : d.sound,
          vibration: b['vibration'] is bool
              ? b['vibration']! as bool
              : d.vibration,
        ),
      );
    }
  }
}

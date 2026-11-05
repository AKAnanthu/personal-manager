import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:personal_life_manager/features/breathing/domain/breathing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Remembers the last-used breathing settings (on this device only).
abstract interface class BreathingSettingsStore {
  Future<BreathingSettings> load();
  Future<void> save(BreathingSettings settings);
}

final class PrefsBreathingSettingsStore implements BreathingSettingsStore {
  PrefsBreathingSettingsStore([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;
  static const _p = 'breathing.';

  @override
  Future<BreathingSettings> load() async {
    const d = BreathingSettings();
    final minutes = await _prefs.getInt('${_p}minutes');
    final pace = await _prefs.getString('${_p}pace');
    return BreathingSettings(
      minutes: BreathingSettings.durations.contains(minutes)
          ? minutes ?? d.minutes
          : d.minutes,
      pace:
          BreathingPace.values.where((p) => p.name == pace).firstOrNull ??
          d.pace,
      sound: await _prefs.getBool('${_p}sound') ?? d.sound,
      vibration: await _prefs.getBool('${_p}vibration') ?? d.vibration,
    );
  }

  @override
  Future<void> save(BreathingSettings s) async {
    await _prefs.setInt('${_p}minutes', s.minutes);
    await _prefs.setString('${_p}pace', s.pace.name);
    await _prefs.setBool('${_p}sound', s.sound);
    await _prefs.setBool('${_p}vibration', s.vibration);
  }
}

/// Side effects of a session: keep the screen on while running, a light
/// vibration cue, the end chime.
abstract interface class BreathingFeedback {
  Future<void> keepScreenOn({required bool on});
  Future<void> cue();
  Future<void> chime();
  Future<void> dispose();
}

final class PlatformBreathingFeedback implements BreathingFeedback {
  AudioPlayer? _player;

  static const chimeAsset = 'sounds/breathing_done.wav';

  @override
  Future<void> keepScreenOn({required bool on}) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } on PlatformException {
      // Not critical: the screen may just dim as usual.
    }
  }

  @override
  Future<void> cue() => HapticFeedback.lightImpact();

  @override
  Future<void> chime() async {
    final player = _player ??= AudioPlayer();
    try {
      // Plays alongside other audio rather than stopping the user's music.
      await player.setAudioContext(
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
          // Silent mode stays silent.
          respectSilence: true,
        ).build(),
      );
      await player.play(AssetSource(chimeAsset));
    } on PlatformException {
      // A missing chime must never break the exercise.
    }
  }

  @override
  Future<void> dispose() async {
    await keepScreenOn(on: false);
    await _player?.dispose();
    _player = null;
  }
}

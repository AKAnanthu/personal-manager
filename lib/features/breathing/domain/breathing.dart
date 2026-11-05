import 'package:equatable/equatable.dart';

/// Inhale/exhale seconds the user can pick.
enum BreathingPace {
  even4(4, 4),
  longExhale(4, 6),
  even5(5, 5);

  BreathingPace(this.inhaleSeconds, this.exhaleSeconds);

  final int inhaleSeconds;
  final int exhaleSeconds;

  Duration get cycle => Duration(seconds: inhaleSeconds + exhaleSeconds);
}

final class BreathingSettings extends Equatable {
  const BreathingSettings({
    this.minutes = 3,
    this.pace = BreathingPace.even4,
    this.sound = true,
    this.vibration = false,
  });

  static const durations = [1, 3, 5];

  final int minutes;
  final BreathingPace pace;

  /// Chime at the end.
  final bool sound;

  /// A light tap at each change between breathing in and out.
  final bool vibration;

  Duration get total => Duration(minutes: minutes);

  BreathingSettings copyWith({
    int? minutes,
    BreathingPace? pace,
    bool? sound,
    bool? vibration,
  }) => BreathingSettings(
    minutes: minutes ?? this.minutes,
    pace: pace ?? this.pace,
    sound: sound ?? this.sound,
    vibration: vibration ?? this.vibration,
  );

  @override
  List<Object?> get props => [minutes, pace, sound, vibration];
}

/// Where a session is at a moment: derived from elapsed time only, so one
/// animation clock drives everything.
final class BreathingMoment extends Equatable {
  const BreathingMoment({
    required this.inhaling,
    required this.phaseProgress,
    required this.cycle,
    required this.remaining,
  });

  factory BreathingMoment.at(Duration elapsed, BreathingSettings s) {
    final inhale = s.pace.inhaleSeconds * 1000;
    final cycleMs = s.pace.cycle.inMilliseconds;
    final total = s.total.inMilliseconds;
    final ms = elapsed.inMilliseconds.clamp(0, total);
    final inCycle = ms % cycleMs;
    final inhaling = inCycle < inhale;
    return BreathingMoment(
      inhaling: inhaling,
      phaseProgress: inhaling
          ? inCycle / inhale
          : (inCycle - inhale) / (cycleMs - inhale),
      cycle: ms ~/ cycleMs,
      remaining: Duration(milliseconds: total - ms),
    );
  }

  final bool inhaling;

  /// 0 → 1 through the current breath in or out.
  final double phaseProgress;

  /// Breath count so far; a change of phase (in/out) is a new cue.
  final int cycle;
  final Duration remaining;

  /// 0 (empty) → 1 (full lungs): the circle grows on the in-breath and
  /// shrinks on the out-breath.
  double get fullness => inhaling ? phaseProgress : 1 - phaseProgress;

  @override
  List<Object?> get props => [inhaling, phaseProgress, cycle, remaining];
}

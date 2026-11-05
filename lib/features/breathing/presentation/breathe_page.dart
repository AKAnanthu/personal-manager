import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/features/breathing/data/breathing_services.dart';
import 'package:personal_life_manager/features/breathing/domain/breathing.dart';
import 'package:personal_life_manager/features/breathing/presentation/breathing_settings_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

enum _Run { idle, running, paused, done }

/// Eye rest and breathing: follow the circle, in and out, for a few
/// minutes. One AnimationController is the clock for everything.
class BreathePage extends StatefulWidget {
  const BreathePage({required this.feedback, super.key});

  final BreathingFeedback feedback;

  @override
  State<BreathePage> createState() => _BreathePageState();
}

class _BreathePageState extends State<BreathePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this)
    ..addListener(_onTick)
    ..addStatusListener(_onStatus);
  late final AppLifecycleListener _lifecycle;
  _Run _run = _Run.idle;
  BreathingSettings _session = const BreathingSettings();
  bool? _lastInhaling;

  @override
  void initState() {
    super.initState();
    // Leaving the app pauses; the user resumes when they're back.
    _lifecycle = AppLifecycleListener(onInactive: _pause, onHide: _pause);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _clock.dispose();
    unawaited(widget.feedback.dispose());
    super.dispose();
  }

  BreathingMoment get _moment =>
      BreathingMoment.at(_session.total * _clock.value, _session);

  void _onTick() {
    if (!_session.vibration || _run != _Run.running) return;
    final inhaling = _moment.inhaling;
    if (_lastInhaling != null && inhaling != _lastInhaling) {
      unawaited(widget.feedback.cue());
    }
    _lastInhaling = inhaling;
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _run != _Run.running) return;
    setState(() => _run = _Run.done);
    unawaited(widget.feedback.keepScreenOn(on: false));
    if (_session.sound) unawaited(widget.feedback.chime());
    if (_session.vibration) unawaited(widget.feedback.cue());
  }

  void _start(BreathingSettings s) {
    _session = s;
    _lastInhaling = null;
    _clock
      ..duration = s.total
      ..value = 0;
    setState(() => _run = _Run.running);
    unawaited(widget.feedback.keepScreenOn(on: true));
    if (s.vibration) unawaited(widget.feedback.cue());
    _clock.forward();
  }

  void _pause() {
    if (_run != _Run.running) return;
    _clock.stop();
    setState(() => _run = _Run.paused);
    unawaited(widget.feedback.keepScreenOn(on: false));
  }

  void _resume() {
    if (_run != _Run.paused) return;
    setState(() => _run = _Run.running);
    unawaited(widget.feedback.keepScreenOn(on: true));
    _clock.forward();
  }

  void _stop() {
    _clock
      ..stop()
      ..value = 0;
    setState(() => _run = _Run.idle);
    unawaited(widget.feedback.keepScreenOn(on: false));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settingsCubit = context.read<BreathingSettingsCubit>();
    final active = _run == _Run.running || _run == _Run.paused;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.moduleName('breathe')),
      ),
      body: BlocBuilder<BreathingSettingsCubit, BreathingSettings>(
        builder: (context, settings) {
          final shown = active ? _session : settings;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              4,
              AppSpacing.gutter,
              32,
            ),
            children: [
              Text(
                l10n.breatheIntro,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _clock,
                builder: (context, _) => _Circle(
                  run: _run,
                  moment: BreathingMoment.at(shown.total * _clock.value, shown),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _clock,
                builder: (context, _) {
                  final m = BreathingMoment.at(
                    shown.total * _clock.value,
                    shown,
                  );
                  final secs = (m.remaining.inMilliseconds / 1000).ceil();
                  return Text(
                    l10n.breatheStatus(
                      '${secs ~/ 60}:${(secs % 60).toString().padLeft(2, '0')}',
                      shown.pace.inhaleSeconds,
                      shown.pace.exhaleSeconds,
                    ),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.section),
              SectionLabel(l10n.breatheDuration),
              Wrap(
                spacing: AppSpacing.gap,
                children: [
                  for (final m in BreathingSettings.durations)
                    ChoiceChip(
                      label: Text(l10n.breatheMinutes(m)),
                      selected: settings.minutes == m,
                      onSelected: active
                          ? null
                          : (_) => settingsCubit.update(
                              settings.copyWith(minutes: m),
                            ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              SectionLabel(l10n.breathePace),
              Wrap(
                spacing: AppSpacing.gap,
                runSpacing: AppSpacing.gap,
                children: [
                  for (final p in BreathingPace.values)
                    ChoiceChip(
                      label: Text(
                        l10n.breathePaceLabel(p.inhaleSeconds, p.exhaleSeconds),
                      ),
                      selected: settings.pace == p,
                      onSelected: active
                          ? null
                          : (_) => settingsCubit.update(
                              settings.copyWith(pace: p),
                            ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: settings.sound,
                onChanged: active
                    ? null
                    : (v) => settingsCubit.update(
                        settings.copyWith(sound: v ?? false),
                      ),
                title: Text(l10n.breatheSound),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: settings.vibration,
                onChanged: active
                    ? null
                    : (v) => settingsCubit.update(
                        settings.copyWith(vibration: v ?? false),
                      ),
                title: Text(l10n.breatheVibration),
              ),
              const SizedBox(height: 16),
              if (active)
                Row(
                  spacing: AppSpacing.gap,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _stop,
                        child: Text(l10n.breatheStop),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: _run == _Run.running ? _pause : _resume,
                        child: Text(
                          _run == _Run.running
                              ? l10n.breathePause
                              : l10n.breatheResume,
                        ),
                      ),
                    ),
                  ],
                )
              else
                FilledButton(
                  onPressed: () => _start(settings),
                  child: Text(
                    _run == _Run.done ? l10n.breatheAgain : l10n.breatheStart,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.run, required this.moment});

  final _Run run;
  final BreathingMoment moment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    // Respect "reduce motion": the circle stays still; the words still
    // change.
    final still = MediaQuery.disableAnimationsOf(context);
    final label = switch (run) {
      _Run.idle => l10n.breatheReady,
      _Run.done => l10n.breatheDone,
      _Run.paused => l10n.breathePaused,
      _Run.running => moment.inhaling ? l10n.breatheIn : l10n.breatheOut,
    };
    final fullness = run == _Run.running || run == _Run.paused
        ? moment.fullness
        : 0.5;
    // Ease so the breath feels natural rather than mechanical.
    final eased = Curves.easeInOutSine.transform(fullness);
    final scale = still ? 0.8 : 0.55 + 0.45 * eased;
    return Semantics(
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 260,
          child: Center(
            child: LayoutBuilder(
              builder: (context, c) {
                final size = math.min<double>(c.maxWidth, 260);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.task.background,
                      ),
                    ),
                    Container(
                      width: size * scale,
                      height: size * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

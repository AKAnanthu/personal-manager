import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/features/dashboard/domain/upcoming_item.dart';

final class DashboardState extends Equatable {
  const DashboardState({
    required this.now,
    this.upcoming = const [],
    this.loaded = false,
  });

  final DateTime now;
  final List<UpcomingItem> upcoming;
  final bool loaded;

  @override
  List<Object?> get props => [now, upcoming, loaded];
}

/// Merges every feature's upcoming items, soonest first. No budget data.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._sources, {this._clock = DateTime.now, this.limit = 5})
    : super(DashboardState(now: _clock()));

  final List<UpcomingSource> _sources;
  final DateTime Function() _clock;
  final int limit;
  final _subs = <StreamSubscription<List<UpcomingItem>>>[];
  Timer? _tick;

  void start() {
    if (_subs.isNotEmpty) return;
    final latest = List<List<UpcomingItem>?>.filled(_sources.length, null);
    for (var i = 0; i < _sources.length; i++) {
      _subs.add(
        _sources[i]().listen(
          (items) {
            latest[i] = items;
            _emit(latest);
          },
          // A failing source just contributes nothing.
          onError: (Object _) {
            latest[i] = const [];
            _emit(latest);
          },
        ),
      );
    }
    if (_sources.isEmpty) emit(DashboardState(now: _clock(), loaded: true));
    _tick = Timer.periodic(
      const Duration(minutes: 1),
      (_) => emit(
        DashboardState(
          now: _clock(),
          upcoming: state.upcoming,
          loaded: state.loaded,
        ),
      ),
    );
  }

  void _emit(List<List<UpcomingItem>?> latest) {
    if (isClosed) return;
    final all = [for (final l in latest) ...?l]
      ..sort((a, b) => a.at.compareTo(b.at));
    emit(
      DashboardState(
        now: _clock(),
        upcoming: all.take(limit).toList(),
        loaded: latest.every((l) => l != null),
      ),
    );
  }

  @override
  Future<void> close() async {
    _tick?.cancel();
    for (final s in _subs) {
      await s.cancel();
    }
    await super.close();
  }
}

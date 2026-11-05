import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/features/breathing/data/breathing_services.dart';
import 'package:personal_life_manager/features/breathing/domain/breathing.dart';

/// The exercise settings, remembered between sessions.
class BreathingSettingsCubit extends Cubit<BreathingSettings> {
  BreathingSettingsCubit(this._store) : super(const BreathingSettings());

  final BreathingSettingsStore _store;

  Future<void> load() async {
    final s = await _store.load();
    if (!isClosed) emit(s);
  }

  void update(BreathingSettings s) {
    emit(s);
    unawaited(_store.save(s));
  }
}

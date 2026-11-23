import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/platform/device_settings.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/sync/sync_engine.dart';
import 'package:personal_life_manager/core/sync/sync_store.dart';
import 'package:personal_life_manager/features/account/data/account_session.dart';

final class AccountState extends Equatable {
  const AccountState({
    required this.sync,
    this.account,
    this.clockAutomatic = true,
    this.appBytes,
    this.records = 0,
    this.files = 0,
    this.quota,
    this.storageFailed = false,
    this.storageFailure,
    this.busy = false,
  });

  final String? account;
  final SyncStatus sync;
  final bool clockAutomatic;

  /// This app's data in Drive; null until loaded.
  final int? appBytes;

  /// Records and files of this account in Drive.
  final int records;
  final int files;
  final StorageQuota? quota;
  final bool storageFailed;
  final Failure? storageFailure;

  /// Signing out or deleting.
  final bool busy;

  AccountState copyWith({
    String? account,
    SyncStatus? sync,
    bool? clockAutomatic,
    int? appBytes,
    int? records,
    int? files,
    StorageQuota? quota,
    bool? storageFailed,
    Failure? storageFailure,
    bool? busy,
  }) => AccountState(
    account: account ?? this.account,
    sync: sync ?? this.sync,
    clockAutomatic: clockAutomatic ?? this.clockAutomatic,
    appBytes: appBytes ?? this.appBytes,
    records: records ?? this.records,
    files: files ?? this.files,
    quota: quota ?? this.quota,
    storageFailed: storageFailed ?? this.storageFailed,
    storageFailure: storageFailure ?? this.storageFailure,
    busy: busy ?? this.busy,
  );

  @override
  List<Object?> get props => [
    account,
    sync,
    clockAutomatic,
    appBytes,
    records,
    files,
    quota,
    storageFailed,
    storageFailure,
    busy,
  ];
}

/// Result of "Sign out" when some changes couldn't be saved to Drive.
final class UnsavedChanges {
  const UnsavedChanges(this.count);

  final int count;
}

class AccountCubit extends Cubit<AccountState> {
  AccountCubit({
    required this._session,
    required this._sync,
    required this._settings,
    required this._lock,
  }) : super(
         AccountState(
           sync: _sync.status.value,
           account: _session.account.value,
         ),
       ) {
    _sync.status.addListener(_onSync);
  }

  final AccountSession _session;
  final SyncEngine _sync;
  final DeviceSettings _settings;
  final AppLock _lock;
  AppLifecycleListener? _lifecycle;

  void _onSync() {
    if (!isClosed) emit(state.copyWith(sync: _sync.status.value));
  }

  Future<void> load() async {
    _lifecycle ??= AppLifecycleListener(
      onResume: () => unawaited(_checkClock()),
    );
    await _checkClock();
    await loadStorage();
  }

  Future<void> _checkClock() async {
    final t = await _settings.automaticTime();
    if (!isClosed) emit(state.copyWith(clockAutomatic: t.time && t.zone));
  }

  Future<void> loadStorage() async {
    final r = await _sync.storage();
    if (isClosed) return;
    switch (r) {
      case Ok(:final value):
        emit(
          state.copyWith(
            appBytes: value.appBytes,
            records: value.records,
            files: value.files,
            quota: value.quota,
            storageFailed: false,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(storageFailed: true, storageFailure: failure));
    }
  }

  Future<Result<SyncReport>> syncNow() async {
    final r = await _session.syncNow();
    if (r is Ok<SyncReport>) unawaited(loadStorage());
    return r;
  }

  Future<void> openDateSettings() =>
      _lock.runExternal(_settings.openDateSettings);

  /// Signs out unless some changes aren't in Drive yet (then [force]).
  Future<UnsavedChanges?> signOut({bool force = false}) async {
    emit(state.copyWith(busy: true));
    if (!force) {
      final unsaved = await _session.unsavedChanges();
      if (unsaved > 0) {
        if (!isClosed) emit(state.copyWith(busy: false));
        return UnsavedChanges(unsaved);
      }
    }
    await _session.signOut();
    return null;
  }

  Future<Result<void>> deleteEverything() async {
    emit(state.copyWith(busy: true));
    final r = await _session.deleteEverything();
    if (!isClosed && r is Err<void>) emit(state.copyWith(busy: false));
    return r;
  }

  @override
  Future<void> close() async {
    _sync.status.removeListener(_onSync);
    _lifecycle?.dispose();
    await super.close();
  }
}

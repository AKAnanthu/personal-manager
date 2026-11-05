import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_details_repository.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';

final class EntryViewState extends Equatable {
  const EntryViewState({
    this.status = LoadStatus.loading,
    this.entry,
    this.busy = false,
    this.failure,
    this.deleted = false,
  });

  final LoadStatus status;
  final PersonalEntry? entry;
  final bool busy;
  final Failure? failure;
  final bool deleted;

  EntryViewState copyWith({
    LoadStatus? status,
    PersonalEntry? Function()? entry,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
    bool? deleted,
  }) => EntryViewState(
    status: status ?? this.status,
    entry: entry != null ? entry() : this.entry,
    busy: busy ?? this.busy,
    failure: clearFailure ? null : (failure ?? this.failure),
    deleted: deleted ?? this.deleted,
  );

  @override
  List<Object?> get props => [status, entry, busy, failure, deleted];
}

/// Shows one entry live (it updates after an edit) and deletes it.
class EntryViewCubit extends Cubit<EntryViewState> {
  EntryViewCubit({required this._repository, required this.entryId})
    : super(const EntryViewState());

  final PersonalDetailsRepository _repository;
  final String entryId;
  StreamSubscription<PersonalEntry?>? _sub;

  void start() {
    _sub ??= _repository.watchEntry(entryId).listen((e) {
      // Deleted elsewhere (or by us): the page closes on [deleted].
      if (e == null && state.entry != null) {
        emit(state.copyWith(deleted: true));
        return;
      }
      emit(
        state.copyWith(
          status: e == null ? LoadStatus.failure : LoadStatus.ready,
          entry: () => e,
          failure: e == null ? const NotFoundFailure() : null,
        ),
      );
    }, onError: (Object _) => emit(state.copyWith(status: LoadStatus.failure)));
  }

  Future<void> delete() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, clearFailure: true));
    final r = await _repository.delete(entryId);
    if (isClosed) return;
    emit(
      r.fold(
        (f) => state.copyWith(busy: false, failure: f),
        (_) => state.copyWith(busy: false, deleted: true),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await super.close();
  }
}

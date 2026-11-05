import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';

abstract interface class LendingRepository {
  Stream<LendingTab> watchTab(LendingDirection direction);

  Stream<LendingRecord?> watchRecord(String id);

  /// Pending records with a due date (for the dashboard), soonest first.
  Stream<List<LendingRecord>> watchUpcomingDue();

  Future<Result<String>> save(LendingDraft draft);

  /// Pending ↔ Completed ("Mark repaid"). Completing sets today's date and
  /// stops the reminder.
  Future<Result<void>> setStatus(String id, LendingStatus status);

  Future<Result<void>> delete(String id);
}

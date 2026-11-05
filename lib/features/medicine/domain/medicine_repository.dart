import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine.dart';

abstract interface class MedicineRepository {
  /// By name.
  Stream<List<Medicine>> watchAll();

  Stream<Medicine?> watchMedicine(String id);

  Future<Result<String>> save(MedicineDraft draft);

  /// Pause or resume reminders without deleting the schedule.
  Future<Result<void>> setEnabled(String id, {required bool value});

  Future<Result<void>> delete(String id);
}

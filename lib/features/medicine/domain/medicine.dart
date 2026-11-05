import 'package:equatable/equatable.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';

/// A reminder schedule only: a name, times, days. No dosage, records or
/// advice (PRD §14).
final class Medicine extends Equatable {
  const Medicine({
    required this.id,
    required this.name,
    required this.times,
    this.weekdays = const {},
    this.enabled = true,
  });

  final String id;
  final String name;

  /// Sorted, no duplicates.
  final List<TimeOfDayMinutes> times;

  /// `DateTime.monday`…`DateTime.sunday`; empty = every day.
  final Set<int> weekdays;
  final bool enabled;

  bool get everyDay => weekdays.isEmpty || weekdays.length == 7;

  bool ringsOn(DateTime day) => everyDay || weekdays.contains(day.weekday);

  @override
  List<Object?> get props => [id, name, times, weekdays, enabled];
}

final class MedicineDraft extends Equatable {
  const MedicineDraft({
    required this.name,
    required this.times,
    this.id,
    this.weekdays = const {},
    this.enabled = true,
  });

  final String? id;
  final String name;
  final List<TimeOfDayMinutes> times;
  final Set<int> weekdays;
  final bool enabled;

  @override
  List<Object?> get props => [id, name, times, weekdays, enabled];
}

/// The next dose across enabled medicines, strictly after [now] (local
/// wall-clock time), or null if none within a week.
({Medicine medicine, DateTime at})? nextDose(
  List<Medicine> medicines,
  DateTime now,
) {
  ({Medicine medicine, DateTime at})? best;
  for (final m in medicines) {
    if (!m.enabled) continue;
    for (var d = 0; d <= 7; d++) {
      final day = DateTime(now.year, now.month, now.day + d);
      if (!m.ringsOn(day)) continue;
      for (final t in m.times) {
        final at = DateTime(day.year, day.month, day.day, t.hour, t.minute);
        if (!at.isAfter(now)) continue;
        if (best == null || at.isBefore(best.at)) best = (medicine: m, at: at);
        break; // times are sorted: the first later one is this day's next
      }
    }
  }
  return best;
}

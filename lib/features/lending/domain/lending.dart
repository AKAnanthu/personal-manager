import 'package:equatable/equatable.dart';

enum LendingDirection { lent, borrowed }

/// Pending or Completed only; no partial repayments in V1.
enum LendingStatus { pending, completed }

/// Due-date reminders ring at 9:00 on the due date (as in the design).
const lendingReminderHour = 9;

final class LendingRecord extends Equatable {
  const LendingRecord({
    required this.id,
    required this.direction,
    required this.person,
    required this.amountPaise,
    required this.givenOn,
    required this.status,
    this.dueOn,
    this.completedOn,
    this.notes = '',
    this.remind = false,
  });

  final String id;
  final LendingDirection direction;
  final String person;
  final int amountPaise;
  final DateTime givenOn;
  final DateTime? dueOn;
  final LendingStatus status;
  final DateTime? completedOn;
  final String notes;
  final bool remind;

  bool get isPending => status == LendingStatus.pending;

  /// The reminder time, if one will ring.
  DateTime? get reminderAt {
    final d = dueOn;
    if (!remind || !isPending || d == null) return null;
    return DateTime(d.year, d.month, d.day, lendingReminderHour);
  }

  @override
  List<Object?> get props => [
    id,
    direction,
    person,
    amountPaise,
    givenOn,
    dueOn,
    status,
    completedOn,
    notes,
    remind,
  ];
}

final class LendingDraft extends Equatable {
  const LendingDraft({
    required this.direction,
    required this.person,
    required this.amountPaise,
    required this.givenOn,
    this.id,
    this.dueOn,
    this.status = LendingStatus.pending,
    this.notes = '',
    this.remind = false,
  });

  final String? id;
  final LendingDirection direction;
  final String person;
  final int amountPaise;
  final DateTime givenOn;
  final DateTime? dueOn;
  final LendingStatus status;
  final String notes;
  final bool remind;

  @override
  List<Object?> get props => [
    id,
    direction,
    person,
    amountPaise,
    givenOn,
    dueOn,
    status,
    notes,
    remind,
  ];
}

/// One tab's records and its header numbers. The total counts pending
/// records only (owner decision).
final class LendingTab extends Equatable {
  const LendingTab(this.records);

  /// Pending first (soonest due), then completed (latest first).
  final List<LendingRecord> records;

  List<LendingRecord> get pending => records.where((r) => r.isPending).toList();

  int get pendingTotalPaise => pending.fold(0, (a, r) => a + r.amountPaise);

  int get pendingPeople =>
      pending.map((r) => r.person.trim().toLowerCase()).toSet().length;

  DateTime? get nextDue {
    final dues = [for (final r in pending) ?r.dueOn]..sort();
    return dues.firstOrNull;
  }

  @override
  List<Object?> get props => [records];
}

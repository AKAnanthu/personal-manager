import 'package:equatable/equatable.dart';

enum UpcomingKind { medicine, reminder, task, lending, documentExpiry }

/// One row in the dashboard's "Coming up" list.
final class UpcomingItem extends Equatable {
  const UpcomingItem({
    required this.kind,
    required this.title,
    required this.at,
    required this.route,
    this.hasTime = true,
  });

  final UpcomingKind kind;
  final String title;
  final DateTime at;

  /// False for date-only items (task due dates).
  final bool hasTime;
  final String route;

  @override
  List<Object?> get props => [kind, title, at, hasTime, route];
}

/// Each feature contributes its upcoming items as a stream.
typedef UpcomingSource = Stream<List<UpcomingItem>> Function();

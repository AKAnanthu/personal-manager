import 'dart:convert';

/// Deterministic notification IDs: the same entity + occurrence always maps
/// to the same positive 31-bit int, so notifications can be replaced or
/// cancelled without storing IDs.
abstract final class NotificationIds {
  static const _mask = 0x7fffffff;

  static int forOccurrence(
    String entityType,
    String entityId,
    String occurrenceKey, {
    int salt = 0,
  }) => _fnv1a('$entityType|$entityId|$occurrenceKey|$salt');

  /// The one-off copy created when the user snoozes notification [originalId].
  static int snoozeOf(int originalId) => _fnv1a('snooze|$originalId');

  /// 32-bit FNV-1a over UTF-8, masked to a positive non-zero int.
  static int _fnv1a(String input) {
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(input)) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    final id = hash & _mask;
    return id == 0 ? 1 : id;
  }
}

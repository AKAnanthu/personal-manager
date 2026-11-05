import 'package:flutter/material.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

Future<DateTime?> pickDate(
  BuildContext context, {
  DateTime? initial,
  DateTime? now,
}) {
  final today = DateUtils.dateOnly(now ?? DateTime.now());
  final start = initial ?? today;
  return showDatePicker(
    context: context,
    initialDate: start,
    firstDate: DateTime(today.year - 50),
    lastDate: DateTime(today.year + 50),
  );
}

Future<TimeOfDay?> pickTime(BuildContext context, {TimeOfDay? initial}) =>
    showTimePicker(context: context, initialTime: initial ?? TimeOfDay.now());

/// Date, then time. Null if either picker is dismissed.
Future<DateTime?> pickDateTime(
  BuildContext context, {
  DateTime? initial,
  DateTime? now,
}) async {
  final date = await pickDate(context, initial: initial, now: now);
  if (date == null || !context.mounted) return null;
  final time = await pickTime(
    context,
    initial: initial == null ? null : TimeOfDay.fromDateTime(initial),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

DateTime withTime(DateTime date, TimeOfDay t) =>
    DateTime(date.year, date.month, date.day, t.hour, t.minute);

/// After saving something with a reminder while notifications are off.
void showNotificationsBlocked(
  BuildContext context,
  NotificationPermissions permissions,
) {
  final l10n = AppLocalizations.of(context);
  showSnack(
    context,
    l10n.notificationsOffMessage,
    actionLabel: l10n.openSettingsAction,
    onAction: permissions.openSettings,
  );
}

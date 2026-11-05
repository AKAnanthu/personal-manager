import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// "8:00 PM" / "20:00", following the device's 12/24-hour setting.
String formatDoseTime(BuildContext context, TimeOfDayMinutes t) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: t.hour, minute: t.minute),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

/// Short weekday name for ISO [weekday] (1 = Monday).
String weekdayShort(String locale, int weekday) =>
    // 1 January 2024 was a Monday.
    DateFormat.E(locale).format(DateTime(2024, 1, weekday));

String weekdayLong(String locale, int weekday) =>
    DateFormat.EEEE(locale).format(DateTime(2024, 1, weekday));

/// "Every day", "Mon – Sat", "Mon, Wed, Fri".
String daysLabel(BuildContext context, Medicine m) {
  final l10n = AppLocalizations.of(context);
  if (m.everyDay) return l10n.medicineEveryDay;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final days = m.weekdays.toList()..sort();
  final consecutive =
      days.length >= 3 && days.last - days.first == days.length - 1;
  if (consecutive) {
    return l10n.medicineDayRange(
      weekdayShort(locale, days.first),
      weekdayShort(locale, days.last),
    );
  }
  return days.map((d) => weekdayShort(locale, d)).join(', ');
}

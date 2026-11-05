import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Locale-aware date/time formatting. Times follow the device 12/24-hour
/// setting.
final class AppFormats {
  AppFormats.of(BuildContext context)
    : _locale = Localizations.localeOf(context).toLanguageTag(),
      _material = MaterialLocalizations.of(context),
      _l10n = AppLocalizations.of(context),
      _use24h = MediaQuery.alwaysUse24HourFormatOf(context);

  final String _locale;
  final MaterialLocalizations _material;
  final AppLocalizations _l10n;
  final bool _use24h;

  /// "4 Nov" (adds the year when it isn't [now]'s).
  String shortDate(DateTime d, {DateTime? now}) {
    final year = (now ?? DateTime.now()).year;
    return d.year == year
        ? DateFormat.MMMd(_locale).format(d)
        : DateFormat.yMMMd(_locale).format(d);
  }

  /// "Wed, 4 Nov".
  String weekdayDate(DateTime d) => DateFormat.MMMEd(_locale).format(d);

  /// "Tuesday, 3 November".
  String longDate(DateTime d) => DateFormat.MMMMEEEEd(_locale).format(d);

  /// "Aug 2031".
  String monthYear(DateTime d) => DateFormat.yMMM(_locale).format(d);

  /// "860 KB", "1.2 MB" (1024-based, as phones show file sizes).
  String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${NumberFormat('#,##0', _locale).format(kb)} KB';
    return '${NumberFormat('#,##0.0', _locale).format(kb / 1024)} MB';
  }

  /// "14 Mar 1992" (always with the year).
  String fullDate(DateTime d) => DateFormat.yMMMd(_locale).format(d);

  String time(DateTime d) => _material.formatTimeOfDay(
    TimeOfDay.fromDateTime(d),
    alwaysUse24HourFormat: _use24h,
  );

  String weekdayName(DateTime d) => DateFormat.EEEE(_locale).format(d);

  String weekdayShort(DateTime d) => DateFormat.E(_locale).format(d);

  String monthShort(DateTime d) => DateFormat.MMM(_locale).format(d);

  /// "29 February" style day + month, no year.
  String dayMonth(DateTime d) => DateFormat.MMMMd(_locale).format(d);

  /// "Today, 8:00 PM" / "Tomorrow, …" / "Yesterday, …" / "12 Nov, …".
  String relativeDateTime(DateTime d, DateTime now) {
    final t = time(d);
    final days = DateUtils.dateOnly(d)
        .difference(DateUtils.dateOnly(now))
        .inDays;
    return switch (days) {
      0 => _l10n.whenToday(t),
      1 => _l10n.whenTomorrow(t),
      -1 => _l10n.whenYesterday(t),
      _ => _l10n.whenDateTime(shortDate(d, now: now), t),
    };
  }
}

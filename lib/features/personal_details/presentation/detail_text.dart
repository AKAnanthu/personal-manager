import 'package:intl/intl.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Date fields are stored as `yyyy-MM-dd`, independent of locale.
final _isoDate = DateFormat('yyyy-MM-dd');

String encodeDetailDate(DateTime d) => _isoDate.format(d);

DateTime? decodeDetailDate(String v) => v.isEmpty ? null : DateTime.tryParse(v);

extension DetailText on AppLocalizations {
  /// The user's title for named kinds, else the kind ("Aadhaar").
  String entryName(PersonalEntry e) => e.kind.namedByUser && e.title.isNotEmpty
      ? e.title
      : detailKind(e.kind.name);

  String fieldLabel(DetailField f) => f.isCustom
      ? ((f.label?.isNotEmpty ?? false) ? f.label ?? '' : customFieldLabelHint)
      : detailField(f.key);
}

/// Value as shown: dates formatted for the locale, the rest as typed.
String displayValue(AppFormats fmt, DetailKind kind, DetailField f) {
  if (kind.spec(f.key)?.input == FieldInput.date) {
    if (decodeDetailDate(f.value) case final d?) return fmt.fullDate(d);
  }
  return f.value;
}

import 'package:equatable/equatable.dart';

enum DetailCategory { personal, family, identification, additional }

enum FieldInput { text, multiline, date, phone, email, idNumber }

/// A template field. Labels come from l10n by [key].
final class FieldSpec {
  const FieldSpec(this.key, this.input, {this.sensitive = false});

  final String key;
  final FieldInput input;

  /// Masked in lists and copied with clipboard auto-clear.
  final bool sensitive;
}

/// Entry types and their template fields (PRD §5).
enum DetailKind {
  profile(DetailCategory.personal, [
    FieldSpec('fullName', FieldInput.text),
    FieldSpec('dateOfBirth', FieldInput.date),
    FieldSpec('phone', FieldInput.phone),
    FieldSpec('email', FieldInput.email),
    FieldSpec('currentAddress', FieldInput.multiline),
    FieldSpec('permanentAddress', FieldInput.multiline),
    FieldSpec('otherInfo', FieldInput.multiline),
  ]),
  familyMember(DetailCategory.family, [
    FieldSpec('relationship', FieldInput.text),
    FieldSpec('phone', FieldInput.phone),
    FieldSpec('dateOfBirth', FieldInput.date),
    FieldSpec('address', FieldInput.multiline),
    FieldSpec('emergencyContact', FieldInput.text),
  ], namedByUser: true),
  aadhaar(DetailCategory.identification, _idFields),
  pan(DetailCategory.identification, _idFields),
  passport(DetailCategory.identification, _idFieldsWithExpiry),
  drivingLicence(DetailCategory.identification, _idFieldsWithExpiry),
  voterId(DetailCategory.identification, _idFields),
  otherId(
    DetailCategory.identification,
    _idFieldsWithExpiry,
    namedByUser: true,
  ),
  education(DetailCategory.additional, [
    FieldSpec('institution', FieldInput.text),
    FieldSpec('qualification', FieldInput.text),
    FieldSpec('year', FieldInput.text),
    FieldSpec('notes', FieldInput.multiline),
  ]),
  employment(DetailCategory.additional, [
    FieldSpec('employer', FieldInput.text),
    FieldSpec('role', FieldInput.text),
    FieldSpec('employeeId', FieldInput.idNumber, sensitive: true),
    FieldSpec('notes', FieldInput.multiline),
  ]),
  financial(DetailCategory.additional, [
    FieldSpec('institution', FieldInput.text),
    FieldSpec('reference', FieldInput.idNumber, sensitive: true),
    FieldSpec('notes', FieldInput.multiline),
  ], namedByUser: true),
  custom(DetailCategory.additional, [], namedByUser: true);

  DetailKind(this.category, this.fields, {this.namedByUser = false});

  final DetailCategory category;
  final List<FieldSpec> fields;

  /// The user types the entry's title (e.g. a family member's name).
  final bool namedByUser;

  static List<DetailKind> of(DetailCategory c) =>
      values.where((k) => k.category == c && k != profile).toList();

  FieldSpec? spec(String key) => fields.where((f) => f.key == key).firstOrNull;
}

const _idFields = [
  FieldSpec('number', FieldInput.idNumber, sensitive: true),
  FieldSpec('nameOnId', FieldInput.text),
  FieldSpec('notes', FieldInput.multiline),
];

const _idFieldsWithExpiry = [
  FieldSpec('number', FieldInput.idNumber, sensitive: true),
  FieldSpec('nameOnId', FieldInput.text),
  FieldSpec('expiryDate', FieldInput.date),
  FieldSpec('notes', FieldInput.multiline),
];

/// A field value. [label] is set only for user-added custom fields.
final class DetailField extends Equatable {
  const DetailField({
    required this.key,
    required this.value,
    this.label,
    this.sensitive = false,
  });

  final String key;
  final String? label;
  final String value;
  final bool sensitive;

  bool get isCustom => label != null;

  Map<String, Object?> toJson() => {
    'k': key,
    if (label != null) 'l': label,
    'v': value,
    if (sensitive) 's': true,
  };

  static DetailField? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final k = json['k'];
    final v = json['v'];
    final l = json['l'];
    if (k is! String || v is! String || (l != null && l is! String)) {
      return null;
    }
    return DetailField(
      key: k,
      value: v,
      label: l as String?,
      sensitive: json['s'] == true,
    );
  }

  @override
  List<Object?> get props => [key, label, value, sensitive];
}

final class PersonalEntry extends Equatable {
  const PersonalEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.fields,
    required this.updatedAt,
    this.linkedDocumentIds = const [],
  });

  final String id;
  final DetailKind kind;

  /// User-entered for [DetailKind.namedByUser] kinds, else empty (the UI
  /// shows the kind's name).
  final String title;
  final List<DetailField> fields;
  final List<String> linkedDocumentIds;
  final DateTime updatedAt;

  String value(String key) =>
      fields.where((f) => f.key == key).firstOrNull?.value ?? '';

  /// The value shown on the card (the ID number, or the first filled field).
  DetailField? get primary {
    final filled = fields.where((f) => f.value.trim().isNotEmpty);
    return filled.where((f) => f.sensitive).firstOrNull ?? filled.firstOrNull;
  }

  @override
  List<Object?> get props => [
    id,
    kind,
    title,
    fields,
    linkedDocumentIds,
    updatedAt,
  ];
}

final class PersonalEntryDraft extends Equatable {
  const PersonalEntryDraft({
    required this.kind,
    required this.fields,
    this.id,
    this.title = '',
    this.linkedDocumentIds = const [],
  });

  final String? id;
  final DetailKind kind;
  final String title;
  final List<DetailField> fields;
  final List<String> linkedDocumentIds;

  @override
  List<Object?> get props => [id, kind, title, fields, linkedDocumentIds];
}

/// "XXXX XXXX 4821": keeps the last 4 letters/digits, hides the rest.
String maskValue(String value) {
  bool isAlnum(int i) => _alnum.hasMatch(value[i]);
  final positions = [
    for (var i = 0; i < value.length; i++)
      if (isAlnum(i)) i,
  ];
  if (positions.length <= 4) return '•' * value.length.clamp(0, 8);
  final firstKept = positions[positions.length - 4];
  return [
    for (var i = 0; i < value.length; i++)
      if (i < firstKept && isAlnum(i)) '•' else value[i],
  ].join();
}

final _alnum = RegExp('[A-Za-z0-9]');

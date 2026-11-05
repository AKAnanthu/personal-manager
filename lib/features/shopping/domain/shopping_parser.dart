// Pure Dart: no Flutter imports, so it is fast to test exhaustively.
import 'package:equatable/equatable.dart';

/// One line of a pasted message, understood as a shopping item.
final class ParsedItem extends Equatable {
  const ParsedItem({
    required this.name,
    required this.line,
    this.quantity,
    this.unit,
    this.needsReview = false,
  });

  final String name;

  /// Normalised quantity as text ("2", "1.5", "1/2"); null when none found.
  final String? quantity;

  /// Canonical unit ("kg", "g", "l", "ml", "pcs", "pkt", "dozen", …).
  final String? unit;

  /// Missing, zero or implausible quantity: the user must confirm it.
  final bool needsReview;

  /// The original line, for the review screen.
  final String line;

  @override
  List<Object?> get props => [name, quantity, unit, needsReview, line];

  @override
  String toString() =>
      'ParsedItem($name, $quantity, $unit${needsReview ? ', review' : ''})';
}

/// Turns user-pasted text (typically a WhatsApp message) into items.
/// Never guesses a quantity: anything unclear is flagged for review.
abstract final class ShoppingParser {
  /// Quantities above this are almost certainly not quantities (phone
  /// numbers, prices) and are flagged.
  static const maxPlausibleQuantity = 999;

  static List<ParsedItem> parse(String text) => [
    for (final raw in text.split(RegExp(r'\r\n|\r|\n')))
      for (final piece in _splitInline(_stripChatPrefix(raw)))
        ?_parseLine(piece, raw.trim()),
  ];

  /// Parses one item typed by the user (e.g. the "Add an item" field).
  static ParsedItem? parseOne(String text) => _parseLine(text, text.trim());

  /// Accepts "2", "1.5", "1,5", "1/2", "1 1/2", "½"; positive only.
  static double? quantityValue(String input) {
    final s = _normaliseNumber(input.trim());
    if (s == null) return null;
    final mixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(s);
    if (mixed != null) {
      final whole = int.parse(mixed[1] ?? '0');
      final den = int.parse(mixed[3] ?? '0');
      if (den == 0) return null;
      final v = whole + int.parse(mixed[2] ?? '0') / den;
      return v > 0 ? v : null;
    }
    final frac = RegExp(r'^(\d+)/(\d+)$').firstMatch(s);
    if (frac != null) {
      final den = int.parse(frac[2] ?? '0');
      if (den == 0) return null;
      final v = int.parse(frac[1] ?? '0') / den;
      return v > 0 ? v : null;
    }
    final v = double.tryParse(s);
    return v != null && v > 0 && v.isFinite ? v : null;
  }

  /// "1,5" → "1.5", "½" → "1/2", "1 ½" → "1 1/2"; null if not a number.
  static String? normaliseQuantity(String input) {
    final s = _normaliseNumber(input.trim());
    return s != null && quantityValue(s) != null ? s : null;
  }

  /// Canonical unit for a typed unit word, or null if it isn't one.
  static String? canonicalUnit(String word) => _units[word.toLowerCase()];

  /// Sum of two quantities as text, for merging duplicates. Null when
  /// either isn't numeric.
  static String? addQuantities(String a, String b) {
    final x = quantityValue(a);
    final y = quantityValue(b);
    if (x == null || y == null) return null;
    final sum = x + y;
    return sum == sum.roundToDouble()
        ? sum.toInt().toString()
        : _trimZeros(sum.toStringAsFixed(3));
  }

  // ---------------------------------------------------------------------

  static const _units = {
    'kg': 'kg', 'kgs': 'kg', 'kilo': 'kg', 'kilos': 'kg', //
    'kilogram': 'kg', 'kilograms': 'kg',
    'g': 'g', 'gm': 'g', 'gms': 'g', 'gr': 'g', 'grm': 'g', 'gram': 'g',
    'grams': 'g',
    'l': 'l', 'lt': 'l', 'ltr': 'l', 'ltrs': 'l', 'litre': 'l', 'litres': 'l',
    'liter': 'l', 'liters': 'l',
    'ml': 'ml', 'mls': 'ml',
    'pc': 'pcs', 'pcs': 'pcs', 'piece': 'pcs', 'pieces': 'pcs', 'nos': 'pcs',
    'no': 'pcs',
    'pkt': 'pkt', 'pkts': 'pkt', 'packet': 'pkt', 'packets': 'pkt',
    'pack': 'pkt', 'packs': 'pkt',
    'dozen': 'dozen', 'doz': 'dozen', 'dz': 'dozen',
    'bottle': 'bottle', 'bottles': 'bottle',
    'box': 'box', 'boxes': 'box',
    'bunch': 'bunch', 'bunches': 'bunch',
    'bag': 'bag', 'bags': 'bag',
    'can': 'can', 'cans': 'can', 'tin': 'tin', 'tins': 'tin',
    'roll': 'roll', 'rolls': 'roll',
  };

  static final String _unitAlt =
      (_units.keys.toList()..sort((a, b) => b.length.compareTo(a.length))).join(
        '|',
      );

  // A number: decimal ("1.5", "1,5"), fraction ("1/2"), mixed ("1 1/2"),
  // or a vulgar fraction, optionally after a whole number ("1½").
  static const _num =
      r'(?:\d+\s+\d+\s*/\s*\d+|\d+\s*/\s*\d+|\d+(?:[.,]\d+)?\s*[½¼¾⅓⅔]?|[½¼¾⅓⅔])';

  // Name … quantity [unit]: "Milk 2", "Rice 5 kg", "Milk - 2", "Milk x2",
  // "Milk: 2", "Milk 2x", "Rice 5kg".
  static final _trailing = RegExp(
    '^(?<name>.*?\\p{L}.*?)\\s*(?:[-–:=]\\s*|\\s+[x×]\\s*|\\s+)(?<qty>$_num)'
    '\\s*(?<unit>$_unitAlt)?\\.?\\s*[x×]?\$',
    caseSensitive: false,
    unicode: true,
  );

  // Quantity [unit] … name: "2 Milk", "5 kg rice", "5kg of rice", "2x milk".
  // The number must stand apart from the name ("7up 2" is not 7 × "up").
  static final _leading = RegExp(
    '^(?<qty>$_num)'
    r'\s*(?<unit>'
    '$_unitAlt'
    r')?\.?'
    r'(?:\s*[x×]\s*|\s+of\s+|\s+)(?<name>\p{L}.*)$',
    caseSensitive: false,
    unicode: true,
  );

  // Name … unit only, no number: "Rice kg".
  static final _unitOnly = RegExp(
    '^(?<name>.*?\\p{L}.*?)\\s+(?<unit>$_unitAlt)\\.?\$',
    caseSensitive: false,
    unicode: true,
  );

  // WhatsApp exports/copies: "[03/11/26, 6:30 PM] Asha: …" (iOS) and
  // "03/11/2026, 18:30 - Asha: …" (Android).
  static final _chatPrefix = RegExp(
    r'^\s*\[?\d{1,2}[/.\-]\d{1,2}[/.\-]\d{2,4},?\s+\d{1,2}[:.]\d{2}'
    r'(?:[:.]\d{2})?\s*(?:[AaPp]\.?\s?[Mm]\.?)?\]?\s*(?:[-–]\s*)?'
    r'[^:]{1,60}:\s*',
  );

  static final _noise = RegExp(
    // The analyzer checks this without the unicode flag; it is valid with
    // it (covered by tests).
    // ignore: valid_regexps
    r'[\p{Extended_Pictographic}\u{1F3FB}-\u{1F3FF}\u{FE0F}\u{200D}\u{20E3}'
    r'\u{2022}\u{25AA}\u{25AB}\u{25E6}\u{2023}\u{2043}✓✔☐☑✅]',
    unicode: true,
  );

  static final _bullet = RegExp(
    r'^\s*(?:[-*•·>+–—]+\s*|\(?\d{1,3}[.)]\s+|\[\s?[xX]?\s?\]\s*)',
  );

  // Lines WhatsApp adds that are never items.
  static final _system = RegExp(
    '<media omitted>|messages and calls are end-to-end encrypted|'
    'this message was deleted|<this message was edited>',
    caseSensitive: false,
  );

  static String _stripChatPrefix(String line) =>
      line.replaceFirst(_chatPrefix, '');

  /// "Rice 5 kg, Sugar 2 kg; Eggs 12" → three pieces. A comma inside a
  /// number ("1,5 kg") doesn't split.
  static Iterable<String> _splitInline(String line) =>
      line.split(RegExp(r'\s*;\s*|,\s+|,(?=\s*\p{L})', unicode: true));

  static ParsedItem? _parseLine(String piece, String originalLine) {
    var s = piece.replaceAll(_noise, ' ');
    if (_system.hasMatch(s)) return null;
    s = s.replaceFirst(_bullet, '');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Separators left dangling ("Milk -").
    s = s.replaceAll(RegExp(r'^[\s\-–:=,.]+|[\s\-–:=,]+$'), '');
    if (!RegExp(r'\p{L}', unicode: true).hasMatch(s)) return null;

    String? qty;
    String? unit;
    var name = s;
    final t = _trailing.firstMatch(s);
    final l = _leading.firstMatch(s);
    if (t != null && l != null) {
      // "2 milk 3": numbers at both ends; can't tell which is meant.
      return _item(s, null, null, originalLine, review: true);
    } else if (l != null) {
      name = l.namedGroup('name') ?? s;
      qty = l.namedGroup('qty');
      unit = l.namedGroup('unit');
    } else if (t != null) {
      name = t.namedGroup('name') ?? s;
      qty = t.namedGroup('qty');
      unit = t.namedGroup('unit');
    } else if (_unitOnly.firstMatch(s) case final u?) {
      name = u.namedGroup('name') ?? s;
      unit = u.namedGroup('unit');
    }
    // "2 kg" alone: a quantity with no item.
    if (canonicalUnit(_cleanName(name)) != null) return null;
    return _item(name, qty, unit, originalLine);
  }

  static ParsedItem _item(
    String rawName,
    String? rawQty,
    String? rawUnit,
    String line, {
    bool review = false,
  }) {
    final name = _cleanName(rawName);
    final qty = rawQty == null ? null : normaliseQuantity(rawQty);
    final value = qty == null ? null : quantityValue(qty);
    final plausible = value != null && value <= maxPlausibleQuantity;
    return ParsedItem(
      name: name,
      quantity: plausible ? qty : null,
      unit: rawUnit == null ? null : canonicalUnit(rawUnit),
      needsReview: review || !plausible,
      line: line,
    );
  }

  static String _cleanName(String s) {
    final n = s
        .replaceAll(RegExp(r'^[\s\-–:=,.]+|[\s\-–:=,.]+$'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
    return n.isEmpty ? n : n[0].toUpperCase() + n.substring(1);
  }

  static const _vulgar = {
    '½': '1/2',
    '¼': '1/4',
    '¾': '3/4',
    '⅓': '1/3',
    '⅔': '2/3',
  };

  static String? _normaliseNumber(String s) {
    var out = s.replaceAll(RegExp(r'\s*/\s*'), '/');
    for (final MapEntry(:key, :value) in _vulgar.entries) {
      out = out.replaceAllMapped(
        RegExp('(\\d*)\\s*$key'),
        (m) => (m[1] ?? '').isEmpty ? value : '${m[1]} $value',
      );
    }
    out = out.replaceAll(RegExp(r'(?<=\d),(?=\d)'), '.');
    out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (!RegExp(r'^(?:\d+ \d+/\d+|\d+/\d+|\d+(?:\.\d+)?)$').hasMatch(out)) {
      return null;
    }
    // "02" → "2", "1.50" → "1.5".
    if (RegExp(r'^\d+(?:\.\d+)?$').hasMatch(out)) {
      final v = double.parse(out);
      return v == v.roundToDouble()
          ? v.toInt().toString()
          : _trimZeros(out.replaceFirst(RegExp(r'^0+(?=\d)'), ''));
    }
    return out;
  }

  static String _trimZeros(String s) =>
      s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
}

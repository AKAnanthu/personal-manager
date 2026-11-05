import 'package:intl/intl.dart';

/// Money is INR only in V1 (owner decision) and always handled as integer
/// paise, never `double`.
abstract final class Money {
  static const currencySymbol = '₹';

  /// Parses user input in rupees ("1,846", "1846.5", "₹ 1,846.50") to paise.
  /// Null for empty, negative, malformed or more than 2 decimals.
  static int? parseRupees(String input) {
    final s = input.replaceAll(RegExp(r'[₹,\s]'), '');
    final m = RegExp(r'^(\d{1,9})(?:\.(\d{1,2}))?$').firstMatch(s);
    if (m == null) return null;
    final rupees = int.parse(m[1] ?? '0');
    final frac = (m[2] ?? '').padRight(2, '0');
    return rupees * 100 + int.parse(frac.isEmpty ? '0' : frac);
  }

  /// "₹1,846" or "₹1,846.50" with Indian grouping ("₹1,23,456").
  static String format(int paise) {
    final whole = paise % 100 == 0;
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: currencySymbol,
      decimalDigits: whole ? 0 : 2,
    ).format(paise / 100);
  }

  /// Editable text for an amount field ("1846" / "1846.50").
  static String toInput(int paise) => paise % 100 == 0
      ? '${paise ~/ 100}'
      : '${paise ~/ 100}.${(paise % 100).toString().padLeft(2, '0')}';
}

/// Builds a safe FTS5 MATCH expression from free text: each word becomes a
/// quoted prefix term (`"rout"*`), so user input can't inject FTS syntax.
/// Returns null when there is nothing searchable.
String? ftsPrefixQuery(String input) {
  final words = input
      .toLowerCase()
      .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
      .where((w) => w.isNotEmpty)
      .take(8);
  if (words.isEmpty) return null;
  return words.map((w) => '"$w"*').join(' ');
}

/// App-password strength. Only [minLength] is enforced; the score drives the
/// strength meter.
enum PasswordStrength {
  tooShort,
  fair,
  good,
  strong;

  static const minLength = 8;

  bool get isAcceptable => this != tooShort;

  /// Filled segments on the 4-segment meter (Good = 3 of 4, as designed).
  int get score => index + 1;

  static PasswordStrength evaluate(String password) {
    if (password.length < minLength) return tooShort;
    var points = 0;
    if (password.length >= 12) points++;
    if (RegExp('[a-z]').hasMatch(password) &&
        RegExp('[A-Z]').hasMatch(password)) {
      points++;
    }
    if (RegExp(r'\d').hasMatch(password)) points++;
    if (RegExp('[^A-Za-z0-9]').hasMatch(password)) points++;
    return switch (points) {
      0 || 1 => fair,
      2 => good,
      _ => strong,
    };
  }
}

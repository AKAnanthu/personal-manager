import 'package:flutter/material.dart';

/// Background/foreground pair for category tiles and status pills.
@immutable
final class AccentPair {
  const AccentPair(this.background, this.foreground);

  factory AccentPair.lerp(AccentPair a, AccentPair b, double t) => AccentPair(
    Color.lerp(a.background, b.background, t) ?? b.background,
    Color.lerp(a.foreground, b.foreground, t) ?? b.foreground,
  );

  final Color background;
  final Color foreground;
}

/// Design tokens that have no slot in [ColorScheme].
@immutable
final class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.cardBorder,
    required this.fieldFill,
    required this.infoBanner,
    required this.mutedTile,
    required this.heroCard,
    required this.onHeroCard,
    required this.navBar,
    required this.formLabel,
    required this.favourite,
    required this.warningText,
    required this.medicine,
    required this.reminder,
    required this.task,
    required this.pdfFile,
    required this.sheetFile,
  });

  final Color cardBorder;
  final Color fieldFill;
  final Color infoBanner;
  final Color mutedTile;
  final Color heroCard;
  final Color onHeroCard;
  final Color navBar;
  final Color formLabel;
  final Color favourite;

  /// Text on the reminder/warning background (darker than its icon colour).
  final Color warningText;
  final AccentPair medicine;
  final AccentPair reminder;
  final AccentPair task;
  final AccentPair pdfFile;
  final AccentPair sheetFile;

  /// Image files share the medicine (blue) pair in the design.
  AccentPair get imageFile => medicine;

  static const light = AppPalette(
    cardBorder: Color(0xFFE3E7E5),
    fieldFill: Color(0xFFEAEEEC),
    infoBanner: Color(0xFFEEF3F1),
    mutedTile: Color(0xFFF4F6F5),
    heroCard: Color(0xFF0F6B5C),
    onHeroCard: Color(0xFFFFFFFF),
    navBar: Color(0xFFFFFFFF),
    formLabel: Color(0xFF3E4643),
    favourite: Color(0xFFB7791F),
    warningText: Color(0xFF5A3B00),
    medicine: AccentPair(Color(0xFFE7EEFB), Color(0xFF2F4F8F)),
    reminder: AccentPair(Color(0xFFFCEFD6), Color(0xFF7A4F00)),
    task: AccentPair(Color(0xFFD6EDE7), Color(0xFF0A4F44)),
    pdfFile: AccentPair(Color(0xFFFBE4E1), Color(0xFF9A2D21)),
    sheetFile: AccentPair(Color(0xFFE3F1E8), Color(0xFF23663E)),
  );

  /// Values marked "derived" are not in the dark mockup; chosen to match the
  /// dark palette and keep ≥4.5:1 text contrast (see theme_contrast_test).
  static const dark = AppPalette(
    cardBorder: Color(0xFF2A3230),
    fieldFill: Color(0xFF222927), // derived
    infoBanner: Color(0xFF1B2523), // derived
    mutedTile: Color(0xFF222927), // derived
    heroCard: Color(0xFF1A2C28),
    onHeroCard: Color(0xFFE4EAE8),
    navBar: Color(0xFF161B1A),
    formLabel: Color(0xFFC2CCC9),
    favourite: Color(0xFFE5B158), // derived
    warningText: Color(0xFFF3D28E),
    medicine: AccentPair(Color(0xFF1E2A44), Color(0xFFB7C9F0)),
    reminder: AccentPair(Color(0xFF3A2E12), Color(0xFFF3D28E)),
    task: AccentPair(Color(0xFF1F3B35), Color(0xFFA8E6D8)),
    pdfFile: AccentPair(Color(0xFF3F221E), Color(0xFFF4B9AF)), // derived
    sheetFile: AccentPair(Color(0xFF1C3324), Color(0xFFA9DCB9)), // derived
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t) ?? b;
    return AppPalette(
      cardBorder: c(cardBorder, other.cardBorder),
      fieldFill: c(fieldFill, other.fieldFill),
      infoBanner: c(infoBanner, other.infoBanner),
      mutedTile: c(mutedTile, other.mutedTile),
      heroCard: c(heroCard, other.heroCard),
      onHeroCard: c(onHeroCard, other.onHeroCard),
      navBar: c(navBar, other.navBar),
      formLabel: c(formLabel, other.formLabel),
      favourite: c(favourite, other.favourite),
      warningText: c(warningText, other.warningText),
      medicine: AccentPair.lerp(medicine, other.medicine, t),
      reminder: AccentPair.lerp(reminder, other.reminder, t),
      task: AccentPair.lerp(task, other.task, t),
      pdfFile: AccentPair.lerp(pdfFile, other.pdfFile, t),
      sheetFile: AccentPair.lerp(sheetFile, other.sheetFile, t),
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

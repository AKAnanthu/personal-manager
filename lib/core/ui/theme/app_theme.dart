import 'package:flutter/material.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';

/// Shape radii from the design.
abstract final class AppRadii {
  static const iconTile = 12.0;
  static const control = 14.0; // inputs, buttons, quick-access tiles
  static const card = 16.0; // cards, FABs
  static const hero = 20.0;
}

/// Spacing from the design.
abstract final class AppSpacing {
  static const gutter = 16.0;
  static const gap = 8.0;
  static const section = 18.0;
  static const rowPadding = 14.0;
}

abstract final class AppTheme {
  static const fontFamily = 'PlusJakartaSans';

  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0F6B5C),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD6EDE7),
    onPrimaryContainer: Color(0xFF0A4F44),
    secondary: Color(0xFF0F6B5C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD6EDE7),
    onSecondaryContainer: Color(0xFF0A4F44),
    error: Color(0xFFA12C1F),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFBE4E1),
    onErrorContainer: Color(0xFF8A2318),
    surface: Color(0xFFF7F8F6),
    onSurface: Color(0xFF1A1D1C),
    onSurfaceVariant: Color(0xFF5B6461),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFFFFFFF),
    surfaceContainerHigh: Color(0xFFEAEEEC),
    surfaceContainerHighest: Color(0xFFEAEEEC),
    outline: Color(0xFFC9D1CE),
    outlineVariant: Color(0xFFEEF1EF),
  );

  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF7DD3C0),
    onPrimary: Color(0xFF00332B),
    primaryContainer: Color(0xFF1F3B35),
    onPrimaryContainer: Color(0xFFA8E6D8),
    secondary: Color(0xFF7DD3C0),
    onSecondary: Color(0xFF00332B),
    secondaryContainer: Color(0xFF1F3B35),
    onSecondaryContainer: Color(0xFFA8E6D8),
    error: Color(0xFFF2B8B5), // derived
    onError: Color(0xFF601410), // derived
    errorContainer: Color(0xFF3F221E), // derived
    onErrorContainer: Color(0xFFF9DEDC), // derived
    surface: Color(0xFF101413),
    onSurface: Color(0xFFE4EAE8),
    onSurfaceVariant: Color(0xFFA3AFAB),
    surfaceContainerLowest: Color(0xFF1A1F1E),
    surfaceContainerLow: Color(0xFF1A1F1E),
    surfaceContainer: Color(0xFF1A1F1E),
    surfaceContainerHigh: Color(0xFF222927), // derived
    surfaceContainerHighest: Color(0xFF222927), // derived
    outline: Color(0xFF46504D), // derived (non-text, ≥3:1 on surface)
    outlineVariant: Color(0xFF252C2A),
  );

  static ThemeData get light => _build(lightScheme, AppPalette.light);
  static ThemeData get dark => _build(darkScheme, AppPalette.dark);

  static ThemeData _build(ColorScheme scheme, AppPalette palette) {
    final text = _textTheme(scheme);
    const pill = StadiumBorder();
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.control),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: palette.cardBorder),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        labelStyle: text.labelLarge?.copyWith(color: palette.formLabel),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: _inputBorder(scheme.outline),
        enabledBorder: _inputBorder(scheme.outline),
        focusedBorder: _inputBorder(scheme.primary, width: 2),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 2),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(palette.fieldFill),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(controlShape),
        constraints: const BoxConstraints(minHeight: 48),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          shape: pill,
          textStyle: text.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 56),
          shape: pill,
          side: BorderSide(color: scheme.outline),
          foregroundColor: scheme.onPrimaryContainer,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        extendedTextStyle: text.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outline),
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primary,
        labelStyle: text.labelMedium?.copyWith(
          fontSize: 13,
          color: palette.formLabel,
        ),
        secondaryLabelStyle: text.labelMedium?.copyWith(
          fontSize: 13,
          color: scheme.onPrimary,
        ),
        checkmarkColor: scheme.onPrimary,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: pill,
          backgroundColor: palette.fieldFill,
          selectedBackgroundColor: scheme.surfaceContainerLowest,
          selectedForegroundColor: scheme.onPrimaryContainer,
          foregroundColor: palette.formLabel,
          side: BorderSide.none,
          minimumSize: const Size(48, 48),
          textStyle: text.labelLarge,
        ),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? null : scheme.outline,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.navBar,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: const StadiumBorder(),
        height: 80,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelMedium?.copyWith(
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: s.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.rowPadding,
          vertical: 4,
        ),
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
        iconColor: scheme.primary,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.control),
        borderSide: BorderSide(color: color, width: width),
      );

  /// Type scale from the design: 24/700 page title, 22/700 app bar title,
  /// 16/700 section title, 15/600 list title, 13–14 body, 12/600 labels.
  static TextTheme _textTheme(ColorScheme scheme) {
    TextStyle s(double size, FontWeight weight, {Color? color, double? h}) =>
        TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: weight,
          height: h,
          color: color ?? scheme.onSurface,
        );
    return TextTheme(
      headlineMedium: s(36, FontWeight.w700),
      headlineSmall: s(24, FontWeight.w700),
      titleLarge: s(22, FontWeight.w700),
      titleMedium: s(16, FontWeight.w700),
      titleSmall: s(15, FontWeight.w600),
      bodyLarge: s(15, FontWeight.w400, h: 1.45),
      bodyMedium: s(14, FontWeight.w400, h: 1.45),
      bodySmall: s(13, FontWeight.w400, color: scheme.onSurfaceVariant),
      labelLarge: s(14, FontWeight.w600),
      labelMedium: s(12, FontWeight.w600),
      labelSmall: s(11, FontWeight.w700),
    );
  }
}

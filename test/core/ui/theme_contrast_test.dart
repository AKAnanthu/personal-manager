import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final (name, scheme, palette) in [
    ('light', AppTheme.lightScheme, AppPalette.light),
    ('dark', AppTheme.darkScheme, AppPalette.dark),
  ]) {
    group('$name theme text contrast ≥ 4.5:1', () {
      final card = scheme.surfaceContainerLowest;
      final pairs = <String, (Color, Color)>{
        'onSurface/surface': (scheme.onSurface, scheme.surface),
        'onSurface/card': (scheme.onSurface, card),
        'onSurfaceVariant/surface': (scheme.onSurfaceVariant, scheme.surface),
        'onSurfaceVariant/card': (scheme.onSurfaceVariant, card),
        'onSurfaceVariant/field': (scheme.onSurfaceVariant, palette.fieldFill),
        'onSurfaceVariant/mutedTile': (
          scheme.onSurfaceVariant,
          palette.mutedTile,
        ),
        'formLabel/card': (palette.formLabel, card),
        'onPrimary/primary': (scheme.onPrimary, scheme.primary),
        'onPrimaryContainer/primaryContainer': (
          scheme.onPrimaryContainer,
          scheme.primaryContainer,
        ),
        'primary(link)/surface': (scheme.primary, scheme.surface),
        'onHero/hero': (palette.onHeroCard, palette.heroCard),
        'onErrorContainer/errorContainer': (
          scheme.onErrorContainer,
          scheme.errorContainer,
        ),
        'error/card': (scheme.error, card),
        'warningText/reminder': (
          palette.warningText,
          palette.reminder.background,
        ),
        'medicine': (palette.medicine.foreground, palette.medicine.background),
        'reminder': (palette.reminder.foreground, palette.reminder.background),
        'task': (palette.task.foreground, palette.task.background),
        'pdfFile': (palette.pdfFile.foreground, palette.pdfFile.background),
        'sheetFile': (
          palette.sheetFile.foreground,
          palette.sheetFile.background,
        ),
      };
      for (final MapEntry(key: label, value: (fg, bg)) in pairs.entries) {
        test(label, () => expect(contrast(fg, bg), greaterThanOrEqualTo(4.5)));
      }
    });

    test('$name favourite icon ≥ 3:1 on cards (non-text)', () {
      expect(
        contrast(palette.favourite, scheme.surfaceContainerLowest),
        greaterThanOrEqualTo(3),
      );
    });
  }
}

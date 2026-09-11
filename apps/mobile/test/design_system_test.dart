import 'package:dopa/app/theme/dopa_theme.dart';
import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  double contrast(Color a, Color b) {
    final x = a.computeLuminance(), y = b.computeLuminance();
    return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
  }

  for (final theme in [DopaTheme.light, DopaTheme.dark]) {
    test('${theme.brightness} readable text and identifiable controls', () {
      final c = theme.colorScheme, s = theme.extension<DopaSurfaces>()!;
      for (final surface in [
        c.surface,
        c.surfaceContainerLow,
        s.soft,
        s.sunlight,
        s.apricot,
      ]) {
        expect(contrast(c.onSurface, surface), greaterThanOrEqualTo(4.5));
      }
      expect(contrast(s.muted, c.surface), greaterThanOrEqualTo(4.5));
      expect(contrast(c.onPrimary, c.primary), greaterThanOrEqualTo(4.5));
      expect(
        contrast(c.outline, c.surfaceContainerLow),
        greaterThanOrEqualTo(3),
      );
      expect(contrast(c.error, c.surface), greaterThanOrEqualTo(4.5));
      expect(theme.textTheme.bodyMedium!.fontSize, 16);
      expect(theme.textTheme.bodyMedium!.fontFamily, 'Pretendard');
    });
  }
}

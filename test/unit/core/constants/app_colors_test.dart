import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elli_friends_app/core/constants/app_colors.dart';

void main() {
  group('AppColors', () {
    group('Primary Colors', () {
      test('primary color should be jungle green', () {
        expect(AppColors.primary, const Color(0xFF4CAF50));
      });

      test('secondary color should be light green', () {
        expect(AppColors.secondary, const Color(0xFF8BC34A));
      });

      test('accent color should be sunny yellow', () {
        expect(AppColors.accent, const Color(0xFFFFEB3B));
      });
    });

    group('UI Elements', () {
      test('background color should be light green tint', () {
        expect(AppColors.background, const Color(0xFFF5F9F5));
      });

      test('surface color should be white', () {
        expect(AppColors.surface, const Color(0xFFFFFFFF));
      });

      test('cardBg color should be light green', () {
        expect(AppColors.cardBg, const Color(0xFFE8F5E9));
      });
    });

    group('Text Colors', () {
      test('textPrimary should be dark green', () {
        expect(AppColors.textPrimary, const Color(0xFF2E7D32));
      });

      test('textSecondary should be medium green', () {
        expect(AppColors.textSecondary, const Color(0xFF66BB6A));
      });

      test('textLight should be white', () {
        expect(AppColors.textLight, const Color(0xFFFFFFFF));
      });
    });

    group('Feedback Colors', () {
      test('success color should be green', () {
        expect(AppColors.success, const Color(0xFF4CAF50));
      });

      test('error color should be red', () {
        expect(AppColors.error, const Color(0xFFFF6B6B));
      });

      test('warning color should be orange', () {
        expect(AppColors.warning, const Color(0xFFFFA726));
      });

      test('correct should be same as success', () {
        expect(AppColors.correct, AppColors.success);
      });

      test('incorrect should be same as error', () {
        expect(AppColors.incorrect, AppColors.error);
      });

      test('hint color should be blue', () {
        expect(AppColors.hint, const Color(0xFF2196F3));
      });
    });

    group('Character Colors', () {
      test('elli color should be grey', () {
        expect(AppColors.elli, const Color(0xFF9E9E9E));
      });

      test('bono color should be brown', () {
        expect(AppColors.bono, const Color(0xFFBCAAA4));
      });

      test('hippo color should be purple', () {
        expect(AppColors.hippo, const Color(0xFFB39DDB));
      });

      test('elliBg should be light grey', () {
        expect(AppColors.elliBg, const Color(0xFFE0E0E0));
      });

      test('bonoBg should be light brown', () {
        expect(AppColors.bonoBg, const Color(0xFFD7CCC8));
      });

      test('hippoBg should be light purple', () {
        expect(AppColors.hippoBg, const Color(0xFFE1BEE7));
      });
    });

    group('Activity Button Colors', () {
      test('watchAgain should be purple', () {
        expect(AppColors.watchAgain, const Color(0xFFB39DDB));
      });

      test('tryAgain should be orange', () {
        expect(AppColors.tryAgain, const Color(0xFFFFCC80));
      });

      test('askForHint should be light blue', () {
        expect(AppColors.askForHint, const Color(0xFF81D4FA));
      });

      test('seeMyScore should be green', () {
        expect(AppColors.seeMyScore, const Color(0xFF81C784));
      });
    });

    group('Round Button Colors', () {
      test('speak should be coral/red', () {
        expect(AppColors.speak, const Color(0xFFEF9A9A));
      });

      test('draw should be yellow', () {
        expect(AppColors.draw, const Color(0xFFFFE082));
      });

      test('think should be blue', () {
        expect(AppColors.think, const Color(0xFF90CAF9));
      });
    });

    group('Border Colors', () {
      test('borderPrimary should be dark green', () {
        expect(AppColors.borderPrimary, const Color(0xFF2E7D32));
      });

      test('borderSecondary should be light green', () {
        expect(AppColors.borderSecondary, const Color(0xFF8BC34A));
      });
    });

    group('Color Accessibility', () {
      test('all colors should be valid Color objects', () {
        expect(AppColors.primary, isA<Color>());
        expect(AppColors.secondary, isA<Color>());
        expect(AppColors.accent, isA<Color>());
        expect(AppColors.background, isA<Color>());
        expect(AppColors.surface, isA<Color>());
        expect(AppColors.cardBg, isA<Color>());
        expect(AppColors.textPrimary, isA<Color>());
        expect(AppColors.textSecondary, isA<Color>());
        expect(AppColors.success, isA<Color>());
        expect(AppColors.error, isA<Color>());
        expect(AppColors.warning, isA<Color>());
        expect(AppColors.elli, isA<Color>());
        expect(AppColors.bono, isA<Color>());
        expect(AppColors.hippo, isA<Color>());
      });

      test('colors should have valid alpha (not transparent)', () {
        expect(AppColors.primary.a, 1.0);
        expect(AppColors.secondary.a, 1.0);
        expect(AppColors.accent.a, 1.0);
        expect(AppColors.background.a, 1.0);
        expect(AppColors.surface.a, 1.0);
      });
    });
  });
}

// test/unit/core/theme/app_theme_test.dart
// Tests for AppTheme

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elli_friends_app/core/theme/app_theme.dart';
import 'package:elli_friends_app/core/constants/app_colors.dart';

void main() {
  group('AppTheme', () {
    test('lightTheme should use Material3', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
    });

    test('lightTheme should have correct color scheme', () {
      final theme = AppTheme.lightTheme;
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.error, AppColors.error);
    });

    test('lightTheme should have correct scaffold background color', () {
      final theme = AppTheme.lightTheme;
      expect(theme.scaffoldBackgroundColor, AppColors.background);
    });

    test('lightTheme should have correct elevated button theme', () {
      final theme = AppTheme.lightTheme;
      final buttonStyle = theme.elevatedButtonTheme.style;

      expect(
        buttonStyle?.backgroundColor?.resolve({}),
        AppColors.primary,
      );
      expect(
        buttonStyle?.foregroundColor?.resolve({}),
        Colors.white,
      );
      expect(
        buttonStyle?.padding?.resolve({}),
        const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      );
      expect(
        buttonStyle?.minimumSize?.resolve({}),
        const Size(120, 60),
      );

      final shape = buttonStyle?.shape?.resolve({}) as RoundedRectangleBorder?;
      expect(
        shape?.borderRadius,
        BorderRadius.circular(30),
      );
    });

    test('lightTheme should have correct card theme', () {
      final theme = AppTheme.lightTheme;
      expect(theme.cardTheme.color, AppColors.cardBg);
      expect(theme.cardTheme.elevation, 2);

      final shape = theme.cardTheme.shape as RoundedRectangleBorder?;
      expect(shape?.borderRadius, BorderRadius.circular(16));
    });

    test('lightTheme should have correct app bar theme', () {
      final theme = AppTheme.lightTheme;
      expect(theme.appBarTheme.backgroundColor, AppColors.primary);
      expect(theme.appBarTheme.foregroundColor, Colors.white);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.centerTitle, isTrue);
    });

    testWidgets('lightTheme should be applied to MaterialApp',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      // Verify theme is applied
      final ThemeData theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
    });
  });
}

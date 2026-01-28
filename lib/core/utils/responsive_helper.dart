import 'package:flutter/material.dart';

/// Helper class for responsive layouts
/// Detects tablet devices and provides scaled dimensions
class ResponsiveHelper {
  final BuildContext context;

  ResponsiveHelper(this.context);

  /// Screen width
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Screen height
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Check if device is tablet (shortestSide > 600)
  bool get isTablet => MediaQuery.of(context).size.shortestSide > 600;

  /// Check if device is large tablet (shortestSide > 900)
  bool get isLargeTablet => MediaQuery.of(context).size.shortestSide > 900;

  /// Scale factor for dimensions (1.0 for phone, 1.5 for tablet)
  double get scaleFactor => isTablet ? 1.5 : 1.0;

  /// Number of columns for grid based on screen width
  int get gridColumns {
    if (screenWidth > 900) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  // Responsive dimensions

  /// Character size (120 on phone, 200 on tablet)
  double get characterSize => isTablet ? 200.0 : 120.0;

  /// Rive character size in lessons (300 on phone, 400 on tablet)
  double get riveCharacterSize => isTablet ? 400.0 : 300.0;

  /// Answer button size (56 on phone, 80 on tablet)
  double get answerButtonSize => isTablet ? 80.0 : 56.0;

  /// Answer button font size (24 on phone, 32 on tablet)
  double get answerButtonFontSize => isTablet ? 32.0 : 24.0;

  /// Dialogue font size (16 on phone, 20 on tablet)
  double get dialogueFontSize => isTablet ? 20.0 : 16.0;

  /// Max width for content containers (prevents stretching on iPad)
  double get maxContentWidth => isTablet ? 600.0 : double.infinity;

  /// Max width for dialogue boxes
  double get maxDialogueWidth => isTablet ? 500.0 : double.infinity;

  /// Padding scale
  double get paddingLarge => isTablet ? 32.0 : 24.0;
  double get paddingMedium => isTablet ? 20.0 : 16.0;

  /// Animal emoji size (48 on phone, 64 on tablet)
  double get animalEmojiSize => isTablet ? 64.0 : 48.0;

  /// Title font size (20 on phone, 24 on tablet)
  double get titleFontSize => isTablet ? 24.0 : 20.0;

  /// Button font size (18 on phone, 22 on tablet)
  double get buttonFontSize => isTablet ? 22.0 : 18.0;

  /// Static method for quick tablet check
  static bool isTabletDevice(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide > 600;
  }

  /// Static method for grid columns
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }
}
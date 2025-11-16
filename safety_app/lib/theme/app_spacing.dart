import 'package:flutter/material.dart';

/// Consistent spacing system based on 8pt grid
/// Ensures visual rhythm and professional layout throughout the app
class AppSpacing {
  // Base spacing values (8pt grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Semantic spacing for specific use cases
  static const double screenPadding = md; // Standard screen edge padding
  static const double sectionSpacing = lg; // Between major sections
  static const double cardPadding = md; // Inside cards
  static const double cardMargin = sm; // Between cards
  static const double inputSpacing = sm; // Between form inputs
  static const double buttonPadding = md; // Inside buttons
  static const double iconTextGap = sm; // Between icons and text

  // EdgeInsets presets for common layouts
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(screenPadding);
  static const EdgeInsets screenPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: screenPadding);
  static const EdgeInsets screenPaddingVertical =
      EdgeInsets.symmetric(vertical: screenPadding);

  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);
  static const EdgeInsets cardPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: cardPadding);
  static const EdgeInsets cardPaddingVertical =
      EdgeInsets.symmetric(vertical: cardPadding);

  static const EdgeInsets cardMarginAll = EdgeInsets.all(cardMargin);
  static const EdgeInsets cardMarginHorizontal =
      EdgeInsets.symmetric(horizontal: cardMargin, vertical: cardMargin);
  static const EdgeInsets cardMarginVertical =
      EdgeInsets.symmetric(vertical: cardMargin);

  static const EdgeInsets buttonPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: xl, vertical: md);
  static const EdgeInsets buttonPaddingSymmetric =
      EdgeInsets.symmetric(horizontal: lg, vertical: sm);

  static const EdgeInsets inputPaddingAll = EdgeInsets.all(md);
  static const EdgeInsets inputPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: md, vertical: sm);

  // SizedBox presets for vertical spacing
  static const SizedBox verticalSpaceXs = SizedBox(height: xs);
  static const SizedBox verticalSpaceSm = SizedBox(height: sm);
  static const SizedBox verticalSpaceMd = SizedBox(height: md);
  static const SizedBox verticalSpaceLg = SizedBox(height: lg);
  static const SizedBox verticalSpaceXl = SizedBox(height: xl);
  static const SizedBox verticalSpaceXxl = SizedBox(height: xxl);

  // SizedBox presets for horizontal spacing
  static const SizedBox horizontalSpaceXs = SizedBox(width: xs);
  static const SizedBox horizontalSpaceSm = SizedBox(width: sm);
  static const SizedBox horizontalSpaceMd = SizedBox(width: md);
  static const SizedBox horizontalSpaceLg = SizedBox(width: lg);
  static const SizedBox horizontalSpaceXl = SizedBox(width: xl);

  // List padding and spacing
  static const EdgeInsets listItemPadding =
      EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets listPadding = EdgeInsets.all(md);
  static const double listItemSpacing = sm;

  // App bar spacing
  static const EdgeInsets appBarPadding =
      EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const double appBarElevation = 0;

  // Bottom sheet spacing
  static const EdgeInsets bottomSheetPadding = EdgeInsets.all(lg);
  static const double bottomSheetRadius = lg;

  // Dialog spacing
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);
  static const EdgeInsets dialogContentPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Utility methods for responsive spacing
  static double responsiveHorizontal(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  static double responsiveVertical(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  static EdgeInsets responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return const EdgeInsets.all(xl);
    } else if (width > 400) {
      return const EdgeInsets.all(lg);
    }
    return const EdgeInsets.all(md);
  }
}

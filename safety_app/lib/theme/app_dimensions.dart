import 'package:flutter/material.dart';

/// Standardized dimensions for consistent UI elements
/// Includes border radius, elevation, and component sizing
class AppDimensions {
  // Border radius values
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 100.0;

  // BorderRadius presets
  static BorderRadius get borderRadiusSm =>
      BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd =>
      BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg =>
      BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl =>
      BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusRound =>
      BorderRadius.circular(radiusRound);

  // Top-only border radius (for cards/sheets)
  static BorderRadius get borderRadiusTopSm => const BorderRadius.only(
        topLeft: Radius.circular(radiusSm),
        topRight: Radius.circular(radiusSm),
      );
  static BorderRadius get borderRadiusTopMd => const BorderRadius.only(
        topLeft: Radius.circular(radiusMd),
        topRight: Radius.circular(radiusMd),
      );
  static BorderRadius get borderRadiusTopLg => const BorderRadius.only(
        topLeft: Radius.circular(radiusLg),
        topRight: Radius.circular(radiusLg),
      );
  static BorderRadius get borderRadiusTopXl => const BorderRadius.only(
        topLeft: Radius.circular(radiusXl),
        topRight: Radius.circular(radiusXl),
      );

  // Elevation values
  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // Border width
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;
  static const double borderWidthThick = 3.0;

  // Button dimensions
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;
  static const double buttonMinWidth = 88.0;

  // Input field dimensions
  static const double inputHeightSmall = 40.0;
  static const double inputHeightMedium = 48.0;
  static const double inputHeightLarge = 56.0;

  // Card dimensions
  static const double cardMinHeight = 80.0;
  static const double cardMaxWidth = 400.0;

  // Avatar/Profile image sizes
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
  static const double avatarSizeXLarge = 96.0;

  // App bar dimensions
  static const double appBarHeight = 56.0;
  static const double appBarHeightLarge = 72.0;

  // Bottom navigation bar
  static const double bottomNavHeight = 64.0;
  static const double bottomNavIconSize = 24.0;

  // Divider thickness
  static const double dividerThin = 1.0;
  static const double dividerMedium = 2.0;

  // Progress indicator sizes
  static const double progressIndicatorSmall = 16.0;
  static const double progressIndicatorMedium = 24.0;
  static const double progressIndicatorLarge = 36.0;

  // Chip dimensions
  static const double chipHeight = 32.0;
  static const double chipBorderRadius = 16.0;

  // Badge dimensions
  static const double badgeSize = 20.0;
  static const double badgeSizeSmall = 16.0;

  // Shimmer dimensions
  static const double shimmerHeight = 16.0;
  static const double shimmerHeightLarge = 24.0;
  static const double shimmerRadius = 4.0;

  // Icon button sizes
  static const double iconButtonSmall = 36.0;
  static const double iconButtonMedium = 48.0;
  static const double iconButtonLarge = 56.0;

  // Maximum content width (for responsive design)
  static const double maxContentWidth = 600.0;
  static const double maxContentWidthWide = 800.0;

  // Utility methods
  static BoxDecoration cardDecoration({
    Color? color,
    List<BoxShadow>? boxShadow,
    Border? border,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadiusLg,
      boxShadow: boxShadow,
      border: border,
      gradient: gradient,
    );
  }

  static BoxDecoration roundDecoration({
    Color? color,
    List<BoxShadow>? boxShadow,
    Border? border,
  }) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: boxShadow,
      border: border,
    );
  }
}

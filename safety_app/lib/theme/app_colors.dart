import 'package:flutter/material.dart';

/// App-wide color palette for Safety First
/// Feminine pink theme designed for women's safety app
class AppColors {
  // Primary Pink Colors
  static const Color primaryPink = Color(0xFFEC4899); // Pink-500 - Hot Pink
  static const Color lightPink = Color(0xFFFCE7F3); // Pink-50 - Soft backgrounds
  static const Color softPink = Color(0xFFFBCFE8); // Pink-200 - Accents
  static const Color deepPink = Color(0xFFDB2777); // Pink-600 - Buttons/emphasis
  static const Color rose = Color(0xFFFDA4AF); // Rose-300 - Soft elements
  static const Color palePink = Color(0xFFFDF2F8); // Pink-25 - Very light backgrounds

  // Accent Colors
  static const Color lavender = Color(0xFFE9D5FF); // Purple-200 - Secondary
  static const Color peach = Color(0xFFFED7AA); // Orange-200 - Soft warnings
  static const Color cream = Color(0xFFFFF7ED); // Orange-50 - Backgrounds
  static const Color softWhite = Color(0xFFFFFAF5); // Warm white

  // Semantic Colors
  static const Color warningRose = Color(0xFFFCE7F3); // Soft pink for warnings
  static const Color errorRose = Color(0xFFFBCFE8); // Pink for errors (still visible)
  static const Color successMint = Color(0xFFD1FAE5); // Soft mint for success

  // Grays (softer versions)
  static const Color darkText = Color(0xFF374151); // Grey-700
  static const Color mediumText = Color(0xFF6B7280); // Grey-500
  static const Color lightText = Color(0xFF9CA3AF); // Grey-400

  // Gradients - Various styles for different use cases
  static LinearGradient get pinkGradient => const LinearGradient(
        colors: [primaryPink, deepPink],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get appBarGradient => const LinearGradient(
        colors: [Color(0xFFF472B6), primaryPink], // Pink-400 to Pink-500
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get cardGradient => const LinearGradient(
        colors: [softWhite, lightPink],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  // New gradient variations
  static LinearGradient get subtleGradient => const LinearGradient(
        colors: [softWhite, lightPink],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get boldGradient => const LinearGradient(
        colors: [deepPink, primaryPink, rose],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get verticalGradient => const LinearGradient(
        colors: [primaryPink, deepPink],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static LinearGradient get shimmerGradient => LinearGradient(
        colors: [
          lightPink.withValues(alpha: 0.1),
          softPink.withValues(alpha: 0.3),
          lightPink.withValues(alpha: 0.1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get overlayGradient => LinearGradient(
        colors: [
          Colors.black.withValues(alpha: 0.0),
          Colors.black.withValues(alpha: 0.3),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  // Radial gradients
  static RadialGradient get radialPinkGradient => const RadialGradient(
        colors: [primaryPink, deepPink],
        radius: 1.5,
      );

  static RadialGradient get glowGradient => RadialGradient(
        colors: [
          primaryPink.withValues(alpha: 0.4),
          primaryPink.withValues(alpha: 0.0),
        ],
        radius: 1.0,
      );

  // Opacity variants for overlays and backgrounds
  static Color get scrimLight => Colors.black.withValues(alpha: 0.25);
  static Color get scrimMedium => Colors.black.withValues(alpha: 0.5);
  static Color get scrimDark => Colors.black.withValues(alpha: 0.75);

  static Color get pinkOverlayLight => primaryPink.withValues(alpha: 0.1);
  static Color get pinkOverlayMedium => primaryPink.withValues(alpha: 0.2);
  static Color get pinkOverlayStrong => primaryPink.withValues(alpha: 0.3);

  // Shimmer colors for loading states
  static const Color shimmerBase = Color(0xFFFDF2F8);
  static const Color shimmerHighlight = Color(0xFFFFFAF5);

  // Shadows - Enhanced with more variations
  static List<BoxShadow> get softPinkShadow => [
        BoxShadow(
          color: softPink.withValues(alpha: 0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get pinkGlow => [
        BoxShadow(
          color: primaryPink.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}

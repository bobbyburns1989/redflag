import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Comprehensive typography system for Pink Flag
/// Uses Poppins for headings (bold, attention-grabbing)
/// Uses Inter for body text (readable, professional)
class AppTextStyles {
  // Display styles (largest, for splash/major headings)
  static TextStyle displayLarge = GoogleFonts.poppins(
    fontSize: 42,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
    height: 1.2,
    color: AppColors.darkText,
  );

  static TextStyle displayMedium = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
    height: 1.3,
    color: AppColors.darkText,
  );

  // Heading styles
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    height: 1.3,
    color: AppColors.darkText,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.4,
    color: AppColors.darkText,
  );

  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.darkText,
  );

  static TextStyle h4 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.darkText,
  );

  // Body styles
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.darkText,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.darkText,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.darkText,
  );

  // Caption and helper text
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.mediumText,
  );

  static TextStyle overline = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
    height: 1.4,
    color: AppColors.mediumText,
  );

  // Button text
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: Colors.white,
  );

  static TextStyle buttonSmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: Colors.white,
  );

  // Color variants - Primary
  static TextStyle get displayLargePrimary =>
      displayLarge.copyWith(color: AppColors.primaryPink);
  static TextStyle get displayMediumPrimary =>
      displayMedium.copyWith(color: AppColors.primaryPink);
  static TextStyle get h1Primary => h1.copyWith(color: AppColors.primaryPink);
  static TextStyle get h2Primary => h2.copyWith(color: AppColors.primaryPink);
  static TextStyle get h3Primary => h3.copyWith(color: AppColors.primaryPink);
  static TextStyle get h4Primary => h4.copyWith(color: AppColors.primaryPink);
  static TextStyle get bodyLargePrimary =>
      bodyLarge.copyWith(color: AppColors.primaryPink);
  static TextStyle get bodyMediumPrimary =>
      bodyMedium.copyWith(color: AppColors.primaryPink);

  // Color variants - White
  static TextStyle get displayLargeWhite =>
      displayLarge.copyWith(color: Colors.white);
  static TextStyle get displayMediumWhite =>
      displayMedium.copyWith(color: Colors.white);
  static TextStyle get h1White => h1.copyWith(color: Colors.white);
  static TextStyle get h2White => h2.copyWith(color: Colors.white);
  static TextStyle get h3White => h3.copyWith(color: Colors.white);
  static TextStyle get bodyLargeWhite =>
      bodyLarge.copyWith(color: Colors.white);
  static TextStyle get bodyMediumWhite =>
      bodyMedium.copyWith(color: Colors.white);
  static TextStyle get bodySmallWhite =>
      bodySmall.copyWith(color: Colors.white);

  // Color variants - Secondary/Hint
  static TextStyle get bodyMediumSecondary =>
      bodyMedium.copyWith(color: AppColors.mediumText);
  static TextStyle get bodySmallSecondary =>
      bodySmall.copyWith(color: AppColors.mediumText);
  static TextStyle get captionHint =>
      caption.copyWith(color: AppColors.lightText);

  // Special purpose styles
  static TextStyle get tagline => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 1,
        color: AppColors.mediumText,
      );

  static TextStyle get error => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.deepPink,
        height: 1.4,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: AppColors.mediumText,
        height: 1.4,
      );

  static TextStyle get link => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryPink,
        decoration: TextDecoration.underline,
        height: 1.4,
      );
}

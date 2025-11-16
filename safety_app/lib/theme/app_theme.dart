import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

/// Centralized theme configuration for Pink Flag app
/// Consolidates colors, typography, dimensions, and component themes
class AppTheme {
  // Export all theme components for easy access
  static final colors = AppColors;
  static final textStyles = AppTextStyles;
  static final dimensions = AppDimensions;

  /// Main light theme for the app
  static ThemeData get lightTheme {
    return ThemeData(
      // Material 3
      useMaterial3: true,

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPink,
        primary: AppColors.primaryPink,
        secondary: AppColors.deepPink,
        surface: AppColors.softWhite,
        error: AppColors.deepPink,
        brightness: Brightness.light,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.softWhite,

      // App bar theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: AppDimensions.elevationNone,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.h2White,
        toolbarHeight: AppDimensions.appBarHeight,
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: AppDimensions.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLg,
        ),
        color: AppColors.softWhite,
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppDimensions.elevationSm,
          minimumSize: Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusMd,
          ),
          textStyle: AppTextStyles.button,
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryPink,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMedium,
          ),
          side: BorderSide(
            color: AppColors.primaryPink,
            width: AppDimensions.borderWidthMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusMd,
          ),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.primaryPink,
          ),
          foregroundColor: AppColors.primaryPink,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.primaryPink,
          ),
          foregroundColor: AppColors.primaryPink,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMd,
          borderSide: BorderSide(
            color: AppColors.lightPink,
            width: AppDimensions.borderWidthThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMd,
          borderSide: BorderSide(
            color: AppColors.softPink,
            width: AppDimensions.borderWidthThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMd,
          borderSide: BorderSide(
            color: AppColors.primaryPink,
            width: AppDimensions.borderWidthMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMd,
          borderSide: BorderSide(
            color: AppColors.deepPink,
            width: AppDimensions.borderWidthThin,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMd,
          borderSide: BorderSide(
            color: AppColors.deepPink,
            width: AppDimensions.borderWidthMedium,
          ),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.mediumText,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightText,
        ),
        errorStyle: AppTextStyles.error,
        prefixIconColor: AppColors.mediumText,
        suffixIconColor: AppColors.mediumText,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryPink,
        unselectedItemColor: AppColors.mediumText,
        selectedLabelStyle: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.caption,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
        elevation: AppDimensions.elevationMd,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLg,
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: AppDimensions.elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLg,
        ),
        titleTextStyle: AppTextStyles.h2,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryPink,
        contentTextStyle: AppTextStyles.bodyMediumWhite,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusMd,
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryPink,
        circularTrackColor: AppColors.lightPink,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.softPink,
        thickness: AppDimensions.dividerThin,
        space: 16,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightPink,
        deleteIconColor: AppColors.deepPink,
        disabledColor: AppColors.lightPink.withValues(alpha: 0.5),
        selectedColor: AppColors.primaryPink,
        secondarySelectedColor: AppColors.softPink,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: AppTextStyles.bodySmall,
        secondaryLabelStyle: AppTextStyles.bodySmallWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.chipBorderRadius),
        ),
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: AppColors.mediumText,
        size: 24,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: AppTextStyles.bodyMedium,
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.mediumText,
        ),
        iconColor: AppColors.primaryPink,
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        titleLarge: AppTextStyles.h4,
        titleMedium: AppTextStyles.bodyLarge,
        titleSmall: AppTextStyles.bodyMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.label,
        labelSmall: AppTextStyles.caption,
      ),
    );
  }

  /// System UI overlay style for different contexts
  static SystemUiOverlayStyle get lightStatusBar {
    return SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    );
  }

  static SystemUiOverlayStyle get darkStatusBar {
    return SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    );
  }
}

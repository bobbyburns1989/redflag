import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../services/haptic_service.dart';

/// Custom snackbar types
enum SnackbarType { success, error, warning, info }

/// Custom snackbar helper for consistent notifications across the app
class CustomSnackbar {
  /// Show a success snackbar with checkmark icon
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    HapticService.instance.success();
    _show(
      context,
      message: message,
      type: SnackbarType.success,
      icon: Icons.check_circle,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Show an error snackbar with error icon
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    HapticService.instance.error();
    _show(
      context,
      message: message,
      type: SnackbarType.error,
      icon: Icons.error,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Show a warning snackbar with warning icon
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    HapticService.instance.warning();
    _show(
      context,
      message: message,
      type: SnackbarType.warning,
      icon: Icons.warning_amber,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Show an info snackbar with info icon
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    HapticService.instance.lightImpact();
    _show(
      context,
      message: message,
      type: SnackbarType.info,
      icon: Icons.info,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Internal method to show snackbar
  static void _show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    required IconData icon,
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final colors = _getColors(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors['background'],
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusMd,
        ),
        margin: const EdgeInsets.all(16),
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: () {
                  HapticService.instance.lightImpact();
                  onAction();
                },
              )
            : null,
      ),
    );
  }

  /// Get colors based on snackbar type
  static Map<String, Color> _getColors(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return {'background': Colors.green, 'text': Colors.white};
      case SnackbarType.error:
        return {'background': AppColors.deepPink, 'text': Colors.white};
      case SnackbarType.warning:
        return {'background': Colors.orange, 'text': Colors.white};
      case SnackbarType.info:
        return {'background': AppColors.primaryPink, 'text': Colors.white};
    }
  }
}

/// Custom snackbar widget for more complex layouts
class CustomSnackbarWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const CustomSnackbarWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticService.instance.lightImpact();
          onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppDimensions.borderRadiusMd,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h4.copyWith(color: Colors.white),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_dimensions.dart';

/// Animated emergency 911 banner with pulsing effect.
///
/// Displays a prominent banner encouraging users to call 911 if in danger.
/// Uses a pulsing animation to draw attention.
class EmergencyBanner extends StatelessWidget {
  /// Animation controller for the pulsing effect.
  /// Should be created with `repeat(reverse: true)` for smooth pulsing.
  final AnimationController pulseController;

  const EmergencyBanner({
    super.key,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (pulseController.value * 0.03),
          child: Container(
            padding: AppSpacing.cardPaddingAll,
            decoration: BoxDecoration(
              gradient: AppColors.pinkGradient,
              borderRadius: AppDimensions.borderRadiusLg,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPink.withValues(
                    alpha: 0.3 + (pulseController.value * 0.2),
                  ),
                  blurRadius: 16 + (pulseController.value * 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.emergency, color: Colors.white, size: 32)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: 2000.ms,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                AppSpacing.horizontalSpaceMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMERGENCY',
                        style: AppTextStyles.overline.copyWith(
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      AppSpacing.verticalSpaceXs,
                      Text(
                        'If you are in immediate danger, call 911',
                        style: AppTextStyles.h4.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/animation.dart';

/// Animation constants for consistent motion throughout the app
/// Follows Material Design motion principles
class AppAnimations {
  // Duration constants
  static const Duration durationInstant = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 800);

  // Specific use case durations
  static const Duration buttonPress = durationFast;
  static const Duration pageTransition = durationMedium;
  static const Duration cardAnimation = durationMedium;
  static const Duration modalAnimation = durationMedium;
  static const Duration shimmerCycle = Duration(milliseconds: 1500);
  static const Duration pulseAnimation = Duration(milliseconds: 2000);
  static const Duration fadeAnimation = durationMedium;
  static const Duration slideAnimation = durationMedium;
  static const Duration scaleAnimation = durationFast;

  // Curve constants (easing functions)
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve accelerateCurve = Curves.easeIn;
  static const Curve decelerateCurve = Curves.easeOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;

  // Custom curves for specific interactions
  static const Curve buttonCurve = Curves.easeInOut;
  static const Curve cardEntranceCurve = Curves.easeOutCubic;
  static const Curve modalEntranceCurve = Curves.easeOutQuart;
  static const Curve modalExitCurve = Curves.easeInQuart;
  static const Curve pageEntranceCurve = Curves.easeOutCubic;
  static const Curve shimmerCurve = Curves.linear;
  static const Curve pulseCurve = Curves.easeInOut;

  // Stagger delays for list animations
  static const Duration staggerShort = Duration(milliseconds: 50);
  static const Duration staggerMedium = Duration(milliseconds: 80);
  static const Duration staggerLong = Duration(milliseconds: 120);

  // Scale values for animations
  static const double scalePressed = 0.98;
  static const double scaleNormal = 1.0;
  static const double scaleExpanded = 1.05;
  static const double scaleHero = 0.95;

  // Opacity values
  static const double opacityHidden = 0.0;
  static const double opacityDimmed = 0.5;
  static const double opacityVisible = 1.0;

  // Slide offsets (for slide animations)
  static const double slideOffsetSmall = 0.1;
  static const double slideOffsetMedium = 0.3;
  static const double slideOffsetLarge = 1.0;

  // Rotation angles (in radians for micro-interactions)
  static const double rotationSubtle = 0.02; // ~1 degree
  static const double rotationSmall = 0.05; // ~3 degrees
  static const double rotationMedium = 0.1; // ~6 degrees

  // Helper method to calculate stagger delay for list items
  static Duration staggerDelay(int index, {Duration baseDelay = staggerMedium}) {
    return Duration(milliseconds: baseDelay.inMilliseconds * index);
  }

  // Helper method for delayed animation start
  static Duration delayFor(Duration delay) => delay;

  // Common animation configurations
  static const Duration rippleDuration = Duration(milliseconds: 200);
  static const Duration tooltipDuration = durationFast;
  static const Duration snackbarDuration = Duration(milliseconds: 250);
  static const Duration dialogDuration = durationMedium;

  // Loading animation speeds
  static const Duration loadingSpinnerDuration = Duration(milliseconds: 1000);
  static const Duration loadingDotDuration = Duration(milliseconds: 600);
  static const Duration loadingPulseDuration = pulseAnimation;
}

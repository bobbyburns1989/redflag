import 'package:flutter/services.dart';

/// Centralized haptic feedback service for Pink Flag app
/// Provides consistent haptic feedback patterns across the app
class HapticService {
  // Singleton pattern
  HapticService._();
  static final HapticService instance = HapticService._();

  /// Light impact - for UI interactions like button taps, switches
  /// Duration: ~10ms
  /// Use: Standard button presses, list item taps, checkbox toggles
  Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact - for important actions or state changes
  /// Duration: ~15ms
  /// Use: Pull-to-refresh, page transitions, important confirmations
  Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for critical actions or errors
  /// Duration: ~20ms
  /// Use: Delete actions, errors, critical warnings
  Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click - for picker/selector changes
  /// Duration: ~5ms (very light)
  /// Use: Tab switches, slider changes, picker rotations
  Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate - platform-specific vibration
  /// Use: Notifications, alerts (use sparingly)
  Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  /// Success pattern - double light tap
  /// Use: Successful form submission, search completion, save confirmation
  Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error pattern - medium then heavy
  /// Use: Form validation errors, API errors, failed operations
  Future<void> error() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Warning pattern - two medium impacts
  /// Use: Important warnings, confirmation dialogs
  Future<void> warning() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
  }

  /// Notification pattern - light, pause, light, pause, medium
  /// Use: New results available, background task complete
  Future<void> notification() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.mediumImpact();
  }

  /// Button press - standard button feedback
  /// Use: All custom buttons, primary interactions
  Future<void> buttonPress() async {
    await HapticFeedback.lightImpact();
  }

  /// Long press - heavier feedback for long press detection
  /// Use: Long press actions, context menus
  Future<void> longPress() async {
    await HapticFeedback.mediumImpact();
  }

  /// Swipe - light feedback for swipe gestures
  /// Use: Page swipes, dismissible items, pull-to-refresh start
  Future<void> swipe() async {
    await HapticFeedback.selectionClick();
  }

  /// Delete - heavy feedback for destructive actions
  /// Use: Delete confirmations, clear all actions
  Future<void> delete() async {
    await HapticFeedback.heavyImpact();
  }
}

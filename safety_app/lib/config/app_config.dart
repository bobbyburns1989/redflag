import 'package:flutter/foundation.dart';

/// Application configuration and feature flags
///
/// This file centralizes app configuration settings and feature toggles
/// for easier management across development, staging, and production environments.
class AppConfig {
  // ==================== FEATURE FLAGS ====================

  /// Toggle between mock and real RevenueCat purchases
  ///
  /// **Development/Testing:**
  /// - `true` = Use mock purchases (instant, no Apple sandbox needed)
  /// - Credits added directly to Supabase
  /// - Perfect for UI testing and rapid iteration
  ///
  /// **Production/Sandbox Testing:**
  /// - `false` = Use real RevenueCat purchases
  /// - Requires RevenueCat offerings configured
  /// - Requires Apple Sandbox test account
  /// - Credits added via RevenueCat webhook
  ///
  /// **To switch modes:**
  /// 1. Change this value
  /// 2. Hot restart the app (press 'R' in terminal)
  static const bool USE_MOCK_PURCHASES = false;  // Production mode - uses real RevenueCat

  /// Enable debug logging for purchases
  static const bool DEBUG_PURCHASES = true;

  /// Enable debug logging for authentication
  static const bool DEBUG_AUTH = true;

  // ==================== API ENDPOINTS ====================

  /// Production backend API URL
  static const String PRODUCTION_API_URL = 'https://pink-flag-api.fly.dev/api';

  /// Local development API URL
  static const String DEV_API_URL = 'http://localhost:8000/api';

  /// Current API URL (change based on environment)
  static const String API_BASE_URL = PRODUCTION_API_URL;

  // ==================== REVENUECAT ====================

  /// RevenueCat API key for iOS
  static const String REVENUECAT_API_KEY = 'appl_IRhHyHobKGcoteGnlLRWUFgnIos';

  /// RevenueCat offering identifier
  /// Must match the offering created in RevenueCat Dashboard
  static const String REVENUECAT_OFFERING_ID = 'default';

  // ==================== SUPABASE ====================

  /// Supabase project URL
  static const String SUPABASE_URL = 'https://qjbtmrbbjivniveptdjl.supabase.co';

  /// Supabase anonymous key
  static const String SUPABASE_ANON_KEY =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqYnRtcmJiaml2bml2ZXB0ZGpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0Mzk4NDMsImV4cCI6MjA3ODAxNTg0M30.xltmKOa23l0KBSrDGOCQ8xJ7jQbxRxzeBjgJ_NtbH0I';

  // ==================== LEGAL ====================

  /// Privacy Policy URL
  static const String PRIVACY_POLICY_URL = 'https://customapps.us/pinkflag/privacy';

  /// Terms of Service URL
  static const String TERMS_OF_SERVICE_URL = 'https://customapps.us/pinkflag/terms';

  // ==================== SUPPORT ====================

  /// Support email address
  static const String SUPPORT_EMAIL = 'support@pinkflagapp.com';

  /// Privacy concerns email
  static const String PRIVACY_EMAIL = 'privacy@pinkflagapp.com';

  // ==================== APP INFO ====================

  /// App display name
  static const String APP_NAME = 'Pink Flag';

  /// App tagline
  static const String APP_TAGLINE = 'Stay Safe, Stay Aware';

  /// App version (must match pubspec.yaml)
  static const String APP_VERSION = '1.2.5';

  /// App build number
  static const String BUILD_NUMBER = '28';

  // ==================== CREDIT PACKAGES ====================

  /// Product IDs for in-app purchases (must match App Store Connect & RevenueCat)
  static const String PRODUCT_ID_3_SEARCHES = 'pink_flag_3_searches';
  static const String PRODUCT_ID_10_SEARCHES = 'pink_flag_10_searches';
  static const String PRODUCT_ID_25_SEARCHES = 'pink_flag_25_searches';

  /// Initial credits for new users (10x multiplier applied)
  /// Enough for 1 name search OR 5 phone searches OR 2 image searches
  static const int INITIAL_USER_CREDITS = 10;

  /// Variable credit costs per search type (v1.2.0+)
  /// Name: 10, Phone: 2, Image: 4 (user-friendly pricing)
  static const int CREDITS_PER_NAME_SEARCH = 10;
  static const int CREDITS_PER_PHONE_SEARCH = 2;
  static const int CREDITS_PER_IMAGE_SEARCH = 4;

  // ==================== PHONE LOOKUP ====================
  // NOTE: Phone lookup is now handled server-side for security.
  // Twilio credentials are secured on the backend and never exposed to clients.
  // Phone lookups are made through: POST /api/phone/lookup

  /// Phone lookup rate limit (15 requests per minute - enforced on backend)
  static const int PHONE_LOOKUP_RATE_LIMIT = 15;

  // ==================== HELPER METHODS ====================

  /// Check if running in production mode
  static bool get isProduction =>
      const bool.fromEnvironment('dart.vm.product', defaultValue: false);

  /// Check if running in debug mode
  static bool get isDebug => !isProduction;

  /// Get environment name
  static String get environmentName => isProduction ? 'Production' : 'Development';

  /// Print configuration summary (for debugging)
  static void printConfig() {
    if (kDebugMode && (DEBUG_PURCHASES || DEBUG_AUTH)) {
      print('');
      print('═══════════════════════════════════════════════════════');
      print('  PINK FLAG APP CONFIGURATION');
      print('═══════════════════════════════════════════════════════');
      print('Environment:       $environmentName');
      print('API URL:          $API_BASE_URL');
      print('Mock Purchases:   $USE_MOCK_PURCHASES');
      print('RevenueCat Key:   ${REVENUECAT_API_KEY.substring(0, 20)}...');
      print('Supabase URL:     $SUPABASE_URL');
      print('Privacy Policy:   $PRIVACY_POLICY_URL');
      print('Terms of Service: $TERMS_OF_SERVICE_URL');
      print('═══════════════════════════════════════════════════════');
      print('');
    }
  }
}

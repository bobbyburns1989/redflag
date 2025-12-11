# Pink Flag

A Flutter-based women's safety application for comprehensive background searches including name lookups, phone lookups, and reverse image searches with automatic credit management and refund protection.

## Overview

Pink Flag is a mobile safety app that helps users perform background checks through multiple search methods. The app features a feminine pink theme, credit-based monetization, and automatic refund protection for API failures.

## Features

### Search Capabilities
- **Name Search**: Search by first/last name with optional filters (age, state, phone, ZIP)
- **Phone Lookup**: Reverse phone number lookup with caller ID, carrier info, and fraud risk assessment
- **Image Search**: Reverse image search using TinEye API to find where photos appear online
- **Advanced Filters**: State, age, phone number, and ZIP code filters for name searches
- **Fraud Risk Assessment**: Color-coded risk levels (safe/medium/high) for phone lookups

### Credit System
- **Variable Pricing**: Name = 10 credits, Phone = 2 credits, Image = 4 credits
- **RevenueCat Integration**: In-app purchases (30, 100, or 250 credits)
- **Real-Time Balance**: Credit counter updates instantly
- **Transaction History**: View all purchases and searches
- **Search History**: Review past searches with privacy controls

### 🔄 Automatic Credit Refund System (v1.1.7)
**NEW!** Automatic refunds when searches fail due to API/server issues:
- **Auto Refund**: 503 (maintenance), 500/502/504 (server errors), 429 (rate limit), timeouts, network errors
- **Instant Processing**: Credits returned immediately, no user action required
- **Full Transparency**: Refunds shown in transaction history with reason
- **UI Indicators**: Refund badges (🔄) in both transaction and search history
- **No Refund**: Client errors (400, invalid input) or successful searches

### User Interface
- **Modern Pink Theme**: Cohesive feminine aesthetic with gradient accents
- **3-Tab Search Interface**: Name, Phone, Image search in segmented control
- **Custom Splash Screen**: Branded launch experience
- **Smooth Animations**: Page transitions with slide and fade effects
- **Bottom Navigation**: Search, Resources, Settings screens
- **Pull-to-Refresh**: Update credit balance and history
- **Loading States**: Shimmer effects and progress indicators

### Settings & Account Management
- **Account**: Email display, change password, sign out
- **Credits**: Buy more credits, restore purchases
- **History**: Transaction history, search history with privacy notice
- **Legal**: Privacy policy, terms of service, about page
- **Account Deletion**: Delete account option

### Authentication
- **Supabase Auth**: Email/password authentication
- **Apple Sign-In**: One-tap login for iOS users
- **Onboarding**: 5-page feature introduction for new users

## 📋 Current Status

**Version**: 1.1.7+13 (November 28, 2025)

**See [CURRENT_STATUS.md](../CURRENT_STATUS.md) for detailed development status including:**
- ✅ Backend deployed to Fly.io (production ready)
- ✅ RevenueCat FIXED and fully operational
- ✅ Phone lookup feature complete
- ✅ Credit refund system implemented
- ✅ Settings screen complete
- ✅ Phone lookup running on Twilio Lookup API v2 (2 credits per lookup)

## Recent Updates

### Version 1.1.7 (November 28, 2025) - Credit Refund System 🔄

**Major Feature: Automatic Credit Refund Protection**
- Automatic credit refunds for API/server failures across all search types
- Refund policy: 503, 500, 502, 504, 429, timeouts, network errors
- Transaction history shows refunds with green 🔄 icon and reason
- Search history displays refund badges for failed searches
- Instant processing via Supabase RPC function

**Phone Validation Fix**
- Fixed US phone number validation for 10-digit format (no country code)
- Improved E.164 formatting for international numbers
- Better error messages for invalid phone numbers

**Database Updates**
- New `refunded` column on searches table
- `refund_credit_for_failed_search()` RPC function
- Performance indexes for refund queries
- Row Level Security policies updated

**Code Changes**
- Phone search service: +130 lines of refund logic
- Image search service: +120 lines of refund logic
- Name search service: +80 lines of refund logic
- Credit transaction model: +54 lines of display helpers
- Transaction history UI: Refund display with green styling
- Search history UI: Refund badges
- Version bumped to 1.1.7+13

**Documentation**
- `CREDIT_REFUND_SYSTEM.md` - Complete architecture (460 lines)
- `CREDIT_REFUND_SCHEMA.sql` - Database schema (200 lines)
- `CREDIT_REFUND_ROADMAP.md` - Implementation plan (600 lines)
- `RELEASE_NOTES_v1.1.7.md` - Comprehensive release notes (550+ lines)

**Status**: Implementation complete ✅ | Database schema ready for deployment | Phone lookup migrated to Twilio (live)

### Version 1.1.5 (November 28, 2025) - Phone Lookup Feature 📱

**Phone Number Reverse Lookup**
- Integrated Sent.dm API for phone lookups (initial launch) → Migrated to Twilio Lookup API v2 in v1.1.13 (2 credits per lookup)
- Caller name (CNAM), carrier, line type, location data
- Fraud risk assessment with color-coded risk levels
- Phone number validation and E.164 formatting
- Results screen with copy-to-clipboard functionality

**Search Interface Update**
- 3-tab segmented control: Name | Phone | Image
- Variable credit costs now live (Name 10, Phone 2, Image 4)
- Phone search history tracking in database

**Files Created**
- `lib/models/phone_search_result.dart` (205 lines)
- `lib/services/phone_search_service.dart` (279 lines)
- `lib/screens/phone_results_screen.dart` (545 lines)
- `PHONE_LOOKUP_IMPLEMENTATION.md` (462 lines)
- `PHONE_LOOKUP_SCHEMA_UPDATE.sql` (53 lines)

**Package Added**
- `phone_numbers_parser: ^8.3.0` for phone validation

### Version 1.1.4 (November 11, 2025) - Settings Enhancement

**Transaction & Search History**
- Transaction history screen with grouped entries by date
- Search history screen with privacy notice and clear action
- Change password flow integrated
- Real-time credit balance updates

**History Service**
- `lib/services/history_service.dart` - Supabase fetch/clear helpers
- `lib/models/credit_transaction.dart` - Transaction data model
- `lib/models/search_history_entry.dart` - Search history model

### Version 1.1.0 (November 10, 2025) - RevenueCat Fix & Settings

**RevenueCat Build Error FIXED**
- Upgraded to `purchases_flutter: ^9.9.4`
- Updated CocoaPods to get `PurchasesHybridCommon 17.17.0`
- iOS build successful (60.1s) with no errors
- RevenueCat fully operational

**Settings Screen Implemented**
- Complete settings screen with 380 lines
- Account management section
- Credits display with buy/restore options
- Transaction and search history access
- Legal pages (privacy policy, terms of service)
- Sign out and delete account options

**RevenueCat Feature Flag Integration**
- `lib/config/app_config.dart` - Centralized configuration
- `USE_MOCK_PURCHASES` flag for easy mode switching
- Mock purchases for rapid testing
- Webhook Edge Function for RevenueCat integration

## Project Structure

```
lib/
├── main.dart                                    # App entry point
├── config/
│   └── app_config.dart                         # Feature flags and configuration
├── models/
│   ├── offender.dart                           # Offender data model
│   ├── search_result.dart                      # Name search result wrapper
│   ├── phone_search_result.dart                # Phone lookup result
│   ├── image_search_result.dart                # Image search result
│   ├── credit_transaction.dart                 # Transaction history model
│   └── search_history_entry.dart               # Search history model
├── screens/
│   ├── splash_screen.dart                      # Branded splash screen
│   ├── onboarding_screen.dart                  # 5-page onboarding flow
│   ├── login_screen.dart                       # Email/password login
│   ├── signup_screen.dart                      # User registration
│   ├── home_screen.dart                        # Main navigation hub
│   ├── search_screen.dart                      # 3-tab search (Name/Phone/Image)
│   ├── results_screen.dart                     # Name search results
│   ├── phone_results_screen.dart               # Phone lookup results
│   ├── image_results_screen.dart               # Image search results
│   ├── resources_screen.dart                   # Safety resources
│   ├── settings_screen.dart                    # Settings hub
│   ├── store_screen.dart                       # Credit purchase
│   └── settings/
│       ├── transaction_history_screen.dart     # Transaction history with refunds
│       ├── search_history_screen.dart          # Search history with refund badges
│       └── change_password_screen.dart         # Password change flow
├── services/
│   ├── api_service.dart                        # Name search API
│   ├── phone_search_service.dart               # Phone lookup with refund logic
│   ├── image_search_service.dart               # Image search with refund logic
│   ├── search_service.dart                     # Name search with refund logic
│   ├── auth_service.dart                       # Supabase authentication
│   ├── history_service.dart                    # Transaction/search history
│   └── revenuecat_service.dart                 # In-app purchases
├── theme/
│   ├── app_colors.dart                         # Pink color palette
│   ├── app_text_styles.dart                    # Typography
│   └── app_spacing.dart                        # Layout constants
└── widgets/
    ├── custom_button.dart                      # Reusable button
    ├── custom_text_field.dart                  # Form input
    ├── custom_card.dart                        # Card component
    ├── custom_bottom_nav.dart                  # Bottom navigation
    ├── custom_snackbar.dart                    # Toast notifications
    ├── loading_widgets.dart                    # Loading states
    ├── offender_card.dart                      # Result card
    └── page_transitions.dart                   # Animations
```

## Getting Started

### Prerequisites
- Flutter SDK 3.32.8 or later
- Dart SDK 3.8.1 or later
- Xcode 16.3 (for iOS development)
- iOS 13.0+ deployment target
- CocoaPods (for iOS dependencies)

### Installation

1. Clone the repository:
```bash
cd /Users/robertburns/Projects/RedFlag/safety_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Install iOS pods:
```bash
cd ios
pod install
cd ..
```

4. Run the app:
```bash
flutter run
```

### Running on Specific Simulator

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on simulator named "333"
flutter run -d 333
```

## Design System

### Color Palette
- **Primary Pink**: `#E91E63` - Main brand color
- **Deep Pink**: `#C2185B` - Accent and emphasis
- **Soft Pink**: `#F8BBD0` - Borders and subtle elements
- **Light Pink**: `#FCE4EC` - Backgrounds and highlights
- **Rose**: `#F06292` - Secondary accents
- **Green**: `#4CAF50` - Success and refund indicators

### Typography
- **Google Fonts**: Roboto and Poppins
- **Headings**: Bold, clear hierarchy
- **Body**: Readable with appropriate line-height
- **Captions**: Smaller informational text

## API Integration

### Production Backend
- **URL**: `https://pink-flag-api.fly.dev/api`
- **Platform**: Fly.io (Python FastAPI)
- **Endpoints**:
  - `POST /api/search/name` - Name search (FastPeopleSearch via Offenders.io)
  - `POST /api/image-search` - Image search (TinEye API)
  - `GET /health` - Health check

### Phone Lookup API
- **Provider**: Twilio Lookup API v2
- **Rate Limit**: App-level 15 requests/minute (cost control)
- **Coverage**: Global (Line Type + CNAM where available)
- **Endpoint**: `https://lookups.twilio.com/v2/PhoneNumbers/{phone}`
- **Credits**: 2 credits per lookup (maps to ~$0.07 user spend)
- **Credentials**: Stored on backend only (not in app_config)

### Supabase Backend
- **Auth**: Email/password + Apple Sign-In
- **Database**: PostgreSQL with Row Level Security
- **Tables**: profiles, credit_transactions, searches
- **RPC Functions**:
  - `deduct_credit_for_search()` - Credit deduction
  - `refund_credit_for_failed_search()` - Automatic refunds

### RevenueCat
- **Products**:
  - `pink_flag_3_searches` - $1.99 (30 credits)
  - `pink_flag_10_searches` - $4.99 (100 credits)
  - `pink_flag_25_searches` - $9.99 (250 credits)
- **API Key**: `appl_IRhHyHobKGcoteGnlLRWUFgnIos`
- **Version**: purchases_flutter ^9.9.4

## Credit Refund System

### How It Works
1. User performs search → Credit deducted → `searchId` tracked
2. API call fails (503, 500, timeout, etc.) → Error detected
3. `shouldRefund()` checks if error is refundable → Returns true
4. `refundCredit()` calls Supabase RPC → Credit instantly refunded
5. UI updates automatically → Shows refund badge

### Refund Policy
✅ **Automatic Refunds**:
- 503 Service Unavailable (API maintenance)
- 500/502/504 Server errors
- 429 Rate limiting
- Network timeouts
- Connection failures
- API authentication errors

❌ **No Refunds**:
- 400 Bad Request (invalid input)
- 404 Not Found
- User validation errors
- Successful searches

### UI Indicators
- **Transaction History**: Green 🔄 icon, refund reason displayed
- **Search History**: Small green "🔄 Refunded" badge
- **Credit Display**: Balance updates immediately

## Testing

### Validation Features
- Form validation for required fields
- Phone number validation (US & international)
- Email validation for authentication
- Input sanitization for search queries
- Network error handling with retry
- Null-safe data display

### Error Handling
- Custom exceptions: `ApiException`, `NetworkException`, `ServerException`, `InsufficientCreditsException`
- User-friendly error messages
- Automatic retry for network failures
- Graceful degradation

## Known Issues

- None currently blocking; monitor Twilio spend and Offenders.io availability.

## Configuration

### Environment Variables
- Supabase URL and Anon Key
- Twilio Account SID and Auth Token
- RevenueCat API Key
- Backend API URL

### Feature Flags (`lib/config/app_config.dart`)
```dart
static const bool USE_MOCK_PURCHASES = true;  // Toggle for testing
```

## Documentation

- **[CURRENT_STATUS.md](../CURRENT_STATUS.md)** - Development status and timeline
- **[CREDIT_REFUND_SYSTEM.md](../CREDIT_REFUND_SYSTEM.md)** - Refund system architecture
- **[CREDIT_REFUND_ROADMAP.md](../CREDIT_REFUND_ROADMAP.md)** - Implementation roadmap
- **[RELEASE_NOTES_v1.1.7.md](../RELEASE_NOTES_v1.1.7.md)** - Version 1.1.7 release notes
- **[PHONE_LOOKUP_IMPLEMENTATION.md](../PHONE_LOOKUP_IMPLEMENTATION.md)** - Phone lookup docs
- **[REVENUECAT_INTEGRATION_GUIDE.md](../REVENUECAT_INTEGRATION_GUIDE.md)** - RevenueCat setup
- **[SETTINGS_SCREEN_COMPLETE.md](../SETTINGS_SCREEN_COMPLETE.md)** - Settings screen docs

## Future Enhancements

- **Search Features**:
  - Location-based proximity search
  - Save favorite searches
  - Bulk search capabilities
  - Export search results

- **User Experience**:
  - Dark mode support
  - Accessibility improvements
  - Push notifications for credits
  - Offline mode for history

- **Analytics**:
  - Search analytics dashboard
  - Credit usage reports
  - Refund trend analysis

## Contributing

This is a private project. For questions or issues, please contact the project maintainer.

## License

Proprietary - All rights reserved

## Acknowledgments

- Flutter framework and community
- Supabase for backend infrastructure
- RevenueCat for monetization platform
- Twilio Lookup API for phone lookups
- TinEye for reverse image search
- Offenders.io for registry data access
- Material Design guidelines

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

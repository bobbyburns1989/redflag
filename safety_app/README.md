# Pink Flag

A Flutter-based safety application for searching and viewing offender registry information with a modern, user-friendly interface.

## Overview

Pink Flag is a mobile application designed to help users search public offender registries through an intuitive, aesthetically pleasing interface. The app features a feminine pink theme and provides easy access to registry data with enhanced search capabilities.

## Features

### Core Functionality
- **Name-based Search**: Search registry by first and last name (both required)
- **Advanced Filters**: Optional filters including age, state, phone number, and ZIP code
- **Results Display**: View detailed offender information cards with location data
- **Onboarding**: First-time user experience with feature highlights
- **Resources**: Access to safety resources and support information

### User Interface
- **Modern Pink Theme**: Cohesive feminine aesthetic with gradient accents
- **Custom Splash Screen**: Branded launch experience
- **Smooth Animations**: Page transitions with slide and fade effects
- **Responsive Design**: Optimized layouts that fit on single screens without scrolling
- **Bottom Navigation**: Easy access to search, results, and resources

## 📋 Current Status

**See [CURRENT_STATUS.md](../CURRENT_STATUS.md) for detailed development status including:**
- ✅ Backend deployed to Fly.io (production ready)
- ⚠️ RevenueCat temporarily disabled (build issue)
- 📊 Project timeline and next steps

## Recent Updates

### Version 1.3 (November 7, 2025)

#### Backend Deployment
- **Production API Deployed**: Backend now live at `https://pink-flag-api.fly.dev`
- **Platform**: Fly.io with auto-scaling and free tier
- **Integration**: Updated `api_service.dart` to use production URL
- **Testing**: Health check and search endpoints verified working

#### Monetization Status
- **RevenueCat Configured**: API key added, products created
- **Known Issue**: iOS build error with purchases_flutter (temporarily disabled)
- **Workaround**: Store screen disabled until CocoaPods update completes
- **Impact**: Core search functionality still operational

### Version 1.2.1 (November 6, 2025)

#### Code Quality & Production Readiness
- **Deprecation Fixes**: Migrated all 42 instances of deprecated `withOpacity()` to modern `withValues(alpha:)` API
- **Code Analysis**: Achieved zero errors, zero warnings, zero info notices
- **Documentation**: Added comprehensive App Store Release Guide (APP_STORE_RELEASE_GUIDE.md)
- **Developer Onboarding**: Created Coding Guidelines for Claude Code AI assistant (CODING_GUIDELINES.md)
- **Production Ready**: Codebase is now ready for App Store submission

### Version 1.2 (November 2025)

#### UI/UX Improvements
- **Balanced Onboarding Buttons**: Next and Back buttons now have equal width for better visual balance (lib/screens/onboarding_screen.dart:141-179)
- **Fixed Bottom Navigation Overflow**: Resolved 8-10 pixel overflow by adjusting container height and padding (lib/widgets/custom_bottom_nav.dart:77-78, 114, 142)
- **Enhanced Text Field Labels**: Fixed floating label overlap with gradient borders by adding white background cutout (lib/widgets/custom_text_field.dart:163-168)
- **Complete Location Display**: Added city and state to address information on result cards (lib/widgets/offender_card.dart:81-90, 146-168)
- **Optimized Search Screen Layout**: Reduced spacing and padding throughout to fit collapsed form on single screen (lib/screens/search_screen.dart:180-430)

#### Technical Changes
- Implemented `Expanded` widgets for equal-width button distribution
- Added `floatingLabelStyle` with `backgroundColor` for Material Design label cutout
- Created `_buildFullAddress()` method for smart null-safe address formatting
- Replaced `AppSpacing` constants with precise `const SizedBox` values for space optimization

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   ├── offender.dart             # Offender data model
│   └── search_result.dart        # Search result wrapper
├── screens/
│   ├── onboarding_screen.dart    # First-time user experience
│   ├── home_screen.dart          # Main navigation hub
│   ├── search_screen.dart        # Registry search interface
│   ├── results_screen.dart       # Search results display
│   └── resources_screen.dart     # Safety resources
├── services/
│   └── api_service.dart          # API communication layer
├── theme/
│   ├── app_colors.dart           # Color palette and gradients
│   ├── app_text_styles.dart      # Typography styles
│   └── app_spacing.dart          # Layout spacing constants
└── widgets/
    ├── custom_button.dart        # Reusable button component
    ├── custom_text_field.dart    # Form input component
    ├── custom_bottom_nav.dart    # Navigation bar
    ├── offender_card.dart        # Result card component
    └── page_transitions.dart     # Animation helpers
```

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK (included with Flutter)
- iOS Simulator or Android Emulator
- Xcode (for iOS development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd safety_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Running on Specific Simulator

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Design System

### Color Palette
- **Primary Pink**: `#E91E63` - Main brand color
- **Deep Pink**: `#C2185B` - Accent and emphasis
- **Soft Pink**: `#F8BBD0` - Borders and subtle elements
- **Light Pink**: `#FCE4EC` - Backgrounds and highlights
- **Rose**: `#F06292` - Secondary accents

### Typography
- **Headings**: Bold, clear hierarchy
- **Body**: Readable with appropriate line-height
- **Captions**: Smaller informational text
- **Overlines**: Section headers in uppercase

### Spacing
- Consistent padding and margins using `AppSpacing` constants
- Recent optimizations use explicit values for precise control
- Balanced vertical rhythm throughout screens

## API Integration

The app integrates with a registry search API through the `ApiService` class:

- **Production Endpoint**: `https://pink-flag-api.fly.dev/api`
- **Backend**: Python FastAPI deployed on Fly.io
- **Search Method**: `searchByName()` with optional filters
- **Error Handling**: Custom `ApiException` with user-friendly messages
- **Response Parsing**: Converts JSON to `SearchResult` and `Offender` models
- **Timeout**: 30 seconds with retry functionality
- **Health Check**: `/health` endpoint for monitoring

## Testing

The app includes comprehensive validation:
- Form validation for required fields
- Input sanitization for optional filters
- Network error handling with retry functionality
- Null-safe data display

## Known Issues

### RevenueCat Build Error (Active)
- **Issue**: Swift compiler error with 'SubscriptionPeriod' type ambiguity
- **Cause**: iOS 18.4/Xcode 16.3 StoreKit changes conflict with PurchasesHybridCommon
- **Status**: Temporarily disabled while resolving
- **Workaround**: Store functionality commented out, core app still functional
- **Fix**: Update to purchases_flutter ^9.9.4 (requires pod repo update)
- **Details**: See [CURRENT_STATUS.md](../CURRENT_STATUS.md#known-issue-revenuecat-build-error)

## Future Enhancements

- Location-based proximity search
- Save favorite searches
- Push notifications for registry updates
- Dark mode support
- Accessibility improvements

## Contributing

This is a private project. For questions or issues, please contact the project maintainer.

## License

Proprietary - All rights reserved

## Acknowledgments

- Flutter framework and community
- Material Design guidelines
- Public registry data providers

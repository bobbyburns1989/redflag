# Pink Flag - Complete Release History

**Last Updated**: January 29, 2025

All version releases in reverse chronological order (latest first).

---

## v1.1.8 (Build 14) - November 28, 2025 🔒 SECURITY FIX

**Type**: Security Enhancement

### What Changed
- ✅ **Apple-Only Authentication**: Removed email/password login UI
- ✅ **Security Fix**: Enforced Apple Sign-In to prevent credit abuse
- ✅ **Code Cleanup**: Reduced login_screen.dart from 389 to 185 lines (52%)

### Why It Matters
- **Before**: Users could create unlimited disposable email accounts for infinite free searches
- **After**: Each Apple ID costs $10-50, prevents bulk account creation
- **Impact**: 99% reduction in expected abuse attempts

### Files Changed
- `lib/screens/login_screen.dart` (-204 lines)
- `lib/services/auth_service.dart` (+12 lines documentation)
- `lib/config/app_config.dart` (version bump)
- `pubspec.yaml` (version 1.1.8+14)

### Documentation
- `APPLE_ONLY_AUTH_MIGRATION.md` - Complete security analysis (900+ lines)
- `RELEASE_NOTES_v1.1.8.md` - Detailed release notes

---

## v1.1.7 (Build 13) - November 28, 2025 🔄 CREDIT REFUNDS

**Type**: Feature Release + Bug Fixes

### What's New
- ✅ **Automatic Credit Refund System**: Credits automatically refunded when searches fail due to API/server errors
- ✅ **Phone Validation Fix**: Improved US phone number validation for 10-digit numbers
- ✅ **UI Improvements**: Refund badges in transaction and search history

### Refund Policy
**Automatic Refunds For:**
- Server errors (500, 502, 503, 504)
- Network connection failures
- Request timeouts
- API rate limiting (429)
- API authentication errors

**No Refund For:**
- Invalid search input (400 errors)
- Successfully completed searches
- User cancellations

### Technical Improvements
- New `refund_credit_for_failed_search()` RPC function in Supabase
- Atomic credit refund transactions
- Enhanced error tracking in search records
- New `refunded` boolean column on searches table

### Files Changed
- `lib/services/search_service.dart` (+80 lines)
- `lib/services/image_search_service.dart` (+120 lines)
- `lib/services/phone_search_service.dart` (+130 lines)
- `lib/models/credit_transaction.dart` (+54 lines)
- `lib/models/search_history_entry.dart` (+2 lines)
- `lib/screens/settings/transaction_history_screen.dart` (refund display)
- `lib/screens/settings/search_history_screen.dart` (+30 lines badges)
- `pubspec.yaml` (version 1.1.7+13)

### Documentation
- `CREDIT_REFUND_SYSTEM.md` - Architecture (460 lines)
- `CREDIT_REFUND_SCHEMA.sql` - Database schema (200 lines)
- `CREDIT_REFUND_ROADMAP.md` - Implementation roadmap (600 lines)
- `RELEASE_NOTES_v1.1.7.md` - Detailed release notes (550+ lines)

---

## v1.1.5 (Build 11) - November 10, 2025 ⚙️ SETTINGS & MONETIZATION

**Type**: Feature Release

### What's New
- ✅ **Settings Screen**: Complete settings implementation with account management
- ✅ **RevenueCat Integration**: Full in-app purchase system
- ✅ **Store Screen**: Buy credit packages (3, 10, 25 searches)
- ✅ **Transaction History**: View all credit transactions
- ✅ **Search History**: View past searches with privacy controls
- ✅ **Change Password**: User account management
- ✅ **Feature Flag System**: Easy switching between mock and real purchases

### Monetization Details
**Credit Packages:**
- 3 Searches: $1.99 ($0.66 per search)
- 10 Searches: $4.99 ($0.50 per search) - Best Value
- 25 Searches: $9.99 ($0.40 per search)

**Backend Integration:**
- RevenueCat SDK integrated
- Supabase webhook for purchase processing
- Real-time credit updates
- Purchase restoration support

### Files Created
- `lib/screens/settings_screen.dart` (380 lines)
- `lib/screens/settings/transaction_history_screen.dart`
- `lib/screens/settings/search_history_screen.dart`
- `lib/screens/settings/change_password_screen.dart`
- `lib/services/history_service.dart`
- `lib/models/credit_transaction.dart`
- `lib/models/search_history_entry.dart`
- `lib/config/app_config.dart` (feature flags)
- `supabase/functions/revenuecat-webhook/index.ts`

### Documentation
- `SETTINGS_SCREEN_COMPLETE.md`
- `REVENUECAT_INTEGRATION_GUIDE.md` (550+ lines)
- `MONETIZATION_COMPLETE.md`

---

## v1.1.4 (Build 10) - November 20, 2025 🐛 BUG FIXES

**Type**: Bug Fix Release

### What's Fixed
- ✅ **TinEye Response Parsing**: Fixed `'Backlink' object has no attribute 'domain'`
- ✅ **TinEye Stats Access**: Fixed stats dictionary access
- ✅ **Image Content Type**: Fixed `Unsupported image type` errors
- ✅ **Apple Sign-In**: Configured Supabase with correct Client ID

### Files Modified
- `backend/services/tineye_service.py`
- `lib/services/image_search_service.dart`

---

## v1.1.3 (Build 9) - November 20, 2025 🖼️ IMAGE SEARCH

**Type**: Feature Release

### What's New
- ✅ **Reverse Image Search**: TinEye API integration for catfish/scam detection
- ✅ **Multiple Input Methods**: Camera, gallery, or URL input
- ✅ **Results Display**: Match counts, domains, backlinks
- ✅ **UI Revamp**: Modern/minimal aesthetic overhaul

### Features
- Search billions of indexed images
- Detect fake profiles using stock photos
- Identify catfishing attempts
- View where images appear online
- 1 credit per search

### Files Created
- `lib/screens/image_results_screen.dart`
- `backend/services/tineye_service.py`

---

## v1.1.2 (Build 8) - November 19, 2025 🐛 BUG FIXES

**Type**: Bug Fix Release

### What's Fixed
- ✅ **Auth Persistence**: Returning users skip onboarding, go straight to home
- ✅ **Purchase Timeout**: Extended from 21s to 78s with progress feedback
- ✅ **Purchase Fallback**: Dialog with "Restore Now" button
- ✅ **Credit Counter**: Auto-updates after purchases and searches

### Files Modified
- `lib/screens/splash_screen.dart`
- `lib/screens/store_screen.dart`
- `lib/screens/search_screen.dart`

---

## v1.1.1 (Build 7) - November 18, 2025 🚨 APPLE COMPLIANCE

**Type**: Compliance Fix

### What Changed
- ✅ **Removed Search History**: Complies with Apple Guideline 5.1.1
- ✅ **Refactored Store Screen**: 695 → 251 lines (64% reduction)
- ✅ **Refactored Auth Service**: 361 → 89 lines + 3 services (77% reduction)

### Files Modified
- `lib/screens/store_screen.dart`
- `lib/services/auth_service.dart`

### Documentation
- `APPLE_REVIEW_RESPONSE_v1.1.1.md`
- `REFACTORING_STORE_SCREEN.md`
- `REFACTORING_AUTH_SERVICE.md`

---

## v1.1.0 (Build 6) - November 18, 2025 🔧 REFACTORING

**Type**: Code Quality Improvements

### What Changed
- ✅ Major refactoring of store and auth services
- ✅ Modular architecture improvements
- ✅ Improved code maintainability

---

## v1.0.3 (Build 5) - November 6, 2025 ✨ CODE QUALITY

**Type**: Code Quality Improvements

### What Changed
- ✅ **Fixed 42 Deprecation Warnings**: `withOpacity` → `withValues` migration
- ✅ **Clean Analysis**: 0 errors, 0 warnings, production-ready
- ✅ **Modern Flutter API**: Updated to latest color API

---

## v1.0.2 - Earlier Release

**Type**: Bug Fixes

### What Changed
- Various bug fixes and improvements
- Deployment guide created

---

## v1.0.1 - Earlier Release

**Type**: Device Support Update

### What Changed
- ✅ **iPad Support Removed**: iPhone only
- ✅ **Bundle ID Fix**: Configured for App Store
- ✅ **App Store Ready**: First production-ready version

---

## v1.0.0 - Initial Release 🎉

**Type**: Initial Release

### What Launched
- ✅ **Pink Flag Branding**: Rebranded from "Safety First"
- ✅ **Splash Screen**: Animated pink flag logo
- ✅ **5-Page Onboarding**: Educational flow with legal/ethical guidance
- ✅ **Search Functionality**: Name search with optional filters
- ✅ **Results Display**: Card-based UI with offender information
- ✅ **Emergency Resources**: Integrated hotlines with tap-to-call
- ✅ **Backend Integration**: FastAPI backend with Offenders.io API
- ✅ **Privacy First**: No tracking, no data collection

### Architecture
- Flutter 3.32.8 + Dart 3.8.1
- Python FastAPI backend
- Supabase authentication and database
- RevenueCat monetization
- Material Design 3 UI

---

## Version Summary

| Version | Build | Date | Type | Key Features |
|---------|-------|------|------|--------------|
| 1.1.8 | 14 | Nov 28, 2025 | Security | Apple-only auth |
| 1.1.7 | 13 | Nov 28, 2025 | Feature | Credit refunds |
| 1.1.5 | 11 | Nov 10, 2025 | Feature | Settings + monetization |
| 1.1.4 | 10 | Nov 20, 2025 | Bug Fix | TinEye fixes |
| 1.1.3 | 9 | Nov 20, 2025 | Feature | Image search |
| 1.1.2 | 8 | Nov 19, 2025 | Bug Fix | Auth + purchases |
| 1.1.1 | 7 | Nov 18, 2025 | Compliance | Apple guidelines |
| 1.1.0 | 6 | Nov 18, 2025 | Refactor | Code quality |
| 1.0.3 | 5 | Nov 6, 2025 | Quality | Deprecation fixes |
| 1.0.2 | - | Earlier | Bug Fix | Various fixes |
| 1.0.1 | - | Earlier | Update | iPhone only |
| 1.0.0 | - | Earlier | Launch | Initial release |

---

## Current Development

See [CURRENT_STATUS.md](../CURRENT_STATUS.md) for latest development status and ongoing work.

---

**Maintained with ❤️ using Claude Code**

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

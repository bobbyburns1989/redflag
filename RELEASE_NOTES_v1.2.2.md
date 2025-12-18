# Pink Flag - Release Notes v1.2.2 (Build 25)

**Release Date**: December 17, 2025
**Status**: Ready for App Store Submission
**Previous Version**: v1.2.1 (Build 24)

---

## 🎯 Release Overview

Version 1.2.2 is a patch release that resolves App Store Connect validation errors and ensures production readiness for the next App Store submission.

**Key Focus**: Version compliance and production configuration

---

## ✨ What's New

### 🔧 Technical Updates

1. **Version Bump to 1.2.2 (Build 25)**
   - Fixed App Store Connect validation error: "Invalid Pre-Release Train"
   - Updated CFBundleShortVersionString from 1.2.1 to 1.2.2
   - Build number incremented from 24 to 25
   - Ensures compatibility with App Store submission requirements

2. **Production Configuration Verified**
   - ✅ RevenueCat real purchases mode enabled (`USE_MOCK_PURCHASES = false`)
   - ✅ Production API endpoint active: `https://pink-flag-api.fly.dev/api`
   - ✅ All configuration constants updated in `app_config.dart`
   - ✅ Full clean build performed with derived data deletion

---

## 🐛 Bug Fixes

### App Store Validation Errors
- **Fixed**: "Invalid Pre-Release Train" error (train version 1.2.1 was closed)
- **Fixed**: CFBundleShortVersionString validation requiring higher version than 1.2.1
- **Solution**: Version bumped to 1.2.2 (Build 25)

---

## 📦 Updated Files

### Version Updates
- `pubspec.yaml` - Version: 1.2.1+24 → 1.2.2+25
- `lib/config/app_config.dart` - APP_VERSION: '1.1.8' → '1.2.2', BUILD_NUMBER: '14' → '25'
- `ios/Flutter/Generated.xcconfig` - Regenerated with correct version numbers

### Documentation Updates
- `README.md` - Version badge updated to 1.2.2, status changed to PRODUCTION
- `CURRENT_STATUS.md` - Updated with v1.2.2 release information
- `RELEASE_NOTES_v1.2.2.md` - Created (this file)

---

## 🚀 Deployment Checklist

### Pre-Submission Verification ✅
- ✅ Xcode derived data deleted
- ✅ Flutter clean performed
- ✅ `flutter pub get` completed
- ✅ `pod install` completed (11 pods installed)
- ✅ Full release build successful (`flutter build ios --release --no-codesign`)
- ✅ Version numbers verified in Generated.xcconfig
- ✅ CFBundleShortVersionString confirmed as 1.2.2
- ✅ CFBundleVersion confirmed as 25
- ✅ USE_MOCK_PURCHASES set to false (production mode)
- ✅ Xcode workspace ready for archiving

### Ready for Archive
The app is now ready for archiving in Xcode:
1. Select "Any iOS Device (arm64)" from device dropdown
2. Product → Archive
3. Distribute App → App Store Connect
4. Upload to TestFlight/App Store

---

## 📊 Current Feature Set

### All Features Operational ✅
- **Name Search**: 10 credits per search (Offenders.io API - 900K+ records)
- **Phone Lookup**: 2 credits per search (Twilio Lookup API v2 - CNAM + carrier info)
- **Reverse Image Search**: 4 credits per search (TinEye API - billions of images)
- **FBI Most Wanted**: FREE bonus check with name searches
- **Credit System**: Variable credit costs based on actual API expenses
- **In-App Purchases**: RevenueCat integration with 3 credit packages
- **Automatic Refunds**: Credits refunded on API failures
- **Apple Sign-In**: Privacy-first authentication (no email required)

### Credit Packages
- **30 Credits** - $1.99 (3-15 searches depending on type)
- **100 Credits** - $4.99 (Best Value - 10-50 searches)
- **250 Credits** - $9.99 (Maximum credits for power users)

---

## 🔒 Security & Privacy

- **Apple Sign-In Only**: Prevents credit abuse with disposable emails
- **No Data Collection**: Privacy-first design
- **HTTPS Only**: Secure API communication
- **JWT Authentication**: Supabase session tokens for backend requests
- **Row Level Security**: Database policies enforce user data isolation

---

## 🏗️ Infrastructure

### Backend
- **Platform**: Fly.io
- **URL**: https://pink-flag-api.fly.dev
- **Version**: v18 (Variable credit costs deployed)
- **Status**: ✅ Operational

### Database
- **Provider**: Supabase (PostgreSQL)
- **Tables**: profiles, credit_transactions, searches, search_history
- **Status**: ✅ Operational with RPC functions for credit management

### Payment Processing
- **Provider**: RevenueCat
- **Mode**: Production (real purchases)
- **Webhook**: Deployed to Supabase Edge Functions
- **Status**: ✅ Active and processing purchases

---

## 📈 Version History

| Version | Build | Date | Highlights |
|---------|-------|------|------------|
| **1.2.2** | 25 | Dec 17, 2025 | Version bump for App Store validation fix |
| 1.2.1 | 24 | Dec 11, 2025 | Twilio migration, variable credit documentation |
| 1.2.0 | 23 | Dec 8, 2025 | Variable credit system deployed |
| 1.1.9 | 15 | Nov 30, 2025 | JWT authentication fix (critical) |
| 1.1.8 | 14 | Nov 29, 2025 | Initial App Store launch |

---

## 🎯 What's Next

### Short Term (Post-Submission)
1. Monitor App Store review process
2. Track purchase conversions in RevenueCat
3. Monitor Supabase for any errors
4. Gather user feedback

### Medium Term (Next Release)
1. Implement enhanced phone lookup with spam detection (Phase 1 from improvement plan)
2. Add premium image search tier with face recognition
3. Performance optimizations based on user metrics
4. UI/UX improvements based on feedback

---

## 📞 Support & Resources

- **Support Email**: support@pinkflagapp.com
- **Privacy Email**: privacy@pinkflagapp.com
- **Privacy Policy**: https://customapps.us/pinkflag/privacy
- **Terms of Service**: https://customapps.us/pinkflag/terms

---

## 🙏 Acknowledgments

Built with Flutter 3.32.8, FastAPI, Supabase, and RevenueCat.

Special thanks to:
- Offenders.io for sex offender registry data
- Twilio for phone lookup API
- TinEye for reverse image search
- FBI.gov for Most Wanted API

---

**Status**: ✅ Production Ready - Awaiting App Store Submission

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

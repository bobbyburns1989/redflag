# Pink Flag - App Store Release Guide

> **Document Purpose**: Step-by-step guide to prepare Pink Flag for App Store submission and production deployment.

**Last Updated**: November 6, 2025
**Target Release**: TBD
**App Version**: 1.0.0+1

---

## 📋 Pre-Release Checklist Overview

- [ ] **Phase 1**: Code Quality & Testing (1-2 days)
- [ ] **Phase 2**: iOS App Configuration (1 day)
- [ ] **Phase 3**: App Assets & Branding (1-2 days)
- [ ] **Phase 4**: Legal & Privacy Documents (1 day)
- [ ] **Phase 5**: Backend Production Setup (1-2 days)
- [ ] **Phase 6**: App Store Connect Setup (1 day)
- [ ] **Phase 7**: Final Testing & Submission (1-2 days)

**Total Estimated Time**: 7-12 days

---

## 🎯 Phase 1: Code Quality & Testing

### 1.1 Run Code Analysis
```bash
cd safety_app

# Run Flutter analyzer
flutter analyze

# Expected: Fix all errors, address important warnings
# Current state: 42 info-level deprecation warnings (withOpacity)
```

**Action Items:**
- [ ] Fix any error-level issues (currently 0 ✅)
- [ ] Address warning-level issues (currently 0 ✅)
- [ ] Document remaining info-level warnings if they're non-breaking

### 1.2 Format Code
```bash
# Format all Dart files
flutter format lib/ test/

# Verify no formatting issues
flutter format --set-exit-if-changed lib/ test/
```

### 1.3 Run Tests
```bash
# Run existing unit tests
flutter test

# Run integration tests (if created)
flutter test integration_test/

# Generate coverage report
flutter test --coverage
```

**⚠️ Current State**: No unit or integration tests exist yet

**Action Items:**
- [ ] **Priority**: Create critical path tests (search flow, API integration)
- [ ] Create widget tests for main screens
- [ ] Test error handling and edge cases
- [ ] **Optional for v1.0**: Aim for >70% code coverage

### 1.4 Test on Real Devices
**Minimum Testing Matrix:**
- [ ] iPhone 13/14 (most common)
- [ ] iPhone SE (smallest screen)
- [ ] iPhone 15 Pro Max (largest screen)
- [ ] iPad (tablet layout verification)

**Test Scenarios:**
- [ ] Complete onboarding flow
- [ ] Search with all filter combinations
- [ ] Results display with 0, 1, 5, 20+ results
- [ ] Pull-to-refresh functionality
- [ ] Emergency resources tap-to-call
- [ ] Bottom navigation transitions
- [ ] All animations perform smoothly
- [ ] No layout overflow on small screens
- [ ] App works in airplane mode (graceful error handling)
- [ ] Background/foreground transitions

---

## 🍎 Phase 2: iOS App Configuration

### 2.1 Verify Bundle Identifier
**Current**: `com.pinkflag.app`

```bash
# Check current bundle ID in Xcode
open safety_app/ios/Runner.xcworkspace
# Navigate to: Runner → General → Bundle Identifier
```

**Action Items:**
- [ ] Confirm bundle ID matches App Store Connect (register if needed)
- [ ] Ensure bundle ID is unique and follows reverse-domain notation
- [ ] No changes needed if `com.pinkflag.app` is registered to your Apple Developer account

### 2.2 Update Info.plist
**File**: `safety_app/ios/Runner/Info.plist`

**Required Fields:**
```xml
<key>CFBundleDisplayName</key>
<string>Pink Flag</string>

<key>CFBundleName</key>
<string>Pink Flag</string>

<key>CFBundleShortVersionString</key>
<string>1.0.0</string>

<key>CFBundleVersion</key>
<string>1</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Pink Flag does not access your photo library.</string>

<key>NSCameraUsageDescription</key>
<string>Pink Flag does not access your camera.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Pink Flag does not access your location for privacy reasons.</string>

<key>NSPhoneCallUsageDescription</key>
<string>Pink Flag needs permission to make emergency calls to safety resources.</string>
```

**Action Items:**
- [ ] Verify all usage descriptions are present
- [ ] Add any missing permissions required by url_launcher for phone calls
- [ ] Remove any unused permission requests

### 2.3 Configure App Transport Security
**File**: `safety_app/ios/Runner/Info.plist`

**For Production (HTTPS only):**
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

**⚠️ Important**: Ensure your production backend uses HTTPS

### 2.4 Set Deployment Target
```bash
# In Xcode: Runner → General → Deployment Info
# Minimum: iOS 13.0 (recommended)
# Current Flutter requirement: iOS 12.0+
```

**Action Items:**
- [ ] Set minimum iOS version to 13.0 or higher
- [ ] Test on lowest supported iOS version

### 2.5 Configure Signing & Capabilities
```bash
# Open in Xcode
open safety_app/ios/Runner.xcworkspace
```

**In Xcode:**
1. Select "Runner" target
2. Go to "Signing & Capabilities"
3. **Action Items:**
   - [ ] Select your Apple Developer Team
   - [ ] Enable "Automatically manage signing" (recommended for first release)
   - [ ] Verify Provisioning Profile is valid
   - [ ] No additional capabilities needed (no push notifications, iCloud, etc.)

---

## 🎨 Phase 3: App Assets & Branding

### 3.1 Create App Icons
**Required Sizes for iOS:**
- 1024×1024 (App Store)
- 180×180 (iPhone 3x)
- 167×167 (iPad Pro)
- 152×152 (iPad 2x)
- 120×120 (iPhone 2x)
- 87×87 (iPhone 3x Settings)
- 80×80 (iPad 2x Settings)
- 76×76 (iPad 1x)
- 60×60 (iPhone 2x Settings)
- 58×58 (iPhone 2x Settings)
- 40×40 (iPad 1x Settings)
- 29×29 (iPhone 1x Settings)
- 20×20 (Notifications)

**Design Guidelines:**
- Use the Pink Flag logo (pink flag on cream background)
- No alpha channel transparency
- Square corners (iOS adds rounded corners automatically)
- No text in icon (display name appears below)
- Test icon visibility on both light and dark backgrounds

**Tools:**
- [App Icon Generator](https://appicon.co/) - Upload 1024×1024, get all sizes
- Design in Figma/Sketch with provided pink gradient theme

**Action Items:**
- [ ] Design 1024×1024 master icon
- [ ] Generate all required sizes
- [ ] Replace icons in `safety_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- [ ] Verify icons display correctly in Xcode

### 3.2 Create Launch Screen
**Current State**: Splash screen with animations (2.5s)

**Action Items:**
- [ ] Verify launch screen loads instantly (static image before splash)
- [ ] Ensure launch screen matches splash screen design
- [ ] File: `safety_app/ios/Runner/Assets.xcassets/LaunchImage.imageset/`
- [ ] Keep design simple (Apple guidelines: instant load)

### 3.3 Prepare App Store Screenshots
**Required Screenshots:**

**iPhone 6.7" (iPhone 15 Pro Max)** - Required
- Resolution: 1290 × 2796 pixels
- Quantity: 3-10 screenshots

**iPhone 6.5" (iPhone 14 Pro Max)** - Optional but recommended
- Resolution: 1284 × 2778 pixels

**iPhone 5.5" (iPhone 8 Plus)** - Optional
- Resolution: 1242 × 2208 pixels

**Recommended Screenshots (in order):**
1. **Splash Screen** - Beautiful pink flag logo with tagline
2. **Search Screen** - Show search form with pink gradient theme
3. **Search Results** - Display sample results with offender cards
4. **Resources Screen** - Emergency resources with 911 banner
5. **Onboarding Snippet** - Privacy/ethical use message

**Screenshot Guidelines:**
- Use device frames (optional but professional)
- Add localized text overlays highlighting features
- Show actual app UI (no mockups)
- Consistent lighting and aesthetic
- Include status bar (time, battery, signal)

**Tools:**
- Use iOS Simulator: `xcrun simctl io booted screenshot screenshot.png`
- [Screenshot Framer](https://screenshots.pro/) - Add device frames
- Figma/Photoshop - Add text overlays

**Action Items:**
- [ ] Capture screenshots on iPhone 15 Pro Max simulator
- [ ] Add device frames (optional)
- [ ] Add feature callout text
- [ ] Export at exact required resolutions

### 3.4 Create App Preview Video (Optional)
**Specifications:**
- Length: 15-30 seconds
- Resolution: Match screenshot sizes
- Format: .mov, .mp4, or .m4v
- Showcase: Onboarding → Search → Results → Resources

**Action Items (Optional for v1.0):**
- [ ] Record screen with QuickTime
- [ ] Edit with iMovie/Final Cut Pro
- [ ] Add background music (royalty-free)
- [ ] Export at required resolution

---

## 📄 Phase 4: Legal & Privacy Documents

### 4.1 Create Privacy Policy
**Required by Apple**: Yes, all apps must have a privacy policy URL

**Pink Flag Official URLs:**
- **Privacy Policy**: https://customapps.us/pinkflag/privacy
- **Terms of Service**: https://customapps.us/pinkflag/terms

**Key Sections for Pink Flag:**
```markdown
1. Introduction
   - Who we are
   - What Pink Flag does

2. Data Collection
   - Email and password (for authentication)
   - Search credits balance
   - Search history (stored in account)
   - Transaction records (in-app purchases)

3. Data NOT Collected
   - No real name or physical address
   - No location or GPS data
   - No contacts or phone number
   - No tracking for advertising

4. Search Data
   - Searches are linked to user account
   - Search history stored for 90 days
   - Can be deleted by user anytime

5. Third-Party Services
   - Supabase (database & auth)
   - RevenueCat (in-app purchases)
   - Apple App Store (payments)
   - Public registry APIs

6. Emergency Resources
   - Phone call functionality (url_launcher)
   - No call logs stored

7. Children's Privacy
   - App rated 17+
   - Not directed at children under 17

8. Data Rights (CCPA/GDPR)
   - Right to access, delete, export data
   - Contact support@pinkflag.app

9. Changes to Privacy Policy
   - How users will be notified

10. Contact Information
   - support@pinkflag.app
   - privacy@pinkflag.app
```

**Action Items:**
- [x] Create `PRIVACY_POLICY.md` document ✅
- [x] Host on public URL: https://customapps.us/pinkflag/privacy ✅
- [ ] Verify URL is accessible before App Store submission
- [ ] Update content if privacy practices change

### 4.2 Create Terms of Service
**Required by Apple**: Required for apps with user accounts and in-app purchases

**Pink Flag Terms of Service**: https://customapps.us/pinkflag/terms

**Key Sections:**
```markdown
1. Acceptance of Terms
2. Service Description
3. Eligibility (17+ years old)
4. User Accounts (creation, security, deletion)
5. Credits and Purchases
   - Non-refundable credits
   - Pricing and refund policies
6. Acceptable Use
   - Prohibited activities (harassment, stalking, FCRA violations)
   - Legal compliance requirements
7. Data and Privacy (reference to Privacy Policy)
8. Disclaimers
   - Data accuracy not guaranteed
   - Verification required
9. Limitation of Liability
10. Third-Party Services (Supabase, RevenueCat, Apple)
11. Intellectual Property
12. Dispute Resolution (arbitration)
13. FCRA Notice (not a consumer reporting agency)
14. Governing Law (California)
15. Contact Information
```

**Action Items:**
- [x] Create Terms of Service document ✅
- [x] Host on public URL: https://customapps.us/pinkflag/terms ✅
- [ ] Link from app Settings → Legal & Support
- [ ] Verify URL is accessible before App Store submission

### 4.3 Add In-App Legal Links
**Recommended**: Add an "About" or "Legal" section to Resources screen

**Action Items:**
- [ ] Add "Privacy Policy" link to Resources screen
- [ ] Add "Terms of Service" link to Resources screen
- [ ] Links open in Safari using url_launcher

---

## 🚀 Phase 5: Backend Production Setup

### 5.1 Choose Hosting Provider
**Options:**
1. **Heroku** (easiest, moderate cost)
2. **AWS Elastic Beanstalk** (scalable, AWS ecosystem)
3. **Google Cloud Run** (serverless, pay-per-use)
4. **DigitalOcean App Platform** (simple, fixed pricing)
5. **Railway** (modern, simple, affordable)

**Recommendation for Pink Flag**: Railway or DigitalOcean (simple, affordable, <5k users)

### 5.2 Configure Production Environment
**Required Environment Variables:**
```bash
# Production .env file
ENVIRONMENT=production
API_BASE_URL=https://your-backend.railway.app

# External API
OFFENDERS_IO_API_KEY=your_production_key
OFFENDERS_IO_BASE_URL=https://api.offenders.io

# Optional: Backup API
CRIMEOMETER_API_KEY=your_backup_key

# CORS (allow Flutter app)
ALLOWED_ORIGINS=https://your-app-domain.com

# Security
SECRET_KEY=generate_secure_random_string
DEBUG=False
```

**Action Items:**
- [ ] Register domain (optional: `api.pinkflag.app`)
- [ ] Generate production API keys
- [ ] Configure environment variables on hosting platform
- [ ] Set up HTTPS/SSL (most platforms auto-provision)

### 5.3 Deploy Backend
**Example: Railway Deployment**
```bash
# Install Railway CLI
brew install railway

# Login
railway login

# Initialize project
cd backend
railway init

# Deploy
railway up

# Set environment variables
railway variables set OFFENDERS_IO_API_KEY=your_key
railway variables set ENVIRONMENT=production
```

**Action Items:**
- [ ] Deploy backend to chosen platform
- [ ] Verify backend is accessible via HTTPS
- [ ] Test all API endpoints from Postman/curl
- [ ] Monitor logs for errors

### 5.4 Update Flutter App for Production
**File**: `safety_app/lib/services/api_service.dart`

**Current:**
```dart
static const String baseUrl = 'http://localhost:8000/api';
```

**Production Approach - Use environment-based configuration:**

**Option 1: Compile-time configuration**
```dart
// lib/config/environment.dart
class Environment {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    if (isProduction) {
      return 'https://your-backend.railway.app/api';
    }
    return 'http://localhost:8000/api'; // Development
  }
}

// lib/services/api_service.dart
import '../config/environment.dart';

class ApiService {
  static final String baseUrl = Environment.apiBaseUrl;
  // ...
}
```

**Option 2: Use flutter_dotenv with separate .env files**
```dart
// .env.production
API_BASE_URL=https://your-backend.railway.app/api

// .env.development
API_BASE_URL=http://localhost:8000/api

// pubspec.yaml (already has flutter_dotenv)
assets:
  - .env.production
  - .env.development

// lib/main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env.production"); // or .env.development
  runApp(const PinkFlagApp());
}

// lib/services/api_service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String baseUrl = dotenv.env['API_BASE_URL']!;
  // ...
}
```

**Action Items:**
- [ ] Choose configuration approach (recommend Option 1 for simplicity)
- [ ] Implement environment-based API URL
- [ ] Test in both development and production modes
- [ ] Update DEVELOPER_GUIDE.md with production setup instructions

---

## 📱 Phase 6: App Store Connect Setup

### 6.1 Register App on App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Sign in with Apple Developer account
3. Click "My Apps" → "+" → "New App"

**Form Fields:**
- **Platform**: iOS
- **Name**: Pink Flag
- **Primary Language**: English (U.S.)
- **Bundle ID**: com.pinkflag.app (must match Xcode)
- **SKU**: pinkflag-ios-001 (internal identifier)
- **User Access**: Full Access

**Action Items:**
- [ ] Create app in App Store Connect
- [ ] Save app ID for reference

### 6.2 Complete App Information
**Section: General Information**
- **App Name**: Pink Flag (max 30 characters)
- **Subtitle**: Stay Safe, Stay Aware (max 30 characters)
- **Privacy Policy URL**: https://customapps.us/pinkflag/privacy

**Section: Categories**
- **Primary Category**: Lifestyle
- **Secondary Category**: Utilities (optional)

**Section: Age Rating**
- **Rating**: 17+ (Mature/Suggestive Themes due to sex offender content)
- **Questionnaire answers**:
  - Contains mature/suggestive themes: Yes
  - Infrequent/mild sexual content or nudity: Yes (registry data)
  - All others: No

**Action Items:**
- [ ] Fill out all required fields
- [ ] Complete age rating questionnaire accurately
- [ ] Add app description (see Section 6.3)

### 6.3 Write App Store Description
**App Description** (max 4,000 characters):

```
Pink Flag: Your Personal Safety Companion

Stay informed, stay safe. Pink Flag is a women's safety app that provides anonymous access to public sex offender registries with a beautiful, easy-to-use interface.

✨ KEY FEATURES

• Anonymous Search - No login, no tracking, no data collection
• Comprehensive Filters - Search by name, age, location, and more
• Beautiful Design - Modern pink gradient aesthetic with smooth animations
• Emergency Resources - Quick access to 911, domestic violence hotlines, and safety tips
• Privacy-First - All searches are anonymous, no data stored on servers
• Ethical by Design - Prominent disclaimers to prevent misuse

🔍 HOW IT WORKS

1. Enter a first and last name to search public registries
2. Optionally filter by age, state, phone number, or ZIP code
3. View detailed results with location and offense information
4. Access emergency resources with one tap

🛡️ PRIVACY & SAFETY

Pink Flag is built with your privacy in mind:
• No user accounts required
• No personal information collected
• No search history stored on servers
• No third-party tracking or analytics
• All searches are completely anonymous

🎯 WHO IS THIS FOR?

• Women meeting someone new (dates, roommates, neighbors)
• Parents checking on coaches, teachers, or caregivers
• Anyone wanting to stay informed about their community
• People using online dating apps who want extra peace of mind

⚠️ ETHICAL USE ONLY

Pink Flag is designed to empower personal safety decisions, not to harass or stalk individuals. Please use this tool responsibly and ethically.

📞 EMERGENCY RESOURCES

• 911 - Emergency Services
• National Domestic Violence Hotline
• National Sexual Assault Hotline
• Suicide Prevention Lifeline
• Crisis Text Line

💖 BEAUTIFUL & INTUITIVE

Pink Flag features a feminine pink gradient theme with smooth animations, making safety awareness both accessible and aesthetically pleasing.

📱 FEATURES AT A GLANCE

✓ Anonymous registry search
✓ Advanced filtering options
✓ Offline-friendly results display
✓ Emergency resources with tap-to-call
✓ No ads, no subscriptions
✓ Completely free

DOWNLOAD NOW and take control of your personal safety with Pink Flag.

---

Pink Flag sources data from public sex offender registries. Data accuracy is not guaranteed. Always verify information with official sources.
```

**Keywords** (max 100 characters, comma-separated):
```
safety,offender,registry,women,dating,background,check,security,search,awareness
```

**Promotional Text** (max 170 characters, appears above description):
```
Anonymous access to public offender registries. No login, no tracking, completely private. Your safety companion for modern dating and daily life.
```

**Action Items:**
- [ ] Write compelling app description
- [ ] Research and add relevant keywords
- [ ] Write promotional text
- [ ] Proofread all text for errors

### 6.4 Upload Screenshots
**Section: App Store Screenshots**
- Upload screenshots created in Phase 3.3
- Add localized captions (optional)
- Order screenshots by importance (first 3 most important)

**Action Items:**
- [ ] Upload iPhone 6.7" screenshots (required)
- [ ] Upload iPhone 6.5" screenshots (recommended)
- [ ] Add optional captions to screenshots
- [ ] Preview how listing will appear in App Store

### 6.5 Set Pricing & Availability
**Pricing**:
- **Price**: Free
- **In-App Purchases**: None

**Availability**:
- **Countries/Regions**: United States (initial release)
- **Device Availability**: iPhone, iPad
- **Pre-Order**: No

**Action Items:**
- [ ] Set app as free
- [ ] Select available countries (start with US)
- [ ] Confirm device availability

### 6.6 Complete App Privacy Section
**Required by Apple since iOS 14.5**

**Data Types Collected:**
- **Answer honestly**: Pink Flag collects NO data

**Section Answers:**
- Contact Info: No
- Health & Fitness: No
- Financial Info: No
- Location: No
- Sensitive Info: No
- Contacts: No
- User Content: No
- Browsing History: No
- Search History: No
- Identifiers: No
- Purchases: No
- Usage Data: No
- Diagnostics: No
- Other Data: No

**Privacy Practices:**
- Data Used to Track You: No
- Data Linked to You: No
- Data Not Linked to You: No

**Action Items:**
- [ ] Complete privacy questionnaire
- [ ] Verify all answers are accurate
- [ ] This will display "No Data Collected" in App Store ✅

---

## 🧪 Phase 7: Final Testing & Submission

### 7.1 Build Release Version
```bash
cd safety_app

# Clean previous builds
flutter clean
flutter pub get

# Build iOS release (archive)
flutter build ios --release

# This creates: safety_app/build/ios/archive/Runner.xcarchive
```

**Action Items:**
- [ ] Run build command successfully
- [ ] Verify no build errors
- [ ] Check build size (should be <100MB)

### 7.2 Archive & Validate in Xcode
```bash
# Open workspace in Xcode
open ios/Runner.xcworkspace
```

**In Xcode:**
1. Select "Any iOS Device (arm64)" as target
2. Product → Archive
3. Wait for archive to complete
4. Organizer window opens automatically
5. Click "Validate App"
6. Follow validation wizard:
   - Select App Store Connect distribution
   - Select your team
   - Choose automatic signing (recommended)
   - Click "Validate"

**Common Validation Errors:**
- Missing icons → Fix in Assets.xcassets
- Missing app usage descriptions → Fix in Info.plist
- Invalid provisioning profile → Check signing settings
- Code signing issues → Verify Apple Developer account

**Action Items:**
- [ ] Archive app successfully
- [ ] Validate app without errors
- [ ] Fix any validation issues

### 7.3 Upload to App Store Connect
**In Xcode Organizer:**
1. After successful validation, click "Distribute App"
2. Select "App Store Connect"
3. Select "Upload"
4. Choose options:
   - ✓ Include bitcode (if applicable)
   - ✓ Upload app symbols (for crash reports)
   - ✓ Manage version and build number
5. Click "Upload"
6. Wait for upload to complete (5-15 minutes)

**Verify Upload:**
1. Go to App Store Connect
2. Navigate to: My Apps → Pink Flag → TestFlight
3. Wait for "Processing" to complete (15-60 minutes)
4. Build should appear in "iOS Builds" section

**Action Items:**
- [ ] Upload build to App Store Connect
- [ ] Verify build appears in TestFlight section
- [ ] Wait for processing to complete

### 7.4 TestFlight Beta Testing (Recommended)
**Why TestFlight?**
- Test on real users before public release
- Catch bugs not found in development
- Get feedback on UX/UI
- Verify all features work in production
- Test with production backend

**Setup:**
1. In App Store Connect → TestFlight
2. Add internal testers (Apple Developer account members)
3. Add external testers (anyone with email, up to 10,000)
4. Add testing information:
   - What to test
   - Known issues
   - Feedback instructions

**Action Items (Recommended):**
- [ ] Add 5-10 external beta testers
- [ ] Distribute build via TestFlight
- [ ] Collect feedback for 3-7 days
- [ ] Fix critical bugs before public release
- [ ] Upload new build if needed

### 7.5 Submit for App Review
**Prerequisites:**
- ✓ All app information complete
- ✓ Privacy policy URL working
- ✓ Screenshots uploaded
- ✓ Build uploaded and processed
- ✓ Age rating set
- ✓ Pricing configured

**Submission Steps:**
1. Go to App Store Connect → My Apps → Pink Flag
2. Click "+ Version" to create version 1.0.0
3. Select the uploaded build
4. Fill out "Version Information":
   - What's New in This Version: "Initial release of Pink Flag"
5. Complete "App Review Information":
   - Contact Information (your email/phone)
   - Notes for Reviewer (see below)
   - Demo Account (not needed - no login)
6. Click "Submit for Review"

**Notes for Reviewer:**
```
Pink Flag is a women's safety app that provides access to public sex offender registries with user authentication and credit-based searches.

TESTING INSTRUCTIONS:
1. Complete the 5-page onboarding (swipe through)
2. Create an account or log in (email/password via Supabase)
3. Initial credits provided for testing searches
4. On search screen, search for: "John Smith" (first and last name required)
5. View results displayed in card format
6. Try optional filters: Age, State, Phone, ZIP
7. Navigate to Resources tab to see emergency hotlines
8. Navigate to Settings tab to view account info and credits
9. Store screen allows purchasing additional search credits (RevenueCat)

BACKEND:
- Production API: https://pink-flag-api.fly.dev
- Database: Supabase (authentication and credit management)
- In-App Purchases: RevenueCat integration
Test searches will return real results from public registry APIs (Offenders.io).

LEGAL DOCUMENTS:
- Privacy Policy: https://customapps.us/pinkflag/privacy
- Terms of Service: https://customapps.us/pinkflag/terms

CREDITS SYSTEM:
Users purchase search credits via in-app purchases:
- 3 searches: $1.99
- 10 searches: $4.99
- 25 searches: $9.99

ETHICAL USE:
The app includes prominent disclaimers about ethical use, responsible usage, and data verification requirements.

Please contact me if you have any questions during review.
```

**Action Items:**
- [ ] Fill out all submission fields
- [ ] Write clear testing instructions for reviewer
- [ ] Provide contact information
- [ ] Submit for review

### 7.6 Monitor Review Status
**Timeline:**
- **In Review**: 24-48 hours (average)
- **Review Complete**: Notification via email
- **Status Options**:
  - ✅ Approved → Ready for Sale
  - ❌ Rejected → Address issues and resubmit

**Common Rejection Reasons:**
1. Crashes or bugs during review
2. Incomplete functionality
3. Misleading app description
4. Privacy policy missing or incorrect
5. Age rating incorrect
6. UI not matching screenshots

**If Rejected:**
1. Read rejection email carefully
2. Address all issues mentioned
3. Update app if needed (new build)
4. Respond in Resolution Center
5. Resubmit for review

**Action Items:**
- [ ] Monitor email for review status
- [ ] Check App Store Connect daily
- [ ] Be ready to respond to reviewer questions
- [ ] Fix issues quickly if rejected

### 7.7 Release Day!
**Once Approved:**
1. App status changes to "Ready for Sale"
2. Choose release option:
   - **Automatically**: App goes live immediately
   - **Manually**: You choose when to release
3. Click "Release This Version" if manual release

**Post-Release:**
- [ ] Verify app appears in App Store search
- [ ] Download and test from App Store
- [ ] Share App Store link with users
- [ ] Monitor user reviews and ratings
- [ ] Set up analytics (privacy-preserving)
- [ ] Prepare for future updates

**App Store URL:**
```
https://apps.apple.com/app/pink-flag/[app-id]
```

---

## 📊 Post-Release Monitoring

### Week 1 After Launch
- [ ] Check for crash reports in App Store Connect
- [ ] Monitor user reviews and respond professionally
- [ ] Track download numbers
- [ ] Verify backend is handling traffic
- [ ] Check API rate limits and costs

### Ongoing Maintenance
- [ ] Plan update schedule (bug fixes, new features)
- [ ] Monitor Apple Developer news (policy changes)
- [ ] Keep dependencies updated (Flutter, packages)
- [ ] Respond to user feedback
- [ ] Track backend API costs and optimize

---

## 🚨 Emergency Rollback Plan

**If Critical Bug Found After Release:**

**Option 1: Remove from Sale**
1. App Store Connect → My Apps → Pink Flag
2. Click "Remove from Sale"
3. Fix bug, submit new version
4. Return to sale when fixed

**Option 2: Update App Quickly**
1. Fix critical bug in code
2. Build new version (increment build number)
3. Upload to App Store Connect
4. Select "Expedited Review" option
5. Explain urgency in review notes

**Option 3: Server-Side Fix** (if backend issue)
1. Fix backend immediately
2. Deploy backend update
3. No app update needed if API contract unchanged

---

## 📝 Version 1.1 Planning

**After Successful 1.0 Launch, Consider:**

**Features:**
- [ ] Dark mode support
- [ ] Search history (local only)
- [ ] Favorites/bookmarks (local only)
- [ ] Map view for results
- [ ] Share results functionality
- [ ] Spanish language support

**Technical Improvements:**
- [ ] Add unit and integration tests
- [ ] Implement analytics (privacy-preserving)
- [ ] Optimize app size
- [ ] Improve offline functionality
- [ ] Add error tracking (Sentry)

**Marketing:**
- [ ] Create landing page
- [ ] Social media presence
- [ ] Blog about safety tips
- [ ] Partner with women's organizations

---

## ✅ Final Pre-Submission Checklist

**Before clicking "Submit for Review", verify:**

- [ ] ✅ App builds and runs without errors
- [ ] ✅ Tested on physical iOS devices (multiple models)
- [ ] ✅ All animations perform smoothly
- [ ] ✅ No console errors or warnings in release build
- [ ] ✅ Backend deployed and accessible via HTTPS
- [ ] ✅ API keys configured for production
- [ ] ✅ Privacy policy URL is live and accessible
- [ ] ✅ Terms of service URL is live (if applicable)
- [ ] ✅ App icons for all sizes created and added
- [ ] ✅ Screenshots uploaded (minimum 3 for iPhone 6.7")
- [ ] ✅ App description written and proofread
- [ ] ✅ Keywords researched and added
- [ ] ✅ Age rating set to 17+
- [ ] ✅ Pricing set to Free
- [ ] ✅ Countries/regions selected
- [ ] ✅ Privacy questionnaire completed accurately
- [ ] ✅ App validated in Xcode without errors
- [ ] ✅ Build uploaded to App Store Connect
- [ ] ✅ Build processed successfully
- [ ] ✅ Testing notes for reviewer written
- [ ] ✅ Contact information provided
- [ ] ✅ TestFlight beta testing completed (recommended)
- [ ] ✅ All stakeholder approvals obtained
- [ ] ✅ Marketing materials ready
- [ ] ✅ Support email/website ready for user questions

---

## 📞 Resources & Support

**Apple Official Documentation:**
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

**Flutter Resources:**
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Flutter Build Modes](https://docs.flutter.dev/testing/build-modes)

**Third-Party Tools:**
- [App Icon Generator](https://appicon.co/)
- [Screenshot Framer](https://screenshots.pro/)
- [Privacy Policy Generator](https://www.privacypolicygenerator.info/)

**Pink Flag Project:**
- [GitHub Repository](https://github.com/bobbyburns1989/redflag)
- [Developer Guide](./DEVELOPER_GUIDE.md)
- [Coding Guidelines](./CODING_GUIDELINES.md)

---

**Document Version**: 1.0
**Last Updated**: November 6, 2025
**Next Review**: After successful App Store submission
**Maintained by**: Pink Flag Development Team

---

**Good luck with your App Store submission! 🚀**

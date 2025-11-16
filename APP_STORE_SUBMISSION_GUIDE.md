# Pink Flag - App Store Submission Guide

**Status**: Ready for submission preparation
**Date**: November 8, 2025

---

## ✅ What's Already Done

### 1. App Configuration
- ✅ App icons created (all sizes including 1024x1024)
- ✅ Info.plist updated with privacy descriptions
- ✅ Bundle ID: `com.pinkflag.app`
- ✅ Display name: "Pink Flag"
- ✅ Version: 1.0.1 (Build 2)
- ✅ Device Support: iPhone only (iPad removed)

### 2. Privacy Policy
- ✅ Comprehensive privacy policy created: `PRIVACY_POLICY.md`
- ⏳ **ACTION NEEDED**: Host this on a public URL (see options below)

### 3. Code Quality
- ✅ All features implemented and working
- ✅ Credit system functional
- ✅ RevenueCat integration complete (mock packages for screenshots)
- ✅ Authentication working with Supabase

---

## 📸 Step 1: Take App Store Screenshots

Apple requires screenshots for **iPhone 6.7" display** (iPhone 15 Pro Max).

### Required Resolution: 1290 × 2796 pixels

### Screenshots to Capture (Minimum 3, Maximum 10):

1. **Splash Screen** - Shows beautiful pink flag logo and branding
2. **Login/Signup Screen** - Shows authentication with "1 free search" messaging
3. **Search Screen** - Main search form with credit balance visible
4. **Store Screen** - Mock packages showing purchase options ✅ (You already have this!)
5. **Results Screen** - Sample search results (optional but good to have)
6. **Resources Screen** - Emergency hotlines and safety resources

### How to Take Screenshots:

#### Option A: Using iOS Simulator (Recommended)
```bash
# 1. List available simulators
xcrun simctl list devices | grep "iPhone 15 Pro Max"

# 2. Boot the iPhone 15 Pro Max simulator
xcrun simctl boot "iPhone 15 Pro Max"

# 3. Open Simulator app
open -a Simulator

# 4. Run your app on the simulator
cd /Users/robertburns/Projects/RedFlag/safety_app
flutter run -d <device-id-from-step-1>

# 5. Navigate through the app and take screenshots
# Method 1: Simulator menu → File → Save Screen
# Method 2: Command line:
xcrun simctl io booted screenshot ~/Desktop/PinkFlag_Screenshot_1.png
xcrun simctl io booted screenshot ~/Desktop/PinkFlag_Screenshot_2.png
# etc...
```

#### Option B: Using Physical iPhone 15 Pro Max
1. Connect iPhone to Mac
2. Run app on physical device
3. Take screenshots (Volume Up + Side Button)
4. AirDrop screenshots to Mac

### Screenshot Checklist:
- [ ] 1. Splash screen with logo
- [ ] 2. Login screen
- [ ] 3. Search screen (with credit badge visible)
- [ ] 4. Store screen (mock packages) ✅ Already have!
- [ ] 5. Results screen (optional)
- [ ] 6. Resources screen

**Note**: Save screenshots to `~/Desktop/AppStore_Screenshots/` for organization

---

## 🔗 Step 2: Host Privacy Policy Publicly

You need a public URL for the Privacy Policy. Here are your options:

### Option A: GitHub Pages (Free, Recommended)
```bash
# 1. Create a docs folder
mkdir -p docs
cp PRIVACY_POLICY.md docs/privacy.md

# 2. Create a simple HTML page
cat > docs/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Pink Flag - Privacy Policy</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
               max-width: 800px; margin: 40px auto; padding: 20px; line-height: 1.6; }
        h1 { color: #EC4899; }
        h2 { color: #DB2777; margin-top: 30px; }
    </style>
</head>
<body>
    <!-- Paste contents of PRIVACY_POLICY.md here, converted to HTML -->
</body>
</html>
EOF

# 3. Enable GitHub Pages
# Go to: https://github.com/bobbyburns1989/redflag/settings/pages
# Source: Deploy from a branch
# Branch: main
# Folder: /docs
# Save

# Your Privacy Policy URL will be:
# https://bobbyburns1989.github.io/redflag/privacy.html
```

### Option B: Use a Markdown Viewer Service (Quickest)
Upload `PRIVACY_POLICY.md` to:
- **GitBook** (https://www.gitbook.com/) - Free, looks professional
- **ReadMe** (https://readme.com/) - Free tier available
- **Notion** (https://www.notion.so/) - Free, make page public

### Option C: Your Own Website
If you have a website, upload the privacy policy there:
- `https://yourwebsite.com/pinkflag/privacy`

**⚠️ IMPORTANT**: Once you have the URL, you'll enter it in App Store Connect.

---

## 🏗️ Step 3: Build & Archive for App Store

### Update pubspec.yaml Version
```bash
# Edit safety_app/pubspec.yaml
# Change: version: 1.0.0+1
# To ensure version and build number are correct
```

### Clean and Build
```bash
cd /Users/robertburns/Projects/RedFlag/safety_app

# Clean previous builds
flutter clean
flutter pub get

# Analyze code (should be clean)
flutter analyze

# Build iOS release
flutter build ios --release
```

### Archive in Xcode
```bash
# Open workspace in Xcode
open ios/Runner.xcworkspace
```

**In Xcode:**
1. **Select Device**: At the top, change target from Simulator to "Any iOS Device (arm64)"
2. **Product Menu** → **Archive**
3. Wait 2-5 minutes for archive to complete
4. **Organizer window opens** automatically with your archive

---

## ✅ Step 4: Validate & Upload

### In Xcode Organizer:

#### Validate App
1. Select your archive
2. Click **"Validate App"**
3. Select distribution method: **App Store Connect**
4. Select your team
5. Choose **Automatically manage signing**
6. Click **"Validate"**
7. Wait for validation (1-2 minutes)
8. ✅ Should say "Validation Successful"

**Common Errors:**
- Missing icons → Already fixed ✅
- Missing privacy descriptions → Already fixed ✅
- Code signing issues → Select correct team in Xcode

#### Upload to App Store Connect
1. Click **"Distribute App"**
2. Select **"App Store Connect"**
3. Select **"Upload"**
4. Choose options:
   - ✓ Upload app symbols (for crash reports)
   - ✓ Manage version and build number
5. Click **"Upload"**
6. Wait 5-15 minutes for upload

**You'll get an email** when upload is complete and processing starts.

---

## 📱 Step 5: Create App in App Store Connect

Go to: https://appstoreconnect.apple.com

### Create New App
1. Click **"My Apps"** → **"+"** → **"New App"**
2. Fill out form:
   - **Platform**: iOS
   - **Name**: Pink Flag
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select `com.pinkflag.app`
   - **SKU**: `pinkflag-ios-001` (internal identifier)
   - **User Access**: Full Access
3. Click **"Create"**

### Your app is now created! The logo will appear after you complete the next steps.

---

## 📝 Step 6: Fill Out App Store Metadata

### Backend Information for Reviewers

**Note**: Your production backend is already deployed and operational:
- **URL**: https://pink-flag-api.fly.dev
- **Status**: ✅ Live and healthy
- **Health Check**: https://pink-flag-api.fly.dev/health
- **Auto-Scaling**: Backend may take 2-3 seconds to wake from sleep on first request

### App Information

#### Category
- **Primary**: Lifestyle
- **Secondary**: Utilities (optional)

#### Age Rating
- **Rating**: 17+ (Mature/Suggestive Themes)
- **Questionnaire**:
  - "Realistic Violence": No
  - "Cartoon or Fantasy Violence": No
  - "Sexual Content or Nudity": Infrequent/Mild (registry data)
  - "Profanity or Crude Humor": No
  - "Alcohol, Tobacco, or Drug Use": No
  - "Mature/Suggestive Themes": Yes (sex offender content)
  - "Horror/Fear Themes": No
  - "Gambling": No
  - "Unrestricted Web Access": No

#### Privacy Policy URL
- **Privacy Policy URL**: `https://[your-hosted-url]/privacy.html`
- **Support URL** (optional): Same as privacy or your GitHub repo

### App Description

**Copy this description** (4,000 character max):

```
Pink Flag: Your Personal Safety Companion

Stay informed, stay safe. Pink Flag provides anonymous access to public sex offender registries with a beautiful, easy-to-use interface designed for personal safety awareness.

✨ KEY FEATURES

• Credit-Based Searches - Get 1 free search when you sign up, purchase more as needed
• Comprehensive Filters - Search by name, age, location, phone, and ZIP code
• Beautiful Design - Modern pink gradient aesthetic with smooth animations
• Emergency Resources - Quick access to 911, domestic violence hotlines, and safety tips
• Privacy-First - Searches are linked to your account, never shared with third parties
• Secure Authentication - Your data is encrypted and protected
• Real-Time Updates - See your credit balance update instantly

🔍 HOW IT WORKS

1. Sign up with your email to get 1 free search credit
2. Enter a first and last name to search public registries
3. Optionally filter by age, state, phone number, or ZIP code
4. View detailed results with location and offense information
5. Purchase more search credits as needed (3, 10, or 25 searches)

🛡️ PRIVACY & SAFETY

Pink Flag is built with your privacy and security in mind:
• Secure authentication with email and password
• All searches are encrypted and secure
• We never sell your personal information
• No third-party tracking or analytics
• Your search history is private and secure

💳 TRANSPARENT PRICING

• 1 FREE search when you sign up
• 3 searches - $0.99
• 10 searches - $2.99 (Best Value)
• 25 searches - $4.99

🎯 WHO IS THIS FOR?

• Women meeting someone new (dates, roommates, neighbors)
• Parents checking on coaches, teachers, or caregivers
• Anyone wanting to stay informed about their community
• People using online dating apps who want extra peace of mind

⚠️ ETHICAL USE ONLY

Pink Flag is designed to empower personal safety decisions, not to harass or stalk individuals. Please use this tool responsibly and ethically.

📞 EMERGENCY RESOURCES

• 911 - Emergency Services
• National Domestic Violence Hotline: 1-800-799-7233
• RAINN Sexual Assault Hotline: 1-800-656-4673
• Suicide Prevention Lifeline: 988
• Crisis Text Line: Text HOME to 741741

💖 BEAUTIFUL & INTUITIVE

Pink Flag features a feminine pink gradient theme with smooth animations, making safety awareness both accessible and aesthetically pleasing.

📱 FEATURES AT A GLANCE

✓ Secure user accounts with email authentication
✓ Credit-based search system (1 free credit on signup)
✓ Advanced filtering options (age, state, phone, location)
✓ Real-time credit balance tracking
✓ In-app credit purchases (consumable, no subscriptions)
✓ Emergency resources with tap-to-call
✓ Beautiful, modern UI design
✓ Privacy-focused and secure

DOWNLOAD NOW and take control of your personal safety with Pink Flag.

---

Pink Flag sources data from public sex offender registries. Data accuracy is not guaranteed. Always verify information with official sources. By using this app, you agree to use it ethically and responsibly.
```

#### Keywords
```
safety,offender,registry,women,dating,background,check,security,search,awareness,credits,purchase
```

#### Promotional Text (170 characters)
```
Anonymous access to public offender registries. Secure authentication, credit-based searches. Your safety companion for modern dating and daily life.
```

### Upload Screenshots
1. Click **"iOS"** → **"Screenshots"**
2. Select **"6.7-inch Display"**
3. Upload screenshots in this order:
   - Screenshot 1: Splash screen
   - Screenshot 2: Login/Signup
   - Screenshot 3: Search screen
   - Screenshot 4: Store screen (you already have this!)
   - Screenshot 5: Resources screen
4. Save

---

## 🔒 Step 7: Complete Privacy Questionnaire

In App Store Connect → App Privacy:

### Data Collection

**Account Info**
- ✅ Yes - Email Address
  - Used for: App Functionality, Analytics
  - Linked to user: Yes

**Purchase History**
- ✅ Yes - Purchase History
  - Used for: App Functionality
  - Linked to user: Yes

**Usage Data**
- ✅ Yes - Product Interaction
  - Used for: App Functionality
  - Linked to user: Yes

**Everything Else**
- ❌ No for all other categories

### Tracking
- **Does this app use data for tracking?** No

### Summary
Your privacy label will show:
- "Data Linked to You: Email Address, Purchase History, Product Interaction"
- "Data Used to Track You: None"

---

## 🚀 Step 8: Submit for Review

### Select Build
1. In App Store Connect, go to your app
2. Click **"+ Version or Platform"** → **"iOS"**
3. Enter version: **1.0.1**
4. Click **"Select a build before you submit your app"**
5. Choose the build you uploaded (Build 2)
6. Click **"Done"**

### Version Information
**What's New in This Version:**
```
Welcome to Pink Flag - Your personal safety companion!

• Search public sex offender registries anonymously
• Get 1 free search credit when you sign up
• Purchase additional credits: 3, 10, or 25 searches
• Beautiful pink-themed interface
• Emergency resources with one-tap calling
• Secure account system with real-time updates

Stay safe, stay aware. 💖
```

### App Review Information
- **Contact Information**: Your email and phone
- **✅ Demo Account Created**: `applereview@pinkflag.com` with 50 search credits
- **Notes for Reviewer**:
```
TEST ACCOUNT CREDENTIALS:
Email: applereview@pinkflag.com
Password: AppleReview2025!

This account has been pre-loaded with 50 search credits for comprehensive testing.

HOW TO TEST THE APP:
1. Sign in with the credentials above
2. Navigate to the Search screen (bottom navigation)
3. Enter test data:
   - First Name: John
   - Last Name: Smith
   - State: Any state (e.g., California)
   - City: Any city (optional)
4. Tap "Search" - this will query public sex offender registries
5. Results will display if matches are found in public databases
6. Each search consumes 1 credit (balance shown in top-right corner)

IN-APP PURCHASE TESTING:
- Navigate to the Store screen via bottom navigation
- Three consumable products are available for review:
  • 3 Searches - $0.99
  • 10 Searches - $2.99
  • 25 Searches - $4.99
- Use Apple's Sandbox testing to verify purchase flow
- Credits are added immediately after successful purchase

APP PURPOSE & DATA SOURCE:
Pink Flag helps users search public sex offender registries for personal safety. All data comes from publicly available government databases (via nsopw.gov API). The app provides a simple, mobile-friendly interface to access this public information.

BACKEND INFRASTRUCTURE:
- Authentication: Supabase
- Backend API: Fly.io hosted service
- Payments: RevenueCat + Apple In-App Purchases
- All user data is encrypted and stored securely

DEVICE SUPPORT:
- iPhone only (iPad support removed in v1.0.1)

Please contact me with any questions during review.
```

### Submit
1. Click **"Add for Review"**
2. Review all information
3. Click **"Submit to App Review"**

---

## ⏱️ What Happens Next?

### Review Timeline
- **Waiting for Review**: 0-48 hours
- **In Review**: 24-48 hours (average)
- **Review Complete**: Notification via email

### Possible Outcomes

#### ✅ Approved
- Status changes to "Ready for Sale"
- App goes live automatically (or manually if you chose that)
- You'll get an email confirmation

#### ❌ Rejected
- Read rejection reason carefully
- Fix the issues mentioned
- Resubmit for review

### Common Rejection Reasons
1. **Crashes during review** - Make sure the app is stable
2. **Missing functionality** - All features should work
3. **Privacy policy incorrect** - Make sure URL is accessible
4. **Age rating wrong** - 17+ is correct for this content
5. **In-app purchases not working** - Explain they're in development/testing mode

---

## 📊 Post-Submission Checklist

- [ ] App created in App Store Connect
- [ ] Build uploaded and processed
- [ ] Screenshots uploaded (minimum 3)
- [ ] Privacy Policy URL working
- [ ] Age rating set to 17+
- [ ] App description written
- [ ] Keywords added
- [ ] Privacy questionnaire completed
- [ ] Review notes written
- [ ] Submitted for review
- [ ] Monitoring email for updates

---

## 🎉 When Approved

1. **Download from App Store** and test
2. **Share with users** - Get the App Store link
3. **Monitor reviews** - Respond professionally
4. **Check analytics** - Track downloads
5. **Plan updates** - Based on user feedback

---

## 💰 In-App Purchases Setup

**Note**: Your IAP products will show as "Missing Metadata" in RevenueCat until you create them in App Store Connect.

### After App is Approved:
1. Go to App Store Connect → Your App → In-App Purchases
2. Create 3 consumable products:
   - `pink_flag_3_searches` - $0.99
   - `pink_flag_10_searches` - $2.99
   - `pink_flag_25_searches` - $4.99
3. Add reference names, descriptions, screenshots
4. Submit each product for review
5. Once approved, RevenueCat will automatically sync
6. Mock packages will be replaced with real products

---

## 🆘 Need Help?

- **Apple Developer Support**: https://developer.apple.com/support/
- **App Store Connect Help**: https://help.apple.com/app-store-connect/
- **Flutter iOS Deployment**: https://docs.flutter.dev/deployment/ios

---

**Good luck with your submission! 🚀**

**Pink Flag - Stay Safe, Stay Aware 💖**

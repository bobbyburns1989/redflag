# App Store Archive Steps - Pink Flag v1.0.0

**Date:** November 10, 2025
**Version:** 1.0.0 (Build 1)
**Status:** ✅ Ready for Archive

---

## ✅ Pre-Archive Checklist (COMPLETED)

- ✅ Production refactoring complete (126+ print statements wrapped in kDebugMode)
- ✅ Deprecated APIs fixed (withOpacity → withValues)
- ✅ Unused imports removed
- ✅ Flutter dependencies updated (flutter pub get)
- ✅ CocoaPods dependencies installed (pod install)
- ✅ iOS build successful (flutter build ios --release)
- ✅ Xcode workspace opened

---

## 📱 Xcode Archive Steps

Xcode should now be open with your project. Follow these steps:

### Step 1: Select Target Device
1. In Xcode toolbar (top), select target: **Any iOS Device (arm64)**
   - Click the device selector dropdown
   - Choose "Any iOS Device (arm64)" or "Generic iOS Device"
   - Do NOT select a simulator

### Step 2: Archive the Build
1. Go to: **Product** → **Archive** (or press ⌘⇧B then ⌘⇧Return)
2. Wait for archive to complete (may take 1-3 minutes)
3. The Organizer window will appear automatically

### Step 3: Validate the Archive (Recommended)
1. In the Organizer window, select your archive
2. Click **Validate App** button (blue)
3. Follow the validation wizard:
   - Choose your distribution certificate
   - Choose "Automatically manage signing"
   - Review and click **Validate**
4. Wait for validation to complete
5. If validation succeeds, proceed to Step 4
6. If validation fails, review errors and fix before continuing

### Step 4: Distribute to App Store
1. Click **Distribute App** button (blue)
2. Select: **App Store Connect**
3. Click **Next**
4. Select: **Upload**
5. Click **Next**
6. Choose distribution options:
   - ✅ Strip Swift symbols
   - ✅ Upload your app's symbols
   - ✅ Manage Version and Build Number (optional)
7. Click **Next**
8. Choose signing:
   - Select **Automatically manage signing** (recommended)
9. Click **Next**
10. Review summary and click **Upload**
11. Wait for upload to complete (may take 5-10 minutes)

### Step 5: Success!
Once upload completes:
- ✅ You'll see a success message
- ✅ Your build will appear in App Store Connect within 5-30 minutes
- ✅ You'll receive an email from Apple when processing completes

---

## 🔍 App Store Connect - Post-Upload

After upload completes, go to [App Store Connect](https://appstoreconnect.apple.com):

1. **Navigate to your app:**
   - My Apps → Pink Flag

2. **Select build for release:**
   - Click on version (1.0.0)
   - Scroll to "Build" section
   - Click "+ Build" or the existing build number
   - Select the build you just uploaded (1.0.0 build 1)

3. **Complete App Information:**
   - App Description
   - Keywords
   - Screenshots (iPhone, iPad if supported)
   - App Previews (optional)
   - Privacy Policy URL: `https://customapps.us/pinkflag/privacy`
   - Terms of Service URL: `https://customapps.us/pinkflag/terms`
   - Support URL
   - Marketing URL (optional)
   - App Category: Lifestyle / Utilities
   - Age Rating: 17+ (contains references to sensitive topics)

4. **App Privacy:**
   - Answer privacy questionnaire
   - Based on your app:
     - ✅ Collects user email (authentication)
     - ✅ Collects search queries
     - ✅ Collects purchase history
     - ❌ Does NOT collect location
     - ❌ Does NOT collect photos/videos
     - ❌ Does NOT share data with third parties

5. **Pricing and Availability:**
   - Select territories (US, etc.)
   - Set price: Free (with in-app purchases)

6. **In-App Purchases:**
   - Verify your 3 consumable products are configured:
     - pink_flag_3_searches ($1.99)
     - pink_flag_10_searches ($4.99)
     - pink_flag_25_searches ($9.99)

7. **Submit for Review:**
   - Review all sections (green checkmarks)
   - Click **Submit for Review**
   - Answer app review questions if prompted

---

## 📋 Build Information

**App Details:**
- **App Name:** Pink Flag
- **Bundle ID:** com.pinkflag.app (✅ matches App Store Connect)
- **Version:** 1.0.0
- **Build Number:** 1
- **Deployment Target:** iOS 13.0+
- **Supported Devices:** iPhone, iPad

**Configuration:**
- ✅ RevenueCat configured (Apple API Key)
- ✅ Supabase backend connected
- ✅ In-app purchases configured
- ✅ Privacy Policy hosted
- ✅ Terms of Service hosted

**Features:**
- User authentication (email/password)
- Sex offender registry search
- In-app credit purchases
- Emergency resources
- Account management (GDPR compliant)

---

## ⚠️ Common Issues and Solutions

### Issue: "Signing for Runner requires a development team"
**Solution:**
1. In Xcode, select **Runner** project (top left)
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Ensure "Automatically manage signing" is checked
5. Select your Team from dropdown

### Issue: "No signing certificate found"
**Solution:**
1. Go to Xcode → Settings → Accounts
2. Select your Apple ID
3. Click **Manage Certificates**
4. Click **+** → **Apple Distribution**
5. Close and try archiving again

### Issue: "Bundle identifier has already been used"
**Solution:**
- Your Bundle ID is correct: `com.pinkflag.app`
- This matches what's registered in App Store Connect (PinkFlag - com.pinkflag.app)
- ✅ This has been fixed - Bundle ID now matches App Store Connect

### Issue: "Build failed - Swift compilation error"
**Solution:**
1. In Xcode: Product → Clean Build Folder (⌘⇧K)
2. Close Xcode
3. Run: `flutter clean && flutter pub get && cd ios && pod install`
4. Reopen Xcode and try again

### Issue: "Missing compliance information"
**Solution:**
- After upload, you may need to answer export compliance questions
- For Pink Flag: Does NOT use encryption beyond HTTPS (answer "No")

---

## 📞 Support

If you encounter issues:
1. Check Xcode organizer logs (Window → Organizer)
2. Review Apple's email for specific feedback
3. Visit [App Store Connect Help](https://developer.apple.com/support/app-store-connect/)

---

## 🎉 Next Steps After Approval

Once approved by Apple:
1. App will be live on App Store
2. Users can download and purchase credits
3. RevenueCat webhook will handle purchase processing
4. Monitor analytics in App Store Connect
5. Respond to user reviews
6. Plan v1.1 features (see PLANNED_FEATURES.md)

---

**Good luck with your App Store submission! 🚀**

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

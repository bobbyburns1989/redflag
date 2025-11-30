# Apple App Store Submission - v1.1.1 (Build 7)

**Date**: November 18, 2025
**Version**: 1.1.1
**Build**: 7
**Previous Rejection**: Guideline 5.1.1 - Data Collection and Storage

---

## 🚨 CRITICAL CHANGES IN v1.1.1

### What Was Removed (Addressing Apple's Concern):
1. ✅ **Search History Feature** - Completely removed from codebase
2. ✅ **Hive Local Storage** - Removed dependency entirely
3. ✅ **All Data Persistence** - No search data stored anywhere (local or remote)

### Files Deleted:
- `lib/services/search_history_service.dart`
- `lib/models/search_history_entry.dart`
- `lib/screens/search_history_screen.dart`
- `lib/screens/search_history_detail_screen.dart`
- All Hive dependencies removed from `pubspec.yaml`

### Files Modified:
- `lib/main.dart` - Removed Hive initialization
- `lib/screens/search_screen.dart` - Removed search saving logic
- `lib/screens/settings_screen.dart` - Removed "Search History" menu item
- `lib/screens/onboarding_screen.dart` - Updated privacy messaging
- `assets/legal/privacy_policy.txt` - Clarified no search storage

---

## 📝 UPDATED APP DESCRIPTION

**Copy this into App Store Connect:**

```
Pink Flag – Women's Safety Search Tool

Stay informed and make safer decisions by searching public sex offender registries when meeting new people, hiring service providers, or considering a move to a new area.

HOW IT WORKS:
• Search by name, city, or state
• View results from official government registries
• Access built-in emergency resources and hotlines

CREDIT-BASED SEARCH:
Purchase credits to run registry searches. Available packages:
• 3 searches – $1.99
• 10 searches – $4.99 (Best Value)
• 25 searches – $9.99

PRIVACY-FIRST DESIGN:
• Searches query official public government databases only
• Results come directly from those sources and are displayed temporarily
• No search history stored – searches are completely private and ephemeral
• No location tracking
• No profile building or data aggregation
• No data collection about searched individuals
• Your searches remain completely anonymous

EMERGENCY RESOURCES:
• Quick access to national safety hotlines
• National Domestic Violence Hotline
• RAINN Sexual Assault Hotline
• Crisis Text Line
• Built-in emergency calling

Pink Flag is a privacy-focused search tool for public information that does not store, collect, or build profiles. Results are displayed temporarily and never saved, ensuring complete privacy and compliance with data protection guidelines.
```

---

## 💬 REVIEWER NOTES

**Copy this into the "Notes" field in App Store Connect:**

```
Thank you for your review of submission 17008210-0396-4953-ba1b-d16471112c8c.

RE: Guideline 5.1.1 - Data Collection and Storage

We have addressed your concern by completely removing the search history feature from the app. Version 1.1.1 includes the following changes:

WHAT WAS REMOVED:
• Search history feature - completely removed from codebase
• Local storage (Hive) - dependency removed entirely
• All search data persistence - nothing is stored locally or remotely

HOW THE APP NOW WORKS:
1. User enters search criteria
2. App queries public government sex offender registries via API
3. Results are displayed temporarily on screen
4. When user navigates away, results disappear
5. No search data is saved anywhere

WHAT WE STORE:
• User account (email, hashed password) - for authentication only
• Search credit balance - for in-app purchase tracking only

WHAT WE DO NOT STORE:
• Search queries or search history
• Search results or offender data
• Any information about searched individuals
• No profile building or data aggregation of any kind

The app now functions as a completely ephemeral search tool. Results are displayed temporarily and immediately discarded when the user navigates away. We have updated our app description and privacy policy to reflect this change.

We believe this addresses the concerns raised in your review. The app no longer collects or stores any information that could be used to build individual profiles.

Thank you for your time and consideration.
```

---

## 🔍 WHAT'S NEW IN THIS VERSION

**For "What's New" field:**

```
Version 1.1.1 - Privacy Update

• Removed search history feature for enhanced privacy
• Searches are now completely ephemeral and not saved
• Results displayed temporarily only
• Updated privacy policy to reflect changes
• Improved app performance and stability
```

---

## ✅ PRE-SUBMISSION CHECKLIST

Before pressing Archive in Xcode:

- [x] Version bumped to 1.1.1
- [x] Build number bumped to 7
- [x] Flutter clean completed
- [x] Dependencies installed (flutter pub get)
- [x] iOS pods installed
- [x] iOS release build completed (76.4MB)
- [x] Xcode workspace opened
- [ ] **In Xcode**: Select "Any iOS Device (arm64)" as target
- [ ] **In Xcode**: Product → Archive
- [ ] **In Xcode**: Distribute App → App Store Connect
- [ ] **App Store Connect**: Update app description (see above)
- [ ] **App Store Connect**: Update "What's New" (see above)
- [ ] **App Store Connect**: Add reviewer notes (see above)
- [ ] **App Store Connect**: Submit for review

---

## 🎯 KEY POINTS FOR APPLE REVIEW

1. **No Search History**: Completely removed from codebase
2. **Ephemeral Results**: Displayed temporarily, then discarded
3. **No Data Collection**: We don't store searched individuals' information
4. **No Profile Building**: We query existing public databases, don't aggregate
5. **Privacy-First**: Updated description explicitly states this

---

## 📊 TECHNICAL DETAILS

**Bundle ID**: com.pinkflag.app
**Version**: 1.1.1
**Build**: 7
**iOS Target**: 12.0+
**Device Support**: iPhone only (iPad removed)
**Size**: 76.4MB

**Dependencies Removed**:
- hive: ^2.2.3
- hive_flutter: ^1.1.0
- uuid: ^4.1.0
- hive_generator: ^2.0.1
- build_runner: ^2.4.6

---

## 📱 TESTING COMPLETED

- ✅ App compiles without errors
- ✅ No search history menu in Settings
- ✅ Searches display results temporarily
- ✅ Results disappear when navigating away
- ✅ No local storage of search data
- ✅ In-app purchases work correctly
- ✅ All other features functional

---

## 🚀 NEXT STEPS

1. **In Xcode** (which is now open):
   - Select "Any iOS Device (arm64)" from the device dropdown
   - Go to Product → Archive
   - Wait for archive to complete
   - Organizer window will open automatically

2. **In Organizer**:
   - Select your archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Follow the prompts to upload

3. **In App Store Connect**:
   - Go to your app
   - Click on "1.1.1" version
   - Update the description (copy from above)
   - Update "What's New" (copy from above)
   - Add reviewer notes (copy from above)
   - Submit for review

---

## 📞 IF APPLE STILL REJECTS

If Apple continues to reject despite these changes, you have these options:

### Option 1: Request Phone Call
Apple offered a phone call to discuss. Use this to explain:
- Sex offender registries are legally mandated public databases
- App doesn't collect or aggregate data
- Similar to a browser accessing public websites
- Legitimate safety purpose

### Option 2: Appeal
Write a detailed appeal explaining the legal framework (Megan's Law) that requires these registries to be public.

### Option 3: Pivot the App
Change the core functionality to something Apple will approve (general safety resources without search).

---

## 🎉 READY TO SUBMIT!

Everything is prepared. All you need to do is:
1. Press Archive in Xcode (which is now open)
2. Upload to App Store Connect
3. Update the description and notes
4. Submit for review

Good luck! 🍀

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

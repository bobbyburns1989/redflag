# Release Notes - v1.1.9 (Build 15)

**Release Date**: November 30, 2025
**Type**: **CRITICAL BUG FIX**
**Status**: Ready for Archive

---

## 🚨 Critical Fix

This release fixes a **production-breaking bug** where all searches were failing with "unexpected error occurred" after the security implementation was deployed.

---

## 🐛 Bug Fixes

### **Authentication Failures (CRITICAL)**
- **Fixed**: Name search failing due to missing JWT token
- **Fixed**: Image search failing due to missing JWT token
- **Fixed**: Phone search database errors
- **Fixed**: Account deletion using wrong table name

### **Root Cause**
Backend was deployed with JWT authentication middleware, but the Flutter app wasn't sending the required Authorization headers.

---

## ✅ What Was Fixed

### **1. Name Search (api_service.dart)**
```dart
// Before (BROKEN)
headers: {'Content-Type': 'application/json'}

// After (FIXED)
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer ${session.accessToken}',
}
```

### **2. Image Search (image_search_service.dart)**
- Added JWT token to multipart image upload requests
- Added JWT token to URL-based image search requests

### **3. Phone Search**
- Already had JWT token (no changes)

### **4. Account Deletion**
- Fixed Edge Function to use `profiles` table instead of `users`
- Redeployed to Supabase

### **5. Credit System**
- Created `CREDIT_DEDUCTION_SCHEMA_FIX.sql` to fix database errors
- Updated RPC functions to use `profiles` table

---

## 📋 Pre-Archive Checklist

### ✅ **Completed**
- [x] Code changes committed and pushed
- [x] Version bumped to 1.1.9+15
- [x] Flutter clean completed
- [x] Pub get completed
- [x] Pod install completed
- [x] Xcode workspace opened

### ⏳ **Before Archive**
- [ ] **CRITICAL**: Run `CREDIT_DEDUCTION_SCHEMA_FIX.sql` in Supabase (see below)
- [ ] Select "Any iOS Device (arm64)" in Xcode
- [ ] Product → Archive
- [ ] Distribute to App Store

---

## 🔧 CRITICAL: Supabase SQL Fix

**YOU MUST RUN THIS BEFORE ARCHIVING!**

1. Open https://app.supabase.com
2. Select your Pink Flag project
3. Click **SQL Editor** → **New Query**
4. Open `schemas/CREDIT_DEDUCTION_SCHEMA_FIX.sql` in your code editor
5. Copy the entire file contents
6. Paste into Supabase SQL Editor
7. Click **Run** (or Cmd+Enter)
8. Wait for "Success. No rows returned"

**This fixes**: "Failed to deduct credit: database_error" when searching

---

## 📱 Archive Instructions

**Xcode is now open and ready!**

### **Steps to Archive**:

1. **Select Device**:
   - Top left in Xcode: Click device selector
   - Choose **"Any iOS Device (arm64)"**

2. **Archive**:
   - Menu: **Product** → **Archive**
   - Wait 5-10 minutes for build to complete
   - Xcode Organizer will open automatically

3. **Distribute**:
   - Click **Distribute App**
   - Choose **App Store Connect**
   - Click **Upload**
   - Follow prompts (should auto-select defaults)

4. **Submit for Review**:
   - Go to https://appstoreconnect.apple.com
   - Select Pink Flag
   - Click on version 1.1.9
   - Add these release notes (see below)
   - Click **Submit for Review**

---

## 📝 App Store Release Notes

**Copy this for App Store submission**:

```
Critical Bug Fix (v1.1.9)

Fixed Issues:
• Fixed search functionality not working after recent update
• Improved API authentication and security
• Enhanced account deletion feature for Apple Sign-In users
• Fixed credit system database errors

This update resolves issues where searches were failing with unexpected errors. We apologize for any inconvenience.
```

---

## 🧪 Testing After Deployment

Once live in production, test:

1. **Name Search**:
   - Search "John Doe"
   - Verify results appear
   - Verify credit is deducted

2. **Image Search**:
   - Upload a photo
   - Verify results appear
   - Verify credit is deducted

3. **Phone Search**:
   - Search a phone number
   - Verify results appear
   - Verify credit is deducted

4. **Account Deletion** (optional):
   - Go to Settings → Delete Account
   - Verify Apple Sign-In prompt appears for Apple users
   - (Don't actually delete unless using test account)

---

## 📊 Changes Summary

**Files Changed**: 5
- `safety_app/lib/services/api_service.dart` - Added JWT auth
- `safety_app/lib/services/image_search_service.dart` - Added JWT auth
- `supabase/functions/delete-account/index.ts` - Fixed table name
- `schemas/CREDIT_DEDUCTION_SCHEMA_FIX.sql` - Fixed DB schema (NEW)
- `safety_app/pubspec.yaml` - Version bump

**Commits**: 3
- `fix(critical): Add JWT authentication to API requests` (eb0ec36)
- `feat: Add account deletion for Apple Sign-In users` (e887278)
- `chore: Bump version to 1.1.9+15` (fe593fb)

**Branch**: `refactor/search-screen-widgets`

---

## ⏰ Timeline Estimate

- **Archive in Xcode**: 10 minutes
- **Upload to App Store Connect**: 15 minutes
- **App Store Processing**: 30-60 minutes
- **Review Approval**: 1-2 days (expedited review possible)

**Total**: App can be live in 1-2 days

---

## 🎯 Next Steps

### **NOW**:
1. ✅ Run SQL fix in Supabase (5 minutes) - **DO THIS FIRST!**
2. ✅ Archive in Xcode (already open)
3. ✅ Upload to App Store Connect

### **AFTER SUBMISSION**:
1. Monitor App Store Connect for review status
2. Test in TestFlight once approved
3. Release to production when confident

### **OPTIONAL**:
1. Request expedited review if needed (explain critical bug fix)
2. Add release notes to GitHub
3. Notify users via social media/email

---

## 🆘 Troubleshooting

### **Archive Fails**
- Clean build folder: Product → Clean Build Folder (Shift+Cmd+K)
- Retry archive

### **Upload Fails**
- Check App Store Connect account is active
- Verify certificates/provisioning profiles are valid
- Try "Validate App" first before "Distribute App"

### **SQL Fix Fails**
- Copy error message
- Check that `profiles` table exists in Supabase
- Verify you're running in the correct project

---

## 📞 Support

If you encounter issues:
- Check Xcode logs for specific errors
- Verify Supabase SQL was run successfully
- Test searches in simulator/TestFlight before production

---

**Release Prepared By**: Claude Code
**Build Status**: ✅ **READY TO ARCHIVE**
**Critical Fix**: ✅ **DEPLOYED TO CODE**
**Database Fix**: ⏳ **PENDING (Run SQL in Supabase)**

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

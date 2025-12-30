# Release Notes - Pink Flag v1.2.6

**Release Date**: December 26, 2025
**Build Number**: 29
**Type**: Critical Bug Fix - Apple Sign-In
**Status**: Ready for App Store Submission

---

## 🚨 CRITICAL BUG FIX

### Apple Sign-In Database Error (App Store Rejection)

**Issue Resolved**: Users could not create accounts when using Apple Sign-In with "Hide My Email" option

**Error Message (Before Fix)**:
```
{"code":"unexpected_failure","message":"Database error saving new user"}
```

**Root Cause**:
- Database schema had `NOT NULL` constraint on email field
- Apple Sign-In returns `NULL` when users choose "Hide My Email" (privacy feature)
- Database rejected profile creation with NULL email

**Impact**:
- ❌ Blocked ALL new user registrations
- ❌ App was completely unusable for new downloads
- ❌ Caused App Store rejection on Dec 23, 2025

---

## ✅ WHAT'S FIXED

### 1. Database Schema Update (Critical)

**Changes Applied**:
```sql
-- Made email column nullable (supports "Hide My Email")
ALTER TABLE profiles ALTER COLUMN email DROP NOT NULL;

-- Updated default credits from 1 to 10 (matches UI promise)
ALTER TABLE profiles ALTER COLUMN credits SET DEFAULT 10;

-- Updated trigger to handle NULL emails gracefully
CREATE OR REPLACE FUNCTION handle_new_user() ...
```

**Benefits**:
- ✅ Apple Sign-In now works with "Hide My Email" option
- ✅ Apple Sign-In works with "Share My Email" option
- ✅ Supports Apple's privacy-first approach
- ✅ Aligns with App Store review guidelines
- ✅ New users correctly receive 10 credits (not 1)

---

### 2. Privacy Improvements

**Before v1.2.6**:
- Required email address for account creation
- Failed when users chose "Hide My Email"
- Discouraged privacy-conscious users

**After v1.2.6**:
- ✅ Fully supports Apple's "Hide My Email" privacy feature
- ✅ Users can sign up without revealing real email
- ✅ Respects user privacy choices
- ✅ Better alignment with Apple's privacy guidelines

---

## 📋 TECHNICAL DETAILS

### Files Modified

**Database**:
- Applied: `schemas/URGENT_APPLE_SIGNIN_FIX.sql`
- Verified: `schemas/VERIFY_FIX.sql`

**Application**:
- `safety_app/pubspec.yaml` - Version 1.2.5+28 → 1.2.6+29
- `safety_app/lib/config/app_config.dart` - Updated version constants

**No Code Changes Required**:
- Apple Sign-In implementation was already correct
- Issue was database-only (schema constraint)
- All existing code continues to work

---

## 🧪 TESTING COMPLETED

### Device Testing

**iPhone 13 mini (iOS 26.2)**:
- ✅ Sign up with "Hide My Email" - Works
- ✅ Sign up with "Share My Email" - Works
- ✅ New users receive 10 credits correctly
- ✅ Login with existing account - Works

**iPad Air (5th gen) (iPadOS 26.2)**:
- ✅ Sign up with "Hide My Email" - Works
- ✅ Sign up with "Share My Email" - Works
- ✅ New users receive 10 credits correctly

**Database Verification**:
- ✅ Email column is nullable
- ✅ Default credits is 10
- ✅ Trigger handles NULL emails
- ✅ New profiles created successfully

---

## 📊 EXPECTED USER IMPACT

### Signup Experience

**Before v1.2.6 (Broken)**:
```
User taps "Sign in with Apple"
→ Chooses "Hide My Email" (default)
→ ❌ ERROR: "Database error saving new user"
→ Cannot create account
```

**After v1.2.6 (Fixed)**:
```
User taps "Sign in with Apple"
→ Chooses "Hide My Email" OR "Share My Email"
→ ✅ Account created successfully
→ ✅ Receives 10 free credits
→ ✅ Can use app immediately
```

### Business Impact

**Metrics Affected**:
- **New User Signups**: 0% → 100% (was completely broken)
- **Signup Success Rate**: Will increase to normal levels
- **Privacy-Conscious Users**: Can now sign up (previously blocked)
- **App Store Approval**: Should pass review this time

---

## 🔒 SECURITY & PRIVACY

### Privacy Enhancements

**Apple "Hide My Email"**:
- Users can sign up anonymously
- No real email required
- Apple provides relay email if needed (e.g., xyz@privaterelay.appleid.com)
- Full support for Apple's privacy features

**Data Storage**:
- Email may be NULL (for hidden emails)
- Email may be relay address (for shared emails)
- No change to existing privacy policy
- All user data remains private and secure

---

## 📱 APP STORE SUBMISSION

### Submission Notes for Apple

**What Changed**:
- Fixed database constraint that blocked Apple Sign-In
- Database now supports "Hide My Email" privacy feature
- No code changes required (database-only fix)

**Testing Completed**:
- ✅ Tested on iPhone 13 mini (iOS 26.2)
- ✅ Tested on iPad Air (5th gen) (iPadOS 26.2)
- ✅ Both "Hide My Email" and "Share My Email" work
- ✅ New users receive 10 credits as promised

**Review Timeline**:
- Previous rejection: Dec 23, 2025
- Fix applied: Dec 26, 2025
- Resubmission: Dec 26, 2025
- Expected approval: Dec 27-29, 2025

---

## 📝 WHAT'S NEW (User-Facing)

### App Store "What's New" Text

```
v1.2.6 - Critical Bug Fix

• Fixed Apple Sign-In for enhanced privacy
• Now supports "Hide My Email" option
• Improved signup experience
• All users receive 10 free credits on signup

Bug fixes and performance improvements.
```

---

## 🔍 RELATED DOCUMENTATION

### Created for This Release

1. **`schemas/URGENT_APPLE_SIGNIN_FIX.sql`**
   - Database migration to fix the issue
   - Makes email nullable, updates default credits

2. **`schemas/VERIFY_FIX.sql`**
   - Verification script to confirm fix applied
   - 7 checks for database integrity

3. **`APP_STORE_REJECTION_FIX_PLAN.md`**
   - Complete analysis of rejection
   - Fix plan, testing plan, rollback plan
   - Review notes for Apple

### Previous Releases

- **v1.2.5**: Pricing clarity update (metadata only)
- **v1.2.4**: Webhook credit amounts fix
- **v1.2.3**: Login UX improvements
- **v1.2.0**: Variable credit system

---

## ✅ SUCCESS CRITERIA

This release is successful when:

1. ✅ Apple reviewers can sign up with "Hide My Email"
2. ✅ Apple reviewers can sign up with "Share My Email"
3. ✅ New users receive 10 credits (not 1)
4. ✅ No "Database error" messages appear
5. ✅ App passes App Store review
6. ✅ App is approved and published

---

## 🆘 ROLLBACK PLAN

### If Critical Issues Arise

**Scenario**: Fix doesn't work in production

**Rollback Steps**:
```sql
-- Revert email to NOT NULL (NOT RECOMMENDED - breaks Hide My Email)
ALTER TABLE profiles ALTER COLUMN email SET NOT NULL;

-- Revert default credits to 1 (NOT RECOMMENDED - UI promises 10)
ALTER TABLE profiles ALTER COLUMN credits SET DEFAULT 1;
```

**NOTE**: Rollback is NOT recommended as it:
- Breaks Apple's "Hide My Email" feature
- Violates App Store guidelines
- Fails Apple review again

**Better Solution**: Debug and fix forward

---

## 📞 SUPPORT

### Common Questions

**Q: Why did this issue happen?**
A: Initial database schema was created before we fully tested Apple Sign-In's "Hide My Email" feature. The NOT NULL constraint was an oversight.

**Q: Will existing users be affected?**
A: No. This fix only affects NEW signups. Existing users can continue logging in normally.

**Q: What if users chose "Hide My Email" before the fix?**
A: Those signups failed completely. Once the fix is live, they can try again successfully.

**Q: Will this happen again?**
A: No. The database schema is now correct and will handle both privacy options going forward.

---

## 🎯 SUMMARY

**Version**: 1.2.6 (Build 29)
**Type**: Critical Bug Fix
**Impact**: Unblocks ALL new user registrations
**Risk Level**: Low (database-only change, thoroughly tested)
**User Impact**: High (enables app usage for new users)
**Privacy**: Enhanced (supports "Hide My Email")

**Status**: ✅ **READY FOR APP STORE SUBMISSION**

---

## 📅 TIMELINE

| Event | Date | Status |
|-------|------|--------|
| App Store Rejection | Dec 23, 2025 | ✅ Received |
| Root Cause Identified | Dec 26, 2025 | ✅ Complete |
| Database Fix Applied | Dec 26, 2025 | ✅ Complete |
| Testing Completed | Dec 26, 2025 | ✅ Complete |
| Version Bumped | Dec 26, 2025 | ✅ Complete |
| **Resubmission** | **Dec 26, 2025** | ⏳ **Ready** |
| Expected Approval | Dec 27-29, 2025 | ⏳ Pending |

---

**Last Updated**: December 26, 2025
**Next Milestone**: App Store approval (1-3 days)
**Priority**: 🔴 **CRITICAL - P0**

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

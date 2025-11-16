# Credits Issue - Fix Summary

**Date**: November 8, 2025
**Status**: ✅ Fixed - Ready to Test

---

## 🔍 Problem Identified

**RACE CONDITION**: App navigates to search screen before database trigger creates user profile.

### Timeline:
1. User signs up ✅
2. Auth user created ✅
3. App navigates to home ⚡ **TOO FAST**
4. SearchScreen queries for credits ❌ **Profile doesn't exist yet!**
5. Returns 0 credits ❌
6. Database trigger creates profile (100-500ms later) ⏰
7. Profile has 1 credit but UI already shows 0 ❌

---

## ✅ Fixes Implemented

### Fix #1: Wait for Profile Creation
**File**: `auth_service.dart`
**Lines**: 34-58

Added `_waitForProfile()` method that polls for profile existence after signup:
- Polls every 500ms for up to 5 seconds
- Returns as soon as profile exists
- Ensures profile is ready before navigation

### Fix #2: Retry Logic for Credit Loading
**File**: `auth_service.dart`
**Lines**: 94-119

Enhanced `getUserCredits()` with retry logic:
- Retries up to 3 times if profile not found
- Exponential backoff: 300ms, 600ms, 900ms
- Gracefully handles late-arriving profiles

---

## 🧪 Testing Required

### Step 1: Grant Current User 1 Credit
Run this SQL in Supabase Dashboard:

```sql
UPDATE public.profiles
SET credits = 1
WHERE email = 'bobbywburns@gmail.com';
```

**Expected**: Credit counter updates from 0 to 1 (via real-time subscription)

### Step 2: Test New Signup Flow
1. Factory reset simulator
2. Sign up with new email (e.g., `test_$(date +%s)@test.com`)
3. **Expected**: See 1 credit immediately (no flickering to 0)
4. Perform search
5. **Expected**: Credit deducts to 0

### Step 3: Test Login Flow
1. Log out
2. Log in with `bobbywburns@gmail.com`
3. **Expected**: See 1 credit immediately

---

## 📋 Files Changed

### `/Users/robertburns/Projects/RedFlag/safety_app/lib/services/auth_service.dart`

**Added Methods**:
- `_waitForProfile(String userId)` - Polls for profile creation
- Enhanced `getUserCredits()` with retry logic

**Modified Methods**:
- `signUp()` - Now waits for profile before returning

### Documentation Created:
- `/Users/robertburns/Projects/RedFlag/CREDITS_RACE_CONDITION_ANALYSIS.md` - Detailed analysis
- `/Users/robertburns/Projects/RedFlag/CREDITS_ISSUE_DIAGNOSIS.md` - Original diagnosis
- `/Users/robertburns/Projects/RedFlag/QUICK_FIX_CREDITS.sql` - SQL fix script

---

## 🎯 Next Steps

1. **Run SQL** to grant current user 1 credit (see Step 1 above)
2. **Hot reload app** to see updated credit count
3. **Test new signup** with fresh email
4. **Verify** credits work end-to-end

---

## 💡 How It Works Now

### New Signup Flow:
```
1. User signs up
2. Auth user created
3. ⏰ App waits for profile (polls every 500ms)
4. Profile created by trigger (has 1 credit)
5. ✅ Profile found!
6. App navigates to home
7. SearchScreen queries credits
8. ✅ Returns 1 credit (with retry if needed)
9. UI shows 1 credit ✅
```

### Fallback Protection:
- If profile takes longer than expected, retry logic ensures we eventually find it
- Real-time subscription updates UI when credits change
- No more 0-credit race condition!

---

## 🐛 Edge Cases Handled

1. **Slow database**: Waits up to 5 seconds for profile
2. **Network delays**: Retry logic with backoff
3. **Trigger failure**: Continues anyway, real-time subscription will update
4. **Multiple tabs**: Real-time updates work across sessions

---

## ✅ Success Criteria

- [x] Code changes implemented
- [ ] SQL run to grant current user credits
- [ ] Hot reload shows 1 credit
- [ ] New signup shows 1 credit immediately
- [ ] Login shows correct credits
- [ ] Search deducts credits properly

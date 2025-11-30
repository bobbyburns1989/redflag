# Signup Fix Plan
**Date**: November 8, 2025
**Priority**: CRITICAL - Users cannot sign up successfully

---

## 🔴 Critical Issues Identified

### Issue #1: Database Trigger Not Working
**Problem**: User profiles are NOT being created automatically when users sign up.

**Evidence**:
```
flutter: 🔍 [AUTH] Attempt 1/10 to find profile...
flutter: ⏳ [AUTH] Profile not found yet, waiting 500ms...
[...10 attempts...]
flutter: ⚠️ [AUTH] Profile still doesn't exist after 5 seconds - continuing anyway
```

**Root Cause**: The `on_auth_user_created` trigger either:
- Doesn't exist in Supabase database
- Is disabled
- Is failing silently
- Has wrong permissions

### Issue #2: Auth State Lost After Signup
**Problem**: User shows as `null` immediately after successful signup.

**Evidence**:
```
flutter: 🔐 [AUTH] Response user: 527fcbc2-f56e-4a2a-87ab-b3995e148a47
flutter: 🔐 [AUTH] Current user immediately after: null
flutter: 🔐 [AUTH] After waitForProfile - Current user: null
flutter: ⚠️ [AUTH] WARNING: Auth state lost after signup process!
```

**Root Cause**: Supabase auth session is not persisting. Possible causes:
- Supabase initialization issue
- Auth flow type misconfiguration
- Session storage issue
- Bug in Supabase Flutter SDK

---

## 📋 Fix Plan

### Phase 1: Fix Database Trigger (HIGHEST PRIORITY)

#### Step 1.1: Verify Trigger Exists in Supabase
**Action**: Run diagnostic query in Supabase SQL Editor

**SQL Query**:
```sql
-- Check if trigger exists
SELECT * FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- Check if function exists
SELECT * FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'handle_new_user';

-- Check if profiles table exists
SELECT * FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name = 'profiles';
```

**Expected Result**: Should return 3 rows (trigger, function, table)
**If 0 rows**: Trigger/function/table don't exist - proceed to Step 1.2

#### Step 1.2: Create Database Trigger
**Action**: Run `/Users/robertburns/Projects/RedFlag/DATABASE_TRIGGER_FIX.sql` in Supabase SQL Editor

**File Location**: `/Users/robertburns/Projects/RedFlag/DATABASE_TRIGGER_FIX.sql`

**What This Does**:
1. Creates `profiles` table with RLS policies
2. Creates `handle_new_user()` function that inserts profile with 1 credit
3. Creates `on_auth_user_created` trigger that fires after auth.users INSERT
4. Grants necessary permissions

#### Step 1.3: Test Trigger Manually
**Action**: Create a test user in Supabase Auth and verify profile is created

**SQL Query**:
```sql
-- Insert a test user (Supabase will handle password hashing)
-- Then check if profile was created

SELECT
    u.email as user_email,
    p.credits,
    p.created_at
FROM auth.users u
LEFT JOIN public.profiles p ON p.id = u.id
ORDER BY u.created_at DESC
LIMIT 5;
```

**Expected Result**: Should show profile with 1 credit for each user
**If profile is NULL**: Trigger is not working - check logs

#### Step 1.4: Grant Credits to Existing Users
**Action**: Fix users who signed up without profiles

**SQL Query**:
```sql
-- Grant 1 credit to all existing users without profiles
INSERT INTO public.profiles (id, email, credits, revenuecat_user_id)
SELECT
    id,
    email,
    1,  -- Grant 1 free credit
    id::TEXT
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.profiles)
ON CONFLICT (id) DO NOTHING;
```

---

### Phase 2: Fix Auth State Persistence

#### Step 2.1: Verify Supabase Initialization
**Action**: Check main.dart Supabase configuration

**File**: `/Users/robertburns/Projects/RedFlag/safety_app/lib/main.dart`

**Required Configuration**:
```dart
await Supabase.initialize(
  url: 'https://qjbtmrbbjivniveptdjl.supabase.co',
  anonKey: 'YOUR_ANON_KEY',
  authOptions: FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,  // ← REQUIRED
    autoRefreshToken: true,           // ← REQUIRED
  ),
);
```

#### Step 2.2: Add Auth State Listener
**Action**: Add global auth state listener to debug auth changes

**Code to Add** in `main.dart`:
```dart
// After Supabase initialization
Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  print('🔐 [MAIN] Auth state changed: ${data.event}');
  print('🔐 [MAIN] Session user: ${data.session?.user.id}');
  print('🔐 [MAIN] Current user: ${Supabase.instance.client.auth.currentUser?.id}');
});
```

#### Step 2.3: Force Session Refresh After Signup
**Action**: Add session refresh in auth_service.dart

**File**: `/Users/robertburns/Projects/RedFlag/safety_app/lib/services/auth_service.dart`

**Change in `signUp()` method**:
```dart
// After waitForProfile(), BEFORE RevenueCat init
await _waitForProfile(response.user!.id);

// NEW: Force refresh session to ensure auth state persists
try {
  final session = await _supabase.auth.refreshSession();
  print('🔐 [AUTH] Session refreshed: ${session.session?.user.id}');
} catch (e) {
  print('⚠️ [AUTH] Failed to refresh session: $e');
}

await RevenueCatService().initialize(response.user!.id);
```

#### Step 2.4: Alternative - Wait for Auth State
**Action**: Wait for auth state to propagate before continuing

**Alternative Code**:
```dart
// After signup response, wait for auth state to become available
await _waitForProfile(response.user!.id);

// NEW: Wait for currentUser to become non-null
int attempts = 0;
while (_supabase.auth.currentUser == null && attempts < 10) {
  print('⏳ [AUTH] Waiting for auth state... attempt ${attempts + 1}/10');
  await Future.delayed(const Duration(milliseconds: 300));
  attempts++;
}

if (_supabase.auth.currentUser == null) {
  print('❌ [AUTH] Auth state still null after waiting');
  return AuthResult.failed('Authentication failed. Please try logging in.');
}

await RevenueCatService().initialize(response.user!.id);
```

---

### Phase 3: Testing Plan

#### Test 1: Database Trigger Test
1. Factory reset simulator
2. Sign up with new test email (e.g., `triggertest@test.com`)
3. Check Supabase database for profile

**Expected Output**:
```
flutter: 🔍 [AUTH] Attempt 1/10 to find profile...
flutter: ✅ [AUTH] Profile found! Credits: 1
```

#### Test 2: Auth Persistence Test
1. Sign up with new email
2. Verify user stays authenticated through entire flow
3. Check that search screen shows 1 credit

**Expected Output**:
```
flutter: 🔐 [AUTH] Current user immediately after: [USER_ID]
flutter: 🔐 [AUTH] After waitForProfile - Current user: [USER_ID]
flutter: ✅ [AUTH] Signup complete - User authenticated: [USER_ID]
flutter: ✅ [SEARCH] Loaded credits: 1
```

#### Test 3: End-to-End Signup Flow
1. Factory reset simulator
2. Sign up with new email
3. Should see:
   - Success message: "You received 1 free search"
   - Navigate to search screen
   - See "1" in credit badge (top right)
   - Should NOT see any error messages

---

## 🎯 Implementation Steps (In Order)

### Step 1: Fix Database Trigger (DO THIS FIRST)
```
1. Open Supabase Dashboard
2. Go to SQL Editor
3. Open /Users/robertburns/Projects/RedFlag/DATABASE_TRIGGER_FIX.sql
4. Copy entire contents
5. Paste into SQL Editor
6. Click "Run"
7. Verify all checks show "✅ EXISTS"
8. Grant credits to existing test users
```

### Step 2: Fix Auth State Persistence
```
1. Open /Users/robertburns/Projects/RedFlag/safety_app/lib/main.dart
2. Verify Supabase initialization has authOptions
3. Add auth state listener
4. Open /Users/robertburns/Projects/RedFlag/safety_app/lib/services/auth_service.dart
5. Add session refresh OR auth state wait after waitForProfile()
6. Save files
```

### Step 3: Clean Build and Test
```
1. flutter clean
2. flutter pub get
3. flutter run -d [simulator_id]
4. Test signup with new email
5. Verify profile created with 1 credit
6. Verify user stays authenticated
7. Verify search screen shows 1 credit
```

---

## 🚨 Quick Fix (If Needed Immediately)

If you need users to sign up NOW before fixing triggers:

1. **Manual Profile Creation**:
   ```sql
   -- After each signup, run this:
   INSERT INTO public.profiles (id, email, credits, revenuecat_user_id)
   SELECT id, email, 1, id::TEXT
   FROM auth.users
   WHERE email = 'USER_EMAIL_HERE'
   ON CONFLICT (id) DO UPDATE SET credits = 1;
   ```

2. **Direct Database Access**: Give users credits manually via SQL after they contact support

---

## 📊 Success Criteria

✅ Database trigger fires automatically on signup
✅ User profile created with 1 credit
✅ User stays authenticated after signup
✅ Search screen shows 1 credit
✅ User can perform search successfully
✅ No "unexpected error" messages

---

## 🔗 Related Files

- Database trigger SQL: `/Users/robertburns/Projects/RedFlag/DATABASE_TRIGGER_FIX.sql`
- Auth service: `/Users/robertburns/Projects/RedFlag/safety_app/lib/services/auth_service.dart`
- Main app: `/Users/robertburns/Projects/RedFlag/safety_app/lib/main.dart`
- Auth persistence docs: `/Users/robertburns/Projects/RedFlag/AUTH_PERSISTENCE_ISSUE.md`
- Race condition analysis: `/Users/robertburns/Projects/RedFlag/CREDITS_RACE_CONDITION_ANALYSIS.md`

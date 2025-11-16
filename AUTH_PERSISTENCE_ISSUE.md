# Authentication Persistence Issue

**Date**: November 8, 2025
**Issue**: User shows as "not authenticated" immediately after successful signup
**Severity**: CRITICAL

---

## 🔍 Problem Analysis

From the debug output on simulator 7:

```
flutter: 🔍 [SEARCH] Loading credits...
flutter: ⚠️ [AUTH] getUserCredits: User not authenticated
flutter: ✅ [SEARCH] Loaded credits: 0
```

**Timeline of Events:**

1. ✅ User signs up with `debugtest@test.com`
2. ✅ Supabase returns successful auth response
3. ✅ App calls `_waitForProfile()` (with NEW code)
4. ⏳ Profile never found (trigger issue - separate problem)
5. ⚠️ App continues and navigates to search screen
6. 🔴 SearchScreen loads and calls `_loadCredits()`
7. 🔴 `getUserCredits()` shows: **"User not authenticated"** ← CRITICAL
8. ❌ Returns 0 credits

## 🤔 Why Is This Happening?

### Hypothesis 1: Auth State Not Persisting Through Navigation
The most likely cause is that Supabase auth state is not properly initialized or persisted when the app navigates from signup to the home screen.

**Possible Causes:**
- Auth session not being saved to secure storage
- Navigation happening before auth state is fully propagated
- Supabase client reinitializing and losing session

### Hypothesis 2: Race Condition in Auth State
Even though signup succeeds, the `currentUser` getter might return `null` for a brief moment during navigation.

### Hypothesis 3: Context/Widget Tree Issue
The auth service might be accessing a stale Supabase client instance.

---

## 🔧 Potential Fixes

### Fix 1: Add Delay After Signup (Quick Fix)
Add a small delay after signup to ensure auth state propagates:

```dart
// In auth_service.dart - signUp()
await _waitForProfile(response.user!.id);

// NEW: Wait for auth state to fully propagate
await Future.delayed(const Duration(milliseconds: 500));

await RevenueCatService().initialize(response.user!.id);
```

### Fix 2: Verify Auth State Before Continuing
Check auth state after signup and before returning:

```dart
// In auth_service.dart - signUp()
await _waitForProfile(response.user!.id);
await RevenueCatService().initialize(response.user!.id);

// NEW: Verify user is still authenticated
if (_supabase.auth.currentUser == null) {
  print('⚠️ [AUTH] Auth state lost after signup!');
  return AuthResult.failed('Authentication state lost. Please try again.');
}

return AuthResult.success(response.user!);
```

### Fix 3: Force Auth State Reload
Explicitly reload the auth session:

```dart
// In auth_service.dart - signUp()
await _waitForProfile(response.user!.id);

// NEW: Force reload auth session
await _supabase.auth.refreshSession();

await RevenueCatService().initialize(response.user!.id);
```

### Fix 4: Add Auth State Listener in Main
Ensure auth state is properly listened to throughout app lifecycle:

```dart
// In main.dart - after Supabase initialization
Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  print('🔐 [MAIN] Auth state changed: ${data.event} - User: ${data.session?.user.id}');
});
```

---

## 🧪 Testing Plan

### Test 1: Add More Debug Logging
Add logging at every step of the signup process:

```dart
// In auth_service.dart - signUp()
print('🔐 [AUTH] Before signup - Current user: ${_supabase.auth.currentUser?.id}');

final response = await _supabase.auth.signUp(email: email, password: password);

print('🔐 [AUTH] After signup - Response user: ${response.user?.id}');
print('🔐 [AUTH] After signup - Current user: ${_supabase.auth.currentUser?.id}');

await _waitForProfile(response.user!.id);

print('🔐 [AUTH] After waitForProfile - Current user: ${_supabase.auth.currentUser?.id}');

await RevenueCatService().initialize(response.user!.id);

print('🔐 [AUTH] After RevenueCat init - Current user: ${_supabase.auth.currentUser?.id}');

return AuthResult.success(response.user!);
```

### Test 2: Check Main.dart Initialization
Verify Supabase is initialized with correct parameters:

```dart
await Supabase.initialize(
  url: 'https://qjbtmrbbjivniveptdjl.supabase.co',
  anonKey: 'YOUR_ANON_KEY',
  authOptions: FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,  // Ensure PKCE flow
    autoRefreshToken: true,           // Auto-refresh tokens
  ),
);
```

---

## 🎯 Recommended Action

**Immediate Next Steps:**

1. **Add enhanced debug logging** to track auth state through entire signup flow
2. **Run the database trigger fix** (DATABASE_TRIGGER_FIX.sql) to fix the profile creation issue
3. **Test signup again** with enhanced logging to see exactly when auth state is lost
4. **Implement Fix #2** (verify auth state) to catch and handle this issue gracefully

---

## 📊 Related Issues

This issue is separate from but related to the database trigger problem:
- **Trigger Issue**: Profile not being created (prevents credits from showing)
- **Auth Issue**: User not authenticated (prevents credit query from running)

**Both issues must be fixed** for the credits system to work properly.

---

## 🔗 Related Files

- `/Users/robertburns/Projects/RedFlag/safety_app/lib/services/auth_service.dart` - Auth service implementation
- `/Users/robertburns/Projects/RedFlag/safety_app/lib/main.dart` - Supabase initialization
- `/Users/robertburns/Projects/RedFlag/safety_app/lib/screens/signup_screen.dart` - Signup flow
- `/Users/robertburns/Projects/RedFlag/CREDITS_RACE_CONDITION_ANALYSIS.md` - Original race condition analysis

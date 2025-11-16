# Credits Not Showing - Root Cause Analysis

**Date**: November 8, 2025
**Issue**: New users see 0 credits instead of 1 free credit after signup

---

## 🔍 Root Cause: RACE CONDITION

### The Problem

There's a **race condition** between the user signup flow and the database trigger that creates the user profile with credits.

### Flow Analysis

#### Current Signup Flow:
```
1. User fills signup form
2. AuthService.signUp() calls Supabase auth.signUp()
3. Supabase creates user in auth.users table ✅
4. auth.signUp() returns immediately with user object ✅
5. App shows success message ✅
6. App navigates to /home (SearchScreen) ✅

   ⚠️ **MEANWHILE IN DATABASE:**
   7. Trigger fires: on_auth_user_created
   8. Function runs: handle_new_user()
   9. Profile created in profiles table with credits = 1

7. SearchScreen.initState() calls _loadCredits() ❌
8. getUserCredits() queries profiles table ❌
9. **RACE CONDITION**: Profile might not exist yet! ❌
10. Query throws error (profile not found) ❌
11. Catch block returns 0 credits ❌
12. UI shows 0 instead of 1 ❌
```

### Evidence

1. **Signup Screen Line 57**: Shows message "You received 1 free search" - assumes credit granted
2. **Signup Screen Line 60**: Immediately navigates to `/home`
3. **No waiting** for profile creation confirmation
4. **AuthService.getUserCredits() Line 76-78**: Silently catches errors and returns 0
5. **SearchScreen.initState() Line 42-55**: Immediately queries credits on mount

### Why This Happens

**Supabase Triggers are ASYNCHRONOUS**:
- `signUp()` returns as soon as auth.users entry is created
- The trigger `on_auth_user_created` fires AFTER INSERT
- Profile creation happens in a separate transaction
- Typical delay: 50-500ms (can be longer under load)

### Why Real-Time Subscription Doesn't Help

Looking at `AuthService.watchCredits()` (Line 91-98):
```dart
return _supabase
    .from('profiles')
    .stream(primaryKey: ['id'])
    .eq('id', currentUser!.id)
    .map((data) {
        if (data.isEmpty) return 0;  // ⚠️ Returns 0 if profile doesn't exist
        return data.first['credits'] as int;
    });
```

**Problem**: If the stream starts before profile is created, it returns empty data → maps to 0.

---

## 🐛 Proof of Concept

### Test This Race Condition

1. Factory reset simulator
2. Sign up with new email
3. Observe: Counter shows 0 immediately
4. Wait 1-2 seconds
5. Counter updates to 1 (when stream receives profile creation)

**OR**

1. Sign up on slow network
2. See 0 credits
3. Pull down to refresh (if implemented)
4. Credits update to 1

---

## ✅ Solutions

### Option A: Wait for Profile Creation (RECOMMENDED)

**Modify**: `auth_service.dart` - signUp() method

```dart
/// Sign up with email/password
Future<AuthResult> signUp(String email, String password) async {
  try {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      return AuthResult.failed('Sign up failed. Please try again.');
    }

    // ✅ NEW: Wait for profile to be created by trigger
    await _waitForProfile(response.user!.id);

    // Initialize RevenueCat with Supabase user ID
    await RevenueCatService().initialize(response.user!.id);

    return AuthResult.success(response.user!);
  } on AuthException catch (e) {
    return AuthResult.failed(e.message);
  } catch (e) {
    return AuthResult.failed('An unexpected error occurred: ${e.toString()}');
  }
}

/// Wait for profile to be created (max 5 seconds)
Future<void> _waitForProfile(String userId, {int maxAttempts = 10}) async {
  for (int i = 0; i < maxAttempts; i++) {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('id, credits')
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        return; // Profile exists, we're good!
      }
    } catch (e) {
      // Continue polling
    }

    // Wait 500ms before next attempt
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Profile still doesn't exist after 5 seconds - something's wrong
  throw Exception('Profile creation timeout. Please contact support.');
}
```

**Pros**:
- ✅ Guarantees profile exists before navigation
- ✅ No UI changes needed
- ✅ User sees correct credit count immediately

**Cons**:
- ❌ Adds 0.5-2s delay to signup (usually < 1s)
- ❌ Signup feels slightly slower

---

### Option B: Retry with Backoff in getUserCredits()

**Modify**: `auth_service.dart` - getUserCredits() method

```dart
/// Get user credits from database (with retry for race condition)
Future<int> getUserCredits({int maxAttempts = 3}) async {
  if (!isAuthenticated) return 0;

  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      final response = await _supabase
          .from('profiles')
          .select('credits')
          .eq('id', currentUser!.id)
          .single();

      return response['credits'] as int;
    } catch (e) {
      // If not last attempt, wait and retry
      if (attempt < maxAttempts - 1) {
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        continue;
      }
      // Last attempt failed, return 0
      return 0;
    }
  }

  return 0;
}
```

**Pros**:
- ✅ Signup remains fast
- ✅ Handles race condition gracefully
- ✅ Minimal code changes

**Cons**:
- ❌ User might see 0 briefly before it updates
- ❌ Wastes API calls on retries

---

### Option C: Show Loading State

**Modify**: `search_screen.dart`

```dart
bool _isLoadingCredits = true;

Future<void> _loadCredits() async {
  setState(() => _isLoadingCredits = true);

  try {
    // Add retry logic
    int attempts = 0;
    int credits = 0;

    while (attempts < 5 && credits == 0) {
      credits = await _searchService.getCurrentCredits();
      if (credits == 0) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      } else {
        break;
      }
    }

    setState(() {
      _currentCredits = credits;
      _isLoadingCredits = false;
    });

    // Watch for real-time credit changes
    _creditsSubscription = _searchService.watchCredits().listen((credits) {
      if (mounted) {
        setState(() => _currentCredits = credits);
      }
    });
  } catch (e) {
    setState(() => _isLoadingCredits = false);
  }
}

// In badge UI:
child: _isLoadingCredits
    ? SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
    : Text('$_currentCredits', ...)
```

**Pros**:
- ✅ Clear visual feedback
- ✅ No failed queries
- ✅ Professional UX

**Cons**:
- ❌ More UI code
- ❌ Still has retry logic

---

## 🎯 Recommended Fix: HYBRID APPROACH

Combine Option A (wait on signup) + improve real-time subscription:

### 1. Add Profile Wait in SignUp
Add `_waitForProfile()` to auth_service.dart

### 2. Improve Credit Loading
Add retry logic to `search_screen.dart`

### 3. Fix Stream Initialization
Ensure stream properly handles late-arriving profiles

---

## 📋 Implementation Steps

1. ✅ **Revert login icon** (completed)
2. ✅ **Add forgot password** (completed)
3. 🔄 **Implement _waitForProfile() in AuthService**
4. 🔄 **Add retry logic to SearchScreen._loadCredits()**
5. 🔄 **Test signup flow**
6. 🔄 **Test with network delays**

---

## 🧪 Testing Checklist

After fix:
- [ ] Sign up with new email → see 1 credit immediately
- [ ] Log out → log in → still see 1 credit
- [ ] Perform search → credit deducts to 0
- [ ] Sign up on slow network → still see 1 credit (may take 1-2s)
- [ ] Factory reset → sign up → immediate 1 credit

---

## 📝 Additional Notes

### Why Manual SQL Grant Worked

When you ran `UPDATE public.profiles SET credits = 1 WHERE email = 'bobbywburns@gmail.com'`, it worked because:
1. Profile already existed (created by trigger eventually)
2. Real-time subscription detected the update
3. UI updated to show 1

### Why New Signups Will Fail

Until we fix the race condition, every new signup will:
1. Create user in auth.users
2. Navigate to home immediately
3. Query for profile (doesn't exist yet)
4. Return 0 credits
5. Profile created 100-500ms later
6. Stream updates (if still mounted)
7. Credits update to 1

This creates a poor user experience with flickering/incorrect initial state.

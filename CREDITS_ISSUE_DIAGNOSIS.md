# Credits Issue Diagnosis & Fix Plan

**Date**: November 8, 2025
**Issue**: User has 0 credits after signup instead of 1 free credit

---

## Problem Analysis

### Observed Behavior
- User signed up with `bobbywburns@gmail.com`
- User has **0 credits** (shown in top-right badge)
- Expected: **1 free credit** on signup

### Expected Flow
1. User signs up via `SignUpScreen`
2. Supabase Auth creates user in `auth.users` table
3. Trigger `on_auth_user_created` fires
4. Function `handle_new_user()` creates profile with `credits = 1`
5. App displays 1 credit in badge

### Potential Root Causes

#### 1. Trigger Not Created/Enabled
- The trigger may not exist in Supabase
- Previous session attempted to run SQL but may have failed
- Need to verify trigger exists and is active

#### 2. Profile Created Before Trigger
- If user signed up before trigger was created, profile may have been created with 0 credits
- Need to check when profile was created vs when trigger was created

#### 3. Trigger Failed Silently
- Trigger may be failing due to permissions or constraint violations
- Supabase logs would show this

#### 4. Profile Exists Without Credits
- Profile may exist from previous signup attempt
- Credits column may be NULL or 0

---

## Diagnosis Steps

### Step 1: Check if Trigger Exists
```sql
-- Query Supabase to check if trigger exists
SELECT
    trigger_name,
    event_manipulation,
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE event_object_table = 'users'
AND trigger_schema = 'auth';
```

### Step 2: Check Current User Profile
```sql
-- Check if profile exists and current credits
SELECT
    id,
    email,
    credits,
    created_at,
    updated_at
FROM public.profiles
WHERE email = 'bobbywburns@gmail.com';
```

### Step 3: Check Auth User
```sql
-- Verify user exists in auth table
SELECT
    id,
    email,
    created_at
FROM auth.users
WHERE email = 'bobbywburns@gmail.com';
```

### Step 4: Check Function Exists
```sql
-- Verify handle_new_user function exists
SELECT
    routine_name,
    routine_type,
    routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'handle_new_user';
```

---

## Fix Strategies

### Option A: Re-run SQL Setup (If Trigger Missing)
1. Open Supabase Dashboard → SQL Editor
2. Run `/Users/robertburns/Projects/RedFlag/supabase_setup.sql`
3. Verify no errors in output
4. Test signup with new user

### Option B: Manually Grant Credits (Quick Fix)
```sql
-- Grant 1 credit to current user
UPDATE public.profiles
SET credits = 1, updated_at = NOW()
WHERE email = 'bobbywburns@gmail.com';
```

### Option C: Recreate Profile (If Corrupted)
```sql
-- Delete existing profile
DELETE FROM public.profiles WHERE email = 'bobbywburns@gmail.com';

-- Re-insert with proper credits
INSERT INTO public.profiles (id, email, credits, revenuecat_user_id)
SELECT
    id,
    email,
    1,
    id::TEXT
FROM auth.users
WHERE email = 'bobbywburns@gmail.com';
```

### Option D: Create Missing Profile (If None Exists)
```sql
-- Create profile if it doesn't exist
INSERT INTO public.profiles (id, email, credits, revenuecat_user_id)
SELECT
    id,
    email,
    1,
    id::TEXT
FROM auth.users
WHERE email = 'bobbywburns@gmail.com'
AND id NOT IN (SELECT id FROM public.profiles);
```

---

## Recommended Fix Plan

### Phase 1: Immediate Fix (2 minutes)
**Action**: Manually grant 1 credit to test user

```sql
UPDATE public.profiles
SET credits = 1
WHERE email = 'bobbywburns@gmail.com';
```

**Test**: Refresh app → should show 1 credit

### Phase 2: Verify Trigger (5 minutes)
**Action**: Check if trigger exists and is working

1. Run diagnosis queries above
2. If trigger missing → run supabase_setup.sql
3. Test with fresh signup (new email)

### Phase 3: Test Full Flow (3 minutes)
**Action**: Complete end-to-end test

1. Factory reset simulator
2. Sign up with `test_$(date +%s)@example.com`
3. Verify 1 credit granted automatically
4. Perform search → should deduct to 0
5. Navigate to store → verify products load

---

## Implementation

### Quick Fix SQL
Run this in Supabase SQL Editor:

```sql
-- Step 1: Grant credits to current user
UPDATE public.profiles
SET credits = 1
WHERE email = 'bobbywburns@gmail.com';

-- Step 2: Verify trigger exists
SELECT count(*) as trigger_exists
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- Step 3: If trigger doesn't exist (count = 0), run full setup
-- (Copy content from supabase_setup.sql)
```

### Verification Query
```sql
-- After fix, verify user has credits
SELECT
    email,
    credits,
    created_at
FROM public.profiles
WHERE email = 'bobbywburns@gmail.com';
```

---

## Next Steps

1. ✅ Revert login icon to simple Icons.flag
2. 🔄 Access Supabase Dashboard
3. 🔄 Run diagnosis queries
4. 🔄 Apply appropriate fix
5. 🔄 Test with hot reload
6. 🔄 Document results

---

## Success Criteria

- [ ] User `bobbywburns@gmail.com` has 1 credit
- [ ] Search badge shows "1" instead of "0"
- [ ] Trigger exists and is enabled
- [ ] New signups automatically receive 1 credit
- [ ] Search functionality deducts credits properly

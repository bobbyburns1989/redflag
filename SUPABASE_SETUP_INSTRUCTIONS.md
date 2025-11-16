# Supabase Database Setup Instructions
**Date**: November 8, 2025
**CRITICAL**: Must complete this to fix signup

---

## 🎯 What This Fixes

Without this setup, new users cannot sign up because:
- Profiles are not created automatically
- Users don't get their 1 free search credit
- Auth state is lost

---

## 📋 Step-by-Step Instructions

### Step 1: Open Supabase SQL Editor

1. Go to: https://app.supabase.com/project/qjbtmrbbjivniveptdjl/sql
2. Click "New query" button
3. Clear any existing SQL in the editor

### Step 2: Run Diagnostic Check

**Copy and paste this SQL** to check current status:

```sql
-- Check if trigger exists
SELECT
    'Trigger Check' as component,
    CASE
        WHEN EXISTS (
            SELECT FROM information_schema.triggers
            WHERE trigger_name = 'on_auth_user_created'
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status;

-- Check if function exists
SELECT
    'Function Check' as component,
    CASE
        WHEN EXISTS (
            SELECT FROM information_schema.routines
            WHERE routine_schema = 'public' AND routine_name = 'handle_new_user'
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status;

-- Check if profiles table exists
SELECT
    'Profiles Table Check' as component,
    CASE
        WHEN EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_schema = 'public' AND table_name = 'profiles'
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status;
```

**Click "Run"**

**Expected Results**:
- All 3 should show "✅ EXISTS"
- If any show "❌ MISSING", proceed to Step 3

### Step 3: Create Database Objects

**Open this file**: `/Users/robertburns/Projects/RedFlag/DATABASE_TRIGGER_FIX.sql`

**Steps**:
1. Open the file in a text editor
2. Copy the ENTIRE contents (all ~150 lines)
3. Paste into Supabase SQL Editor
4. Click "Run"

**This creates**:
- `profiles` table with credits column
- `handle_new_user()` function
- `on_auth_user_created` trigger
- RLS (Row Level Security) policies
- colors.xml file reference for Android

### Step 4: Verify Setup Worked

Run this verification query:

```sql
-- Verify everything is created
SELECT 'Verification Results' as status;

SELECT
    'Profiles Table' as component,
    CASE
        WHEN EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_schema = 'public' AND table_name = 'profiles'
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status;

SELECT
    'Handle New User Function' as component,
    CASE
        WHEN EXISTS (
            SELECT FROM information_schema.routines
            WHERE routine_schema = 'public' AND routine_name = 'handle_new_user'
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status;

SELECT
    'On Auth User Created Trigger' as component,
    CASE
        WHEN EXISTS (
            SELECT FROM information_schema.triggers
            WHERE trigger_name = 'on_auth_user_created'
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status;
```

**All 3 should show "✅ EXISTS"**

### Step 5: Grant Credits to Existing Test Users

Run this to give 1 credit to all users who signed up during testing:

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
ON CONFLICT (id) DO UPDATE SET credits = 1, updated_at = NOW();

-- Verify credits were granted
SELECT
    u.email,
    p.credits,
    p.created_at
FROM auth.users u
LEFT JOIN public.profiles p ON p.id = u.id
ORDER BY u.created_at DESC;
```

**Expected Result**: Should see all test users with 1 credit

---

## 🧪 Testing the Fix

### Test 1: Manual Trigger Test

Create a test user to verify the trigger fires:

```sql
-- This will create a user in auth.users
-- The trigger should automatically create a profile

-- Check recent users and their profiles
SELECT
    u.email as user_email,
    u.created_at as user_created,
    p.credits,
    p.created_at as profile_created,
    CASE
        WHEN p.id IS NULL THEN '❌ TRIGGER FAILED'
        ELSE '✅ TRIGGER WORKED'
    END as trigger_status
FROM auth.users u
LEFT JOIN public.profiles p ON p.id = u.id
ORDER BY u.created_at DESC
LIMIT 10;
```

### Test 2: App Signup Test

1. Factory reset your simulator
2. Open the PinkFlag app
3. Sign up with a new email (e.g., `triggertest@gmail.com`)
4. Should see success message
5. Should navigate to search screen
6. Should show "1" in top-right credit badge
7. Should NOT see any error messages

**If successful**, you'll see in console:
```
flutter: 🔍 [AUTH] Attempt 1/10 to find profile...
flutter: ✅ [AUTH] Profile found! Credits: 1
flutter: ✅ [AUTH] Auth state confirmed: [USER_ID]
flutter: ✅ [SEARCH] Loaded credits: 1
```

---

## 🚨 Troubleshooting

### Issue: Trigger Still Not Working

**Check trigger is enabled**:
```sql
SELECT
    trigger_name,
    event_manipulation,
    action_statement,
    action_timing,
    action_orientation
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';
```

Should show:
- `action_timing`: AFTER
- `event_manipulation`: INSERT
- `action_orientation`: ROW

**Re-create the trigger**:
```sql
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();
```

### Issue: Permission Denied

Run this to grant permissions:

```sql
-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO authenticated, anon;

-- Grant permissions on profiles table
GRANT ALL ON public.profiles TO authenticated;
GRANT SELECT ON public.profiles TO anon;

-- Grant execute on function
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO authenticated;
```

### Issue: Function Failing Silently

Check PostgreSQL logs in Supabase dashboard:
1. Go to Database → Logs
2. Look for errors related to `handle_new_user`

---

## ✅ Success Criteria

After completing this setup, you should have:

- ✅ Profiles table exists with RLS policies
- ✅ `handle_new_user()` function exists and works
- ✅ `on_auth_user_created` trigger exists and is enabled
- ✅ All existing test users have 1 credit
- ✅ New signups automatically get 1 credit
- ✅ New signups show authenticated state
- ✅ Search screen shows correct credit count

---

## 📞 Need Help?

If the trigger still doesn't work after following these steps:

1. Check Supabase logs (Database → Logs)
2. Verify PostgreSQL version is compatible (should be 15+)
3. Check if `auth.users` table exists and is accessible
4. Verify RLS is configured correctly

---

## 🔗 Related Files

- Full trigger SQL: `/Users/robertburns/Projects/RedFlag/DATABASE_TRIGGER_FIX.sql`
- Fix plan: `/Users/robertburns/Projects/RedFlag/SIGNUP_FIX_PLAN.md`
- Auth persistence docs: `/Users/robertburns/Projects/RedFlag/AUTH_PERSISTENCE_ISSUE.md`

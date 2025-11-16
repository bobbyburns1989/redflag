-- QUICK FIX: Grant Credits to Test User
-- Run this in Supabase Dashboard → SQL Editor
-- URL: https://app.supabase.com/project/qjbtmrbbjivniveptdjl/sql

-- ============================================
-- STEP 1: Check current user status
-- ============================================
SELECT
    'Current Profile Status' as check_type,
    email,
    credits,
    created_at
FROM public.profiles
WHERE email = 'bobbywburns@gmail.com';

-- ============================================
-- STEP 2: Grant 1 credit to test user
-- ============================================
UPDATE public.profiles
SET credits = 1, updated_at = NOW()
WHERE email = 'bobbywburns@gmail.com';

-- ============================================
-- STEP 3: Verify the update
-- ============================================
SELECT
    'Updated Profile Status' as check_type,
    email,
    credits,
    updated_at
FROM public.profiles
WHERE email = 'bobbywburns@gmail.com';

-- ============================================
-- STEP 4: Check if trigger exists
-- ============================================
SELECT
    'Trigger Status' as check_type,
    count(*) as exists,
    CASE
        WHEN count(*) > 0 THEN 'Trigger EXISTS ✓'
        ELSE 'Trigger MISSING ✗ - Need to run supabase_setup.sql'
    END as status
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- ============================================
-- OPTIONAL: Check all profiles and credits
-- ============================================
SELECT
    email,
    credits,
    created_at
FROM public.profiles
ORDER BY created_at DESC
LIMIT 10;

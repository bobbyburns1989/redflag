-- DATABASE TRIGGER FIX
-- Run this in Supabase Dashboard → SQL Editor
-- URL: https://app.supabase.com/project/qjbtmrbbjivniveptdjl/sql
-- ============================================================================

-- STEP 1: Check if profiles table exists
-- ============================================================================
SELECT
    'Profiles Table Check' as check_type,
    EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'profiles'
    ) as table_exists;

-- STEP 2: Check if trigger exists
-- ============================================================================
SELECT
    'Trigger Check' as check_type,
    trigger_name,
    event_manipulation,
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- If the above returns 0 rows, trigger doesn't exist - continue below

-- STEP 3: Check if handle_new_user function exists
-- ============================================================================
SELECT
    'Function Check' as check_type,
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'handle_new_user';

-- ============================================================================
-- FIX: Create profiles table if missing
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    credits INTEGER NOT NULL DEFAULT 1,
    revenuecat_user_id TEXT UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
CREATE POLICY "Users can view their own profile"
    ON public.profiles
    FOR SELECT
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile"
    ON public.profiles
    FOR UPDATE
    USING (auth.uid() = id);

-- ============================================================================
-- FIX: Create or replace the trigger function
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert profile with 1 free credit
    INSERT INTO public.profiles (id, email, credits, revenuecat_user_id)
    VALUES (
        NEW.id,
        NEW.email,
        1,  -- Free search on signup
        NEW.id::TEXT
    );

    -- Log success
    RAISE NOTICE 'Profile created for user: % with email: %', NEW.id, NEW.email;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the auth user creation
        RAISE WARNING 'Failed to create profile for user %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- FIX: Create or replace the trigger
-- ============================================================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- VERIFY: Check that everything is created
-- ============================================================================
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

-- ============================================================================
-- FIX: Grant credit to test user (debugtest@test.com)
-- ============================================================================
-- Find the user ID and create/update profile
INSERT INTO public.profiles (id, email, credits, revenuecat_user_id)
SELECT
    id,
    email,
    1,  -- Grant 1 credit
    id::TEXT
FROM auth.users
WHERE email = 'debugtest@test.com'
ON CONFLICT (id)
DO UPDATE SET
    credits = 1,
    updated_at = NOW();

-- Verify the fix worked
SELECT
    'Final Check' as check_type,
    email,
    credits,
    created_at
FROM public.profiles
WHERE email = 'debugtest@test.com';

-- ============================================================================
-- INSTRUCTIONS FOR NEXT STEPS:
-- ============================================================================
-- 1. Run this entire script in Supabase SQL Editor
-- 2. Check that all verification results show "✅ EXISTS"
-- 3. Check that debugtest@test.com now has 1 credit
-- 4. The app should auto-update via real-time subscription to show 1 credit
-- 5. Test signup with a NEW email to verify trigger works for future signups
-- ============================================================================

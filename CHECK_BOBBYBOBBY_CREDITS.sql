-- Check if bobbybobby@gmail.com profile exists and grant credits
-- Run in Supabase SQL Editor

-- Step 1: Check current profile status
SELECT
    'Current Status' as check,
    email,
    credits,
    created_at
FROM public.profiles
WHERE email = 'bobbybobby@gmail.com';

-- Step 2: Grant 1 credit (or create profile if missing)
INSERT INTO public.profiles (id, email, credits, revenuecat_user_id)
SELECT
    id,
    email,
    1,
    id::TEXT
FROM auth.users
WHERE email = 'bobbybobby@gmail.com'
ON CONFLICT (id)
DO UPDATE SET credits = 1, updated_at = NOW();

-- Step 3: Verify the update
SELECT
    'After Update' as check,
    email,
    credits,
    updated_at
FROM public.profiles
WHERE email = 'bobbybobby@gmail.com';

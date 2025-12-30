-- =====================================================
-- URGENT: Apple Sign-In Database Fix for App Store Rejection
-- =====================================================
--
-- Issue: Users cannot sign up because email field is NOT NULL
-- but Apple Sign-In returns NULL for users who hide their email
--
-- Error: {"code":"unexpected_failure","message":"Database error saving new user"}
--
-- This script fixes:
-- 1. Makes email nullable (allows Apple "Hide My Email")
-- 2. Updates initial credits from 1 to 10 (matches UI promise)
-- 3. Fixes trigger to not require email
--
-- Run this in Supabase SQL Editor IMMEDIATELY
-- =====================================================

-- =====================================================
-- STEP 1: Make email column nullable
-- =====================================================

-- Drop NOT NULL constraint from email
ALTER TABLE public.profiles
  ALTER COLUMN email DROP NOT NULL;

-- Optional: Drop UNIQUE constraint if you want to allow NULL emails for multiple users
-- (PostgreSQL treats each NULL as distinct, so this is safe)
-- ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_email_key;

COMMENT ON COLUMN public.profiles.email IS
  'Email address (may be NULL for Apple Sign-In users who hide their email)';

-- =====================================================
-- STEP 2: Update initial credits to 10
-- =====================================================

-- Change default credits from 1 to 10
ALTER TABLE public.profiles
  ALTER COLUMN credits SET DEFAULT 10;

-- Update existing users with 1 credit to have 10
-- (Only if you want to be generous to existing users)
UPDATE public.profiles
  SET credits = 10, updated_at = NOW()
  WHERE credits = 1;

-- =====================================================
-- STEP 3: Fix trigger to handle NULL email gracefully
-- =====================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert profile with email (may be NULL for Apple Sign-In)
  INSERT INTO public.profiles (id, email, credits, revenuecat_user_id, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,  -- ✅ Now allows NULL
    10,  -- ✅ Updated from 1 to 10
    NEW.id::TEXT,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;  -- Prevents duplicate inserts

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- STEP 4: Verify the fix
-- =====================================================

-- Check current schema
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'profiles'
  AND column_name IN ('email', 'credits');

-- Expected output:
-- email    | text    | YES | NULL
-- credits  | integer | YES | 10

-- =====================================================
-- SUCCESS!
-- =====================================================

SELECT
  'Database fix applied successfully!' AS status,
  '✅ Email is now nullable' AS fix_1,
  '✅ Initial credits updated to 10' AS fix_2,
  '✅ Trigger updated to handle NULL emails' AS fix_3;

-- =====================================================
-- TESTING (Optional - DO NOT run in production)
-- =====================================================

-- To test the fix, you can manually trigger the function:
--
-- 1. Create a test user in Supabase Auth Dashboard
-- 2. The trigger should auto-create profile with:
--    - email: NULL (if not provided)
--    - credits: 10
--
-- 3. Verify:
--    SELECT * FROM profiles WHERE id = 'YOUR-TEST-USER-ID';

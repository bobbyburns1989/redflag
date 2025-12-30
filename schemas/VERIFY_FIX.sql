-- =====================================================
-- Verification Script - Apple Sign-In Fix
-- =====================================================
--
-- Run this AFTER applying URGENT_APPLE_SIGNIN_FIX.sql
-- to confirm the fix was applied correctly
--
-- =====================================================

-- =====================================================
-- CHECK 1: Verify email is nullable
-- =====================================================

SELECT
  'CHECK 1: Email Column' AS test_name,
  CASE
    WHEN is_nullable = 'YES' THEN '✅ PASS: Email is nullable'
    ELSE '❌ FAIL: Email is still NOT NULL'
  END AS result
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'profiles'
  AND column_name = 'email';

-- =====================================================
-- CHECK 2: Verify default credits is 10
-- =====================================================

SELECT
  'CHECK 2: Default Credits' AS test_name,
  CASE
    WHEN column_default LIKE '%10%' THEN '✅ PASS: Default credits is 10'
    ELSE '❌ FAIL: Default credits is not 10 (got: ' || COALESCE(column_default, 'NULL') || ')'
  END AS result
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'profiles'
  AND column_name = 'credits';

-- =====================================================
-- CHECK 3: Verify trigger function exists
-- =====================================================

SELECT
  'CHECK 3: Trigger Function' AS test_name,
  CASE
    WHEN COUNT(*) > 0 THEN '✅ PASS: Trigger function exists'
    ELSE '❌ FAIL: Trigger function not found'
  END AS result
FROM pg_proc
WHERE proname = 'handle_new_user';

-- =====================================================
-- CHECK 4: Verify trigger is attached
-- =====================================================

SELECT
  'CHECK 4: Trigger Attachment' AS test_name,
  CASE
    WHEN COUNT(*) > 0 THEN '✅ PASS: Trigger is attached to auth.users'
    ELSE '❌ FAIL: Trigger not attached'
  END AS result
FROM pg_trigger
WHERE tgname = 'on_auth_user_created';

-- =====================================================
-- CHECK 5: View trigger function source
-- =====================================================

SELECT
  'CHECK 5: Trigger Function Source' AS test_name,
  '✅ See below for function source' AS result;

-- Show the actual trigger function code
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'handle_new_user';

-- =====================================================
-- CHECK 6: Test data - Recent profiles
-- =====================================================

SELECT
  'CHECK 6: Recent Profiles' AS test_name,
  '✅ See below for recent profiles' AS result;

-- Show last 5 profiles to verify structure
SELECT
  id,
  COALESCE(email, '[NULL - Hidden Email]') AS email,
  credits,
  created_at
FROM public.profiles
ORDER BY created_at DESC
LIMIT 5;

-- =====================================================
-- CHECK 7: Count profiles with NULL email
-- =====================================================

SELECT
  'CHECK 7: NULL Email Support' AS test_name,
  'Found ' || COUNT(*) || ' profile(s) with NULL email (Apple Hide My Email)' AS result
FROM public.profiles
WHERE email IS NULL;

-- =====================================================
-- SUMMARY
-- =====================================================

SELECT
  '========== VERIFICATION COMPLETE ==========' AS summary,
  'All checks above should show ✅ PASS' AS instruction,
  'If any checks show ❌ FAIL, re-run URGENT_APPLE_SIGNIN_FIX.sql' AS fix_instruction;

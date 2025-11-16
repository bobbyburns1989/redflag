-- ============================================================================
-- PINK FLAG - DATABASE SETUP VERIFICATION SCRIPT
-- ============================================================================
-- Run this in Supabase SQL Editor to verify all components are configured
-- URL: https://app.supabase.com/project/qjbtmrbbjivniveptdjl/sql
-- ============================================================================

-- SECTION 1: Check Tables
-- ============================================================================
SELECT
    '📋 TABLE CHECK' as section,
    'Checking if required tables exist...' as description;

SELECT
    'profiles' as table_name,
    CASE
        WHEN EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_schema = 'public' AND table_name = 'profiles'
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status;

SELECT
    'credit_transactions' as table_name,
    CASE
        WHEN EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_schema = 'public' AND table_name = 'credit_transactions'
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status;

SELECT
    'searches' as table_name,
    CASE
        WHEN EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_schema = 'public' AND table_name = 'searches'
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status;

-- SECTION 2: Check credit_transactions Schema
-- ============================================================================
SELECT
    '📊 CREDIT_TRANSACTIONS SCHEMA' as section,
    'Verifying column names match webhook expectations...' as description;

SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'credit_transactions'
ORDER BY ordinal_position;

-- SECTION 3: Check Triggers
-- ============================================================================
SELECT
    '🔔 TRIGGER CHECK' as section,
    'Verifying database triggers are active...' as description;

SELECT
    trigger_name,
    event_manipulation as event,
    event_object_table as table,
    action_statement as function,
    CASE
        WHEN trigger_name = 'on_auth_user_created' THEN '✅ ACTIVE'
        ELSE '⚠️  UNKNOWN TRIGGER'
    END as status
FROM information_schema.triggers
WHERE trigger_schema IN ('public', 'auth')
ORDER BY trigger_name;

-- SECTION 4: Check Functions
-- ============================================================================
SELECT
    '⚙️ FUNCTION CHECK' as section,
    'Verifying database functions exist...' as description;

SELECT
    routine_name,
    routine_type,
    CASE
        WHEN routine_name IN ('handle_new_user', 'deduct_credit_for_search', 'add_credits_from_purchase')
        THEN '✅ EXISTS'
        ELSE '⚠️  UNKNOWN FUNCTION'
    END as status
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN ('handle_new_user', 'deduct_credit_for_search', 'add_credits_from_purchase')
ORDER BY routine_name;

-- SECTION 5: Check RLS Policies
-- ============================================================================
SELECT
    '🔒 ROW LEVEL SECURITY' as section,
    'Checking RLS policies are configured...' as description;

SELECT
    schemaname,
    tablename,
    policyname,
    CASE
        WHEN policyname IS NOT NULL THEN '✅ ACTIVE'
        ELSE '❌ NO POLICIES'
    END as status
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('profiles', 'credit_transactions', 'searches')
ORDER BY tablename, policyname;

-- SECTION 6: Check User Profiles
-- ============================================================================
SELECT
    '👥 USER PROFILES' as section,
    'Listing recent user profiles and credits...' as description;

SELECT
    email,
    credits,
    created_at,
    updated_at
FROM public.profiles
ORDER BY created_at DESC
LIMIT 10;

-- SECTION 7: Check Recent Transactions
-- ============================================================================
SELECT
    '💰 RECENT TRANSACTIONS' as section,
    'Showing last 10 credit transactions...' as description;

SELECT
    ct.transaction_type,
    ct.credits_change,
    ct.balance_after,
    ct.revenuecat_transaction_id,
    ct.notes,
    p.email,
    ct.created_at
FROM public.credit_transactions ct
JOIN public.profiles p ON ct.user_id = p.id
ORDER BY ct.created_at DESC
LIMIT 10;

-- SECTION 8: Summary Statistics
-- ============================================================================
SELECT
    '📈 SUMMARY STATISTICS' as section,
    'Overview of system usage...' as description;

SELECT
    'Total Users' as metric,
    COUNT(*) as value
FROM public.profiles;

SELECT
    'Total Searches' as metric,
    COUNT(*) as value
FROM public.searches;

SELECT
    'Total Transactions' as metric,
    COUNT(*) as value
FROM public.credit_transactions;

SELECT
    'Total Credits Distributed' as metric,
    SUM(credits_change) as value
FROM public.credit_transactions
WHERE transaction_type = 'purchase';

SELECT
    'Total Credits Spent' as metric,
    ABS(SUM(credits_change)) as value
FROM public.credit_transactions
WHERE transaction_type = 'search';

-- ============================================================================
-- ✅ VERIFICATION COMPLETE
-- ============================================================================
-- Review the results above:
-- 1. All tables should show ✅ EXISTS
-- 2. credit_transactions should have columns: credits_change, revenuecat_transaction_id, balance_after
-- 3. Trigger 'on_auth_user_created' should show ✅ ACTIVE
-- 4. All 3 functions should show ✅ EXISTS
-- 5. RLS policies should show ✅ ACTIVE for all tables
-- ============================================================================

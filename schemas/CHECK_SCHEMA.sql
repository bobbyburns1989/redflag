-- =====================================================
-- Schema Check - Find actual column names
-- Run this first to see what columns exist
-- =====================================================

-- Check profiles table columns
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'profiles'
ORDER BY ordinal_position;

-- Check credit_transactions table columns
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'credit_transactions'
ORDER BY ordinal_position;

-- Check searches table columns
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'searches'
ORDER BY ordinal_position;

-- Sample data from profiles (just to see structure)
SELECT * FROM profiles LIMIT 1;

-- Sample data from credit_transactions (just to see structure)
SELECT * FROM credit_transactions LIMIT 1;

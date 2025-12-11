-- =====================================================
-- Variable Credit System Migration
-- Pink Flag v1.2.0
-- Created: 2025-12-04
-- =====================================================
--
-- This migration implements the 10x credit multiplier and prepares
-- the system for variable credit costs per search type.
--
-- IMPORTANT: Run this script BEFORE deploying the backend changes
-- to ensure user credits are properly migrated.
--
-- =====================================================

-- =====================================================
-- STEP 1: Backup current credit data
-- =====================================================

-- Create a backup table with timestamp
CREATE TABLE IF NOT EXISTS credit_migration_backup_20251204 AS
SELECT
  user_id,
  credits as old_credits,
  updated_at as backed_up_at
FROM profiles
WHERE credits > 0;

-- Verify backup
SELECT
  COUNT(*) as users_with_credits,
  SUM(old_credits) as total_credits_before
FROM credit_migration_backup_20251204;

-- =====================================================
-- STEP 2: Apply 10x multiplier to all user credits
-- =====================================================

-- Multiply all existing user credits by 10
UPDATE profiles
SET
  credits = credits * 10,
  updated_at = NOW()
WHERE credits > 0;

-- Verify migration
SELECT
  COUNT(*) as migrated_users,
  SUM(credits) as total_credits_after,
  MIN(credits) as min_credits,
  MAX(credits) as max_credits,
  AVG(credits)::INTEGER as avg_credits
FROM profiles
WHERE credits > 0;

-- =====================================================
-- STEP 3: Create audit trail in credit_transactions
-- =====================================================

-- Log the migration for each user who received credits
INSERT INTO credit_transactions (
  user_id,
  transaction_type,
  credits,
  status,
  provider,
  created_at
)
SELECT
  p.user_id,
  'system_migration',
  b.old_credits * 9, -- The additional credits added (10x - original)
  'completed',
  'credit_system_v2_10x_multiplier',
  NOW()
FROM profiles p
INNER JOIN credit_migration_backup_20251204 b ON p.user_id = b.user_id
WHERE b.old_credits > 0;

-- Verify transaction log
SELECT
  COUNT(*) as migration_transactions,
  SUM(credits) as total_credits_added
FROM credit_transactions
WHERE provider = 'credit_system_v2_10x_multiplier';

-- =====================================================
-- STEP 4: Verification queries
-- =====================================================

-- Compare before and after
SELECT
  'Before Migration' as period,
  COUNT(*) as users,
  SUM(old_credits) as total_credits
FROM credit_migration_backup_20251204

UNION ALL

SELECT
  'After Migration' as period,
  COUNT(*) as users,
  SUM(credits) as total_credits
FROM profiles
WHERE credits > 0;

-- Show sample of migrated users
SELECT
  b.user_id,
  b.old_credits,
  p.credits as new_credits,
  (p.credits::FLOAT / b.old_credits) as multiplier
FROM credit_migration_backup_20251204 b
INNER JOIN profiles p ON b.user_id = p.user_id
ORDER BY b.old_credits DESC
LIMIT 10;

-- =====================================================
-- STEP 5: Add documentation notes
-- =====================================================

-- Document the migration in a notes table (create if doesn't exist)
CREATE TABLE IF NOT EXISTS system_migration_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  migration_name TEXT NOT NULL,
  migration_date TIMESTAMP DEFAULT NOW(),
  description TEXT,
  affected_rows INTEGER,
  status TEXT DEFAULT 'completed'
);

INSERT INTO system_migration_log (
  migration_name,
  description,
  affected_rows,
  status
)
SELECT
  'credit_system_v2_10x_multiplier',
  'Applied 10x credit multiplier to prepare for variable search costs. Name: 10 credits, Image: 4 credits, Phone: 2 credits',
  COUNT(*),
  'completed'
FROM profiles
WHERE credits > 0;

-- =====================================================
-- STEP 6: Health check queries
-- =====================================================

-- Check for any anomalies (users with 0 credits after migration)
SELECT
  'Anomaly Check' as check_name,
  COUNT(*) as count
FROM credit_migration_backup_20251204 b
INNER JOIN profiles p ON b.user_id = p.user_id
WHERE b.old_credits > 0 AND p.credits = 0;

-- Check that multiplier was applied correctly
SELECT
  'Multiplier Verification' as check_name,
  COUNT(*) as correctly_multiplied
FROM credit_migration_backup_20251204 b
INNER JOIN profiles p ON b.user_id = p.user_id
WHERE p.credits = (b.old_credits * 10);

-- =====================================================
-- STEP 7: Rollback script (use only if needed)
-- =====================================================

/*
-- ROLLBACK SCRIPT - USE ONLY IF MIGRATION FAILED
-- This restores credits to their pre-migration values

-- Restore from backup
UPDATE profiles p
SET
  credits = b.old_credits,
  updated_at = NOW()
FROM credit_migration_backup_20251204 b
WHERE p.user_id = b.user_id;

-- Remove migration transactions
DELETE FROM credit_transactions
WHERE provider = 'credit_system_v2_10x_multiplier';

-- Mark migration as rolled back
UPDATE system_migration_log
SET status = 'rolled_back'
WHERE migration_name = 'credit_system_v2_10x_multiplier';

-- Verify rollback
SELECT
  COUNT(*) as restored_users,
  SUM(credits) as total_credits
FROM profiles
WHERE credits > 0;
*/

-- =====================================================
-- STEP 8: Post-migration cleanup (optional, run after 30 days)
-- =====================================================

/*
-- After confirming migration was successful, you can drop the backup table
-- ONLY RUN THIS AFTER 30+ DAYS OF SUCCESSFUL OPERATION

DROP TABLE IF EXISTS credit_migration_backup_20251204;

-- Update migration log
UPDATE system_migration_log
SET description = description || ' [Backup table dropped after 30 days]'
WHERE migration_name = 'credit_system_v2_10x_multiplier';
*/

-- =====================================================
-- STEP 9: Final report
-- =====================================================

-- Generate final migration report
SELECT
  '🎉 Credit Migration Complete' as status,
  COUNT(DISTINCT p.user_id) as total_users_migrated,
  SUM(b.old_credits) as total_old_credits,
  SUM(p.credits) as total_new_credits,
  (SUM(p.credits)::FLOAT / SUM(b.old_credits))::NUMERIC(10,2) as actual_multiplier,
  NOW() as migration_completed_at
FROM profiles p
INNER JOIN credit_migration_backup_20251204 b ON p.user_id = b.user_id
WHERE b.old_credits > 0;

-- =====================================================
-- END OF MIGRATION
-- =====================================================

-- ✅ MIGRATION SUMMARY:
-- 1. All user credits multiplied by 10
-- 2. Audit trail created in credit_transactions
-- 3. Backup table created for rollback safety
-- 4. Migration logged in system_migration_log
--
-- NEXT STEPS:
-- 1. Deploy backend with new credit costs:
--    - Name search: 10 credits
--    - Image search: 4 credits
--    - Phone search: 2 credits
-- 2. Update Flutter app to display new credit counts
-- 3. Monitor user feedback and credit consumption
--
-- 🚨 IMPORTANT: Keep backup table for at least 30 days!

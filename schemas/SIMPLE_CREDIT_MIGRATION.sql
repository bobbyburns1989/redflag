-- =====================================================
-- Simple Credit Migration (No Transaction Logging)
-- Pink Flag v1.2.0
-- Created: 2025-12-04
-- =====================================================
--
-- This is a simplified version that:
-- 1. Backs up your credits
-- 2. Multiplies them by 10
-- 3. Verifies the change
-- (Skips transaction logging due to constraint issues)
--
-- =====================================================

-- =====================================================
-- STEP 1: Backup current credit data
-- =====================================================

CREATE TABLE IF NOT EXISTS credit_migration_backup_20251204 AS
SELECT
  id,
  credits as old_credits,
  updated_at as backed_up_at
FROM profiles
WHERE credits > 0;

-- Verify backup
SELECT
  'Backup Created' as step,
  COUNT(*) as users_with_credits,
  SUM(old_credits) as total_credits_before
FROM credit_migration_backup_20251204;

-- =====================================================
-- STEP 2: Apply 10x multiplier to all user credits
-- =====================================================

UPDATE profiles
SET
  credits = credits * 10,
  updated_at = NOW()
WHERE credits > 0;

-- =====================================================
-- STEP 3: Verification
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

-- Show your migrated credits
SELECT
  b.id,
  b.old_credits as before,
  p.credits as after,
  (p.credits::FLOAT / b.old_credits) as multiplier
FROM credit_migration_backup_20251204 b
INNER JOIN profiles p ON b.id = p.id
ORDER BY b.old_credits DESC;

-- Check that multiplier was applied correctly
SELECT
  'Multiplier Check' as verification,
  COUNT(*) as correctly_multiplied,
  CASE
    WHEN COUNT(*) = (SELECT COUNT(*) FROM credit_migration_backup_20251204)
    THEN '✅ SUCCESS - All credits multiplied by 10'
    ELSE '⚠️  Some credits may not have been multiplied'
  END as status
FROM credit_migration_backup_20251204 b
INNER JOIN profiles p ON b.id = p.id
WHERE p.credits = (b.old_credits * 10);

-- =====================================================
-- Final Report
-- =====================================================

SELECT
  '🎉 Credit Migration Complete' as status,
  COUNT(DISTINCT p.id) as total_users_migrated,
  SUM(b.old_credits) as total_old_credits,
  SUM(p.credits) as total_new_credits,
  (SUM(p.credits)::FLOAT / SUM(b.old_credits))::NUMERIC(10,2) as actual_multiplier,
  NOW() as migration_completed_at
FROM profiles p
INNER JOIN credit_migration_backup_20251204 b ON p.id = b.id
WHERE b.old_credits > 0;

-- =====================================================
-- END OF MIGRATION
-- =====================================================

/*
ROLLBACK SCRIPT - USE ONLY IF NEEDED:

UPDATE profiles p
SET credits = b.old_credits, updated_at = NOW()
FROM credit_migration_backup_20251204 b
WHERE p.id = b.id;

-- Then verify:
SELECT * FROM profiles WHERE id IN (SELECT id FROM credit_migration_backup_20251204);
*/

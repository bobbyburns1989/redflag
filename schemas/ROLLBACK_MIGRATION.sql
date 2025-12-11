-- =====================================================
-- ROLLBACK SCRIPT for BetTrndz Project
-- This will undo the 10x credit multiplier
-- =====================================================

-- Step 1: Restore credits from backup
UPDATE profiles p
SET
  credits = b.old_credits,
  updated_at = NOW()
FROM credit_migration_backup_20251204 b
WHERE p.id = b.id;

-- Step 2: Verify rollback worked
SELECT
  'Rollback Complete' as status,
  COUNT(*) as restored_users,
  SUM(credits) as total_credits_restored
FROM profiles p
INNER JOIN credit_migration_backup_20251204 b ON p.id = b.id;

-- Step 3: Show before/after to confirm
SELECT
  'Credits Restored' as verification,
  COUNT(*) as users_restored,
  CASE
    WHEN COUNT(*) = (SELECT COUNT(*) FROM credit_migration_backup_20251204)
    THEN '✅ All users restored to original credits'
    ELSE '⚠️ Some users may not have been restored'
  END as status
FROM profiles p
INNER JOIN credit_migration_backup_20251204 b ON p.id = b.id
WHERE p.credits = b.old_credits;

-- Step 4: Optional - Drop backup table (only after confirming rollback)
-- DROP TABLE credit_migration_backup_20251204;

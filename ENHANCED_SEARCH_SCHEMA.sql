-- Enhanced Search Database Schema
-- Version: 1.2.0
-- Date: November 28, 2025
-- Purpose: Add FBI wanted match tracking to searches table

-- ============================================================================
-- SCHEMA CHANGES
-- ============================================================================

-- Add FBI match tracking column to searches table
-- This allows analytics on how often FBI wanted persons are found in searches
ALTER TABLE searches
ADD COLUMN IF NOT EXISTS fbi_match BOOLEAN DEFAULT FALSE;

-- Add comment to document the column
COMMENT ON COLUMN searches.fbi_match IS
'TRUE if this search found a match on FBI Most Wanted list, FALSE otherwise. Used for analytics and security monitoring.';

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Create index for FBI match queries (for analytics dashboard)
-- This allows fast queries like "how many FBI matches this month?"
CREATE INDEX IF NOT EXISTS idx_searches_fbi_match
ON searches(user_id, fbi_match, created_at)
WHERE fbi_match = TRUE;

-- Create composite index for user's FBI match history
CREATE INDEX IF NOT EXISTS idx_searches_user_fbi
ON searches(user_id, created_at DESC)
WHERE fbi_match = TRUE;

-- ============================================================================
-- ANALYTICS QUERIES (Examples)
-- ============================================================================

-- Count total FBI matches (all time)
-- SELECT COUNT(*) as total_fbi_matches
-- FROM searches
-- WHERE fbi_match = TRUE;

-- Count FBI matches this month
-- SELECT COUNT(*) as monthly_fbi_matches
-- FROM searches
-- WHERE fbi_match = TRUE
--   AND created_at >= date_trunc('month', CURRENT_DATE);

-- FBI matches by user (top 10)
-- SELECT user_id, COUNT(*) as fbi_match_count
-- FROM searches
-- WHERE fbi_match = TRUE
-- GROUP BY user_id
-- ORDER BY fbi_match_count DESC
-- LIMIT 10;

-- FBI match rate (percentage of searches that find FBI wanted persons)
-- SELECT
--   COUNT(*) FILTER (WHERE fbi_match = TRUE) as fbi_matches,
--   COUNT(*) as total_searches,
--   (COUNT(*) FILTER (WHERE fbi_match = TRUE)::FLOAT / COUNT(*) * 100) as match_rate_percent
-- FROM searches;

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

-- FBI match field should be:
-- - Readable by user who performed the search
-- - Readable by admin/analytics
-- - Not writable by users (only by backend RPC functions)

-- Note: Existing RLS policies on searches table should already cover this
-- No changes needed unless you want specific FBI match policies

-- ============================================================================
-- TESTING
-- ============================================================================

-- Verify column was added
-- SELECT column_name, data_type, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'searches' AND column_name = 'fbi_match';

-- Verify indexes were created
-- SELECT indexname, indexdef
-- FROM pg_indexes
-- WHERE tablename = 'searches' AND indexname LIKE '%fbi%';

-- ============================================================================
-- ROLLBACK (if needed)
-- ============================================================================

-- To rollback these changes:
-- DROP INDEX IF EXISTS idx_searches_fbi_match;
-- DROP INDEX IF EXISTS idx_searches_user_fbi;
-- ALTER TABLE searches DROP COLUMN IF EXISTS fbi_match;

-- ============================================================================
-- NOTES
-- ============================================================================

-- 1. This schema is backwards compatible - existing searches will have fbi_match = FALSE
-- 2. The column is nullable to distinguish between "checked and no match" (FALSE)
--    vs "not checked yet" (NULL), though we default to FALSE for simplicity
-- 3. Indexes are partial (WHERE fbi_match = TRUE) for efficiency since most searches
--    won't match FBI wanted list
-- 4. Consider adding a migration script if you have millions of existing rows
-- 5. FBI match data is sensitive - ensure proper RLS policies are in place

-- ============================================================================
-- DEPLOYMENT INSTRUCTIONS
-- ============================================================================

-- 1. Backup your database before applying schema changes
-- 2. Run this SQL in Supabase SQL Editor
-- 3. Verify with test queries above
-- 4. Update application code to use fbi_match field (already done in v1.2.0)
-- 5. Monitor FBI match rate in analytics dashboard

-- ============================================================================

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

-- =====================================================
-- Credit Deduction System - Database Schema
-- Pink Flag v1.1.8
-- Created: November 30, 2025
-- =====================================================

-- =====================================================
-- 1. Create deduct_credit_for_search() function
-- =====================================================
--
-- This function atomically validates and deducts credits before performing a search.
-- It prevents race conditions and ensures users cannot manipulate their credit balance.
--
-- Returns JSON with:
--   - success: TRUE if credit deducted, FALSE if insufficient credits
--   - search_id: UUID of created search record (only if success)
--   - credits: Remaining credits after deduction (or current if insufficient)
--   - error: Error code if failed (e.g., "insufficient_credits")

CREATE OR REPLACE FUNCTION deduct_credit_for_search(
  p_user_id UUID,
  p_query TEXT,
  p_results_count INT DEFAULT 0,
  p_cost INT DEFAULT 1
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_credits INT;
  v_new_credits INT;
  v_search_id UUID;
  v_transaction_id UUID;
BEGIN
  -- STEP 1: Get current credits (with row lock to prevent race conditions)
  SELECT credits INTO v_current_credits
  FROM users
  WHERE id = p_user_id
  FOR UPDATE;  -- Lock this row until transaction completes

  -- Check if user exists
  IF v_current_credits IS NULL THEN
    RETURN json_build_object(
      'success', FALSE,
      'error', 'user_not_found',
      'credits', 0,
      'message', 'User not found'
    );
  END IF;

  -- STEP 2: Validate sufficient credits
  IF v_current_credits < p_cost THEN
    RETURN json_build_object(
      'success', FALSE,
      'error', 'insufficient_credits',
      'credits', v_current_credits,
      'message', 'Insufficient credits. You need ' || p_cost || ' credit(s) but only have ' || v_current_credits || '.'
    );
  END IF;

  -- STEP 3: Deduct credits
  v_new_credits := v_current_credits - p_cost;

  UPDATE users
  SET
    credits = v_new_credits,
    updated_at = NOW()
  WHERE id = p_user_id;

  -- STEP 4: Record credit deduction transaction
  INSERT INTO credit_transactions (
    user_id,
    transaction_type,
    credits,
    status,
    provider,
    created_at
  ) VALUES (
    p_user_id,
    'deduct',
    p_cost,
    'completed',
    'search',  -- Source of deduction
    NOW()
  )
  RETURNING id INTO v_transaction_id;

  -- STEP 5: Create search record in searches table
  -- Note: search_type will be updated by backend after API call
  INSERT INTO searches (
    user_id,
    query,
    search_type,
    results_count,
    refunded,
    created_at,
    updated_at
  ) VALUES (
    p_user_id,
    p_query,
    'pending',  -- Will be updated to 'name', 'image', or 'phone' by backend
    p_results_count,
    FALSE,
    NOW(),
    NOW()
  )
  RETURNING id INTO v_search_id;

  -- STEP 6: Return success response
  RETURN json_build_object(
    'success', TRUE,
    'search_id', v_search_id,
    'credits', v_new_credits,
    'transaction_id', v_transaction_id,
    'message', 'Credit deducted successfully. Remaining credits: ' || v_new_credits
  );

EXCEPTION
  WHEN OTHERS THEN
    -- Rollback is automatic for function failures
    RETURN json_build_object(
      'success', FALSE,
      'error', 'database_error',
      'message', SQLERRM
    );
END;
$$;

COMMENT ON FUNCTION deduct_credit_for_search IS 'Atomically validates and deducts credits before performing a search. Prevents race conditions and credit manipulation.';

-- =====================================================
-- 2. Create update_search_results() helper function
-- =====================================================
--
-- Updates search record with actual results count after API call completes.
-- Also updates the search_type from 'pending' to the actual type.

CREATE OR REPLACE FUNCTION update_search_results(
  p_search_id UUID,
  p_results_count INT,
  p_search_type TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Update search record with results
  UPDATE searches
  SET
    results_count = p_results_count,
    search_type = COALESCE(p_search_type, search_type),  -- Only update if provided
    updated_at = NOW()
  WHERE id = p_search_id;

  -- Verify update succeeded
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', FALSE,
      'error', 'search_not_found',
      'message', 'Search record not found'
    );
  END IF;

  RETURN json_build_object(
    'success', TRUE,
    'message', 'Search results updated successfully'
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', FALSE,
      'error', 'database_error',
      'message', SQLERRM
    );
END;
$$;

COMMENT ON FUNCTION update_search_results IS 'Updates search record with actual results count after API call completes';

-- =====================================================
-- 3. Grant execute permissions
-- =====================================================

-- Allow authenticated users to call these functions
GRANT EXECUTE ON FUNCTION deduct_credit_for_search(UUID, TEXT, INT, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION deduct_credit_for_search(UUID, TEXT, INT, INT) TO service_role;

GRANT EXECUTE ON FUNCTION update_search_results(UUID, INT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION update_search_results(UUID, INT, TEXT) TO service_role;

-- =====================================================
-- 4. Add index for pending searches (optional cleanup)
-- =====================================================

-- Index for finding pending searches (if you want to clean up orphaned records)
CREATE INDEX IF NOT EXISTS idx_searches_pending
ON searches(search_type, created_at)
WHERE search_type = 'pending';

COMMENT ON INDEX idx_searches_pending IS 'Index for finding pending searches (not completed by backend)';

-- =====================================================
-- 5. Verification queries (run after applying schema)
-- =====================================================

-- Verify deduct_credit_for_search function exists
SELECT proname, prosrc
FROM pg_proc
WHERE proname = 'deduct_credit_for_search';

-- Verify update_search_results function exists
SELECT proname, prosrc
FROM pg_proc
WHERE proname = 'update_search_results';

-- Verify permissions
SELECT routine_name, grantee, privilege_type
FROM information_schema.routine_privileges
WHERE routine_name IN ('deduct_credit_for_search', 'update_search_results');

-- =====================================================
-- 6. Test the deduct function (optional)
-- =====================================================

-- Test credit deduction (replace USER_ID_HERE with actual UUID)
/*
SELECT deduct_credit_for_search(
  'USER_ID_HERE'::UUID,
  'Test Search Query',
  0,  -- results_count (will be updated later)
  1   -- cost (1 credit)
);
*/

-- Test with insufficient credits
-- (Set user credits to 0 first, then try deduct)
/*
UPDATE users SET credits = 0 WHERE id = 'USER_ID_HERE'::UUID;

SELECT deduct_credit_for_search(
  'USER_ID_HERE'::UUID,
  'Test Search',
  0,
  1
);
-- Should return: {"success": false, "error": "insufficient_credits", "credits": 0}
*/

-- Test update_search_results
/*
SELECT update_search_results(
  'SEARCH_ID_HERE'::UUID,
  5,      -- results_count
  'name'  -- search_type
);
*/

-- =====================================================
-- 7. View credit deduction history
-- =====================================================

-- View recent credit deductions
/*
SELECT
  ct.id,
  ct.user_id,
  ct.transaction_type,
  ct.credits as amount,
  ct.status,
  ct.provider,
  ct.created_at,
  s.query,
  s.search_type,
  s.results_count,
  s.refunded
FROM credit_transactions ct
LEFT JOIN searches s ON s.user_id = ct.user_id
  AND s.created_at >= ct.created_at
  AND s.created_at <= ct.created_at + INTERVAL '1 second'
WHERE ct.transaction_type = 'deduct'
ORDER BY ct.created_at DESC
LIMIT 20;
*/

-- =====================================================
-- 8. Cleanup orphaned pending searches (optional)
-- =====================================================

-- Find searches that are still "pending" after 1 hour (likely failed API calls)
/*
SELECT
  id,
  user_id,
  query,
  search_type,
  created_at,
  EXTRACT(EPOCH FROM (NOW() - created_at))/60 as minutes_ago
FROM searches
WHERE search_type = 'pending'
  AND created_at < NOW() - INTERVAL '1 hour'
ORDER BY created_at DESC;
*/

-- Cleanup old pending searches (run periodically)
/*
UPDATE searches
SET search_type = 'failed'
WHERE search_type = 'pending'
  AND created_at < NOW() - INTERVAL '1 hour';
*/

-- =====================================================
-- 9. Rollback script (in case of issues)
-- =====================================================

/*
-- ROLLBACK SCRIPT - RUN ONLY IF NEEDED

-- Drop functions
DROP FUNCTION IF EXISTS deduct_credit_for_search(UUID, TEXT, INT, INT);
DROP FUNCTION IF EXISTS update_search_results(UUID, INT, TEXT);

-- Drop index
DROP INDEX IF EXISTS idx_searches_pending;
*/

-- =====================================================
-- END OF SCHEMA
-- =====================================================

-- DEPLOYMENT INSTRUCTIONS:
-- 1. Backup your database
-- 2. Run this SQL in Supabase SQL Editor
-- 3. Verify with test queries above
-- 4. Test with a user that has credits
-- 5. Test with a user that has 0 credits (should fail)
-- 6. Monitor credit_transactions table for audit trail

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

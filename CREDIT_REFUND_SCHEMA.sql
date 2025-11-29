-- =====================================================
-- Credit Refund System - Database Schema
-- Pink Flag v1.1.7
-- Created: 2025-11-28
-- =====================================================

-- =====================================================
-- 1. Add 'refunded' column to searches table
-- =====================================================

ALTER TABLE searches
ADD COLUMN IF NOT EXISTS refunded BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN searches.refunded IS 'True if credit was refunded for this search due to API/service failure';

-- =====================================================
-- 2. Create index for refunded searches
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_searches_refunded
ON searches(refunded, user_id);

COMMENT ON INDEX idx_searches_refunded IS 'Index for filtering refunded searches by user';

-- =====================================================
-- 3. Create refund_credit_for_failed_search() function
-- =====================================================

CREATE OR REPLACE FUNCTION refund_credit_for_failed_search(
  p_user_id UUID,
  p_search_id UUID,
  p_reason TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_credits INT;
  v_new_credits INT;
  v_transaction_id UUID;
  v_already_refunded BOOLEAN;
BEGIN
  -- Check if search was already refunded (prevent double refunds)
  SELECT refunded INTO v_already_refunded
  FROM searches
  WHERE id = p_search_id;

  IF v_already_refunded = TRUE THEN
    -- Return error if already refunded
    RETURN json_build_object(
      'success', FALSE,
      'error', 'already_refunded',
      'message', 'This search has already been refunded'
    );
  END IF;

  -- Get current credits
  SELECT credits INTO v_current_credits
  FROM users
  WHERE id = p_user_id;

  IF v_current_credits IS NULL THEN
    RETURN json_build_object(
      'success', FALSE,
      'error', 'user_not_found',
      'message', 'User not found'
    );
  END IF;

  -- Add 1 credit back
  v_new_credits := v_current_credits + 1;

  -- Update user credits
  UPDATE users
  SET
    credits = v_new_credits,
    updated_at = NOW()
  WHERE id = p_user_id;

  -- Record refund transaction
  INSERT INTO credit_transactions (
    user_id,
    transaction_type,
    credits,
    status,
    provider,
    created_at
  ) VALUES (
    p_user_id,
    'refund',
    1,
    'completed',
    p_reason, -- Store refund reason in provider field
    NOW()
  )
  RETURNING id INTO v_transaction_id;

  -- Mark search as refunded
  UPDATE searches
  SET
    refunded = TRUE,
    updated_at = NOW()
  WHERE id = p_search_id;

  -- Return success with updated credits
  RETURN json_build_object(
    'success', TRUE,
    'credits', v_new_credits,
    'transaction_id', v_transaction_id,
    'refund_reason', p_reason,
    'message', 'Credit refunded successfully'
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

COMMENT ON FUNCTION refund_credit_for_failed_search IS 'Refunds 1 credit to user for a failed search (API errors, timeouts, etc.)';

-- =====================================================
-- 4. Grant execute permissions
-- =====================================================

-- Allow authenticated users to call the refund function
GRANT EXECUTE ON FUNCTION refund_credit_for_failed_search(UUID, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION refund_credit_for_failed_search(UUID, UUID, TEXT) TO service_role;

-- =====================================================
-- 5. Add RLS policy for refund transactions
-- =====================================================

-- Users can view their own refund transactions
-- (This may already exist for credit_transactions, but adding for completeness)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'credit_transactions'
    AND policyname = 'Users can view their refund transactions'
  ) THEN
    CREATE POLICY "Users can view their refund transactions"
    ON credit_transactions
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);
  END IF;
END$$;

-- =====================================================
-- 6. Verification queries (run after applying schema)
-- =====================================================

-- Verify refunded column exists
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'searches' AND column_name = 'refunded';

-- Verify index exists
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'searches' AND indexname = 'idx_searches_refunded';

-- Verify function exists
SELECT proname, prosrc
FROM pg_proc
WHERE proname = 'refund_credit_for_failed_search';

-- =====================================================
-- 7. Test the refund function (optional)
-- =====================================================

-- Test refund for a specific search
-- Replace with actual user_id and search_id
/*
SELECT refund_credit_for_failed_search(
  'USER_ID_HERE'::UUID,
  'SEARCH_ID_HERE'::UUID,
  'api_maintenance_503'
);
*/

-- View all refunded searches
/*
SELECT
  s.id,
  s.query,
  s.search_type,
  s.refunded,
  s.created_at,
  ct.provider as refund_reason
FROM searches s
LEFT JOIN credit_transactions ct
  ON ct.user_id = s.user_id
  AND ct.transaction_type = 'refund'
  AND ct.created_at >= s.created_at
WHERE s.refunded = TRUE
ORDER BY s.created_at DESC
LIMIT 10;
*/

-- =====================================================
-- 8. Rollback script (in case of issues)
-- =====================================================

/*
-- ROLLBACK SCRIPT - RUN ONLY IF NEEDED

-- Drop function
DROP FUNCTION IF EXISTS refund_credit_for_failed_search(UUID, UUID, TEXT);

-- Drop index
DROP INDEX IF EXISTS idx_searches_refunded;

-- Remove column
ALTER TABLE searches DROP COLUMN IF EXISTS refunded;

-- Drop RLS policy
DROP POLICY IF EXISTS "Users can view their refund transactions" ON credit_transactions;
*/

-- =====================================================
-- END OF SCHEMA
-- =====================================================

-- Run this script in Supabase SQL Editor
-- Then verify with the verification queries above

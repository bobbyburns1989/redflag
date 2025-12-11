-- =====================================================
-- FIXED Credit Deduction System - Database Schema
-- Pink Flag v1.1.8
-- Fixed: Changed 'users' to 'profiles' table
-- =====================================================

-- Drop existing functions first
DROP FUNCTION IF EXISTS deduct_credit_for_search(UUID, TEXT, INT, INT);
DROP FUNCTION IF EXISTS update_search_results(UUID, INT, TEXT);

-- =====================================================
-- 1. Create deduct_credit_for_search() function (FIXED)
-- =====================================================

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
  -- FIXED: Changed from 'users' to 'profiles'
  SELECT credits INTO v_current_credits
  FROM profiles
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
  -- FIXED: Changed from 'users' to 'profiles'
  v_new_credits := v_current_credits - p_cost;

  UPDATE profiles
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

-- =====================================================
-- 2. Create update_search_results() helper function
-- =====================================================

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
    search_type = COALESCE(p_search_type, search_type),
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

-- =====================================================
-- 3. Grant execute permissions
-- =====================================================

GRANT EXECUTE ON FUNCTION deduct_credit_for_search(UUID, TEXT, INT, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION deduct_credit_for_search(UUID, TEXT, INT, INT) TO service_role;

GRANT EXECUTE ON FUNCTION update_search_results(UUID, INT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION update_search_results(UUID, INT, TEXT) TO service_role;

-- =====================================================
-- 4. Add index for pending searches (optional cleanup)
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_searches_pending
ON searches(search_type, created_at)
WHERE search_type = 'pending';

-- =====================================================
-- END OF SCHEMA
-- =====================================================

-- ✅ FIXED: Changed 'users' table to 'profiles' table
-- This should resolve the "database_error" when deducting credits

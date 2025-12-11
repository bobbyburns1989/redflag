-- Fix RPC functions to return JSONB instead of JSON
-- This resolves the "JSON could not be generated" error with Supabase Python client

-- Fix deduct_credit_for_search return type
CREATE OR REPLACE FUNCTION deduct_credit_for_search(
  p_user_id UUID,
  p_query TEXT,
  p_results_count INT DEFAULT 0,
  p_cost INT DEFAULT 1
)
RETURNS JSONB  -- Changed from JSON to JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_credits INT;
  v_new_credits INT;
  v_search_id UUID;
  v_transaction_id UUID;
BEGIN
  -- Get current credits with row lock
  SELECT credits INTO v_current_credits
  FROM profiles
  WHERE id = p_user_id
  FOR UPDATE;

  -- Check if user exists
  IF v_current_credits IS NULL THEN
    RETURN jsonb_build_object(  -- Changed from json_build_object
      'success', FALSE,
      'error', 'user_not_found',
      'credits', 0,
      'message', 'User not found'
    );
  END IF;

  -- Validate sufficient credits
  IF v_current_credits < p_cost THEN
    RETURN jsonb_build_object(  -- Changed from json_build_object
      'success', FALSE,
      'error', 'insufficient_credits',
      'credits', v_current_credits,
      'message', 'Insufficient credits. You need ' || p_cost || ' credit(s) but only have ' || v_current_credits || '.'
    );
  END IF;

  -- Deduct credits
  v_new_credits := v_current_credits - p_cost;

  UPDATE profiles
  SET
    credits = v_new_credits,
    updated_at = NOW()
  WHERE id = p_user_id;

  -- Record credit deduction transaction
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
    'search',
    NOW()
  )
  RETURNING id INTO v_transaction_id;

  -- Create search record
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
    'pending',
    p_results_count,
    FALSE,
    NOW(),
    NOW()
  )
  RETURNING id INTO v_search_id;

  -- Return success
  RETURN jsonb_build_object(  -- Changed from json_build_object
    'success', TRUE,
    'search_id', v_search_id,
    'credits', v_new_credits,
    'transaction_id', v_transaction_id,
    'message', 'Credit deducted successfully. Remaining credits: ' || v_new_credits
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(  -- Changed from json_build_object
      'success', FALSE,
      'error', 'database_error',
      'credits', 0,
      'message', 'Database error: ' || SQLERRM
    );
END;
$$;

-- Fix refund_credit_for_failed_search return type
CREATE OR REPLACE FUNCTION refund_credit_for_failed_search(
  p_user_id UUID,
  p_search_id UUID,
  p_reason TEXT,
  p_amount INT DEFAULT 1
)
RETURNS JSONB  -- Changed from JSON to JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_credits INT;
  v_new_credits INT;
  v_transaction_id UUID;
BEGIN
  -- Get current credits
  SELECT credits INTO v_current_credits
  FROM profiles
  WHERE id = p_user_id;

  -- Check if user exists
  IF v_current_credits IS NULL THEN
    RETURN jsonb_build_object(  -- Changed from json_build_object
      'success', FALSE,
      'error', 'user_not_found',
      'credits', 0,
      'message', 'User not found'
    );
  END IF;

  -- Add credits back
  v_new_credits := v_current_credits + p_amount;

  UPDATE profiles
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
    p_amount,
    'completed',
    p_reason,
    NOW()
  )
  RETURNING id INTO v_transaction_id;

  -- Update search record to mark as refunded
  UPDATE searches
  SET
    refunded = TRUE,
    updated_at = NOW()
  WHERE id = p_search_id;

  -- Return success
  RETURN jsonb_build_object(  -- Changed from json_build_object
    'success', TRUE,
    'credits', v_new_credits,
    'transaction_id', v_transaction_id,
    'message', 'Credit refunded successfully. New balance: ' || v_new_credits
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(  -- Changed from json_build_object
      'success', FALSE,
      'error', 'database_error',
      'credits', v_current_credits,
      'message', 'Refund failed: ' || SQLERRM
    );
END;
$$;

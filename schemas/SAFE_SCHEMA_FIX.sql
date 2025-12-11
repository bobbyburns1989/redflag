-- =====================================================
-- SAFE Database Schema Fix for Pink Flag
-- Handles existing tables/policies gracefully
-- Run this in Supabase SQL Editor
-- =====================================================

-- =====================================================
-- STEP 1: Drop existing policies (if they exist)
-- =====================================================

DROP POLICY IF EXISTS "Users can view own searches" ON searches;
DROP POLICY IF EXISTS "Users can view own transactions" ON credit_transactions;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;

-- =====================================================
-- STEP 2: Create missing tables (if they don't exist)
-- =====================================================

CREATE TABLE IF NOT EXISTS searches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  query TEXT NOT NULL,
  search_type TEXT NOT NULL DEFAULT 'pending',
  results_count INT DEFAULT 0,
  refunded BOOLEAN DEFAULT FALSE,
  fbi_match BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS credit_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  transaction_type TEXT NOT NULL,
  credits INT NOT NULL,
  status TEXT DEFAULT 'completed',
  provider TEXT,
  provider_transaction_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  credits INT DEFAULT 10,  -- 10x multiplier applied (was 1)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- STEP 3: Add indexes (if they don't exist)
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_searches_user_id ON searches(user_id);
CREATE INDEX IF NOT EXISTS idx_searches_created_at ON searches(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_credit_transactions_user_id ON credit_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_id ON profiles(id);

-- =====================================================
-- STEP 4: Drop and recreate functions
-- =====================================================

DROP FUNCTION IF EXISTS deduct_credit_for_search(UUID, TEXT, INT, INT);
DROP FUNCTION IF EXISTS update_search_results(UUID, INT, TEXT);
DROP FUNCTION IF EXISTS refund_credit_for_failed_search(UUID, UUID, TEXT);

-- =====================================================
-- Create deduct_credit_for_search() function
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
  SELECT credits INTO v_current_credits
  FROM profiles
  WHERE id = p_user_id
  FOR UPDATE;

  IF v_current_credits IS NULL THEN
    RETURN json_build_object(
      'success', FALSE,
      'error', 'user_not_found',
      'credits', 0,
      'message', 'User not found'
    );
  END IF;

  IF v_current_credits < p_cost THEN
    RETURN json_build_object(
      'success', FALSE,
      'error', 'insufficient_credits',
      'credits', v_current_credits,
      'message', 'Insufficient credits'
    );
  END IF;

  v_new_credits := v_current_credits - p_cost;

  UPDATE profiles
  SET credits = v_new_credits, updated_at = NOW()
  WHERE id = p_user_id;

  INSERT INTO credit_transactions (
    user_id, transaction_type, credits, status, provider, created_at
  ) VALUES (
    p_user_id, 'deduct', p_cost, 'completed', 'search', NOW()
  ) RETURNING id INTO v_transaction_id;

  INSERT INTO searches (
    user_id, query, search_type, results_count, refunded, created_at, updated_at
  ) VALUES (
    p_user_id, p_query, 'pending', p_results_count, FALSE, NOW(), NOW()
  ) RETURNING id INTO v_search_id;

  RETURN json_build_object(
    'success', TRUE,
    'search_id', v_search_id,
    'credits', v_new_credits,
    'transaction_id', v_transaction_id,
    'message', 'Credit deducted'
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
-- Create update_search_results() function
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
  UPDATE searches
  SET
    results_count = p_results_count,
    search_type = COALESCE(p_search_type, search_type),
    updated_at = NOW()
  WHERE id = p_search_id;

  IF NOT FOUND THEN
    RETURN json_build_object('success', FALSE, 'error', 'search_not_found');
  END IF;

  RETURN json_build_object('success', TRUE);

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object('success', FALSE, 'error', 'database_error', 'message', SQLERRM);
END;
$$;

-- =====================================================
-- Create refund_credit_for_failed_search() function
-- =====================================================

CREATE OR REPLACE FUNCTION refund_credit_for_failed_search(
  p_user_id UUID,
  p_search_id UUID,
  p_reason TEXT DEFAULT 'api_error'
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_credits INT;
  v_new_credits INT;
  v_refund_amount INT DEFAULT 1;
BEGIN
  SELECT credits INTO v_current_credits
  FROM profiles
  WHERE id = p_user_id
  FOR UPDATE;

  IF v_current_credits IS NULL THEN
    RETURN json_build_object('success', FALSE, 'error', 'user_not_found');
  END IF;

  v_new_credits := v_current_credits + v_refund_amount;

  UPDATE profiles
  SET credits = v_new_credits, updated_at = NOW()
  WHERE id = p_user_id;

  UPDATE searches
  SET refunded = TRUE, updated_at = NOW()
  WHERE id = p_search_id;

  INSERT INTO credit_transactions (
    user_id, transaction_type, credits, status, provider, created_at
  ) VALUES (
    p_user_id, 'refund', v_refund_amount, 'completed', p_reason, NOW()
  );

  RETURN json_build_object('success', TRUE, 'credits', v_new_credits);

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object('success', FALSE, 'error', 'database_error', 'message', SQLERRM);
END;
$$;

-- =====================================================
-- STEP 5: Grant permissions
-- =====================================================

GRANT EXECUTE ON FUNCTION deduct_credit_for_search(UUID, TEXT, INT, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION deduct_credit_for_search(UUID, TEXT, INT, INT) TO service_role;

GRANT EXECUTE ON FUNCTION update_search_results(UUID, INT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION update_search_results(UUID, INT, TEXT) TO service_role;

GRANT EXECUTE ON FUNCTION refund_credit_for_failed_search(UUID, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION refund_credit_for_failed_search(UUID, UUID, TEXT) TO service_role;

-- =====================================================
-- STEP 6: Enable RLS and create policies
-- =====================================================

ALTER TABLE searches ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own searches" ON searches
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view own transactions" ON credit_transactions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- =====================================================
-- STEP 7: Create or replace trigger for auto-profiles
-- =====================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, credits, created_at, updated_at)
  VALUES (NEW.id, 10, NOW(), NOW())  -- 10x multiplier applied (was 1)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- SUCCESS! Schema is now ready.
-- =====================================================

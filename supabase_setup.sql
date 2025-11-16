-- Pink Flag - Supabase Database Setup Script
-- Run this in Supabase SQL Editor: https://app.supabase.com → SQL Editor

-- 1. Create profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    credits INTEGER DEFAULT 1,
    revenuecat_user_id TEXT UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create credit_transactions table
CREATE TABLE IF NOT EXISTS public.credit_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    credits_change INTEGER NOT NULL,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('purchase', 'search', 'bonus', 'admin')),
    revenuecat_transaction_id TEXT,
    balance_after INTEGER NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create searches table
CREATE TABLE IF NOT EXISTS public.searches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    query TEXT NOT NULL,
    filters JSONB,
    results_count INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Create indexes
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_revenuecat ON public.profiles(revenuecat_user_id);
CREATE INDEX IF NOT EXISTS idx_credit_transactions_user_id ON public.credit_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_searches_user_id ON public.searches(user_id);

-- 5. Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.searches ENABLE ROW LEVEL SECURITY;

-- 6. Create RLS Policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can view own transactions" ON public.credit_transactions;
CREATE POLICY "Users can view own transactions"
    ON public.credit_transactions FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view own searches" ON public.searches;
CREATE POLICY "Users can view own searches"
    ON public.searches FOR SELECT
    USING (auth.uid() = user_id);

-- 7. Function: Create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, credits, revenuecat_user_id)
    VALUES (
        NEW.id,
        NEW.email,
        1,  -- Free search on signup
        NEW.id::TEXT
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Trigger: Auto-create profile when user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 9. Function: Deduct credit for search
CREATE OR REPLACE FUNCTION public.deduct_credit_for_search(
    p_user_id UUID,
    p_query TEXT,
    p_results_count INTEGER DEFAULT 0
)
RETURNS JSON AS $$
DECLARE
    v_current_credits INTEGER;
    v_new_balance INTEGER;
    v_search_id UUID;
BEGIN
    -- Get current credits (with row lock)
    SELECT credits INTO v_current_credits
    FROM public.profiles
    WHERE id = p_user_id
    FOR UPDATE;

    -- Check if user has credits
    IF v_current_credits < 1 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'insufficient_credits',
            'credits', v_current_credits
        );
    END IF;

    -- Deduct credit
    UPDATE public.profiles
    SET credits = credits - 1,
        updated_at = NOW()
    WHERE id = p_user_id
    RETURNING credits INTO v_new_balance;

    -- Log search
    INSERT INTO public.searches (user_id, query, results_count)
    VALUES (p_user_id, p_query, p_results_count)
    RETURNING id INTO v_search_id;

    -- Log transaction
    INSERT INTO public.credit_transactions (
        user_id,
        credits_change,
        transaction_type,
        balance_after
    ) VALUES (
        p_user_id,
        -1,
        'search',
        v_new_balance
    );

    RETURN json_build_object(
        'success', true,
        'credits', v_new_balance,
        'search_id', v_search_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Function: Add credits from purchase
CREATE OR REPLACE FUNCTION public.add_credits_from_purchase(
    p_user_id UUID,
    p_credits_to_add INTEGER,
    p_revenuecat_transaction_id TEXT,
    p_notes TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_new_balance INTEGER;
BEGIN
    -- Check if transaction already processed
    IF EXISTS (
        SELECT 1 FROM public.credit_transactions
        WHERE revenuecat_transaction_id = p_revenuecat_transaction_id
    ) THEN
        SELECT credits INTO v_new_balance
        FROM public.profiles
        WHERE id = p_user_id;

        RETURN json_build_object(
            'success', true,
            'duplicate', true,
            'credits', v_new_balance
        );
    END IF;

    -- Add credits
    UPDATE public.profiles
    SET credits = credits + p_credits_to_add,
        updated_at = NOW()
    WHERE id = p_user_id
    RETURNING credits INTO v_new_balance;

    -- Log transaction
    INSERT INTO public.credit_transactions (
        user_id,
        credits_change,
        transaction_type,
        revenuecat_transaction_id,
        balance_after,
        notes
    ) VALUES (
        p_user_id,
        p_credits_to_add,
        'purchase',
        p_revenuecat_transaction_id,
        v_new_balance,
        p_notes
    );

    RETURN json_build_object(
        'success', true,
        'credits', v_new_balance,
        'credits_added', p_credits_to_add
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON public.profiles TO anon, authenticated;
GRANT SELECT ON public.credit_transactions TO authenticated;
GRANT SELECT ON public.searches TO authenticated;
GRANT EXECUTE ON FUNCTION public.deduct_credit_for_search TO authenticated;
GRANT EXECUTE ON FUNCTION public.add_credits_from_purchase TO authenticated;

-- Success message
SELECT 'Database setup complete!' AS status;

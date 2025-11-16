-- Add constraint to prevent negative credits
-- This protects against race conditions where two concurrent searches
-- could both check credits before either one deducts

-- Add the constraint
ALTER TABLE public.profiles
ADD CONSTRAINT positive_credits CHECK (credits >= 0);

-- Verify the constraint was added
SELECT
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'public.profiles'::regclass
AND conname = 'positive_credits';

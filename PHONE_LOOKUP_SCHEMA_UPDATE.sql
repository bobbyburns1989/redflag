-- Phone Lookup Feature - Database Schema Updates
-- Pink Flag v1.1.6
-- Run this in Supabase SQL Editor: https://app.supabase.com → SQL Editor

-- 1. Add columns to searches table to support phone lookups
ALTER TABLE public.searches
ADD COLUMN IF NOT EXISTS search_type TEXT DEFAULT 'name',
ADD COLUMN IF NOT EXISTS phone_number TEXT;

-- 2. Add check constraint for search_type
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'searches_search_type_check'
    ) THEN
        ALTER TABLE public.searches
        ADD CONSTRAINT searches_search_type_check
        CHECK (search_type IN ('name', 'phone', 'image'));
    END IF;
END $$;

-- 3. Create index on phone_number for faster lookups
CREATE INDEX IF NOT EXISTS idx_searches_phone_number
ON public.searches(phone_number);

-- 4. Create index on search_type
CREATE INDEX IF NOT EXISTS idx_searches_search_type
ON public.searches(search_type);

-- 5. Update existing searches to have search_type = 'name'
UPDATE public.searches
SET search_type = CASE
    WHEN phone_number IS NOT NULL THEN 'phone'
    WHEN query LIKE '%image%' OR query LIKE '%photo%' THEN 'image'
    ELSE 'name'
END
WHERE search_type IS NULL;

-- 6. Verify the changes
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'searches'
AND column_name IN ('search_type', 'phone_number')
ORDER BY ordinal_position;

-- Success message
SELECT 'Phone lookup schema updates complete!' AS status;

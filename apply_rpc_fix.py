#!/usr/bin/env python3
"""
Apply RPC function fix to Supabase database.
Changes return type from JSON to JSONB to fix client parsing issues.
"""

import os
import sys

# Add backend directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'backend'))

from supabase import create_client

# Supabase credentials
SUPABASE_URL = "https://qjbtmrbbjivniveptdjl.supabase.co"
SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqYnRtcmJiaml2bml2ZXB0ZGpsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjQzOTg0MywiZXhwIjoyMDc4MDE1ODQzfQ.aJAe8N-oT-xmh1Dh_rfjUpKGjlCqk44b7zoWQUj4MII"

# Read the SQL migration file
with open('schemas/FIX_RPC_JSON_RETURN_TYPE.sql', 'r') as f:
    sql_content = f.read()

print("🔧 Applying RPC function fix to database...")
print("=" * 60)

try:
    # Create Supabase admin client
    supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    # Split SQL into individual statements
    statements = [s.strip() for s in sql_content.split(';') if s.strip() and not s.strip().startswith('--')]

    print(f"📝 Found {len(statements)} SQL statements to execute\n")

    for i, statement in enumerate(statements, 1):
        # Show first 100 chars of statement
        preview = statement[:100].replace('\n', ' ')
        if len(statement) > 100:
            preview += "..."

        print(f"[{i}/{len(statements)}] Executing: {preview}")

        try:
            # Execute using raw SQL via RPC (if available) or direct query
            # Note: Supabase Python client doesn't have direct SQL execution
            # We'll need to use PostgreSQL connection instead
            print(f"  ⚠️  Cannot execute via Supabase Python client")
            print(f"  ℹ️  Please run this manually in Supabase SQL Editor")

        except Exception as e:
            print(f"  ❌ Error: {e}")
            raise

    print("\n" + "=" * 60)
    print("❌ Migration requires manual execution")
    print("\nPlease:")
    print("1. Go to: https://supabase.com/dashboard/project/qjbtmrbbjivniveptdjl/sql/new")
    print("2. Copy and paste the contents of: schemas/FIX_RPC_JSON_RETURN_TYPE.sql")
    print("3. Click 'Run' to execute")

except Exception as e:
    print(f"\n❌ Migration failed: {e}")
    sys.exit(1)

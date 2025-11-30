"""
Supabase Client Service

Provides a singleton Supabase client for backend operations.
Used for server-side credit validation, user management, and database operations.

This client uses the service role key for admin operations (bypassing RLS).
"""

import os
from typing import Optional
from supabase import create_client, Client
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Supabase configuration
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")  # Admin key for backend
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")  # Public key (for RLS-aware operations)

# Global client instance (singleton pattern)
_supabase_client: Optional[Client] = None
_supabase_admin_client: Optional[Client] = None


def get_supabase_client(use_service_role: bool = False) -> Client:
    """
    Get or create a Supabase client instance.

    Args:
        use_service_role: If True, uses service role key (bypasses RLS).
                         If False, uses anon key (respects RLS).

    Returns:
        Client: Supabase client instance

    Raises:
        ValueError: If Supabase credentials are not configured

    Usage:
        # For admin operations (bypass RLS)
        admin_client = get_supabase_client(use_service_role=True)

        # For user operations (respect RLS) - typically use JWT instead
        client = get_supabase_client(use_service_role=False)
    """
    global _supabase_client, _supabase_admin_client

    if not SUPABASE_URL:
        raise ValueError("SUPABASE_URL environment variable is not set")

    if use_service_role:
        # Admin client with service role key (bypasses RLS)
        if not SUPABASE_SERVICE_ROLE_KEY:
            raise ValueError(
                "SUPABASE_SERVICE_ROLE_KEY environment variable is not set. "
                "Get this from Supabase Dashboard > Settings > API > service_role key"
            )

        if _supabase_admin_client is None:
            _supabase_admin_client = create_client(
                SUPABASE_URL,
                SUPABASE_SERVICE_ROLE_KEY
            )

        return _supabase_admin_client
    else:
        # Standard client with anon key (respects RLS)
        if not SUPABASE_ANON_KEY:
            raise ValueError("SUPABASE_ANON_KEY environment variable is not set")

        if _supabase_client is None:
            _supabase_client = create_client(
                SUPABASE_URL,
                SUPABASE_ANON_KEY
            )

        return _supabase_client


def get_admin_client() -> Client:
    """
    Convenience method to get admin client (service role).

    Returns:
        Client: Supabase admin client that bypasses RLS

    Usage:
        admin = get_admin_client()
        result = admin.table('profiles').select('*').execute()
    """
    return get_supabase_client(use_service_role=True)


def get_user_client() -> Client:
    """
    Convenience method to get user client (anon key).

    Note: This client respects RLS. For authenticated operations,
    you should set the user's JWT token:

        client = get_user_client()
        client.auth.set_session(access_token, refresh_token)

    Returns:
        Client: Supabase client that respects RLS
    """
    return get_supabase_client(use_service_role=False)

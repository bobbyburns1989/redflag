"""
Authentication Middleware for Supabase JWT Validation

This middleware validates Supabase JWT tokens on protected endpoints.
It extracts the user ID from the token and attaches it to the request state.

Usage:
    from middleware.auth import require_auth, get_current_user

    @router.post("/protected-endpoint", dependencies=[Depends(require_auth)])
    async def protected_route(request: Request):
        user_id = get_current_user(request)
        # Use user_id for authorization logic
"""

from fastapi import Request, HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
from typing import Optional
import os

# Security scheme for Swagger UI
security = HTTPBearer()

# Get Supabase JWT secret from environment
# This is the secret key used to sign JWT tokens
# Find it in Supabase Dashboard > Settings > API > JWT Settings > JWT Secret
SUPABASE_JWT_SECRET = os.getenv("SUPABASE_JWT_SECRET")

def get_current_user(request: Request) -> str:
    """
    Extract the current user ID from the request state.

    This should only be called after require_auth dependency has run.

    Args:
        request: FastAPI request object

    Returns:
        str: User ID from the JWT token

    Raises:
        HTTPException: If user_id is not found in request state
    """
    user_id = getattr(request.state, "user_id", None)
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not authenticated"
        )
    return user_id


async def require_auth(
    request: Request,
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> str:
    """
    Dependency that validates Supabase JWT token and extracts user ID.

    This function:
    1. Checks for Authorization header
    2. Validates JWT signature using Supabase JWT secret
    3. Extracts user ID from token payload
    4. Attaches user_id to request.state for downstream use

    Args:
        request: FastAPI request object
        credentials: HTTP Bearer token from Authorization header

    Returns:
        str: User ID from the validated token

    Raises:
        HTTPException 401: If token is missing, invalid, or expired
        HTTPException 500: If SUPABASE_JWT_SECRET is not configured
    """
    # Check if JWT secret is configured
    if not SUPABASE_JWT_SECRET:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Server configuration error: JWT secret not configured"
        )

    # Extract token from Authorization header
    token = credentials.credentials

    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        # Decode and validate JWT token
        # Supabase uses HS256 algorithm for JWT signing
        payload = jwt.decode(
            token,
            SUPABASE_JWT_SECRET,
            algorithms=["HS256"],
            options={
                "verify_signature": True,
                "verify_exp": True,  # Verify token hasn't expired
                "verify_aud": False,  # Don't verify audience
            }
        )

        # Extract user ID from token payload
        # Supabase stores user ID in 'sub' (subject) claim
        user_id: Optional[str] = payload.get("sub")

        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token: missing user ID",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Attach user_id to request state for downstream use
        request.state.user_id = user_id

        return user_id

    except JWTError as e:
        # Token is invalid or expired
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid or expired token: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except Exception as e:
        # Unexpected error during token validation
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Token validation error: {str(e)}"
        )


async def optional_auth(
    request: Request,
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(HTTPBearer(auto_error=False))
) -> Optional[str]:
    """
    Optional authentication dependency.

    Similar to require_auth but doesn't raise an error if no token is provided.
    Useful for endpoints that work differently for authenticated vs anonymous users.

    Args:
        request: FastAPI request object
        credentials: Optional HTTP Bearer token

    Returns:
        Optional[str]: User ID if token is valid, None if no token provided
    """
    if not credentials:
        return None

    try:
        return await require_auth(request, credentials)
    except HTTPException:
        return None

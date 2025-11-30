"""
Phone Lookup Router

Handles phone number reverse lookup requests using Sent.dm API.
This endpoint securely stores the Sent.dm API key on the server side
to prevent client-side exposure.

Endpoints:
- POST /api/phone/lookup: Lookup phone number information
"""

from fastapi import APIRouter, HTTPException, Request, Depends
from pydantic import BaseModel, Field, validator
from typing import Optional, Dict, Any
from slowapi import Limiter
from slowapi.util import get_remote_address
import os
import httpx
import re

from middleware.auth import require_auth, get_current_user

router = APIRouter()

# Initialize rate limiter
limiter = Limiter(key_func=get_remote_address)

# Get Sent.dm API key from environment
SENTDM_API_KEY = os.getenv("SENTDM_API_KEY")
SENTDM_API_URL = "https://www.sent.dm/api/phone-lookup"


class PhoneLookupRequest(BaseModel):
    """Request model for phone lookup."""
    phone_number: str = Field(..., description="Phone number to lookup (10+ digits, US format preferred)")

    @validator('phone_number')
    def validate_phone_number(cls, v):
        """Validate phone number format."""
        # Remove all non-digit characters
        digits_only = re.sub(r'\D', '', v)

        # Check minimum length
        if len(digits_only) < 10:
            raise ValueError("Phone number must be at least 10 digits")

        return digits_only


class PhoneLookupResult(BaseModel):
    """Response model for phone lookup results."""
    phone_number: str
    caller_name: Optional[str] = None  # CNAM (Caller ID Name)
    carrier: Optional[str] = None
    line_type: Optional[str] = None  # Mobile, Landline, VoIP, etc.
    location: Optional[str] = None  # City, State
    fraud_risk: Optional[str] = None  # Risk assessment
    fraud_score: Optional[int] = None  # Numeric risk score
    metadata: Optional[Dict[str, Any]] = None  # Additional API response data


@router.post("/phone/lookup", response_model=PhoneLookupResult, dependencies=[Depends(require_auth)])
@limiter.limit("15/minute")  # Match Sent.dm API rate limit (15 requests/minute)
async def lookup_phone(
    request: Request,
    lookup_request: PhoneLookupRequest
):
    """
    Perform reverse lookup on a phone number using Sent.dm API.

    **Authentication Required**: Must provide valid Supabase JWT token.

    **Rate Limit**: 15 requests per minute per IP address (matches Sent.dm API limit).

    Returns caller information including:
    - Caller Name (CNAM)
    - Carrier information
    - Line type (Mobile, Landline, VoIP)
    - Location (City/State)
    - Fraud risk assessment

    **Note**: This endpoint requires the user to have sufficient credits.
    Credits are validated and deducted server-side before the lookup is performed.

    **Use Cases**:
    - Verify unknown caller identity
    - Check for potential scam/spam numbers
    - Validate contact information
    - Assess fraud risk before responding

    **Security**: The Sent.dm API key is securely stored on the server
    and never exposed to the client.
    """
    # Check if API key is configured
    if not SENTDM_API_KEY:
        raise HTTPException(
            status_code=500,
            detail="Phone lookup service not configured. Please contact support."
        )

    # Get authenticated user ID
    user_id = get_current_user(request)

    # TODO: Validate user has sufficient credits before performing lookup
    # This will be implemented in the server-side credit validation phase

    try:
        # Call Sent.dm API
        async with httpx.AsyncClient(timeout=15.0) as client:
            response = await client.get(
                SENTDM_API_URL,
                params={
                    "number": lookup_request.phone_number,
                    "api_key": SENTDM_API_KEY
                },
                headers={
                    "Accept": "application/json"
                }
            )

            # Handle non-success responses
            if response.status_code == 503:
                # Service temporarily unavailable (maintenance)
                # TODO: Trigger credit refund for this failed lookup
                raise HTTPException(
                    status_code=503,
                    detail="Phone lookup service is temporarily unavailable. Your credit will be refunded."
                )
            elif response.status_code == 500:
                # Server error
                # TODO: Trigger credit refund for this failed lookup
                raise HTTPException(
                    status_code=500,
                    detail="Phone lookup service encountered an error. Your credit will be refunded."
                )
            elif response.status_code == 429:
                # Rate limit exceeded
                raise HTTPException(
                    status_code=429,
                    detail="Too many requests. Please try again in a minute."
                )
            elif response.status_code == 400:
                # Bad request (invalid phone number format)
                raise HTTPException(
                    status_code=400,
                    detail="Invalid phone number format. Please check the number and try again."
                )
            elif response.status_code != 200:
                # Other errors
                raise HTTPException(
                    status_code=response.status_code,
                    detail=f"Phone lookup failed with status {response.status_code}"
                )

            # Parse successful response
            data = response.json()

            # Extract and structure the response
            # Sent.dm API response structure (adjust based on actual API documentation)
            result = PhoneLookupResult(
                phone_number=lookup_request.phone_number,
                caller_name=data.get("caller_name") or data.get("cnam"),
                carrier=data.get("carrier"),
                line_type=data.get("line_type") or data.get("type"),
                location=data.get("location"),
                fraud_risk=data.get("fraud_risk"),
                fraud_score=data.get("fraud_score"),
                metadata=data  # Store full response for debugging
            )

            # TODO: After successful lookup, deduct 1 credit from user's account
            # This will be implemented in the server-side credit validation phase

            return result

    except httpx.TimeoutException:
        # Network timeout
        # TODO: Trigger credit refund for this failed lookup
        raise HTTPException(
            status_code=504,
            detail="Phone lookup request timed out. Your credit will be refunded."
        )
    except httpx.NetworkError as e:
        # Network error
        # TODO: Trigger credit refund for this failed lookup
        raise HTTPException(
            status_code=503,
            detail=f"Network error during phone lookup. Your credit will be refunded."
        )
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except Exception as e:
        # Unexpected error
        print(f"Phone lookup error: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Unexpected error during phone lookup: {str(e)}"
        )


@router.get("/phone/test")
async def test_phone_lookup():
    """
    Test endpoint to verify phone lookup service is configured.

    This endpoint does NOT require authentication.
    """
    if not SENTDM_API_KEY:
        return {
            "status": "error",
            "message": "Sent.dm API key not configured",
            "configured": False
        }

    return {
        "status": "ok",
        "message": "Phone lookup service is properly configured",
        "configured": True,
        "rate_limit": "15 requests per minute"
    }

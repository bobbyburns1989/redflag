"""
Phone Lookup Router

Handles phone number reverse lookup requests using Twilio Lookup API v2.
Twilio credentials are stored on the server side to prevent client-side exposure.

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
from services.credit_service import get_credit_service, InsufficientCreditsError

router = APIRouter()

# Initialize rate limiter (protects Twilio cost exposure)
limiter = Limiter(key_func=get_remote_address)

# Initialize credit service
credit_service = get_credit_service()

# Get Twilio credentials from environment
TWILIO_ACCOUNT_SID = os.getenv("TWILIO_ACCOUNT_SID")
TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN")
TWILIO_LOOKUP_URL = "https://lookups.twilio.com/v2/PhoneNumbers"


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
@limiter.limit("15/minute")  # App-level guardrail to control Twilio spend
async def lookup_phone(
    request: Request,
    lookup_request: PhoneLookupRequest
):
    """
    Perform reverse lookup on a phone number using Twilio Lookup API v2.

    **Authentication Required**: Must provide valid Supabase JWT token.

    **Rate Limit**: 15 requests per minute per IP address.

    Returns caller information including:
    - Caller Name (CNAM)
    - Carrier information
    - Line type (Mobile, Landline, VoIP)
    - Country code

    **Note**: This endpoint requires the user to have sufficient credits.
    Credits are validated and deducted server-side before the lookup is performed.

    **Cost**: $0.018 per lookup ($0.008 for Line Type Intelligence + $0.01 for Caller Name)

    **Use Cases**:
    - Verify unknown caller identity
    - Check for potential scam/spam numbers
    - Validate contact information
    - Identify line type (mobile vs landline)

    **Security**: Twilio credentials are securely stored on the server
    and never exposed to the client.
    """
    # Check if Twilio credentials are configured
    if not TWILIO_ACCOUNT_SID or not TWILIO_AUTH_TOKEN:
        raise HTTPException(
            status_code=500,
            detail="Phone lookup service not configured. Please contact support."
        )

    # Get authenticated user ID
    user_id = get_current_user(request)

    try:
        # STEP 1: Validate and deduct credit BEFORE performing lookup
        # Phone searches cost 2 credits due to Twilio API pricing ($0.018/lookup)
        credit_result = await credit_service.check_and_deduct_credit(
            user_id=user_id,
            search_type="phone",
            query=lookup_request.phone_number,
            cost=2
        )

        search_id = credit_result["search_id"]
        remaining_credits = credit_result["credits"]

        # STEP 2: Call Twilio Lookup API v2
        async with httpx.AsyncClient(timeout=15.0) as client:
            # Format phone number for URL (E.164 format with + prefix)
            phone_number = lookup_request.phone_number
            if not phone_number.startswith('+'):
                phone_number = f'+{phone_number}'

            response = await client.get(
                f"{TWILIO_LOOKUP_URL}/{phone_number}",
                params={
                    "Fields": "line_type_intelligence,caller_name"
                },
                auth=(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN),
                headers={
                    "Accept": "application/json"
                }
            )

            # Handle non-success responses
            if response.status_code == 503:
                # Service temporarily unavailable (maintenance)
                # Refund credit for service unavailability
                await credit_service.refund_credit(
                    user_id=user_id,
                    search_id=search_id,
                    reason="api_maintenance_503",
                    amount=2
                )
                raise HTTPException(
                    status_code=503,
                    detail="Phone lookup service is temporarily unavailable. Your credit has been refunded."
                )
            elif response.status_code == 500:
                # Server error
                # Refund credit for server error
                await credit_service.refund_credit(
                    user_id=user_id,
                    search_id=search_id,
                    reason="server_error_500",
                    amount=2
                )
                raise HTTPException(
                    status_code=500,
                    detail="Phone lookup service encountered an error. Your credit has been refunded."
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
            # Twilio Lookup API v2 response structure
            line_type_intel = data.get("line_type_intelligence", {})
            caller_name_data = data.get("caller_name", {})

            result = PhoneLookupResult(
                phone_number=data.get("phone_number", lookup_request.phone_number),
                caller_name=caller_name_data.get("caller_name"),
                carrier=line_type_intel.get("carrier_name"),
                line_type=line_type_intel.get("type"),  # mobile, landline, voip, etc.
                location=f"{data.get('country_code', '')}",  # Twilio provides country code
                fraud_risk=None,  # Available with SMS Pumping Risk package ($0.025 extra)
                fraud_score=None,  # Available with SMS Pumping Risk package
                metadata=data  # Store full response for debugging
            )

            # STEP 3: Update search history with results
            await credit_service.update_search_results(
                search_id=search_id,
                results_count=1,  # Phone lookups always return 1 result
                search_type="phone"
            )

            return result

    except httpx.TimeoutException:
        # Network timeout - refund credit
        await credit_service.refund_credit(
            user_id=user_id,
            search_id=search_id,
            reason="request_timeout",
            amount=2
        )
        raise HTTPException(
            status_code=504,
            detail="Phone lookup request timed out. Your credit has been refunded."
        )

    except httpx.NetworkError as e:
        # Network error - refund credit
        await credit_service.refund_credit(
            user_id=user_id,
            search_id=search_id,
            reason="network_error",
            amount=2
        )
        raise HTTPException(
            status_code=503,
            detail=f"Network error during phone lookup. Your credit has been refunded."
        )

    except InsufficientCreditsError:
        # Re-raise credit errors as-is (already formatted)
        raise

    except HTTPException:
        # Re-raise HTTP exceptions
        raise

    except Exception as e:
        # Unexpected error - refund credit if it was deducted
        if 'search_id' in locals() and search_id:
            await credit_service.refund_credit(
                user_id=user_id,
                search_id=search_id,
                reason="unknown_error",
                amount=2
            )

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
    if not TWILIO_ACCOUNT_SID or not TWILIO_AUTH_TOKEN:
        return {
            "status": "error",
            "message": "Twilio credentials not configured",
            "configured": False
        }

    return {
        "status": "ok",
        "message": "Phone lookup service is properly configured with Twilio",
        "configured": True,
        "provider": "Twilio Lookup API v2",
        "rate_limit": "15 requests per minute",
        "features": ["Line Type Intelligence", "Caller Name (CNAM)"]
    }

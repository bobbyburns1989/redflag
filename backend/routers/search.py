from fastapi import APIRouter, HTTPException, Query, Request, Depends
from pydantic import BaseModel
from typing import Optional, List
from slowapi import Limiter
from slowapi.util import get_remote_address

from services.offender_api import OffenderAPIService
from services.credit_service import get_credit_service, InsufficientCreditsError
from middleware.auth import require_auth, get_current_user

router = APIRouter()

# Initialize rate limiter for this router
limiter = Limiter(key_func=get_remote_address)

# Initialize credit service
credit_service = get_credit_service()

# Lazy initialization to ensure environment variables are loaded first
def get_offender_service():
    return OffenderAPIService()

class SearchRequest(BaseModel):
    firstName: str
    lastName: str
    phoneNumber: Optional[str] = None
    zipCode: Optional[str] = None
    age: Optional[str] = None
    state: Optional[str] = None

class OffenderResult(BaseModel):
    id: str
    fullName: str
    age: Optional[int] = None
    city: Optional[str] = None
    state: Optional[str] = None
    offenseDescription: Optional[str] = None
    registrationDate: Optional[str] = None
    distance: Optional[float] = None
    address: Optional[str] = None

@router.post("/search/name", response_model=List[OffenderResult], dependencies=[Depends(require_auth)])
@limiter.limit("10/minute")  # Max 10 searches per minute per IP
async def search_by_name(
    search_request: SearchRequest,
    request: Request
):
    """
    Search sex offender registries by name and optional filters.

    **Authentication Required**: Must provide valid Supabase JWT token.

    **Rate Limit**: 10 requests per minute per IP address.

    Returns a list of potential matches with disclaimer that these should be verified independently.

    **Note**: This endpoint requires the user to have sufficient credits.
    Credits are validated and deducted server-side before the search is performed.
    """
    # Get authenticated user ID from request state
    user_id = get_current_user(request)

    # Create search query string for logging
    query = f"{search_request.firstName} {search_request.lastName}"

    try:
        # STEP 1: Validate and deduct credit BEFORE performing search
        credit_result = await credit_service.check_and_deduct_credit(
            user_id=user_id,
            search_type="name",
            query=query,
            cost=1
        )

        search_id = credit_result["search_id"]
        remaining_credits = credit_result["credits"]

        # STEP 2: Perform the actual search
        offender_service = get_offender_service()
        results = await offender_service.search_by_name(
            first_name=search_request.firstName,
            last_name=search_request.lastName,
            phone_number=search_request.phoneNumber,
            zip_code=search_request.zipCode,
            age=search_request.age,
            state=search_request.state
        )

        # Post-filter by age and state if provided (since external APIs may not support these filters)
        if search_request.age:
            try:
                target_age = int(search_request.age)
                # Filter results within a 5-year range
                results = [r for r in results if r.get('age') and abs(r['age'] - target_age) <= 5]
            except ValueError:
                pass  # Invalid age format, skip filtering

        if search_request.state:
            # Filter by state (case-insensitive)
            results = [r for r in results if r.get('state', '').upper() == search_request.state.upper()]

        # STEP 3: Update search history with results count
        await credit_service.update_search_results(
            search_id=search_id,
            results_count=len(results),
            search_type="name"
        )

        return results

    except InsufficientCreditsError:
        # Re-raise credit errors as-is (already formatted)
        raise

    except HTTPException:
        # Re-raise HTTP exceptions
        raise

    except Exception as e:
        # For unexpected errors, refund the credit if it was deducted
        if 'search_id' in locals() and search_id:
            await credit_service.refund_credit(
                user_id=user_id,
                search_id=search_id,
                reason="api_error_500"
            )

        raise HTTPException(
            status_code=500,
            detail=f"Error searching offender database: {str(e)}"
        )

@router.get("/search/test")
async def test_search():
    """Test endpoint to verify API connectivity"""
    return {
        "message": "Search API is working",
        "endpoints": {
            "POST /api/search/name": "Search by name with optional filters"
        }
    }

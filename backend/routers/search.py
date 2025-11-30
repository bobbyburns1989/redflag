from fastapi import APIRouter, HTTPException, Query, Request, Depends
from pydantic import BaseModel
from typing import Optional, List
from slowapi import Limiter
from slowapi.util import get_remote_address

from services.offender_api import OffenderAPIService
from middleware.auth import require_auth, get_current_user

router = APIRouter()

# Initialize rate limiter for this router
limiter = Limiter(key_func=get_remote_address)

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
    try:
        # Get authenticated user ID from request state
        user_id = get_current_user(request)

        # TODO: Validate user has sufficient credits before performing search
        # This will be implemented in the next phase (server-side credit validation)

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

        return results
    except Exception as e:
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

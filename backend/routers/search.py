from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel
from typing import Optional, List
from services.offender_api import OffenderAPIService

router = APIRouter()

# Lazy initialization to ensure environment variables are loaded first
def get_offender_service():
    return OffenderAPIService()

class SearchRequest(BaseModel):
    firstName: str
    lastName: str
    phoneNumber: Optional[str] = None
    zipCode: Optional[str] = None

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

@router.post("/search/name", response_model=List[OffenderResult])
async def search_by_name(request: SearchRequest):
    """
    Search sex offender registries by name and optional filters.

    Returns a list of potential matches with disclaimer that these should be verified independently.
    """
    try:
        offender_service = get_offender_service()
        results = await offender_service.search_by_name(
            first_name=request.firstName,
            last_name=request.lastName,
            phone_number=request.phoneNumber,
            zip_code=request.zipCode
        )
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

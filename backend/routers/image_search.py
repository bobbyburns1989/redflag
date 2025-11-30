"""
Image Search Router

Handles reverse image search requests using TinEye API.
Users can upload an image file or provide a URL to check where the image appears online.

Endpoints:
- POST /api/image-search: Search by uploaded image or URL
- GET /api/image-search/remaining: Check remaining API searches
"""

from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Request, Depends
from pydantic import BaseModel
from typing import Optional, List
from slowapi import Limiter
from slowapi.util import get_remote_address

from services.tineye_service import TinEyeService
from middleware.auth import require_auth, get_current_user

router = APIRouter()

# Initialize rate limiter for this router
limiter = Limiter(key_func=get_remote_address)


def get_tineye_service():
    """Lazy initialization of TinEye service."""
    return TinEyeService()


class ImageSearchResult(BaseModel):
    """Response model for image search results."""
    domain: str
    page_url: str
    image_url: Optional[str] = None
    crawl_date: Optional[str] = None


class ImageSearchResponse(BaseModel):
    """Complete response for image search."""
    total_matches: int
    total_backlinks: int
    results: List[ImageSearchResult]
    message: str


@router.post("/image-search", response_model=ImageSearchResponse, dependencies=[Depends(require_auth)])
@limiter.limit("10/minute")  # Max 10 image searches per minute per IP
async def search_image(
    request: Request,
    image: Optional[UploadFile] = File(None),
    image_url: Optional[str] = Form(None)
):
    """
    Perform reverse image search to find where an image appears online.

    **Authentication Required**: Must provide valid Supabase JWT token.

    **Rate Limit**: 10 requests per minute per IP address.

    Accepts either:
    - image: Uploaded image file (multipart/form-data)
    - image_url: Direct URL to an image

    Returns list of websites/domains where the image was found.

    Use cases:
    - Verify if a photo is original or stolen
    - Detect catfishing/fake profiles
    - Find higher resolution versions
    - Check if image is a stock photo

    **Note**: This endpoint requires the user to have sufficient credits.
    """
    # Get authenticated user ID
    user_id = get_current_user(request)

    # TODO: Validate user has sufficient credits before performing search
    # Validate input - need either image file or URL
    if not image and not image_url:
        raise HTTPException(
            status_code=400,
            detail="Either 'image' file or 'image_url' must be provided"
        )

    if image and image_url:
        raise HTTPException(
            status_code=400,
            detail="Provide either 'image' file or 'image_url', not both"
        )

    try:
        tineye_service = get_tineye_service()

        if image:
            # Validate file type
            if image.content_type not in ["image/jpeg", "image/png", "image/gif", "image/webp"]:
                raise HTTPException(
                    status_code=400,
                    detail=f"Unsupported image type: {image.content_type}. Use JPEG, PNG, GIF, or WebP."
                )

            # Read image data
            image_data = await image.read()

            # Check file size (max 10MB)
            if len(image_data) > 10 * 1024 * 1024:
                raise HTTPException(
                    status_code=400,
                    detail="Image file too large. Maximum size is 10MB."
                )

            # Perform search
            result = await tineye_service.search_by_image_data(image_data)
        else:
            # Search by URL
            result = await tineye_service.search_by_url(image_url)

        # Generate user-friendly message
        if result["total_matches"] == 0:
            message = "No matches found. This image appears to be original or not indexed."
        elif result["total_matches"] == 1:
            message = "1 match found. This image appears elsewhere online."
        else:
            message = f"{result['total_matches']} matches found. This image appears on multiple websites."

        return ImageSearchResponse(
            total_matches=result["total_matches"],
            total_backlinks=result["total_backlinks"],
            results=result["results"],
            message=message
        )

    except HTTPException:
        raise
    except Exception as e:
        print(f"Image search error: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Image search failed: {str(e)}"
        )


@router.get("/image-search/remaining")
async def get_remaining_searches():
    """
    Get the number of remaining TinEye API searches.

    Useful for monitoring usage and knowing when to purchase more searches.
    """
    try:
        tineye_service = get_tineye_service()
        remaining = await tineye_service.get_remaining_searches()

        return {
            "remaining_searches": remaining,
            "message": f"You have {remaining} image searches remaining in your TinEye account."
        }
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get remaining searches: {str(e)}"
        )


@router.get("/image-search/test")
async def test_image_search():
    """Test endpoint to verify image search API is configured."""
    try:
        tineye_service = get_tineye_service()
        remaining = await tineye_service.get_remaining_searches()

        return {
            "status": "configured",
            "message": "TinEye API is properly configured",
            "remaining_searches": remaining
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"TinEye API configuration error: {str(e)}",
            "remaining_searches": 0
        }

"""
TinEye Reverse Image Search Service

This service integrates with TinEye's API to perform reverse image searches,
helping users identify if an image appears elsewhere online (catfish/scam detection).

Usage:
- search_by_image_data(): Search using raw image bytes (from file upload)
- search_by_url(): Search using an image URL

Returns structured results with domains, URLs, and crawl dates where the image was found.
"""

import os
from typing import List, Dict, Any, Optional
from urllib.parse import urlparse
from pytineye import TinEyeAPIRequest


class TinEyeService:
    """
    Service for performing reverse image searches via TinEye API.

    TinEye indexes billions of images and can find where an image appears online,
    including modified versions. Useful for detecting:
    - Catfishing (stolen photos)
    - Stock photos being used as real profiles
    - Scam profiles using others' images
    """

    def __init__(self):
        self.api_key = os.getenv("TINEYE_API_KEY")
        self.api_url = "https://api.tineye.com/rest/"

        if not self.api_key:
            raise ValueError("TINEYE_API_KEY not configured in environment")

        # Initialize TinEye API client
        self.api = TinEyeAPIRequest(
            api_url=self.api_url,
            api_key=self.api_key
        )

    async def search_by_image_data(self, image_data: bytes) -> Dict[str, Any]:
        """
        Search TinEye using raw image data (file upload).

        Args:
            image_data: Raw bytes of the image file

        Returns:
            Dictionary containing:
            - total_matches: Number of matches found
            - results: List of match details (domain, URLs, dates)
            - query_hash: Hash of the searched image
        """
        try:
            # TinEye's pytineye library is synchronous, so we call it directly
            # In production, consider running in thread pool for true async
            response = self.api.search_data(data=image_data)
            return self._transform_response(response)
        except Exception as e:
            print(f"TinEye search error: {e}")
            raise Exception(f"Image search failed: {str(e)}")

    async def search_by_url(self, image_url: str) -> Dict[str, Any]:
        """
        Search TinEye using an image URL.

        Args:
            image_url: Direct URL to the image file

        Returns:
            Dictionary containing match results
        """
        try:
            response = self.api.search_url(url=image_url)
            return self._transform_response(response)
        except Exception as e:
            print(f"TinEye URL search error: {e}")
            raise Exception(f"Image search failed: {str(e)}")

    def _transform_response(self, response) -> Dict[str, Any]:
        """
        Transform TinEye API response into standardized format.

        The TinEye response object contains:
        - total_results: Total number of matches
        - matches: List of match objects with backlinks

        We extract the most useful information for the user.
        """
        results = []

        # Process each match
        for match in response.matches:
            # Each match can have multiple backlinks (pages where image appears)
            for backlink in match.backlinks:
                # Extract domain from URL since Backlink object doesn't have domain attribute
                try:
                    domain = urlparse(backlink.url).netloc if backlink.url else "Unknown"
                except Exception:
                    domain = "Unknown"

                results.append({
                    "domain": domain,
                    "page_url": backlink.url,
                    "image_url": backlink.backlink,
                    "crawl_date": backlink.crawl_date.isoformat() if backlink.crawl_date else None,
                })

        # Remove duplicates by page_url while preserving order
        seen_urls = set()
        unique_results = []
        for result in results:
            if result["page_url"] not in seen_urls:
                seen_urls.add(result["page_url"])
                unique_results.append(result)

        return {
            "total_matches": response.total_results,
            "total_backlinks": response.total_backlinks,
            "results": unique_results[:50],  # Limit to first 50 results
            "stats": {
                "total_results": response.total_results,
                "total_backlinks": response.total_backlinks,
            }
        }

    async def get_remaining_searches(self) -> int:
        """
        Get the number of remaining searches in the TinEye account.

        Useful for monitoring API usage and alerting when bundle is low.
        """
        try:
            response = self.api.remaining_searches()
            return response.remaining_searches
        except Exception as e:
            print(f"Error getting remaining searches: {e}")
            return -1

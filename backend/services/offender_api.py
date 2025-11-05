import httpx
import os
from typing import List, Optional, Dict, Any

class OffenderAPIService:
    """
    Service for querying sex offender registries.

    Currently supports:
    - Offenders.io API
    - CrimeoMeter Sex Offenders API (fallback)
    """

    def __init__(self):
        self.offenders_io_key = os.getenv("OFFENDERS_IO_API_KEY")
        self.crimeometer_key = os.getenv("CRIMEOMETER_API_KEY")
        self.base_url_offenders_io = "https://api.offenders.io/v1"
        self.base_url_crimeometer = "https://api.crimeometer.com/v1"

    async def search_by_name(
        self,
        first_name: str,
        last_name: Optional[str] = None,
        phone_number: Optional[str] = None,
        zip_code: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Search for offenders by name and optional filters.

        Args:
            first_name: Required first name to search
            last_name: Optional last name filter
            phone_number: Optional phone number filter
            zip_code: Optional ZIP code for location filtering

        Returns:
            List of matching offender records
        """

        # Try Offenders.io first
        if self.offenders_io_key:
            try:
                return await self._search_offenders_io(
                    first_name, last_name, phone_number, zip_code
                )
            except Exception as e:
                print(f"Offenders.io API error: {e}")
                # Fall through to alternative API

        # Fallback to CrimeoMeter if available
        if self.crimeometer_key and zip_code:
            try:
                return await self._search_crimeometer(
                    first_name, last_name, zip_code
                )
            except Exception as e:
                print(f"CrimeoMeter API error: {e}")

        # If no API keys configured, return mock data for development
        if not self.offenders_io_key and not self.crimeometer_key:
            return self._get_mock_data(first_name, last_name)

        return []

    async def _search_offenders_io(
        self,
        first_name: str,
        last_name: Optional[str],
        phone_number: Optional[str],
        zip_code: Optional[str]
    ) -> List[Dict[str, Any]]:
        """Query Offenders.io API"""

        params = {
            "first_name": first_name,
        }

        if last_name:
            params["last_name"] = last_name
        if zip_code:
            params["zip_code"] = zip_code

        headers = {
            "x-api-key": self.offenders_io_key,
            "Content-Type": "application/json"
        }

        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{self.base_url_offenders_io}/offenders/search",
                params=params,
                headers=headers,
                timeout=10.0
            )
            response.raise_for_status()
            data = response.json()

            # Transform to standard format
            return self._transform_offenders_io_response(data)

    async def _search_crimeometer(
        self,
        first_name: str,
        last_name: Optional[str],
        zip_code: str
    ) -> List[Dict[str, Any]]:
        """Query CrimeoMeter API"""

        params = {
            "first_name": first_name,
            "zip_code": zip_code
        }

        if last_name:
            params["last_name"] = last_name

        headers = {
            "x-api-key": self.crimeometer_key
        }

        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{self.base_url_crimeometer}/offenders",
                params=params,
                headers=headers,
                timeout=10.0
            )
            response.raise_for_status()
            data = response.json()

            return self._transform_crimeometer_response(data)

    def _transform_offenders_io_response(self, data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Transform Offenders.io response to standard format"""
        results = []
        offenders = data.get("offenders", [])

        for offender in offenders:
            results.append({
                "id": offender.get("id", ""),
                "fullName": f"{offender.get('first_name', '')} {offender.get('last_name', '')}".strip(),
                "age": offender.get("age"),
                "city": offender.get("city"),
                "state": offender.get("state"),
                "offenseDescription": offender.get("offense_description"),
                "registrationDate": offender.get("registration_date"),
                "distance": offender.get("distance"),
                "address": f"{offender.get('city', '')}, {offender.get('state', '')}"
            })

        return results

    def _transform_crimeometer_response(self, data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Transform CrimeoMeter response to standard format"""
        results = []
        offenders = data.get("offenders", [])

        for offender in offenders:
            results.append({
                "id": str(offender.get("id", "")),
                "fullName": offender.get("name", ""),
                "age": offender.get("age"),
                "city": offender.get("city"),
                "state": offender.get("state"),
                "offenseDescription": offender.get("charges"),
                "registrationDate": offender.get("registration_date"),
                "distance": offender.get("distance_miles"),
                "address": offender.get("location", "")
            })

        return results

    def _get_mock_data(self, first_name: str, last_name: Optional[str]) -> List[Dict[str, Any]]:
        """Return mock data for development/testing when no API keys are configured"""
        return [
            {
                "id": "mock-1",
                "fullName": f"{first_name} {last_name or 'Doe'}",
                "age": 45,
                "city": "San Francisco",
                "state": "CA",
                "offenseDescription": "Mock offense - API key not configured",
                "registrationDate": "2020-01-15",
                "distance": None,
                "address": "San Francisco, CA"
            },
            {
                "id": "mock-2",
                "fullName": f"{first_name} Smith",
                "age": 38,
                "city": "Oakland",
                "state": "CA",
                "offenseDescription": "Mock offense - Configure API keys in .env",
                "registrationDate": "2018-06-22",
                "distance": None,
                "address": "Oakland, CA"
            }
        ]

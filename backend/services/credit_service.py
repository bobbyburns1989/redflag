"""
Credit Validation Service

Handles server-side credit validation, deduction, and refunds.
This prevents client-side manipulation of credit balances.

All credit operations are performed using Supabase RPC functions for atomic transactions.
"""

from typing import Dict, Any, Optional
from fastapi import HTTPException, status
from .supabase_client import get_admin_client


class InsufficientCreditsError(HTTPException):
    """Raised when user doesn't have enough credits for an operation."""

    def __init__(self, current_credits: int):
        super().__init__(
            status_code=status.HTTP_402_PAYMENT_REQUIRED,
            detail={
                "error": "insufficient_credits",
                "message": f"Not enough credits. You have {current_credits} credit(s).",
                "current_credits": current_credits,
            }
        )


class CreditService:
    """
    Service for managing user credits server-side.

    All operations are atomic and executed via Supabase RPC functions.
    """

    def __init__(self):
        """Initialize credit service with Supabase admin client."""
        self.supabase = get_admin_client()

    async def get_user_credits(self, user_id: str) -> int:
        """
        Get current credit balance for a user.

        Args:
            user_id: Supabase user ID

        Returns:
            int: Current credit balance

        Raises:
            HTTPException: If user not found or database error
        """
        try:
            response = self.supabase.table("profiles").select("credits").eq("user_id", user_id).single().execute()

            if not response.data:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User profile not found"
                )

            return response.data.get("credits", 0)

        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to fetch user credits: {str(e)}"
            )

    async def check_and_deduct_credit(
        self,
        user_id: str,
        search_type: str,
        query: str,
        cost: int = 1
    ) -> Dict[str, Any]:
        """
        Check if user has sufficient credits and deduct if available.

        This uses the Supabase RPC function `deduct_credit_for_search` which:
        1. Checks if user has >= cost credits
        2. Deducts the credits atomically
        3. Creates a search history entry
        4. Returns the search ID and remaining credits

        Args:
            user_id: Supabase user ID
            search_type: Type of search ('name', 'phone', 'image')
            query: Search query (for logging)
            cost: Number of credits to deduct (default: 1)

        Returns:
            Dict containing:
                - search_id: UUID of created search entry
                - credits: Remaining credits after deduction
                - success: Boolean indicating success

        Raises:
            InsufficientCreditsError: If user doesn't have enough credits
            HTTPException: If database operation fails
        """
        try:
            # Call Supabase RPC function for atomic credit deduction
            response = self.supabase.rpc(
                "deduct_credit_for_search",
                {
                    "p_user_id": user_id,
                    "p_query": query,
                    "p_results_count": 0,  # Will be updated after API call
                    "p_cost": cost,
                }
            ).execute()

            result = response.data

            if not result or not result.get("success"):
                error = result.get("error", "unknown_error")

                if error == "insufficient_credits":
                    current_credits = result.get("credits", 0)
                    raise InsufficientCreditsError(current_credits)

                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Credit deduction failed: {error}"
                )

            return {
                "search_id": result.get("search_id"),
                "credits": result.get("credits"),
                "success": True,
            }

        except InsufficientCreditsError:
            raise
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Credit validation error: {str(e)}"
            )

    async def refund_credit(
        self,
        user_id: str,
        search_id: str,
        reason: str,
        amount: int = 1
    ) -> Dict[str, Any]:
        """
        Refund credits for a failed search.

        This uses the Supabase RPC function `refund_credit_for_failed_search` which:
        1. Adds credits back to user's balance
        2. Creates a refund transaction record
        3. Updates the search entry with refund status

        Args:
            user_id: Supabase user ID
            search_id: UUID of the search entry to refund
            reason: Reason code for refund (e.g., "api_error_503")
            amount: Number of credits to refund (default: 1)

        Returns:
            Dict containing:
                - credits: Updated credit balance after refund
                - success: Boolean indicating success

        Raises:
            HTTPException: If refund operation fails
        """
        try:
            response = self.supabase.rpc(
                "refund_credit_for_failed_search",
                {
                    "p_user_id": user_id,
                    "p_search_id": search_id,
                    "p_reason": reason,
                    "p_amount": amount,
                }
            ).execute()

            result = response.data

            if not result or not result.get("success"):
                error = result.get("error", "unknown_error")
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Credit refund failed: {error}"
                )

            return {
                "credits": result.get("credits"),
                "success": True,
            }

        except HTTPException:
            raise
        except Exception as e:
            # Refunds are best-effort - log error but don't fail the request
            print(f"Warning: Credit refund failed for user {user_id}: {e}")
            return {
                "credits": 0,
                "success": False,
                "error": str(e),
            }

    async def update_search_results(
        self,
        search_id: str,
        results_count: int,
        search_type: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None
    ) -> bool:
        """
        Update search entry with results count and metadata.

        Args:
            search_id: UUID of the search entry
            results_count: Number of results returned
            search_type: Optional search type ('name', 'phone', 'image')
            metadata: Optional additional metadata to store

        Returns:
            bool: True if update successful, False otherwise
        """
        try:
            update_data = {"results_count": results_count}

            if search_type:
                update_data["search_type"] = search_type

            if metadata:
                update_data["metadata"] = metadata

            self.supabase.table("searches").update(update_data).eq("id", search_id).execute()

            return True

        except Exception as e:
            # Don't fail the request if history update fails
            print(f"Warning: Failed to update search results for {search_id}: {e}")
            return False


# Singleton instance for dependency injection
_credit_service: Optional[CreditService] = None


def get_credit_service() -> CreditService:
    """
    Get or create singleton CreditService instance.

    Returns:
        CreditService: The credit service instance

    Usage:
        from services.credit_service import get_credit_service

        credit_service = get_credit_service()
        result = await credit_service.check_and_deduct_credit(user_id, "name", "John Doe")
    """
    global _credit_service

    if _credit_service is None:
        _credit_service = CreditService()

    return _credit_service

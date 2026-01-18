# AI Coding Context - Pink Flag

> **Purpose**: Optimized documentation for AI coding assistants
> **Last Updated**: January 14, 2026
> **Version**: 1.2.3+26
> **Critical**: Read this FIRST before making any code changes

---

## 🚨 CRITICAL RULES

### Credit System Architecture
**⚠️ NEVER deduct credits on client-side ⚠️**

```
✅ CORRECT FLOW:
Flutter → HTTP POST → Backend → deduct_credit() RPC → Supabase

❌ WRONG FLOW (causes double deduction):
Flutter → deduct_credit() RPC → Supabase
Flutter → HTTP POST → Backend → deduct_credit() RPC → Supabase
```

**Single Source of Truth**: Backend handles ALL credit operations
- `backend/routers/search.py` calls `credit_service.check_and_deduct_credit()`
- `backend/services/credit_service.py` calls Supabase RPC `deduct_credit_for_search`
- Client (`SearchService`) ONLY calls backend API endpoints

### Code Locations

**DO NOT MODIFY** these files to add client-side credit logic:
- `safety_app/lib/services/search_service.dart:25-77` - Name search (backend handles credits)
- `safety_app/lib/services/phone_search_service.dart` - Phone search (backend handles credits)
- `safety_app/lib/services/image_search_service.dart:34-79` - Image search (backend handles credits)

**MODIFY THESE** if changing credit logic:
- `backend/services/credit_service.py` - Credit validation/deduction/refunds
- `backend/routers/search.py` - Name search endpoint
- `backend/routers/phone_lookup.py` - Phone search endpoint
- `backend/routers/image_search.py` - Image search endpoint

---

## 📂 Project Structure

```
RedFlag/
├── safety_app/                    # Flutter Mobile App
│   ├── lib/
│   │   ├── services/
│   │   │   ├── search_service.dart      ⚠️ NO credit deduction! (v1.1.10)
│   │   │   ├── phone_search_service.dart ⚠️ NO credit deduction!
│   │   │   ├── image_search_service.dart ⚠️ NO credit deduction! (v1.1.11)
│   │   │   ├── api_service.dart         → HTTP client for backend
│   │   │   └── auth_service.dart        → Supabase auth facade
│   │   ├── models/
│   │   │   ├── search_result.dart       → Name search results
│   │   │   ├── fbi_wanted_result.dart   → FBI wanted data
│   │   │   └── credit_transaction.dart  → Credit history
│   │   └── screens/
│   │       ├── search_screen.dart       → Main search UI (refactored)
│   │       ├── results_screen.dart      → Name search results
│   │       ├── image_results_screen.dart → Image search results
│   │       └── phone_results_screen.dart → Phone search results
│   └── pubspec.yaml                     → Version: 1.1.11+17
│
├── backend/                       # Python FastAPI Backend
│   ├── services/
│   │   ├── credit_service.py           ✅ SINGLE SOURCE OF TRUTH
│   │   ├── supabase_client.py          → Admin client
│   │   └── offender_api.py             → External API integration
│   ├── routers/
│   │   └── search.py                   ✅ Calls credit_service
│   └── main.py                         → FastAPI app + JWT auth
│
├── schemas/
│   └── FIX_RPC_JSON_RETURN_TYPE.sql   ⏳ Apply this for permanent fix
│
└── releases/
    └── RELEASE_NOTES_v1.1.10.md       → This release details
```

---

## 💳 Credit System (v1.1.11 - ALL SEARCH TYPES FIXED)

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Client                           │
│                                                              │
│  SearchService.searchByName()           ✅ v1.1.10          │
│  ImageSearchService.searchByImage()     ✅ v1.1.11          │
│  PhoneSearchService.searchPhone()       ✅ Already correct   │
│      │                                                       │
│      ├─ ❌ OLD: await _supabase.rpc('deduct_credit')       │
│      │                                                       │
│      ├─ ✅ NEW: await _apiService.search*()                │
│      │          (Backend handles credit deduction)          │
│      │                                                       │
│      └─ await _checkFBIWanted() (Free, runs in parallel)    │
│                                                              │
└──────────────────────────│───────────────────────────────────┘
                           │ HTTP POST
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend API                               │
│  routers/search.py                                           │
│      │                                                       │
│      ├─ 1. Extract user_id from JWT token                   │
│      │                                                       │
│      ├─ 2. credit_service.check_and_deduct_credit()         │
│      │       │                                               │
│      │       ├─ Calls: deduct_credit_for_search RPC         │
│      │       └─ Returns: {search_id, credits, success}      │
│      │                                                       │
│      ├─ 3. offender_api.search_by_name()                    │
│      │       (Call external API)                            │
│      │                                                       │
│      ├─ 4. On success: Update search history                │
│      │                                                       │
│      └─ 5. On failure: credit_service.refund_credit()       │
│              (Automatic refund for 503, 500, timeout)       │
│                                                              │
└──────────────────────────│───────────────────────────────────┘
                           │ Supabase RPC
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Supabase PostgreSQL                       │
│                                                              │
│  RPC: deduct_credit_for_search(user_id, query, cost)        │
│      └─ Atomic: Deduct credits + Create search record       │
│                                                              │
│  RPC: refund_credit_for_failed_search(user_id, search_id)   │
│      └─ Atomic: Add credits + Mark search refunded          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Key Files & Methods

#### Backend Credit Service
**File**: `backend/services/credit_service.py`

**Methods**:
```python
async def check_and_deduct_credit(
    user_id: str,
    search_type: str,
    query: str,
    cost: int = 1
) -> Dict[str, Any]:
    """
    ✅ Single source of truth for credit deduction

    Returns:
        {
            "search_id": UUID,
            "credits": int,  # Remaining credits
            "success": True
        }

    Raises:
        InsufficientCreditsError: User doesn't have enough credits
    """

async def refund_credit(
    user_id: str,
    search_id: str,
    reason: str,
    amount: int = 1
) -> Dict[str, Any]:
    """
    Refund credits for failed searches

    Triggered by: 503, 500, 502, 504, timeouts, network errors
    NOT triggered by: 400, 404 (user's query is invalid/no results)
    """
```

#### Client Search Service
**File**: `safety_app/lib/services/search_service.dart`

```dart
/// ✅ CORRECT: No client-side credit deduction
Future<SearchResult> searchByName({
  required String firstName,
  String? lastName,
  String? phoneNumber,
  String? zipCode,
  String? age,
  String? state,
}) async {
  try {
    // Backend handles credit deduction automatically
    final results = await Future.wait([
      _apiService.searchByName(...),  // ✅ Backend deducts credit
      _checkFBIWanted(...),            // Free API
    ]);

    return enhancedResult;
  } catch (e) {
    // Backend handles refunds automatically
    rethrow;
  }
}
```

#### API Endpoint
**File**: `backend/routers/search.py`

```python
@router.post("/name")
async def search_by_name(
    request: SearchRequest,
    user_id: str = Depends(get_current_user)
):
    """
    ✅ Handles credit deduction before search
    ✅ Refunds on API failures
    """

    # Step 1: Deduct credit FIRST
    credit_result = await credit_service.check_and_deduct_credit(
        user_id=user_id,
        search_type="name",
        query=f"{request.firstName} {request.lastName}",
        cost=1
    )

    try:
        # Step 2: Perform search
        results = await offender_api.search_by_name(...)

        # Step 3: Update search history
        await credit_service.update_search_results(...)

        return results

    except Exception as e:
        # Step 4: Refund on failure
        if should_refund(e):
            await credit_service.refund_credit(...)
        raise
```

---

## 🔧 Common Coding Tasks

### Adding a New Search Endpoint

**⚠️ ALL SEARCH TYPES NOW USE BACKEND-ONLY CREDIT DEDUCTION**
- ✅ Name Search (v1.1.10)
- ✅ Image Search (v1.1.11)
- ✅ Phone Search (always correct)

**❌ WRONG WAY:**
```dart
// DON'T DO THIS IN CLIENT CODE!
final response = await _supabase.rpc('deduct_credit_for_search', ...);
final result = await _apiService.newSearch(...);
```

**✅ CORRECT WAY:**

1. **Backend** (`backend/routers/new_search.py`):
```python
@router.post("/new-search")
async def new_search(
    request: NewSearchRequest,
    user_id: str = Depends(get_current_user)
):
    # ✅ Deduct credit on backend
    credit_result = await credit_service.check_and_deduct_credit(
        user_id=user_id,
        search_type="new_search",
        query=request.query,
        cost=1
    )

    try:
        results = await external_api.search(...)
        return results
    except Exception as e:
        if should_refund(e):
            await credit_service.refund_credit(...)
        raise
```

2. **Client** (`safety_app/lib/services/new_search_service.dart`):
```dart
Future<NewSearchResult> performNewSearch(String query) async {
  // ✅ Just call backend - it handles credits
  return await _apiService.newSearch(query);
}
```

### Debugging Credit Issues

**Check these in order:**

1. **Backend logs** - Look for credit deduction messages:
```
🔵 [CREDIT] Calling RPC deduct_credit_for_search for user abc123, cost: 1
⚠️ [CREDIT] RPC execute() threw exception: APIError
✅ [CREDIT] Extracted successful result from exception - search_id: def456, credits: 19
```

2. **Database** - Check Supabase:
```sql
-- View recent searches
SELECT * FROM searches WHERE user_id = 'abc123' ORDER BY created_at DESC LIMIT 10;

-- View recent credit transactions
SELECT * FROM credit_transactions WHERE user_id = 'abc123' ORDER BY created_at DESC LIMIT 10;

-- Check current credits
SELECT credits FROM profiles WHERE user_id = 'abc123';
```

3. **Client logs** - Check Flutter console:
```dart
flutter: ✅ [AUTH] getUserCredits: Found 20 credits
flutter: ✅ [SEARCH] Search completed: 26 results
flutter: ✅ [AUTH] getUserCredits: Found 19 credits (after search)
```

### Modifying Refund Logic

**File**: `backend/services/credit_service.py`

```python
def should_refund(error: Exception) -> bool:
    """
    Determine if credit should be refunded based on error

    ✅ REFUND: 500, 502, 503, 504, timeout, network error
    ❌ NO REFUND: 400, 404, validation error
    """
    if isinstance(error, HTTPException):
        # Refund server errors, not client errors
        return error.status_code >= 500

    if isinstance(error, (TimeoutException, NetworkException)):
        return True

    return False
```

---

## 🐛 Known Issues & Workarounds

### Issue 1: Supabase Python Client Byte String Response

**Status**: ⏳ Workaround active, permanent fix available

**Problem**:
```python
# Supabase RPC returns JSON type → Python client throws exception
# Actual response embedded as byte string in exception
response = supabase.rpc("deduct_credit_for_search", ...)
# Throws: APIError with details = b'{"success": true, ...}'
```

**Current Workaround** (`credit_service.py:154-192`):
```python
except Exception as e:
    # Extract JSON from byte string
    byte_match = re.search(r"b\\'({[^}]+})\\'", str(e))
    if byte_match:
        result = json.loads(byte_match.group(1))
        return result
```

**Permanent Fix** (`schemas/FIX_RPC_JSON_RETURN_TYPE.sql`):
```sql
-- Change RPC return type from JSON → JSONB
CREATE OR REPLACE FUNCTION deduct_credit_for_search(...)
RETURNS JSONB  -- Changed from JSON
AS $$
BEGIN
  RETURN jsonb_build_object(...);  -- Changed from json_build_object
END;
$$;
```

**Action Required**:
1. Apply `FIX_RPC_JSON_RETURN_TYPE.sql` in Supabase dashboard
2. Remove workaround code in `credit_service.py`
3. Test thoroughly in production

---

## 📝 Version History

### v1.2.3 (Jan 14, 2026) - **CURRENT**
**🔧 Critical Fix: RevenueCat Purchase Attribution**
- ✅ Fixed: RC now initialized for existing sessions in splash_screen.dart
- ✅ Fixed: Added logIn/logOut methods to revenuecat_service.dart
- ✅ Fixed: auth_service.dart now calls RC logOut on sign out
- ✅ Fixed: Webhook credit values updated to 30/100/250 (10x system)
- ✅ Fixed: Bundle ID references corrected to com.pinkflag.app

**Files Modified**:
- `safety_app/lib/screens/splash_screen.dart`
- `safety_app/lib/services/revenuecat_service.dart`
- `safety_app/lib/services/auth_service.dart`
- `supabase/functions/revenuecat-webhook/index.ts`

**Migration**: Deploy webhook after app update

### v1.1.11 (Dec 1, 2025)
**🐛 Critical Bug Fix: Double Credit Deduction in Image Search**
- ✅ Removed client-side credit deduction from image search
- ✅ Backend is now single source of truth for ALL search types
- ✅ Verified: 1 image search = 1 credit ✅

**Files Modified**:
- `safety_app/lib/services/image_search_service.dart` (removed client-side credit logic)
- `safety_app/lib/services/search_service.dart` (cleaned up unused imports)
- `safety_app/pubspec.yaml` (version bump to 1.1.11+17)

**Migration**: None required, pure code change

### v1.1.10 (Dec 1, 2025)
**🐛 Critical Bug Fix: Double Credit Deduction in Name Search**
- ✅ Removed client-side credit deduction from name search
- ✅ Backend is now single source of truth
- ✅ Verified: 1 name search = 1 credit ✅

**Files Modified**:
- `safety_app/lib/services/search_service.dart` (removed lines 45-205)
- `backend/services/credit_service.py` (added debug logging)
- `backend/README.md` (updated architecture docs)

**Migration**: None required, pure code change

### v1.1.9 (Nov XX, 2025)
- Added JWT authentication to API requests
- Prevents unauthorized credit deduction

### v1.1.7 (Nov 28, 2025)
- Automatic credit refunds for API failures
- Refund triggers: 503, 500, timeout, network errors

---

## 🎯 Quick Reference

### Environment Setup
```bash
# Backend
cd backend
source venv/bin/activate
python main.py  # Runs on :8000

# Flutter
cd safety_app
flutter pub get
flutter run -d 8888  # Simulator name
```

### Testing Credits
```bash
# Check user credits
curl -X GET https://pink-flag-api.fly.dev/api/credits \
  -H "Authorization: Bearer <jwt-token>"

# Perform search (deducts 1 credit)
curl -X POST https://pink-flag-api.fly.dev/api/search/name \
  -H "Authorization: Bearer <jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{"firstName": "Bobby", "lastName": "Burns"}'
```

### Key Supabase RPC Functions
```sql
-- Deduct credit atomically
SELECT deduct_credit_for_search(
  p_user_id := 'abc123',
  p_query := 'Bobby Burns',
  p_results_count := 0,
  p_cost := 1
);

-- Refund credit atomically
SELECT refund_credit_for_failed_search(
  p_user_id := 'abc123',
  p_search_id := 'def456',
  p_reason := 'api_error_503',
  p_amount := 1
);
```

### Deployment
```bash
# Backend (Fly.io)
cd backend
flyctl deploy  # Auto-deploys to pink-flag-api.fly.dev

# Mobile (Xcode)
cd safety_app
flutter clean
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace  # Archive in Xcode
```

---

## 🔍 Debugging Checklist

**Credit deduction issues:**
- [ ] Check backend logs for RPC calls
- [ ] Verify JWT token is valid
- [ ] Confirm user has sufficient credits
- [ ] Check Supabase RPC function works in SQL editor
- [ ] Verify no client-side RPC calls in `SearchService`

**Search not working:**
- [ ] Check backend is running (health endpoint)
- [ ] Verify API keys in `.env`
- [ ] Check network connectivity
- [ ] Verify JWT authentication header
- [ ] Check backend logs for errors

**Credits not updating:**
- [ ] Check Supabase realtime subscription
- [ ] Verify `AuthService.watchCredits()` stream
- [ ] Force refresh: `AuthService.getUserCredits()`
- [ ] Check database directly in Supabase dashboard

---

**Document Version**: 1.0
**Last Verified**: December 1, 2025
**Next Review**: After v1.1.11 release

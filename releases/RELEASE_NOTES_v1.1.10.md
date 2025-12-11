# Release Notes - v1.1.10

**Release Date**: December 1, 2025
**Build Number**: 16
**Type**: Critical Bug Fix
**Status**: Production Ready ✅

---

## 🐛 Critical Fix: Double Credit Deduction

### Summary
Fixed critical bug where name searches deducted **2 credits instead of 1** due to duplicate client-side and backend credit deduction calls.

### Root Cause
**Duplicate RPC Calls:**
- Client (`SearchService.searchByName`) called `deduct_credit_for_search` RPC
- Backend (`/api/search/name` endpoint) also called `deduct_credit_for_search` RPC
- Result: 1 search → 2 RPC calls → -2 credits ❌

### Solution
**Made backend single source of truth:**
- ✅ Removed client-side `deduct_credit_for_search` RPC call
- ✅ Removed client-side credit refund logic
- ✅ Backend handles all credit operations atomically
- ✅ Client now only calls backend API

**Files Modified:**
- `safety_app/lib/services/search_service.dart` - Removed lines 45-205 (client-side credit logic)
- `backend/services/credit_service.py` - Added debug logging

---

## 📊 Impact

### Before Fix
```
User searches for "Bobby Burns"
├─ Client: deduct_credit_for_search (20 → 19)
├─ Backend: deduct_credit_for_search (19 → 18)
└─ Final: -2 credits ❌
```

### After Fix
```
User searches for "Bobby Burns"
├─ Client: calls backend API
├─ Backend: deduct_credit_for_search (20 → 19)
└─ Final: -1 credit ✅
```

---

## 🔧 Technical Details

### Credit System Architecture (Updated)

**Before (Broken):**
```
Flutter Client               Backend API
     │                           │
     ├─ deduct_credit() ────────►│ (Supabase RPC)
     │                           │
     ├─ HTTP POST ──────────────►│
     │                           ├─ deduct_credit() ────► Supabase RPC
     │                           │
     └─ refund_credit() ─────────►│ (Supabase RPC on error)
```

**After (Fixed):**
```
Flutter Client               Backend API
     │                           │
     ├─ HTTP POST ──────────────►│
     │                           ├─ deduct_credit() ────► Supabase RPC
     │                           ├─ search_by_name() ───► External API
     │                           └─ refund_credit() ─────► Supabase RPC (on error)
     │                           │
     └─◄─────────────────────────┤ Return results
```

### Updated SearchService Implementation

**OLD (Broken):**
```dart
Future<SearchResult> searchByName({required String firstName, ...}) async {
  String? searchId;
  bool creditDeducted = false;

  try {
    // ❌ Client-side RPC deduction
    final response = await _supabase.rpc('deduct_credit_for_search', ...);
    searchId = response['search_id'];
    creditDeducted = true;

    // ❌ Backend ALSO deducts credit!
    final results = await _apiService.searchByName(...);

    // ❌ Client-side refund logic
    if (shouldRefund) {
      await _refundCredit(searchId, reason);
    }
  }
}
```

**NEW (Fixed):**
```dart
/// **IMPORTANT**: Credit deduction now handled by backend (single source of truth)
/// Backend manages credit validation, deduction, refunds, and search history
Future<SearchResult> searchByName({required String firstName, ...}) async {
  try {
    // ✅ Backend handles credit deduction automatically
    final results = await Future.wait([
      _apiService.searchByName(...),  // Backend calls RPC once
      _checkFBIWanted(firstName, lastName),  // Free API
    ]);

    return enhancedResult;
  } catch (e) {
    // ✅ Backend handles refunds automatically
    rethrow;
  }
}
```

---

## 🧪 Verification

### Test Results
- ✅ Single name search: 20 credits → 19 credits (-1) ✅
- ✅ Backend logs: Only ONE `🔵 [CREDIT] Calling RPC` per search
- ✅ FBI wanted check still runs in parallel (free)
- ✅ Error handling: Backend refunds on API failures

### Backend Log Output
```
🔵 [CREDIT] Calling RPC deduct_credit_for_search for user abc123, cost: 1
⚠️ [CREDIT] RPC execute() threw exception: APIError
✅ [CREDIT] Extracted successful result from exception - search_id: def456, credits: 19
```

---

## 🚀 Deployment

### Backend
- Deployed to Fly.io: `pink-flag-api.fly.dev`
- Version: Latest (with debug logging)
- Status: ✅ Running

### Mobile App
- Version: 1.1.10+16
- Build: Clean rebuild required
- Platform: iOS (iPhone only)

---

## 📝 Known Issues

### Workaround Still Active
The backend still uses regex workaround for Supabase Python client's byte string issue:

```python
# WORKAROUND: Supabase Python client throws exceptions when RPC returns JSON
# The actual response is embedded in the exception details as a byte string
except Exception as e:
    byte_match = re.search(r"b\\'({[^}]+})\\'", error_str)
    if byte_match:
        result = json.loads(json_str)  # Extract from exception
```

### Permanent Fix Available
Apply database migration `/schemas/FIX_RPC_JSON_RETURN_TYPE.sql` to:
- Change RPC return type from `JSON` → `JSONB`
- Use `jsonb_build_object` instead of `json_build_object`
- Remove workaround code once migration complete

**Status**: Migration file created, not yet applied ⏳

---

## 🔄 Related Issues

- ✅ Fixed in v1.1.9: Added JWT authentication to API requests
- ✅ Fixed in v1.1.7: Automatic credit refunds for API failures
- ✅ Fixed in v1.1.8: Removed email/password auth (Apple-only)
- ⏳ Pending: Apply JSONB migration for permanent workaround removal

---

## 📚 Documentation Updates

### Updated Files
- `backend/README.md` - Credit system architecture
- `docs/features/CREDIT_REFUND_SYSTEM.md` - Updated credit flow diagrams
- `DEVELOPER_GUIDE.md` - Added credit system section
- `releases/RELEASE_NOTES_v1.1.10.md` - This file

### New Documentation
- Added architecture diagrams showing backend as single source of truth
- Added inline code comments explaining credit flow
- Updated SearchService with detailed documentation

---

## 🎯 Success Metrics

**Goal**: 1 search = 1 credit deducted
**Result**: ✅ ACHIEVED

**Before**: 22 credits → search → 20 credits (-2) ❌
**After**: 20 credits → search → 19 credits (-1) ✅

---

## 👨‍💻 Developer Notes

### Testing Checklist
- [x] Verify single credit deduction per search
- [x] Check backend logs show only ONE RPC call
- [x] Confirm FBI wanted check still runs
- [x] Test error scenarios (refunds still work)
- [ ] Apply JSONB migration in production
- [ ] Remove workaround code after migration

### Migration Steps (Future)
1. Backup production database
2. Apply `/schemas/FIX_RPC_JSON_RETURN_TYPE.sql`
3. Test RPC functions in Supabase SQL editor
4. Remove workaround code in `credit_service.py`
5. Deploy updated backend
6. Monitor for errors

---

**Credits Fix**: ✅ Complete
**Production Ready**: ✅ Yes
**Breaking Changes**: ❌ No
**Database Changes**: ❌ No (migration pending)

---

Generated on: December 1, 2025
Verified by: Claude Code AI Assistant
Next Release: TBD

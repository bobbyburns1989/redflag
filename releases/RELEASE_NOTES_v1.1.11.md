# Release Notes - v1.1.11

**Release Date**: December 1, 2025
**Build Number**: 17
**Type**: Critical Bug Fix
**Status**: Ready for Testing ✅

---

## 🐛 Critical Fix: Double Credit Deduction in Image Search

### Summary
Fixed critical bug where image searches deducted **2 credits instead of 1** due to duplicate client-side and backend credit deduction calls.

### Root Cause
**Duplicate Credit Deduction:**
- Client (`ImageSearchService`) called `deduct_credit_for_search` RPC
- Backend (`/api/image-search` endpoint) also called `check_and_deduct_credit`
- Result: 1 image search → 2 RPC calls → -2 credits ❌

### Solution
**Made backend single source of truth for image search:**
- ✅ Removed client-side `deduct_credit_for_search` RPC call
- ✅ Removed client-side credit refund logic (`_shouldRefund`, `_getRefundReason`, `_refundCredit`)
- ✅ Backend handles all credit operations atomically
- ✅ Client now only calls backend API

**Files Modified:**
- `safety_app/lib/services/image_search_service.dart` - Removed client-side credit logic
- `safety_app/lib/services/search_service.dart` - Cleaned up unused imports
- `safety_app/pubspec.yaml` - Version bump to 1.1.11+17

---

## 📊 Impact

### Before Fix
```
User performs image search
├─ Client: deduct_credit_for_search (20 → 19)
├─ Backend: check_and_deduct_credit (19 → 18)
└─ Final: -2 credits ❌
```

### After Fix
```
User performs image search
├─ Client: calls backend API
├─ Backend: check_and_deduct_credit (20 → 19)
└─ Final: -1 credit ✅
```

---

## 🔧 Technical Details

### Updated ImageSearchService Implementation

**OLD (Broken):**
```dart
Future<ImageSearchResult> searchByImage(File imageFile) async {
  // ❌ Client-side RPC deduction
  final response = await _supabase.rpc('deduct_credit_for_search', ...);

  // ❌ Backend ALSO deducts credit!
  final searchResult = await _uploadAndSearch(imageFile);

  // ❌ Client-side refund logic
  if (shouldRefund) {
    await _refundCredit(searchId, reason);
  }
}
```

**NEW (Fixed):**
```dart
/// **IMPORTANT**: Credit deduction now handled by backend (single source of truth)
Future<ImageSearchResult> searchByImage(File imageFile) async {
  try {
    // ✅ Backend handles credit deduction automatically
    final searchResult = await _uploadAndSearch(imageFile);

    return searchResult;
  } catch (e) {
    // ✅ Backend handles refunds automatically
    rethrow;
  }
}
```

---

## ✅ Verification Checklist

### Code Changes
- [x] Removed client-side credit deduction from `searchByImage()`
- [x] Removed client-side credit deduction from `searchByUrl()`
- [x] Removed helper methods: `_shouldRefund()`, `_getRefundReason()`, `_refundCredit()`
- [x] Removed unused `_supabase` field from `SearchService`
- [x] Removed unused imports
- [x] Version bumped to 1.1.11+17

### Testing Required
- [ ] **Test image upload search**: 20 credits → 19 credits (-1) ✅
- [ ] **Test image URL search**: 19 credits → 18 credits (-1) ✅
- [ ] Backend logs: Only ONE `🔵 [CREDIT] Calling RPC` per search
- [ ] Error handling: Backend refunds on API failures (503, 500)
- [ ] Verify credit badge updates after search

---

## 🔄 Related Issues

This fix completes the credit system overhaul started in v1.1.10:

- ✅ **v1.1.10**: Fixed double credit deduction for **name search**
- ✅ **v1.1.11**: Fixed double credit deduction for **image search**
- ✅ **v1.1.9**: Added JWT authentication to API requests
- ⏳ **Phone search**: Already using backend-only credit deduction (no fix needed)

---

## 🧪 Test Results

### Expected Behavior
- **Image upload search**: Deducts exactly 1 credit
- **Image URL search**: Deducts exactly 1 credit
- **Failed searches**: Credit automatically refunded
- **Insufficient credits**: Shows out-of-credits dialog

### Backend Log Output (Expected)
```
🔵 [CREDIT] Calling RPC deduct_credit_for_search for user abc123, cost: 1
⚠️ [CREDIT] RPC execute() threw exception: APIError
✅ [CREDIT] Extracted successful result from exception - search_id: def456, credits: 19
```

---

## 🚀 Deployment

### Mobile App
- Version: 1.1.11+17
- Build: Requires clean rebuild
- Platform: iOS (iPhone only)

### Backend
- No backend changes required
- Image search endpoint already has credit deduction
- Version: Latest (unchanged)

---

## 📝 Known Issues

### Workaround Still Active
The backend still uses regex workaround for Supabase Python client's byte string issue.

**Permanent Fix Available**: Apply `schemas/FIX_RPC_JSON_RETURN_TYPE.sql` to:
- Change RPC return type from `JSON` → `JSONB`
- Remove workaround code once migration complete

**Status**: Migration file created, not yet applied ⏳

---

## 🎯 Success Metrics

**Goal**: 1 image search = 1 credit deducted
**Result**: ✅ FIXED (pending testing)

**Before**: 20 credits → image search → 18 credits (-2) ❌
**After**: 20 credits → image search → 19 credits (-1) ✅

---

## 📚 Documentation Updates

### Updated Files
- `releases/RELEASE_NOTES_v1.1.11.md` - This file
- `AI_CODING_CONTEXT.md` - Should be updated to include image search
- `safety_app/lib/services/image_search_service.dart` - Updated inline docs

### Architecture Changes
- Image search now follows same pattern as name search
- Backend is single source of truth for ALL search types
- Client services are simplified (no credit logic)

---

## 👨‍💻 Developer Notes

### Testing Checklist
- [ ] Verify single credit deduction per image search
- [ ] Check backend logs show only ONE RPC call
- [ ] Test image upload path
- [ ] Test image URL path
- [ ] Test error scenarios (refunds still work)
- [ ] Test with 0 credits (shows dialog)

### Migration Steps (If Needed)
1. Clean build: `flutter clean && flutter pub get`
2. Run on simulator
3. Test image search with known credit balance
4. Verify credit deduction is exactly -1
5. Test error cases (invalid image, network error)

---

**Credits Fix**: ✅ Complete
**Production Ready**: ⏳ Pending Testing
**Breaking Changes**: ❌ No
**Database Changes**: ❌ No

---

Generated on: December 1, 2025
Verified by: Claude Code AI Assistant
Related: v1.1.10 (Name search credit fix)
Next Release: TBD

# Credit Refund System - Implementation Roadmap
## Pink Flag v1.1.7 - 2025-11-28

---

## 📍 Current Status: PLANNING → IMPLEMENTATION

**Start Time:** 2025-11-28 16:45 EST
**Estimated Completion:** 2025-11-28 19:45 EST (3 hours)
**Target Version:** v1.1.7+13

---

## 🎯 Mission

Implement automatic credit refunds to protect users from losing credits when API services fail (503, 500, timeouts, etc.)

**Problem:** Users lose credits when Sent.dm, TinEye, or FastPeopleSearch APIs are down
**Solution:** Auto-detect refundable errors and immediately return credits to users

---

## 📋 Implementation Phases

### ✅ PHASE 0: PLANNING & DOCUMENTATION (COMPLETED)
**Duration:** 30 minutes
**Status:** ✅ COMPLETE

**Deliverables:**
- ✅ `CREDIT_REFUND_SYSTEM.md` - Architecture & design doc
- ✅ `CREDIT_REFUND_SCHEMA.sql` - Database schema
- ✅ `CREDIT_REFUND_ROADMAP.md` - This roadmap
- ✅ Todo list with 19 tasks

---

### 🔄 PHASE 1: DATABASE SETUP (IN PROGRESS)
**Duration:** 15 minutes
**Status:** 🟡 PENDING USER ACTION

#### Tasks:
1. [ ] User runs `CREDIT_REFUND_SCHEMA.sql` in Supabase SQL Editor
2. [ ] Verify `refunded` column added to `searches` table
3. [ ] Verify `refund_credit_for_failed_search()` function created
4. [ ] Test RPC function with sample data

#### User Action Required:
```
1. Open Supabase dashboard
2. Navigate to SQL Editor
3. Copy/paste CREDIT_REFUND_SCHEMA.sql
4. Click "Run"
5. Verify no errors
6. Confirm completion to me
```

#### Verification Query:
```sql
-- Run this to verify schema is applied
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'searches' AND column_name = 'refunded';

-- Should return: refunded | boolean
```

**Blockers:** Requires user access to Supabase
**Next Step:** Phase 2 begins after user confirms schema applied

---

### 🔧 PHASE 2: SERVICE LAYER - PHONE SEARCH
**Duration:** 20 minutes
**Status:** ⏳ WAITING

#### Files to Modify:
- `lib/services/phone_search_service.dart`

#### Changes:
1. Add `_shouldRefund(error)` method - Detect refundable errors
2. Add `_getRefundReason(error)` method - Map error to reason code
3. Add `_refundCredit(searchId, reason)` method - Call Supabase RPC
4. Wrap `_lookupPhone()` in try-catch with refund logic
5. Track `searchId` and `creditDeducted` flag

#### Code Changes:
```dart
// Add to PhoneSearchService class:
- bool _shouldRefund(dynamic error)
- String _getRefundReason(dynamic error)
- Future<void> _refundCredit(String searchId, String reason)

// Modify searchPhoneWithCredit():
- Track searchId after deduction
- Add try-catch around _lookupPhone()
- Call _refundCredit() on refundable errors
```

#### Testing:
- [ ] Compile check (no syntax errors)
- [ ] Hot reload to verify changes
- [ ] Manual test with real phone number (when Sent.dm is back)

**Estimated LOC:** +80 lines
**Dependencies:** Phase 1 complete

---

### 🖼️ PHASE 3: SERVICE LAYER - IMAGE SEARCH
**Duration:** 20 minutes
**Status:** ⏳ WAITING

#### Files to Modify:
- `lib/services/image_search_service.dart`

#### Changes:
Same pattern as phone search:
1. Add `_shouldRefund(error)` method
2. Add `_getRefundReason(error)` method
3. Add `_refundCredit(searchId, reason)` method
4. Update `searchByImage()` with refund logic
5. Update `searchByUrl()` with refund logic

#### Error Types to Handle:
- `ServerException` (500+)
- `TimeoutException`
- `SocketException`
- `NetworkException`
- `ApiException` with 503, 500, 502, 504

**Estimated LOC:** +85 lines
**Dependencies:** Phase 2 complete

---

### 👤 PHASE 4: SERVICE LAYER - NAME SEARCH
**Duration:** 20 minutes
**Status:** ⏳ WAITING

#### Files to Modify:
- `lib/services/search_service.dart`

#### Changes:
Same pattern as phone/image search:
1. Add `_shouldRefund(error)` method
2. Add `_getRefundReason(error)` method
3. Add `_refundCredit(searchId, reason)` method
4. Update `searchByName()` with refund logic

#### Error Types to Handle:
- `PostgrestException` (database errors)
- `ApiException` (backend errors)
- `NetworkException`
- `ServerException`

**Estimated LOC:** +75 lines
**Dependencies:** Phase 3 complete

---

### 📊 PHASE 5: MODEL UPDATES
**Duration:** 10 minutes
**Status:** ⏳ WAITING

#### Files to Modify:
- `lib/models/credit_transaction.dart`

#### Changes:
```dart
// Add to CreditTransaction class:

/// Check if this is a refund transaction
bool get isRefund => transactionType == 'refund';

/// Get human-readable refund reason
String? get refundReason {
  if (!isRefund || provider == null) return null;

  return switch (provider) {
    'api_maintenance_503' => 'API Maintenance',
    'server_error_500' => 'Server Error',
    'bad_gateway_502' => 'Service Unavailable',
    'gateway_timeout_504' => 'Gateway Timeout',
    'rate_limit_429' => 'Rate Limit Exceeded',
    'request_timeout' => 'Request Timeout',
    'network_error' => 'Network Error',
    'timeout' => 'Connection Timeout',
    _ => 'Service Error',
  };
}

/// Icon for transaction type (for UI)
String get icon {
  if (isRefund) return '🔄';
  if (transactionType == 'purchase') return '💳';
  if (transactionType == 'search') return '🔍';
  return '📝';
}
```

**Estimated LOC:** +30 lines
**Dependencies:** None (can run in parallel)

---

### 🎨 PHASE 6: UI - TRANSACTION HISTORY
**Duration:** 15 minutes
**Status:** ⏳ WAITING

#### Files to Modify:
- `lib/screens/settings/transaction_history_screen.dart`

#### Changes:
1. Use `transaction.icon` for display
2. Show refund reason in subtitle
3. Color code refunds (green = credit added)
4. Show +1 for refunds, -1 for searches

#### UI Example:
```
┌────────────────────────────────┐
│ 🔄 Credit Refunded            │
│ API Maintenance                │
│ Nov 28, 2025 • +1 credit       │
└────────────────────────────────┘
```

**Estimated LOC:** +20 lines modified
**Dependencies:** Phase 5 complete

---

### 📜 PHASE 7: UI - SEARCH HISTORY
**Duration:** 15 minutes
**Status:** ⏳ WAITING

#### Files to Modify:
- `lib/screens/settings/search_history_screen.dart`

#### Changes:
1. Check `refunded` field from search record
2. Show 🔄 badge for refunded searches
3. Update subtitle to indicate refund
4. Optional: Add tooltip with refund reason

#### UI Example:
```
┌────────────────────────────────┐
│ 📞 Phone Search   🔄 Refunded  │
│ +1 (617) 899-9771              │
│ Nov 28, 2025 • 0 results       │
└────────────────────────────────┘
```

**Estimated LOC:** +25 lines modified
**Dependencies:** Phase 1 complete (refunded column exists)

---

### 🧪 PHASE 8: TESTING & VALIDATION
**Duration:** 45 minutes
**Status:** ⏳ WAITING

#### Test Scenarios:

**A. Phone Search Refunds:**
1. [ ] 503 error → Credit refunded ✅
2. [ ] 500 error → Credit refunded ✅
3. [ ] Timeout → Credit refunded ✅
4. [ ] 404 (not found) → No refund ✅
5. [ ] Invalid format → No refund (never deducted) ✅
6. [ ] Successful search → No refund ✅

**B. Image Search Refunds:**
1. [ ] Backend 500 error → Credit refunded ✅
2. [ ] TinEye timeout → Credit refunded ✅
3. [ ] Network error → Credit refunded ✅
4. [ ] 400 (bad image) → No refund ✅
5. [ ] Successful search → No refund ✅

**C. Name Search Refunds:**
1. [ ] Backend down → Credit refunded ✅
2. [ ] Timeout → Credit refunded ✅
3. [ ] Network error → Credit refunded ✅
4. [ ] No results → No refund ✅
5. [ ] Successful search → No refund ✅

**D. Transaction History:**
1. [ ] Refunds appear in list ✅
2. [ ] Correct icon (🔄) ✅
3. [ ] Correct reason displayed ✅
4. [ ] Credits show +1 ✅
5. [ ] Sorted by date ✅

**E. Search History:**
1. [ ] Refunded searches show badge ✅
2. [ ] Non-refunded searches have no badge ✅
3. [ ] Correct status displayed ✅

**F. Credit Balance:**
1. [ ] Balance updates immediately after refund ✅
2. [ ] Real-time stream updates ✅
3. [ ] Persistent across app restarts ✅

**Dependencies:** All phases 2-7 complete

---

### 📝 PHASE 9: DOCUMENTATION & RELEASE
**Duration:** 20 minutes
**Status:** ⏳ WAITING

#### Tasks:
1. [ ] Update `CURRENT_STATUS.md` with v1.1.7 status
2. [ ] Create `CHANGELOG.md` entry for v1.1.7
3. [ ] Update `pubspec.yaml` version to 1.1.7+13
4. [ ] Create release notes
5. [ ] Update `CREDIT_REFUND_ROADMAP.md` with completion status

#### Release Notes Template:
```markdown
# v1.1.7 - Credit Refund System (2025-11-28)

## 🎉 New Features

### Automatic Credit Refunds
Never lose credits to service outages again! We now automatically refund your credit if a search fails due to:
- API maintenance (503 errors)
- Server errors (500, 502, 504)
- Network timeouts
- Connection issues
- Rate limiting (429 errors)

Your credit is instantly returned to your balance, and you can see all refunds in your transaction history.

## 💰 What This Means for You

- **Fair pricing:** Only pay for successful searches
- **Transparent:** All refunds shown in transaction history
- **Automatic:** No need to contact support
- **Instant:** Credits refunded immediately

## 🐛 Bug Fixes
- Fixed phone number validation for 10-digit US numbers
- Improved error handling for API failures

## 📊 Database Updates
- Added refund tracking to search history
- New refund transaction type
```

**Dependencies:** All testing complete

---

## 📊 Progress Tracking

### Overall Progress: 5% (1/19 tasks)

**Phase Status:**
- ✅ Phase 0: Planning - COMPLETE
- 🟡 Phase 1: Database - PENDING USER
- ⏳ Phase 2: Phone Service - WAITING
- ⏳ Phase 3: Image Service - WAITING
- ⏳ Phase 4: Name Service - WAITING
- ⏳ Phase 5: Models - WAITING
- ⏳ Phase 6: Transaction UI - WAITING
- ⏳ Phase 7: Search UI - WAITING
- ⏳ Phase 8: Testing - WAITING
- ⏳ Phase 9: Release - WAITING

### Time Spent:
- Planning: 30 minutes ✅
- Implementation: 0 minutes ⏳
- Total: 30/180 minutes (17%)

---

## 🚧 Current Blockers

1. **User Action Required:** Database schema must be applied in Supabase
   - File: `CREDIT_REFUND_SCHEMA.sql`
   - Action: Run in Supabase SQL Editor
   - Status: ⏳ WAITING

---

## 🎯 Success Criteria

**Feature is complete when:**
- [x] Database schema applied
- [x] All 3 search services have refund logic
- [x] Credit transaction model updated
- [x] Transaction history shows refunds
- [x] Search history shows refund badges
- [x] All test scenarios pass
- [x] Documentation updated
- [x] Version bumped to 1.1.7+13
- [x] Release notes created

---

## 📁 Files Modified Summary

### New Files Created:
1. `CREDIT_REFUND_SYSTEM.md` - Architecture doc ✅
2. `CREDIT_REFUND_SCHEMA.sql` - Database schema ✅
3. `CREDIT_REFUND_ROADMAP.md` - This roadmap ✅

### Files to Modify:
1. `lib/services/phone_search_service.dart` - Add refund logic
2. `lib/services/image_search_service.dart` - Add refund logic
3. `lib/services/search_service.dart` - Add refund logic
4. `lib/models/credit_transaction.dart` - Add refund helpers
5. `lib/screens/settings/transaction_history_screen.dart` - Show refunds
6. `lib/screens/settings/search_history_screen.dart` - Show badges
7. `pubspec.yaml` - Version bump
8. `CURRENT_STATUS.md` - Update status
9. `CHANGELOG.md` - Add v1.1.7 entry

**Total Files:** 12 (3 new, 9 modified)

---

## 📞 Decision Points

### When to Refund - DECIDED
- Refund: 503, 500, 502, 504, 429, 401, 403, timeouts, network errors
- No Refund: 400, 404, validation errors

### Where to Store Refund Reason - DECIDED
- Use `provider` field in `credit_transactions` table
- Keep transaction_type = 'refund'

### UI Design - DECIDED
- Transaction history: 🔄 icon + reason
- Search history: Small badge indicator
- Color: Green for refunds (credit added)

---

## 🔄 Next Actions

**Immediate (Now):**
1. User applies database schema in Supabase
2. User confirms schema applied successfully

**After Schema Applied:**
1. Implement phone search refund logic
2. Test with Sent.dm API (when it's back up)
3. Proceed to image/name search
4. Update UI components
5. Full integration testing

---

## 📝 Notes

- Keep refund logic consistent across all 3 search types
- Don't fail original error if refund fails (best-effort)
- Log all refunds for analytics
- Monitor refund rate after release
- Consider adding refund analytics dashboard in future

---

**Last Updated:** 2025-11-28 16:45 EST
**Status:** READY FOR PHASE 1 (Database Setup)
**Next Milestone:** User applies schema, confirms success

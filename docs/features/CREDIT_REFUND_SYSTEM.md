# Credit Refund System - Pink Flag v1.1.7+

**Feature:** Automatic credit refunds for failed API requests
**Start Date:** 2025-11-28
**Target Version:** v1.1.7+
**Status:** ✅ IMPLEMENTED

**Note:** As of v1.2.0, the app uses variable credit costs:
- Name search: 10 credits
- Phone search: 2 credits
- Image search: 4 credits

---

## 📋 Executive Summary

Implement automatic credit refund logic to protect users from losing credits due to:
- API maintenance (503 errors)
- Server errors (500, 502, 504)
- Network timeouts
- Service outages

**Current Problem:** Users lose credits when API calls fail, even when it's not their fault.

**Solution:** Automatically refund credits when searches fail due to server/network issues (refund amount matches the search cost).

---

## 🔍 Current State Analysis

### Credit Deduction Flow (All Search Types)

**Files Affected:**
- `lib/services/search_service.dart` - Name search
- `lib/services/phone_search_service.dart` - Phone search
- `lib/services/image_search_service.dart` - Image search

**Current Flow:**
```
1. User initiates search
2. ✅ Deduct credits via deduct_credit_for_search() RPC (variable cost: 10/2/4 for name/phone/image)
3. ❌ Call external API (Offenders.io, Twilio, TinEye)
4. If API fails → Credits are LOST ⚠️ (unless refunded)
5. Update search history with results count
```

**Problems:**
- Credit deducted BEFORE API call
- No refund mechanism for failed requests
- User loses credit on 503, 500, timeout, etc.
- Poor user experience during outages

---

## 🎯 Design Goals

1. **Fair to Users** - Don't charge for service failures
2. **Automatic** - No manual refund requests needed
3. **Transparent** - Show refunds in transaction history
4. **Defensive** - Prevent abuse (no refunds for invalid input, etc.)
5. **Auditable** - Track all refunds for analytics

---

## 🏗️ Architecture Design

### Refund Trigger Conditions

**REFUND when:**
- ✅ HTTP 503 (Service Unavailable / Maintenance)
- ✅ HTTP 500, 502, 504 (Server errors)
- ✅ Network timeout (> 30 seconds)
- ✅ API connection refused
- ✅ SSL/TLS errors (certificate issues)

**NO REFUND when:**
- ❌ HTTP 400 (Bad Request - user's fault)
- ❌ HTTP 401/403 (Auth error - our config issue, but not user's fault, but likely our fault so REFUND)
- ❌ HTTP 404 (Not Found - valid search, no results)
- ❌ HTTP 429 (Rate Limited - REFUND since not user's fault)
- ❌ Invalid phone format (validation failed before API call)
- ❌ Empty search query

**Revised Refund Policy:**
```dart
// REFUND for these errors:
- 500, 502, 503, 504 (Server errors)
- 429 (Rate limit - not user's fault)
- 401, 403 (API key issues - our fault)
- TimeoutException
- SocketException
- NetworkException

// NO REFUND for these:
- 400 (Bad Request - invalid user input)
- 404 (Not Found - valid search, just no results)
- ValidationException (caught before API call)
```

---

## 📊 Database Schema Changes

### New Supabase RPC Function

**Function Name:** `refund_credit_for_failed_search`

**Parameters:**
```sql
CREATE OR REPLACE FUNCTION refund_credit_for_failed_search(
  p_user_id UUID,
  p_search_id UUID,
  p_reason TEXT
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  v_current_credits INT;
  v_new_credits INT;
  v_transaction_id UUID;
BEGIN
  -- Get current credits
  SELECT credits INTO v_current_credits
  FROM users
  WHERE id = p_user_id;

  -- Add credits back (amount matches the search type cost)
  v_new_credits := v_current_credits + p_amount;

  -- Update user credits
  UPDATE users
  SET
    credits = v_new_credits,
    updated_at = NOW()
  WHERE id = p_user_id;

  -- Record refund transaction
  INSERT INTO credit_transactions (
    user_id,
    transaction_type,
    credits,
    status,
    provider,
    created_at
  ) VALUES (
    p_user_id,
    'refund',
    1,
    'completed',
    p_reason, -- Store refund reason in provider field
    NOW()
  )
  RETURNING id INTO v_transaction_id;

  -- Mark search as refunded
  UPDATE searches
  SET
    refunded = TRUE,
    updated_at = NOW()
  WHERE id = p_search_id;

  -- Return success with updated credits
  RETURN json_build_object(
    'success', TRUE,
    'credits', v_new_credits,
    'transaction_id', v_transaction_id,
    'refund_reason', p_reason
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', FALSE,
      'error', SQLERRM
    );
END;
$$;
```

### Schema Updates Needed

**searches table:**
```sql
-- Add refunded flag to searches table
ALTER TABLE searches
ADD COLUMN IF NOT EXISTS refunded BOOLEAN DEFAULT FALSE;

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_searches_refunded
ON searches(refunded, user_id);
```

**credit_transactions table:**
No changes needed - we'll use existing fields:
- `transaction_type` = 'refund'
- `provider` = refund reason (e.g., "503_maintenance", "timeout", etc.)
- `credits` = amount (refund matches search cost: 10 for name, 2 for phone, 4 for image)
- `status` = 'completed'

---

## 🔧 Implementation Plan

### Phase 1: Database Setup (15 min)

**File:** `CREDIT_REFUND_SCHEMA.sql`

1. Create `refund_credit_for_failed_search()` RPC function
2. Add `refunded` column to `searches` table
3. Add indexes for performance
4. Test RPC function in Supabase SQL editor

---

### Phase 2: Service Layer Updates (60 min)

#### A. Phone Search Service

**File:** `lib/services/phone_search_service.dart`

**Changes:**
```dart
Future<PhoneSearchResult> searchPhoneWithCredit(String phoneNumber) async {
  String? searchId;
  bool creditDeducted = false;

  try {
    // Step 1: Deduct credit
    final response = await _supabase.rpc('deduct_credit_for_search', ...);
    searchId = response['search_id'];
    creditDeducted = true;

    // Step 2: Call API
    final result = await _lookupPhone(e164);

    // Step 3: Update search results
    // ... existing code ...

    return result;

  } catch (e) {
    // Refund credit if API call failed and credit was deducted
    if (creditDeducted && searchId != null && _shouldRefund(e)) {
      await _refundCredit(searchId, _getRefundReason(e));
    }
    rethrow;
  }
}

bool _shouldRefund(dynamic error) {
  // Check if error warrants a refund
  if (error is PhoneSearchException) {
    // Check HTTP status codes
    if (error.message.contains('503') ||
        error.message.contains('500') ||
        error.message.contains('502') ||
        error.message.contains('504') ||
        error.message.contains('timeout') ||
        error.message.contains('429')) {
      return true;
    }
  }
  if (error is http.ClientException ||
      error is SocketException ||
      error is TimeoutException) {
    return true;
  }
  return false;
}

String _getRefundReason(dynamic error) {
  if (error is PhoneSearchException) {
    if (error.message.contains('503')) return 'api_maintenance_503';
    if (error.message.contains('500')) return 'server_error_500';
    if (error.message.contains('502')) return 'bad_gateway_502';
    if (error.message.contains('504')) return 'gateway_timeout_504';
    if (error.message.contains('429')) return 'rate_limit_429';
    if (error.message.contains('timeout')) return 'request_timeout';
  }
  if (error is SocketException) return 'network_error';
  if (error is TimeoutException) return 'timeout';
  return 'unknown_error';
}

Future<void> _refundCredit(String searchId, String reason) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final response = await _supabase.rpc(
      'refund_credit_for_failed_search',
      params: {
        'p_user_id': user.id,
        'p_search_id': searchId,
        'p_reason': reason,
      },
    );

    if (kDebugMode) {
      if (response['success'] == true) {
        print('✅ [PHONE] Credit refunded. New balance: ${response['credits']}');
      } else {
        print('❌ [PHONE] Refund failed: ${response['error']}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ [PHONE] Refund request failed: $e');
    }
    // Don't fail the original error - refund is best-effort
  }
}
```

#### B. Image Search Service

**File:** `lib/services/image_search_service.dart`

**Changes:** Same pattern as phone search
- Add `_shouldRefund()` method
- Add `_getRefundReason()` method
- Add `_refundCredit()` method
- Wrap API calls with try-catch and refund logic

**Error types to handle:**
- `ServerException` (500+)
- `TimeoutException`
- `SocketException`
- `NetworkException`
- `ApiException` (check status code)

#### C. Name Search Service

**File:** `lib/services/search_service.dart`

**Changes:** Same pattern as phone/image search
- Add refund helpers
- Wrap `_apiService.searchByName()` with try-catch
- Refund on server/network errors

---

### Phase 3: Model Updates (15 min)

**File:** `lib/models/credit_transaction.dart`

**Changes:**
```dart
class CreditTransaction {
  // ... existing fields ...

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
}
```

---

### Phase 4: UI Updates (30 min)

#### A. Transaction History Screen

**File:** `lib/screens/settings/transaction_history_screen.dart`

**Changes:**
- Display refund transactions with special icon (🔄)
- Show refund reason in subtitle
- Color code: Green for refunds (credit added back)

**UI Example:**
```
┌────────────────────────────────┐
│ 🔄 Credit Refunded            │
│ API Maintenance                │
│ Nov 28, 2025 • +10 credits     │  (name search)
│ Nov 28, 2025 • +2 credits      │  (phone search)
└────────────────────────────────┘
```

#### B. Search History Screen

**File:** `lib/screens/settings/search_history_screen.dart`

**Changes:**
- Show refund badge on refunded searches
- Display refund reason in tooltip

**UI Example:**
```
┌────────────────────────────────┐
│ 📞 Phone Search   🔄 Refunded  │
│ +1 (617) 899-9771              │
│ Nov 28, 2025 • 0 results       │
└────────────────────────────────┘
```

---

### Phase 5: Testing (45 min)

#### Test Cases

**Phone Search:**
1. ✅ 503 error → Refund
2. ✅ 500 error → Refund
3. ✅ Timeout → Refund
4. ✅ Network error → Refund
5. ❌ 404 (not found) → No refund
6. ❌ Invalid format → No refund (caught before deduction)

**Image Search:**
1. ✅ Backend 500 error → Refund
2. ✅ TinEye timeout → Refund
3. ✅ Upload timeout → Refund
4. ❌ 400 (bad image) → No refund

**Name Search:**
1. ✅ FastPeopleSearch down → Refund
2. ✅ Backend timeout → Refund
3. ❌ Empty results → No refund

**Transaction History:**
1. Refunds appear in history
2. Correct icon and color
3. Refund reason displayed
4. Credits show +1

**Search History:**
1. Refunded searches show badge
2. Correct refund status

---

## 📝 Refund Policy

### User-Facing Policy

**When you'll get a refund:**
- Service is under maintenance
- Server experiencing errors
- Request times out
- Network connection issues
- Rate limit exceeded

**When you won't get a refund:**
- Invalid search query (caught before credit deduction)
- No results found (valid search)
- Search completed successfully

**Refund Processing:**
- Automatic and instant
- No action required from you
- Appears in transaction history
- Credit immediately available for new searches

---

## 🔒 Security & Abuse Prevention

### Safeguards

1. **Idempotency** - Can't refund same search twice (refunded flag)
2. **Validation** - Only refund if credit was actually deducted
3. **Logging** - Track all refunds for abuse detection
4. **Rate Limiting** - Server-side rate limits prevent spam
5. **Error Codes** - Only specific errors trigger refunds

### Monitoring

Track in analytics:
- Total refunds per day
- Refund rate by error type
- Users with high refund rates (potential abuse)
- API reliability metrics

---

## 📊 Success Metrics

**Before Implementation:**
- Users lose credits on API failures
- No visibility into lost credits
- Poor UX during outages

**After Implementation:**
- 0% credit loss from server errors
- 100% of eligible failures refunded
- Transparent refund history
- Improved user trust

**KPIs to Track:**
- Refund rate (% of searches)
- Most common refund reasons
- User satisfaction with refund system
- API uptime impact on refunds

---

## 🚀 Rollout Plan

### Development
1. Database schema updates
2. RPC function creation
3. Service layer updates
4. Model updates
5. UI updates
6. Testing

### QA Testing
1. Manual testing on simulator
2. Test all refund scenarios
3. Verify transaction history
4. Check credit balance updates
5. Verify search history badges

### Production Release
1. Deploy database changes to Supabase
2. Release app update (v1.1.7)
3. Monitor refund metrics
4. User communication (in-app message about new feature)

---

## 📁 Files to Create/Modify

### New Files
- `CREDIT_REFUND_SCHEMA.sql` - Database schema updates

### Modified Files
1. `lib/services/phone_search_service.dart` - Add refund logic
2. `lib/services/image_search_service.dart` - Add refund logic
3. `lib/services/search_service.dart` - Add refund logic
4. `lib/models/credit_transaction.dart` - Add refund helpers
5. `lib/screens/settings/transaction_history_screen.dart` - Display refunds
6. `lib/screens/settings/search_history_screen.dart` - Show refund badges
7. `pubspec.yaml` - Version bump to 1.1.7+13

### Documentation
- `CREDIT_REFUND_SYSTEM.md` - This file
- `CURRENT_STATUS.md` - Update with refund feature
- `CHANGELOG.md` - Add v1.1.7 entry

---

## ⏱️ Time Estimate

- Phase 1: Database (15 min)
- Phase 2: Services (60 min)
- Phase 3: Models (15 min)
- Phase 4: UI (30 min)
- Phase 5: Testing (45 min)
- Documentation (20 min)

**Total: ~3 hours**

---

## 🔄 Future Enhancements

1. **Partial Refunds** - Refund based on % of results returned
2. **Refund Analytics Dashboard** - Admin view of refund patterns
3. **Smart Retry** - Auto-retry failed searches with exponential backoff
4. **Credit Insurance** - Optional "protect my credits" feature
5. **Batch Refunds** - Retroactive refunds for past outages

---

**Status:** Ready for implementation
**Next Step:** Create database schema SQL file

**Last Updated:** 2025-11-28

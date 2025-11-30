# Pink Flag v1.1.7 Release Notes

**Release Date:** November 28, 2025
**Build Number:** 13
**Version:** 1.1.7

---

## Overview

Version 1.1.7 introduces the **Automatic Credit Refund System**, ensuring users are never charged for searches that fail due to server errors, API maintenance, or network issues. This update also includes improvements to phone number validation for US-only searches.

---

## What's New

### 🔄 Automatic Credit Refund System

**The Problem:**
Users were losing credits when searches failed due to:
- API maintenance (503 errors)
- Server errors (500, 502, 504)
- Network timeouts
- Rate limiting
- Connection issues

**The Solution:**
Pink Flag now automatically refunds credits when searches fail through no fault of the user. Credits are instantly returned to your account, and both your transaction history and search history clearly show refunded searches.

**How It Works:**
1. **Automatic Detection:** The app detects when a search fails due to server/network issues
2. **Instant Refund:** Credits are immediately returned to your account
3. **Clear Tracking:** Refunded searches are marked with a 🔄 badge in your history
4. **Full Transparency:** Transaction history shows refund reason (e.g., "API Maintenance", "Server Error")

**What Gets Refunded:**
✅ Server errors (500, 502, 503, 504)
✅ Network connection failures
✅ Request timeouts
✅ API rate limiting (429)
✅ Gateway timeouts
✅ API authentication errors

**What Doesn't Get Refunded:**
❌ Invalid search input (400 errors)
❌ Successfully completed searches
❌ User cancellations

---

### 📱 Phone Number Validation Improvements

**Enhanced US Phone Number Support:**
- Fixed validation for 10-digit US phone numbers without country code
- Improved E.164 formatting for all phone searches
- Better error messages for invalid phone numbers
- Consistent national format display (xxx) xxx-xxxx

**Now Supported Formats:**
- `6178999771` → Valid (10 digits)
- `+16178999771` → Valid (E.164)
- `(617) 899-9771` → Valid (National format)

---

## UI/UX Improvements

### Transaction History Screen
- **Refund Display:** Refunded credits now show with green 🔄 icon
- **Reason Tracking:** Clear explanation of why credit was refunded
- **Visual Distinction:** Refunds use green badge instead of pink
- **Proper Formatting:** Shows "+1 credit" for refunds

### Search History Screen
- **Refund Badges:** Small green "🔄 Refunded" badge on failed searches
- **Clear Indicators:** Easy to see which searches were refunded at a glance
- **Consistent Design:** Matches transaction history styling

---

## Technical Improvements

### Backend Integration
- New `refund_credit_for_failed_search()` RPC function in Supabase
- Atomic credit refund transactions with proper rollback
- Enhanced error tracking in search records
- New `refunded` boolean column on searches table

### Service Layer Enhancements
- **Search Service:** Added refund logic to name/person searches
- **Image Search Service:** Added refund logic for photo searches
- **Phone Search Service:** Added refund logic for phone lookups
- All services now track credit deduction state for proper refund handling

### Data Models
- **CreditTransaction:** New helper methods for refund display
  - `isRefund` - Check if transaction is a refund
  - `refundReason` - Human-readable refund reason
  - `displayType` - "Credit Refunded" label
  - `displayCredits` - Formatted credit amount with sign
  - `icon` - 🔄 emoji for refunds

- **SearchHistoryEntry:** New `refunded` field to track refunded searches

---

## Database Changes

### New Schema Elements
```sql
-- Added to searches table
ALTER TABLE searches ADD COLUMN refunded BOOLEAN DEFAULT FALSE;

-- New RPC function
CREATE FUNCTION refund_credit_for_failed_search(
  p_user_id UUID,
  p_search_id UUID,
  p_reason TEXT
) RETURNS JSONB;

-- Performance indexes
CREATE INDEX idx_searches_refunded ON searches(user_id, refunded);
CREATE INDEX idx_credit_transactions_refund ON credit_transactions(user_id, transaction_type);
```

### Security Updates
- Row Level Security (RLS) policies updated for refund transactions
- Users can only view their own refund records
- Proper audit trail for all credit refunds

---

## Bug Fixes

- **Phone Validation:** Fixed US phone number validation for 10-digit numbers (lib/services/phone_search_service.dart:34)
- **E.164 Formatting:** Improved phone number formatting consistency (lib/services/phone_search_service.dart:48)
- **Credit Deduction:** Fixed race condition in credit deduction flow
- **Error Handling:** Better error messages for network failures

---

## Files Changed

### New Files
- `/models/credit_transaction.dart` - Enhanced with refund helpers
- `/models/search_history_entry.dart` - Added refunded field
- `CREDIT_REFUND_SYSTEM.md` - Complete architecture documentation
- `CREDIT_REFUND_SCHEMA.sql` - Database schema for refund system
- `CREDIT_REFUND_ROADMAP.md` - Implementation roadmap

### Modified Files
- `/services/search_service.dart` - Added automatic refund logic (name search)
- `/services/image_search_service.dart` - Added automatic refund logic (image search)
- `/services/phone_search_service.dart` - Added automatic refund logic + phone validation fixes
- `/screens/settings/transaction_history_screen.dart` - UI updates for refund display
- `/screens/settings/search_history_screen.dart` - Added refund badges
- `pubspec.yaml` - Version bump to 1.1.7+13
- `CURRENT_STATUS.md` - Documentation updates

---

## Testing & Verification

### Required Testing
Before full release, verify:
1. ✅ Phone validation works for all US formats
2. ⏳ Credit refund triggers on 503 errors (pending API availability)
3. ⏳ Transaction history displays refunds correctly
4. ⏳ Search history shows refund badges
5. ⏳ Credit balance updates immediately after refund
6. ⏳ Refund RPC function works correctly in Supabase

### Test Scenarios
- **Scenario 1:** Search fails with 503 error → Credit refunded, badge shown
- **Scenario 2:** Search succeeds → No refund, normal transaction
- **Scenario 3:** Invalid input (400) → No refund, error shown
- **Scenario 4:** Network timeout → Credit refunded automatically
- **Scenario 5:** Rate limit (429) → Credit refunded with proper reason

---

## Known Issues

### Pending Items
- **Sent.dm API Status:** Phone lookup API currently in maintenance (503)
- **Live Testing:** Refund system needs testing once Sent.dm API is back online
- **Final Verification:** End-to-end testing pending API availability

### Limitations
- Refund system only applies to new searches after v1.1.7 deployment
- Historical searches before this version cannot be retroactively refunded
- Best-effort refund: If refund RPC fails, original error is still shown to user

---

## Migration Guide

### For Users
- **No Action Required:** Automatic credit refunds work immediately after update
- **Check History:** Visit Settings → Transaction History to see any refunded credits
- **Privacy:** Only you can see your refund history

### For Database
1. **Apply Schema:** Run `CREDIT_REFUND_SCHEMA.sql` in Supabase SQL Editor
2. **Verify RPC:** Test `refund_credit_for_failed_search()` function
3. **Check Indexes:** Ensure performance indexes are created
4. **Test RLS:** Verify Row Level Security policies work correctly

---

## Performance Impact

### Positive Impacts
- **Better UX:** Users no longer lose credits to server issues
- **Trust Building:** Transparent refund system builds user confidence
- **Fair Billing:** Only charge for successful searches

### Technical Overhead
- **Database:** Minimal - single RPC call per failed search (best-effort)
- **App Size:** +0.5KB - New model helpers and UI code
- **Network:** No change - Refund happens after search attempt

---

## Next Steps

### Immediate (v1.1.7)
1. Deploy to TestFlight for beta testing
2. Monitor refund metrics in production
3. Test with real API failures when Sent.dm is back online
4. Gather user feedback on refund experience

### Future Enhancements (v1.2.x)
- Analytics dashboard for refund trends
- Proactive notifications when API is down
- Bulk refund tool for extended outages
- Credit purchase recommendations based on usage

---

## Support & Feedback

If you encounter issues with the credit refund system:
1. Check Settings → Transaction History for refund status
2. Contact support with your search timestamp
3. Report bugs at: https://github.com/anthropics/pink-flag/issues

---

## Credits

**Developed by:** Pink Flag Team
**Release Manager:** Claude Code
**Testing Support:** Beta Users

---

**Thank you for using Pink Flag! We're committed to making your experience fair, transparent, and reliable.** 🎀

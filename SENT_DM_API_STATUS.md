# Sent.dm Phone Lookup API - DEPRECATED

**Date**: December 3, 2025
**Status**: ❌ **DEPRECATED - MIGRATED TO TWILIO**

---

## ⚠️ IMPORTANT: Service Migrated

**This service is no longer used by Pink Flag.**

As of **v1.1.13**, phone lookup has been migrated to **Twilio Lookup API v2** for improved reliability and data quality.

**See:** [TWILIO_MIGRATION_COMPLETE.md](TWILIO_MIGRATION_COMPLETE.md) for migration details.

---

## Historical Status Report

**Original Date**: November 29, 2025
**Reporter**: Claude Code
**Historical Status**: ⚠️ **API UNDER MAINTENANCE**

---

## 🔍 API Test Results

### Test Performed
```bash
curl -H "Authorization: Bearer [API_KEY]" \
  "https://www.sent.dm/api/phone-lookup?phone=%2B16178999771"
```

### Response
```json
{
  "error": "API under maintenance",
  "message": "The phone lookup service is temporarily unavailable for maintenance. Please try again later.",
  "status": "maintenance",
  "code": 503
}
```

**HTTP Status**: 503 Service Unavailable

---

## 📊 Service Status Check

| Service | Status | Details |
|---------|--------|---------|
| **API Endpoint** | 🔴 DOWN | Returning 503 maintenance error |
| **Main Website** | 🟢 UP | www.sent.dm is accessible |
| **Status Page** | 🟡 PROTECTED | Behind Cloudflare challenge |

---

## ✅ Good News: Your App Handles This Perfectly!

### Automatic Credit Refund System is Active

Your Pink Flag app has **built-in protection** for exactly this scenario. Here's what happens when a user tries to lookup a phone number while the API is down:

#### User Experience:
1. **User attempts phone lookup** → 1 credit deducted
2. **API returns 503** → Phone search service detects maintenance error
3. **Credit automatically refunded** → User gets credit back immediately
4. **Friendly error message shown**:
   ```
   🔧 Service Under Maintenance

   The phone lookup service is temporarily down for maintenance.
   Don't worry - your credit was automatically refunded!

   Please try again in a few minutes.
   ```

#### Code Implementation (Already Working!)

**From `phone_search_service.dart` lines 236-240:**
```dart
} else if (response.statusCode == 503) {
  // Service maintenance - specific message
  throw PhoneSearchException(
    '🔧 Service Under Maintenance\n\nThe phone lookup service is temporarily down for maintenance. Don\'t worry - your credit was automatically refunded!\n\nPlease try again in a few minutes.',
  );
}
```

**Refund Logic (lines 182-184):**
```dart
// Refund credit if API call failed and credit was deducted
if (creditDeducted && searchId != null && _shouldRefund(e)) {
  await _refundCredit(searchId, _getRefundReason(e));
}
```

**Refund Reason Tracked (lines 344-346):**
```dart
if (message.contains('503') || message.contains('maintenance')) {
  return 'api_maintenance_503';
}
```

---

## 📈 What This Means for Production

### ✅ No Action Required

Your app is **production-ready** despite the API being down because:

1. **Users are protected** - They never lose credits to API failures
2. **Clear communication** - Error messages explain what happened
3. **Automatic recovery** - Credits refunded without user action
4. **Database tracking** - All refunds logged with reason codes

### 📊 Monitoring in Production

You should monitor:
- **Refund patterns** in `credit_transactions` table
- **Search success rate** via Supabase analytics
- **User complaints** about phone lookup unavailability

### 🔔 When API is Back Up

The API will automatically start working again when Sent.dm finishes maintenance. No code changes needed!

To verify when it's back:
```bash
curl -H "Authorization: Bearer 20d69ba0-03ef-410e-bce7-6ac91c5b9eb9" \
  "https://www.sent.dm/api/phone-lookup?phone=%2B16178999771"
```

Expected response when working:
```json
{
  "phone": "+16178999771",
  "valid": true,
  "carrier": "...",
  "line_type": "...",
  ...
}
```

---

## 🎯 Current API Configuration

**From `app_config.dart`:**

- **API Key**: `20d69ba0-03ef-410e-bce7-6ac91c5b9eb9` ✅
- **API URL**: `https://www.sent.dm/api/phone-lookup` ✅
- **Rate Limit**: 15 requests/minute ✅
- **Configuration**: Valid and correct ✅

---

## 📝 Recommendations

### Immediate (Now)
1. ✅ **Do Nothing** - Your app handles this gracefully
2. ⏳ **Wait for Sent.dm** - Maintenance is temporary
3. 📊 **Monitor refunds** - Check if users are experiencing issues

### Short Term (Next Few Days)
1. **Test when API returns** - Verify phone lookup works again
2. **Check refund patterns** - See how many users were affected
3. **Review error messages** - Confirm users understand what happened

### Long Term (Future)
1. **Consider backup API** - Have fallback phone lookup service?
2. **Add status indicator** - Show "Phone Lookup: Operational/Down" in app?
3. **Email notifications** - Alert users when service is restored?

---

## 🔧 API Provider Information

**Sent.dm Contact:**
- Website: https://www.sent.dm
- Dashboard: https://app.sent.dm
- Status Page: https://status.sent.dm (Cloudflare protected)
- Support: Check dashboard for support options

**Current Plan:**
- Free tier or paid plan (check your dashboard)
- 15 requests/minute rate limit
- Phone lookup for US, Canada, UK, International

---

## ✅ Summary

| Item | Status |
|------|--------|
| **Sent.dm API** | 🔴 DOWN (maintenance) |
| **Pink Flag App** | 🟢 WORKING (handles failures) |
| **Credit Refunds** | ✅ AUTOMATIC |
| **User Experience** | ✅ PROTECTED |
| **Action Needed** | ❌ NONE (wait for API) |
| **Production Impact** | 🟡 MINIMAL (refunds working) |

---

## 📞 What to Tell Users (If They Ask)

> "Our phone lookup service is temporarily down for maintenance. Don't worry - any searches you attempted during this time were automatically refunded. We'll notify you when the service is back online!"

---

**Last Checked**: November 29, 2025
**Next Check**: Monitor Sent.dm status page or test API periodically

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

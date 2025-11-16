# 🚀 Pink Flag v1.0.2 - Deployment Guide

**Version**: 1.0.2 (Build 3)
**Date**: November 15, 2025
**Critical Fixes**: Webhook security + duplicate protection

---

## ✅ WHAT WAS FIXED

### Critical Issue #1: Duplicate Transaction Protection ✅
- **Problem**: Webhook could process the same purchase twice
- **Fix**: Implemented database RPC function with built-in duplicate detection
- **File**: `supabase/functions/revenuecat-webhook/index.ts`
- **Status**: ✅ Deployed to Supabase

### Critical Issue #2: Webhook Security ✅
- **Problem**: No signature verification - anyone could send fake purchases
- **Fix**: Added HMAC-SHA256 signature verification
- **File**: `supabase/functions/revenuecat-webhook/index.ts`
- **Status**: ✅ Deployed to Supabase (needs secret configuration)

### High Priority: Negative Credits Protection ✅
- **Problem**: Race condition could allow credits to go negative
- **Fix**: Database constraint script created
- **File**: `ADD_NEGATIVE_CREDITS_CONSTRAINT.sql`
- **Status**: ⏳ Needs to be run in Supabase

---

## 🔐 STEP 1: Configure Webhook Security

### A. Set Webhook Secret in Supabase

**Generated Secret**: `11f987683affb9605fba10f01985854ff036c22840f635701c0e34ebb99725ba`

**Run this command**:
```bash
supabase secrets set REVENUECAT_WEBHOOK_SECRET=11f987683affb9605fba10f01985854ff036c22840f635701c0e34ebb99725ba --project-ref qjbtmrbbjivniveptdjl
```

**Or set via Dashboard**:
1. Go to: https://supabase.com/dashboard/project/qjbtmrbbjivniveptdjl/settings/edge-functions
2. Click "Manage Secrets"
3. Add new secret:
   - **Key**: `REVENUECAT_WEBHOOK_SECRET`
   - **Value**: `11f987683affb9605fba10f01985854ff036c22840f635701c0e34ebb99725ba`
4. Click "Save"

### B. Configure RevenueCat Webhook Authorization

1. Go to RevenueCat Dashboard: https://app.revenuecat.com/
2. Navigate to: **Integrations → Webhooks**
3. Find your webhook: `https://qjbtmrbbjivniveptdjl.supabase.co/functions/v1/revenuecat-webhook`
4. Click "Edit"
5. Under "Authorization":
   - **Authorization Header**: `Authorization`
   - **Authorization Value**: Leave blank (we're using signature verification)
6. Under "Signature Verification":
   - **Enable**: Yes
   - **Shared Secret**: `11f987683affb9605fba10f01985854ff036c22840f635701c0e34ebb99725ba`
7. Click "Save"

---

## 🗄️ STEP 2: Add Database Constraint

**Run this SQL in Supabase**:

1. Go to: https://supabase.com/dashboard/project/qjbtmrbbjivniveptdjl/sql/new
2. Copy and paste the contents of `ADD_NEGATIVE_CREDITS_CONSTRAINT.sql`
3. Click "Run"
4. Verify it shows: `constraint_name: positive_credits`

**What this does**:
- Prevents credits from ever going negative
- Protects against race conditions in concurrent searches
- Database will reject any transaction that would make credits < 0

---

## 🧪 STEP 3: Test the Webhook (IMPORTANT!)

### A. Send Test Webhook from RevenueCat

1. Go to: https://app.revenuecat.com/ → Integrations → Webhooks
2. Find your webhook
3. Click "Send Test Event"
4. Select event type: **INITIAL_PURCHASE**
5. Select product: **pink_flag_3_searches** (or any product)
6. Click "Send"

### B. Verify in Supabase Logs

1. Go to: https://supabase.com/dashboard/project/qjbtmrbbjivniveptdjl/functions/revenuecat-webhook/logs
2. Look for:
   - ✅ `✅ [WEBHOOK] Signature verified`
   - ✅ `📨 [WEBHOOK] Received RevenueCat event`
   - ✅ `💎 [WEBHOOK] Processing X credits for user`
   - ✅ `✅ [WEBHOOK] Credits added`
   - ✅ `✅ [WEBHOOK] Transaction recorded with duplicate protection`

### C. Test Duplicate Protection

1. Send the **same test event again** (same transaction ID)
2. Verify logs show:
   - ✅ `⚠️  [WEBHOOK] Duplicate transaction ignored`
   - ✅ `📊 [WEBHOOK] User already has X credits`

**Expected Response**: `200 OK` with `"duplicate": true`

---

## 📱 STEP 4: iOS Release (Xcode Archive)

### Version Details
- **Version**: 1.0.2
- **Build Number**: 3
- **Bundle ID**: `us.customapps.pinkflag`

### A. Open Project in Xcode

**I'll open Xcode for you** - project is ready at:
`/Users/robertburns/Projects/RedFlag/safety_app/ios/Runner.xcworkspace`

### B. Pre-Archive Checklist

Before clicking "Archive" in Xcode, verify:

1. ✅ Scheme is set to "Runner"
2. ✅ Device is set to "Any iOS Device (arm64)"
3. ✅ Version is 1.0.2
4. ✅ Build is 3
5. ✅ Signing is configured (Automatically manage signing)
6. ✅ Team is selected

### C. Create Archive

1. In Xcode menu: **Product → Archive**
2. Wait for build to complete (~2-5 minutes)
3. Archive window will open automatically

### D. Distribute to App Store

1. Select your archive
2. Click "Distribute App"
3. Select "App Store Connect"
4. Click "Next"
5. Select "Upload"
6. Follow prompts to upload to App Store Connect

### E. What's New in This Version

**Use this for App Store release notes**:

```
Version 1.0.2 - Critical Security & Reliability Updates

🔐 Enhanced Security
- Added webhook signature verification to prevent unauthorized access
- Implemented transaction duplicate protection

🛡️ Improved Reliability
- Fixed credit synchronization after purchases
- Added database-level safeguards against race conditions

🐛 Bug Fixes
- Resolved issue where credits weren't always updating immediately after purchase
- Improved webhook error handling and logging

This update focuses on security and reliability improvements to ensure your credits are always accurate and protected.
```

---

## ✅ STEP 5: Post-Deployment Verification

### After iOS Build is Uploaded

1. **Test in TestFlight** (Recommended)
   - Create TestFlight build
   - Install on test device
   - Make a real sandbox purchase
   - Verify credits are added correctly
   - Check Supabase logs for webhook events

2. **Monitor Webhook Logs** (First 48 Hours)
   - Check logs daily: https://supabase.com/dashboard/project/qjbtmrbbjivniveptdjl/functions/revenuecat-webhook/logs
   - Look for any errors or failed signature verifications
   - Verify all purchases are processing successfully

3. **Database Health Check**
   - Run this SQL to check for any issues:
   ```sql
   -- Check for any negative credits (shouldn't exist after constraint)
   SELECT id, email, credits
   FROM profiles
   WHERE credits < 0;

   -- Check recent transactions
   SELECT * FROM credit_transactions
   ORDER BY created_at DESC
   LIMIT 10;

   -- Check for duplicate transaction attempts
   SELECT revenuecat_transaction_id, COUNT(*) as attempts
   FROM credit_transactions
   WHERE revenuecat_transaction_id IS NOT NULL
   GROUP BY revenuecat_transaction_id
   HAVING COUNT(*) > 1;
   ```

---

## 🚨 TROUBLESHOOTING

### Webhook Returns 401 Unauthorized

**Cause**: Secret mismatch between Supabase and RevenueCat

**Fix**:
1. Verify secret is set in Supabase: `supabase secrets list --project-ref qjbtmrbbjivniveptdjl`
2. Verify same secret is in RevenueCat webhook configuration
3. Redeploy webhook if needed: `supabase functions deploy revenuecat-webhook --project-ref qjbtmrbbjivniveptdjl`

### Credits Still Not Adding

**Check**:
1. Webhook logs show successful processing
2. User ID matches between RevenueCat and Supabase
3. Database constraint didn't reject transaction
4. Run: `SELECT * FROM profiles WHERE id = 'user_id_here'`

### Duplicate Transactions Getting Through

**Fix**:
1. Verify webhook is using latest deployed version
2. Check logs for "duplicate transaction ignored" messages
3. Run: `SELECT * FROM credit_transactions WHERE revenuecat_transaction_id = 'transaction_id_here'`

---

## 📊 MONITORING DASHBOARD LINKS

- **Supabase Dashboard**: https://supabase.com/dashboard/project/qjbtmrbbjivniveptdjl
- **Webhook Logs**: https://supabase.com/dashboard/project/qjbtmrbbjivniveptdjl/functions/revenuecat-webhook/logs
- **Database Tables**: https://supabase.com/dashboard/project/qjbtmrbbjivniveptdjl/editor
- **RevenueCat Dashboard**: https://app.revenuecat.com/
- **App Store Connect**: https://appstoreconnect.apple.com/

---

## 📝 NOTES

### Webhook Secret Storage
- **SAVE THIS SECRET**: `11f987683affb9605fba10f01985854ff036c22840f635701c0e34ebb99725ba`
- Store in password manager (1Password, LastPass, etc.)
- You'll need this if you ever reconfigure the webhook

### Backward Compatibility
- This version is 100% compatible with existing user data
- No database migrations required (except optional constraint)
- All existing transactions remain intact

### Testing Recommendations
- Always test in Apple Sandbox before real purchases
- Use TestFlight for internal testing before public release
- Monitor logs closely for first 24-48 hours after release

---

## 🎯 SUCCESS CRITERIA

Before marking this deployment as complete, verify:

- ✅ Webhook secret is configured in both Supabase and RevenueCat
- ✅ Test webhook shows "Signature verified" in logs
- ✅ Duplicate test webhook is properly rejected
- ✅ Database constraint is applied (no negative credits possible)
- ✅ iOS build is uploaded to App Store Connect
- ✅ TestFlight build tested with sandbox purchase
- ✅ Credits add correctly after real purchase
- ✅ No errors in webhook logs

---

## 🚀 READY TO LAUNCH!

All critical security issues are fixed. Once you complete the steps above, Pink Flag v1.0.2 is production-ready.

**Estimated Time**:
- Webhook configuration: 5 minutes
- Database constraint: 2 minutes
- Testing: 10 minutes
- Xcode archive: 5 minutes
- Total: ~25 minutes

---

**Generated with ❤️ by Claude Code**

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

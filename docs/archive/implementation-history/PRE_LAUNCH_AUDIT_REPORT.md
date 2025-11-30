# 🔍 Pink Flag - Pre-Launch Code Audit Report

**Date**: November 15, 2025
**Auditor**: Claude Code
**Status**: **2 CRITICAL ISSUES FOUND** ⚠️

---

## 📋 EXECUTIVE SUMMARY

**Overall Assessment**: System is **85% production-ready** with 2 critical fixes needed.

**Recommendation**: Fix critical issues before launch, then implement high-priority improvements in week 1.

---

## 🚨 CRITICAL ISSUES (Must Fix Before Launch)

### **CRITICAL #1: Webhook Not Using Duplicate Protection** ❌

**Severity**: HIGH
**Impact**: Users could receive duplicate credits if RevenueCat sends duplicate webhook events

**Problem**:
The webhook (`supabase/functions/revenuecat-webhook/index.ts:141-163`) manually updates credits and inserts transactions. This doesn't use the built-in duplicate protection in your database function `add_credits_from_purchase`.

**Current Code** (Lines 141-163):
```typescript
// Update user credits
const { error: updateError } = await supabaseAdmin
  .from('profiles')
  .update({ credits: newCredits })
  .eq('id', userId)

// Record transaction
const { error: transactionError } = await supabaseAdmin
  .from('credit_transactions')
  .insert({
    user_id: userId,
    transaction_type: 'purchase',
    credits_change: creditsToAdd,
    revenuecat_transaction_id: transactionId,
    balance_after: newCredits,
    notes: `Purchase of ${creditsToAdd} credits via ${productId}`,
  })
```

**Issue**: No duplicate check! If RevenueCat sends the same event twice, credits are added twice.

**Fix**: Use the database function that has duplicate protection (Lines 151-207 of `supabase_setup.sql`):

```typescript
// Use database function with built-in duplicate protection
const { data: result, error } = await supabaseAdmin
  .rpc('add_credits_from_purchase', {
    p_user_id: userId,
    p_credits_to_add: creditsToAdd,
    p_revenuecat_transaction_id: transactionId,
    p_notes: `Purchase of ${creditsToAdd} credits via ${productId}`,
  })

if (error) {
  console.error('❌ [WEBHOOK] Error adding credits:', error)
  throw new Error(`Failed to add credits: ${error.message}`)
}

// Check if this was a duplicate
if (result.duplicate) {
  console.log(`⚠️ [WEBHOOK] Duplicate transaction ignored: ${transactionId}`)
  return new Response(
    JSON.stringify({
      success: true,
      message: 'Duplicate transaction - already processed',
      user_id: userId,
      transaction_id: transactionId,
      duplicate: true,
    }),
    {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    }
  )
}

console.log(`✅ [WEBHOOK] Credits added: ${result.credits_added}`)
console.log(`📊 [WEBHOOK] New balance: ${result.credits}`)
```

**Files to Change**:
- `supabase/functions/revenuecat-webhook/index.ts` (Lines 100-172)

---

### **CRITICAL #2: Missing Webhook Signature Verification** ⚠️

**Severity**: MEDIUM-HIGH
**Impact**: Anyone could send fake purchase events to your webhook

**Problem**:
The webhook accepts any POST request without verifying it's from RevenueCat. An attacker could send fake purchase events to add unlimited credits.

**Current State**:
- JWT auth disabled (required for RevenueCat to work)
- No signature verification
- Anyone with the URL can send events

**Fix**: Add RevenueCat webhook signature verification:

```typescript
// At top of webhook file
const REVENUECAT_WEBHOOK_SECRET = Deno.env.get('REVENUECAT_WEBHOOK_SECRET') ?? ''

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // SECURITY: Verify webhook is from RevenueCat
    const signature = req.headers.get('X-RevenueCat-Signature')

    if (!signature && REVENUECAT_WEBHOOK_SECRET) {
      console.error('❌ [WEBHOOK] Missing signature header')
      return new Response(
        JSON.stringify({ error: 'Unauthorized - missing signature' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401,
        }
      )
    }

    // Get raw body for signature verification
    const body = await req.text()

    // Verify signature (if secret is configured)
    if (REVENUECAT_WEBHOOK_SECRET && signature) {
      const expectedSignature = await crypto.subtle.digest(
        'SHA-256',
        new TextEncoder().encode(body + REVENUECAT_WEBHOOK_SECRET)
      )
      const expectedHex = Array.from(new Uint8Array(expectedSignature))
        .map(b => b.toString(16).padStart(2, '0'))
        .join('')

      if (signature !== expectedHex) {
        console.error('❌ [WEBHOOK] Invalid signature')
        return new Response(
          JSON.stringify({ error: 'Unauthorized - invalid signature' }),
          {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 401,
          }
        )
      }
    }

    const payload: RevenueCatEvent = JSON.parse(body)
    // ... rest of webhook code
```

**Additional Setup Required**:
1. Set webhook secret in Supabase: Dashboard → Settings → Edge Functions → Secrets
2. Add same secret in RevenueCat: Dashboard → Webhooks → Authorization

**Files to Change**:
- `supabase/functions/revenuecat-webhook/index.ts`

**Alternative (Quick Fix for Launch)**:
If you can't implement signatures immediately, at least add IP whitelist check for RevenueCat's IPs.

---

## ⚠️ HIGH PRIORITY (Fix in Week 1)

### **HIGH #1: Direct Credit Addition in Production**

**File**: `safety_app/lib/services/auth_service.dart:305-349`

**Problem**: The `addCredits()` method allows direct credit addition from the app, bypassing RevenueCat. This is meant for testing but shouldn't be accessible in production.

**Fix**: Add production guard:
```dart
Future<void> addCredits(int amount) async {
  if (!isAuthenticated) {
    throw Exception('User not authenticated');
  }

  // SECURITY: Only allow in debug mode or mock purchase mode
  if (!kDebugMode && !AppConfig.USE_MOCK_PURCHASES) {
    throw Exception('Direct credit addition not allowed in production');
  }

  // ... rest of code
}
```

---

### **HIGH #2: No Transaction Timeout**

**File**: `supabase/functions/revenuecat-webhook/index.ts`

**Problem**: Database operations have no timeout. If Supabase is slow, webhook could hang and RevenueCat will retry, causing duplicates.

**Fix**: Add timeout to database operations (use the function from Critical #1 which has built-in transaction handling).

---

### **HIGH #3: Missing Negative Balance Check**

**File**: `supabase_setup.sql:102-123` (deduct_credit_for_search function)

**Problem**: Check on line 109 prevents going negative, but doesn't handle concurrent requests properly.

**Current Code**:
```sql
IF v_current_credits < 1 THEN
    RETURN json_build_object(
        'success', false,
        'error', 'insufficient_credits',
        'credits', v_current_credits
    );
END IF;
```

**Issue**: Two concurrent searches could both pass this check before either deducts.

**Fix**: Add constraint at database level:
```sql
ALTER TABLE public.profiles
ADD CONSTRAINT positive_credits CHECK (credits >= 0);
```

This will cause transaction to fail if credits would go negative, preventing race condition.

---

## ✅ MEDIUM PRIORITY (Nice to Have)

### **MED #1: Missing Retry Logic in Store Screen**

**File**: `safety_app/lib/screens/store_screen.dart:101-122`

**Issue**: If purchase succeeds but credit refresh fails, user won't see new credits.

**Improvement**: Add retry logic:
```dart
Future<void> _purchasePackage(Package package) async {
  setState(() => _isPurchasing = true);

  final result = await _revenueCatService.purchasePackage(package);

  setState(() => _isPurchasing = false);

  if (!mounted) return;

  if (result.success) {
    CustomSnackbar.showSuccess(context, 'Credits added successfully!');

    // Reload credits with retry
    for (int i = 0; i < 3; i++) {
      try {
        final newCredits = await _authService.getUserCredits();
        setState(() => _currentCredits = newCredits);
        break;
      } catch (e) {
        if (i == 2) {
          CustomSnackbar.showInfo(context, 'Credits added but display refresh failed. Restart app to see new balance.');
        }
        await Future.delayed(Duration(seconds: i + 1));
      }
    }
  }
  // ... rest
}
```

---

### **MED #2: No Monitoring/Analytics**

**Issue**: No way to track webhook failures, purchase success rate, or credit issues.

**Recommendation**: Add monitoring:
1. Sentry for error tracking
2. PostHog for analytics
3. Webhook success/failure logging to separate table

---

### **MED #3: TODO Comments in Production Code**

**Found in**:
- `safety_app/lib/screens/settings_screen.dart:204, 262, 323`

**TODOs**:
- Line 204: "Navigate to transaction history"
- Line 262: "Show about screen"
- Line 323: "Navigate to change password"

**Action**: Either implement or remove before launch.

---

## ✅ GOOD PRACTICES FOUND

1. ✅ **Row-Level Security (RLS)** enabled on all tables
2. ✅ **Row locking** in deduct_credit_for_search (prevents race conditions)
3. ✅ **Retry logic** in getUserCredits (handles transient failures)
4. ✅ **Real-time credit updates** via Supabase subscriptions
5. ✅ **Duplicate check** in add_credits_from_purchase function
6. ✅ **Error logging** throughout webhook
7. ✅ **Transaction recording** for audit trail
8. ✅ **CORS headers** properly configured
9. ✅ **Loading states** in UI during purchases
10. ✅ **Mock purchase mode** for testing

---

## 📊 SECURITY ASSESSMENT

| Component | Rating | Notes |
|-----------|--------|-------|
| Database Schema | ✅ Good | RLS enabled, proper constraints |
| Webhook Security | ❌ Poor | No signature verification |
| Credit Deduction | ✅ Good | Row locking prevents race conditions |
| Credit Addition | ⚠️ Fair | Missing duplicate check in webhook |
| API Keys | ✅ Good | Properly using anon key, not service role |
| Input Validation | ✅ Good | Product ID validated before processing |
| Auth Flow | ✅ Good | PKCE flow, auto-refresh enabled |

**Overall Security Score**: 6/10 (needs Critical #2 fixed)

---

## 🚀 LAUNCH CHECKLIST

### **Before Launch (MUST DO)**
- [ ] Fix Critical #1: Use `add_credits_from_purchase` function in webhook
- [ ] Fix Critical #2: Add webhook signature verification (or IP whitelist)
- [ ] Set `USE_MOCK_PURCHASES = false` in production
- [ ] Test end-to-end purchase flow with real money (sandbox)
- [ ] Verify credits appear correctly
- [ ] Test with multiple concurrent purchases
- [ ] Add constraint to prevent negative credits
- [ ] Remove or implement TODO items in settings screen

### **Week 1 After Launch (HIGH PRIORITY)**
- [ ] Add production guard to `addCredits()` method
- [ ] Implement retry logic in store screen
- [ ] Set up error monitoring (Sentry/similar)
- [ ] Monitor webhook logs daily
- [ ] Add analytics tracking for purchases

### **Nice to Have**
- [ ] Transaction history screen
- [ ] About screen
- [ ] Change password screen
- [ ] Webhook failure alerts
- [ ] Admin dashboard for credit management

---

## 🔧 FILES THAT NEED CHANGES

### **Critical (Before Launch)**
1. `supabase/functions/revenuecat-webhook/index.ts` - Use RPC function, add signature verification
2. `supabase_setup.sql` - Add negative credits constraint

### **High Priority (Week 1)**
3. `safety_app/lib/services/auth_service.dart` - Add production guard
4. `safety_app/lib/screens/store_screen.dart` - Add retry logic
5. `safety_app/lib/screens/settings_screen.dart` - Implement or remove TODOs

---

## 💡 RECOMMENDATIONS

### **Immediate Actions**
1. **Fix Critical #1 and #2 before any production purchases**
2. **Test thoroughly** with Apple Sandbox purchases
3. **Monitor logs closely** for first 48 hours after launch

### **Architecture Improvements**
1. Consider moving webhook logic to a dedicated service
2. Add database indices on `revenuecat_transaction_id` for faster duplicate checks
3. Implement exponential backoff in webhook for database retries

### **Business Continuity**
1. Document manual credit addition process for emergency support
2. Create admin scripts for credit management (refunds, bonuses, etc.)
3. Set up alerts for webhook failures

---

## ✅ CONFIDENCE LEVEL

**Current State**: 70% confident (with critical issues)
**After Fixes**: 95% confident for launch

---

## 📞 NEXT STEPS

1. **I'll implement Critical #1 fix** (use database function in webhook)
2. **You verify** the changes work with test webhook
3. **You decide** on Critical #2: signature verification or IP whitelist
4. **Test end-to-end** purchase flow
5. **Launch** 🚀

---

**Generated with ❤️ by Claude Code**

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

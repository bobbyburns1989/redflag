# Pink Flag - Monetization Guide

**Last Updated**: November 10, 2025
**Status**: Production Ready ✅
**RevenueCat Version**: purchases_flutter ^9.9.4

---

## Quick Start

### Enable Real Purchases

1. Open `lib/config/app_config.dart`
2. Change: `USE_MOCK_PURCHASES = true` → `false`
3. Ensure RevenueCat API key is configured
4. Hot restart the app

### Test with Mock Purchases (Default)

- Already configured for instant testing
- No sandbox account needed
- Credits added directly to Supabase
- Perfect for rapid development

---

## Architecture Overview

```
User Flow:
Onboarding → Login/Signup (Apple Sign-In) → Search
                                            ↓
                                    Out of Credits?
                                            ↓
                                    Store Screen → Purchase
                                            ↓
                                    RevenueCat → Webhook
                                            ↓
                                    Supabase → Credits Added
```

---

## Credit Packages

| Package | Price | Credits | Cost per Search | Savings |
|---------|-------|---------|-----------------|---------|
| **Starter** | $1.99 | 3 | $0.66 | - |
| **Popular** | $4.99 | 10 | $0.50 | 24% |
| **Best Value** | $9.99 | 25 | $0.40 | 40% |

**Backend Cost**: $0.20 per search (Offenders.io API)
**Net Profit**: 33-56% after Apple's 30% cut

---

## RevenueCat Setup

### Dashboard Configuration

1. **Create Products** (Already Done ✅)
   - Product ID: `pink_flag_3_searches` → 3 credits
   - Product ID: `pink_flag_10_searches` → 10 credits
   - Product ID: `pink_flag_25_searches` → 25 credits

2. **Create Offering** (Required for Production)
   - Name: "default"
   - Add all 3 products
   - Set as current offering

3. **Configure Webhook**
   - URL: Your Supabase Edge Function URL
   - Authorization: Bearer token from Supabase
   - Events: All purchase events

### App Store Connect Setup

1. **Create In-App Purchases**
   - Type: Consumable
   - Product IDs must match RevenueCat exactly
   - Prices: $1.99, $4.99, $9.99

2. **Submit for Review**
   - Include screenshots of store screen
   - Explain credit system in notes
   - Test with sandbox account first

---

## Code Configuration

### Feature Flag System

**File**: `lib/config/app_config.dart`

```dart
class AppConfig {
  // Toggle between mock and real purchases
  static const bool USE_MOCK_PURCHASES = true; // Set false for production

  // API Keys
  static const String revenueCatApiKey = 'appl_IRhHyHobKGcoteGnlLRWUFgnIos';
  static const String supabaseUrl = 'https://qjbtmrbbijvniiveptdij.supabase.co';
  static const String supabaseAnonKey = 'your_anon_key_here';
}
```

### Service Layer

**File**: `lib/services/revenuecat_service.dart`

```dart
// Initialize RevenueCat
await Purchases.configure(
  PurchasesConfiguration(AppConfig.revenueCatApiKey)
);

// Purchase a package
await Purchases.purchasePackage(package);

// Restore purchases
await Purchases.restorePurchases();
```

**File**: `lib/services/auth_service.dart`

```dart
// Get current credits
Future<int> getCurrentCredits()

// Watch credits in real-time
Stream<int> watchCredits()

// Add credits from purchase
Future<void> addCredits(int amount, String source)
```

---

## Supabase Integration

### Database Schema

**Profiles Table**:
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users,
  email TEXT,
  credits INTEGER DEFAULT 1, -- 1 free credit on signup
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Credit Transactions Table**:
```sql
CREATE TABLE credit_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id),
  credits INTEGER NOT NULL, -- Positive for add, negative for deduct
  transaction_type TEXT NOT NULL, -- 'purchase', 'search', 'refund'
  source TEXT, -- 'revenuecat', 'search_name', 'search_image', etc.
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### RPC Functions

**Add Credits**:
```sql
CREATE FUNCTION add_credits_from_purchase(
  p_user_id UUID,
  p_credits INTEGER,
  p_source TEXT
) RETURNS JSONB;
```

**Deduct Credits**:
```sql
CREATE FUNCTION deduct_credit_for_search(
  p_user_id UUID,
  p_search_type TEXT
) RETURNS JSONB;
```

**Refund Credits** (v1.1.7+):
```sql
CREATE FUNCTION refund_credit_for_failed_search(
  p_user_id UUID,
  p_search_id UUID,
  p_reason TEXT
) RETURNS JSONB;
```

---

## Webhook Integration

### Supabase Edge Function

**File**: `supabase/functions/revenuecat-webhook/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from '@supabase/supabase-js'

serve(async (req) => {
  const event = await req.json()

  // Validate webhook signature
  // Process purchase event
  // Add credits to user's profile
  // Log transaction

  return new Response(JSON.stringify({ received: true }), {
    headers: { "Content-Type": "application/json" },
  })
})
```

### Deploy Webhook

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link project
supabase link --project-ref your-project-ref

# Deploy function
supabase functions deploy revenuecat-webhook
```

---

## Testing Checklist

### Mock Purchase Testing (Development)

- [ ] Set `USE_MOCK_PURCHASES = true`
- [ ] Navigate to Store screen
- [ ] Click "Buy Now" on any package
- [ ] Verify instant credit addition
- [ ] Check transaction history
- [ ] Test all 3 packages

### Sandbox Purchase Testing (Pre-Production)

- [ ] Set `USE_MOCK_PURCHASES = false`
- [ ] Create Sandbox tester in App Store Connect
- [ ] Sign in with sandbox account on device
- [ ] Purchase each package
- [ ] Verify webhook processes correctly
- [ ] Test purchase restoration
- [ ] Check credit balance updates

### Production Checklist

- [ ] RevenueCat "default" offering created
- [ ] All 3 products added to offering
- [ ] Webhook URL configured in RevenueCat
- [ ] App Store Connect products approved
- [ ] Sandbox testing completed
- [ ] Real device testing completed
- [ ] Feature flag set to `USE_MOCK_PURCHASES = false`

---

## Common Issues & Solutions

### "No offerings available"

**Problem**: Store screen shows no packages

**Solution**:
1. Check RevenueCat Dashboard → "default" offering exists
2. Verify all 3 products added to offering
3. Ensure App Store Connect products approved
4. Check API key is correct in `app_config.dart`

### Credits not updating after purchase

**Problem**: Purchase succeeds but credits don't increase

**Solution**:
1. Check webhook logs in Supabase Edge Functions
2. Verify webhook URL in RevenueCat dashboard
3. Test RPC function manually in Supabase SQL Editor
4. Check Row Level Security policies allow inserts

### "Purchase already owned"

**Problem**: Sandbox purchases show as already owned

**Solution**:
1. Consumable purchases should not have this issue
2. Verify products are marked "Consumable" in App Store Connect
3. Try "Restore Purchases" button in Store screen
4. Sign out and back into sandbox account

---

## Monitoring & Analytics

### Key Metrics to Track

**Business Metrics**:
- Daily/Monthly revenue
- Average revenue per user (ARPU)
- Conversion rate (signups → first purchase)
- Package popularity (which packages sell most)

**Technical Metrics**:
- Purchase success rate
- Webhook processing time
- Failed purchase reasons
- Restore purchase frequency

### RevenueCat Dashboard

- Real-time revenue tracking
- Customer lifecycle analytics
- Cohort analysis
- Subscription metrics (future)

### Supabase Queries

**Total Revenue**:
```sql
SELECT
  SUM(CASE
    WHEN source LIKE '%_3_searches' THEN 1.99
    WHEN source LIKE '%_10_searches' THEN 4.99
    WHEN source LIKE '%_25_searches' THEN 9.99
  END) as total_revenue
FROM credit_transactions
WHERE transaction_type = 'purchase';
```

**Top Spenders**:
```sql
SELECT
  user_id,
  email,
  SUM(credits) as total_purchased
FROM credit_transactions ct
JOIN profiles p ON ct.user_id = p.id
WHERE transaction_type = 'purchase'
GROUP BY user_id, email
ORDER BY total_purchased DESC
LIMIT 10;
```

---

## Future Enhancements

### Potential Features

1. **Subscription Tier** ($9.99/month unlimited searches)
2. **Promotional Codes** (20% off first purchase)
3. **Referral System** (Give 1 credit, get 1 credit)
4. **Credit Bundles** (50 searches for $19.99)
5. **Seasonal Sales** (Black Friday 50% off)

### Implementation Complexity

| Feature | Complexity | Estimated Time | Value |
|---------|-----------|----------------|-------|
| Subscription | High | 2 weeks | High |
| Promo Codes | Medium | 1 week | Medium |
| Referrals | High | 2 weeks | Medium |
| Bundles | Low | 2 days | Medium |
| Sales | Low | 1 day | Low |

---

## Additional Documentation

**Comprehensive Guides**:
- [MONETIZATION_COMPLETE.md](../../MONETIZATION_COMPLETE.md) - Full implementation details
- [REVENUECAT_INTEGRATION_GUIDE.md](../../docs/archive/implementation-history/REVENUECAT_INTEGRATION_GUIDE.md) - Step-by-step setup (archived)

**Database**:
- [CREDIT_REFUND_SCHEMA.sql](../../schemas/CREDIT_REFUND_SCHEMA.sql) - Refund system schema

**Release Notes**:
- [RELEASE_HISTORY.md](../../releases/RELEASE_HISTORY.md) - All monetization updates

---

## Support

**RevenueCat**:
- Docs: https://docs.revenuecat.com
- Dashboard: https://app.revenuecat.com
- Support: support@revenuecat.com

**Supabase**:
- Docs: https://supabase.com/docs
- Dashboard: https://app.supabase.com
- Community: https://discord.supabase.com

---

**Built with ❤️ using Claude Code**

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

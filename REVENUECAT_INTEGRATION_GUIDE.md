# Pink Flag - RevenueCat Integration Guide

**Last Updated**: November 10, 2025
**Status**: Feature flag implemented - Ready for full integration
**Current Mode**: Mock purchases (testing mode)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Current Implementation Status](#current-implementation-status)
3. [Feature Flag System](#feature-flag-system)
4. [RevenueCat Dashboard Setup](#revenuecat-dashboard-setup)
5. [Testing with Sandbox](#testing-with-sandbox)
6. [Webhook Integration](#webhook-integration)
7. [Switching to Production](#switching-to-production)
8. [Troubleshooting](#troubleshooting)

---

## Overview

Pink Flag uses **RevenueCat** for in-app purchase management with a flexible architecture that supports both:
- **Mock purchases** (instant testing, no sandbox needed)
- **Real purchases** (production-ready RevenueCat flow)

### Architecture

```
User Taps Purchase
       ↓
   App Config Check
       ↓
   ┌─────────────┴─────────────┐
   ↓ Mock Mode                 ↓ Real Mode
Add credits                RevenueCat Purchase
directly via                    ↓
Supabase                  Webhook to Supabase
   ↓                            ↓
✅ Credits Added          ✅ Credits Added
```

---

## Current Implementation Status

### ✅ Completed

1. **App Configuration** (`lib/config/app_config.dart`)
   - Feature flag: `USE_MOCK_PURCHASES = true`
   - Centralized configuration for all app settings
   - Easy toggle between modes

2. **RevenueCat Service** (`lib/services/revenuecat_service.dart`)
   - Initialize with user ID after login
   - Get offerings from RevenueCat
   - Purchase packages
   - Restore purchases

3. **Store Screen** (`lib/screens/store_screen.dart`)
   - Displays credit packages
   - Supports both mock and real purchases
   - Shows debug messages when offerings fail to load

4. **Auth Integration** (`lib/services/auth_service.dart`)
   - RevenueCat initialized after signup/login
   - User ID synced between Supabase and RevenueCat

5. **Database Schema**
   - `profiles` table with `credits` column
   - `credit_transactions` table for transaction history

### ⏳ Pending

1. **RevenueCat Dashboard**
   - Create "Default" Offering
   - Add products to offering

2. **Supabase Webhook**
   - Edge Function to receive RevenueCat webhooks
   - Add credits when purchase succeeds

3. **Sandbox Testing**
   - Apple Sandbox account setup
   - End-to-end purchase testing

---

## Feature Flag System

### Location
`safety_app/lib/config/app_config.dart`

### Key Settings

```dart
// Toggle between mock and real purchases
static const bool USE_MOCK_PURCHASES = true;  // ← Change this

// Enable debug logging
static const bool DEBUG_PURCHASES = true;
static const bool DEBUG_AUTH = true;

// RevenueCat configuration
static const String REVENUECAT_API_KEY = 'appl_IRhHyHobKGcoteGnlLRWUFgnIos';
static const String REVENUECAT_OFFERING_ID = 'default';
```

### How to Switch Modes

**For Development/Testing (Current):**
```dart
static const bool USE_MOCK_PURCHASES = true;
```
- ✅ Instant testing
- ✅ No Apple sandbox needed
- ✅ Credits added immediately to Supabase
- ⚠️ No payment processing

**For Production/Real Testing:**
```dart
static const bool USE_MOCK_PURCHASES = false;
```
- ✅ Real RevenueCat integration
- ✅ Apple payment processing
- ⚠️ Requires RevenueCat Dashboard setup
- ⚠️ Requires Apple Sandbox account

**After changing:**
1. Save the file
2. Hot restart the app (press 'R' in terminal)
3. The new mode will be active

---

## RevenueCat Dashboard Setup

### Step 1: Access RevenueCat Dashboard

1. Go to [https://app.revenuecat.com](https://app.revenuecat.com)
2. Navigate to your PinkFlag project
3. You should see your 3 products already synced from App Store Connect:
   - `pink_flag_3_searches`
   - `pink_flag_10_searches`
   - `pink_flag_25_searches`

### Step 2: Create an Offering

An "Offering" is RevenueCat's way of grouping products that you want to sell.

1. Click **Product catalog** in the left sidebar
2. Click the **Offerings** tab
3. Click **New offering**
4. Enter the following:
   - **Identifier**: `default` (must match `REVENUECAT_OFFERING_ID` in AppConfig)
   - **Display name**: `Default Offering`
   - **Description**: `Main credit packages for Pink Flag`
5. Click **Create**

### Step 3: Add Products to Offering

1. Open the `default` offering you just created
2. Click **Add package**
3. For each product, create a package:

   **Package 1: 3 Searches**
   - Identifier: `three_searches`
   - Product: Select `pink_flag_3_searches`
   - Click **Add**

   **Package 2: 10 Searches**
   - Identifier: `ten_searches`
   - Product: Select `pink_flag_10_searches`
   - Click **Add**

   **Package 3: 25 Searches**
   - Identifier: `twenty_five_searches`
   - Product: Select `pink_flag_25_searches`
   - Click **Add**

4. Click **Save**

### Step 4: Verify Configuration

1. Go to **Apps** in the left sidebar
2. Select **PinkFlag (App Store)**
3. Verify:
   - ✅ API Key is shown: `appl_IRhHyHobKGcoteGnlLRWUFgnIos`
   - ✅ Bundle ID matches: `com.pinkflag.safetyapp`
   - ✅ Products show status "Ready to Submit"

---

## Testing with Sandbox

### Step 1: Create Apple Sandbox Account

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **Users and Access** → **Sandbox Testers**
3. Click the **+** button
4. Create a test account:
   - Email: Use a unique email (e.g., `pinkflag.test1@gmail.com`)
   - Password: Create a strong password
   - Country: United States
   - Birthdate: Make sure account is 17+
5. Save the account

### Step 2: Configure Simulator/Device

**On iOS Simulator:**
1. Open **Settings** app
2. Go to **App Store** → **Sandbox Account**
3. Sign in with your sandbox test account

**On Physical Device:**
1. **Sign out** of your real Apple ID in Settings → App Store
2. Launch Pink Flag app
3. Try to make a purchase
4. iOS will prompt for Apple ID → Enter sandbox account credentials

### Step 3: Enable Real Purchases in App

1. Open `safety_app/lib/config/app_config.dart`
2. Change:
   ```dart
   static const bool USE_MOCK_PURCHASES = false;  // ← Real purchases
   ```
3. Hot restart the app (press 'R')

### Step 4: Test Purchase Flow

1. Sign up or log in to Pink Flag
2. Go to Settings → Store (or when out of credits)
3. You should see 3 credit packages with real prices
4. Tap **Purchase** on any package
5. iOS payment sheet should appear
6. Complete purchase with sandbox account
7. Credits should be added to your account

### Expected Behavior

**Successful Purchase:**
```
1. User taps Purchase → iOS payment sheet
2. User completes purchase → RevenueCat processes
3. RevenueCat fires webhook → Supabase Edge Function
4. Edge Function adds credits → User's profile updated
5. App shows success message → Credits refreshed
```

**If Offerings Don't Load:**
- Check RevenueCat Dashboard has "default" offering
- Check products are added to offering
- Check RevenueCat API key matches
- Enable debug mode and check console logs

---

## Webhook Integration

RevenueCat needs to notify your backend when a purchase succeeds so credits can be added.

### Step 1: Create Supabase Edge Function

Create a file: `supabase/functions/revenuecat-webhook/index.ts`

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Parse RevenueCat webhook payload
    const payload = await req.json()
    console.log('📨 [WEBHOOK] Received:', payload)

    // Extract event type
    const eventType = payload.event.type
    const userId = payload.event.app_user_id
    const productId = payload.event.product_id

    console.log(`📨 [WEBHOOK] Event: ${eventType}, User: ${userId}, Product: ${productId}`)

    // Only process purchase events
    if (eventType !== 'INITIAL_PURCHASE' && eventType !== 'RENEWAL') {
      console.log('⏭️ [WEBHOOK] Ignoring non-purchase event')
      return new Response(JSON.stringify({ received: true }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    // Determine credits based on product ID
    let creditsToAdd = 0
    let amount = 0.0

    switch (productId) {
      case 'pink_flag_3_searches':
        creditsToAdd = 3
        amount = 1.99
        break
      case 'pink_flag_10_searches':
        creditsToAdd = 10
        amount = 4.99
        break
      case 'pink_flag_25_searches':
        creditsToAdd = 25
        amount = 9.99
        break
      default:
        console.warn(`⚠️ [WEBHOOK] Unknown product ID: ${productId}`)
        return new Response(JSON.stringify({ error: 'Unknown product' }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        })
    }

    // Initialize Supabase Admin client
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Get current credits
    const { data: profile, error: fetchError } = await supabaseAdmin
      .from('profiles')
      .select('credits')
      .eq('id', userId)
      .single()

    if (fetchError) {
      console.error('❌ [WEBHOOK] Error fetching profile:', fetchError)
      throw fetchError
    }

    const currentCredits = profile.credits
    const newCredits = currentCredits + creditsToAdd

    // Update credits
    const { error: updateError } = await supabaseAdmin
      .from('profiles')
      .update({ credits: newCredits })
      .eq('id', userId)

    if (updateError) {
      console.error('❌ [WEBHOOK] Error updating credits:', updateError)
      throw updateError
    }

    console.log(`✅ [WEBHOOK] Credits updated: ${currentCredits} → ${newCredits}`)

    // Record transaction
    const { error: transactionError } = await supabaseAdmin
      .from('credit_transactions')
      .insert({
        user_id: userId,
        transaction_type: 'purchase',
        credits: creditsToAdd,
        provider: 'revenuecat',
        provider_transaction_id: payload.event.transaction_id,
      })

    if (transactionError) {
      console.warn('⚠️ [WEBHOOK] Error recording transaction:', transactionError)
      // Don't fail the webhook if transaction recording fails
    }

    console.log('✅ [WEBHOOK] Purchase processed successfully')

    return new Response(
      JSON.stringify({
        success: true,
        creditsAdded: creditsToAdd,
        newTotal: newCredits,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )
  } catch (error) {
    console.error('❌ [WEBHOOK] Error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
```

### Step 2: Deploy Edge Function

```bash
# Login to Supabase
supabase login

# Deploy the function
supabase functions deploy revenuecat-webhook --project-ref qjbtmrbbjivniveptdjl

# Get the function URL
# Should be: https://qjbtmrbbjivniveptdjl.supabase.co/functions/v1/revenuecat-webhook
```

### Step 3: Configure RevenueCat Webhook

1. Go to RevenueCat Dashboard
2. Click **Integrations** in the left sidebar
3. Find **Webhooks** and click **Configure**
4. Click **Add Webhook**
5. Enter:
   - **URL**: `https://qjbtmrbbjivniveptdjl.supabase.co/functions/v1/revenuecat-webhook`
   - **Events**: Select all purchase events:
     - `INITIAL_PURCHASE`
     - `RENEWAL`
     - `NON_RENEWING_PURCHASE`
6. Click **Add**
7. Click **Send Test Event** to verify

### Step 4: Test Webhook

1. Make a sandbox purchase in the app
2. Go to RevenueCat Dashboard → **Event History**
3. You should see the purchase event
4. Check Supabase logs:
   ```bash
   supabase functions logs revenuecat-webhook
   ```
5. Verify credits were added in Supabase database

---

## Switching to Production

### Before App Store Submission

1. **Create Offering in RevenueCat Dashboard** (see above)
2. **Deploy Webhook to Supabase** (see above)
3. **Test with Sandbox Account** (see above)
4. **Keep mock purchases enabled** for final UI testing

### For App Store Submission

1. **Switch to real purchases:**
   ```dart
   // lib/config/app_config.dart
   static const bool USE_MOCK_PURCHASES = false;
   ```

2. **Build release version:**
   ```bash
   cd safety_app
   flutter build ios --release
   ```

3. **Submit to App Store** with in-app purchases

### After App Store Approval

1. Products go live automatically
2. Webhook starts receiving real purchase events
3. Users can purchase credits with real money

---

## Troubleshooting

### Offerings Not Loading

**Symptoms:**
- Store screen shows "No Products Available"
- Console shows: `_offerings = null`

**Solutions:**
1. Check RevenueCat Dashboard has "default" offering
2. Verify products are added to the offering
3. Verify offering identifier matches: `AppConfig.REVENUECAT_OFFERING_ID = 'default'`
4. Check RevenueCat API key is correct
5. Ensure RevenueCat initialized after login
6. Try signing out and back in

### Purchase Fails

**Symptoms:**
- iOS payment sheet doesn't appear
- Error: "Unable to complete purchase"

**Solutions:**
1. Verify sandbox account is signed in (Settings → App Store)
2. Check products are "Ready to Submit" in App Store Connect
3. Ensure app is signed with correct provisioning profile
4. Check RevenueCat logs in dashboard
5. Try restoring purchases

### Credits Not Added After Purchase

**Symptoms:**
- Purchase succeeds but credits don't update
- No webhook event in RevenueCat dashboard

**Solutions:**
1. Check webhook URL is configured in RevenueCat
2. Verify Supabase Edge Function is deployed
3. Check Edge Function logs for errors
4. Verify product ID mapping in webhook code
5. Test webhook with RevenueCat test event

### Mock Purchases Not Working

**Symptoms:**
- "Purchase" button does nothing
- Error in console

**Solutions:**
1. Verify `USE_MOCK_PURCHASES = true`
2. Check user is logged in
3. Verify Supabase database connection
4. Check `profiles` table has `credits` column
5. Check console logs for specific error

---

## Configuration Reference

### App Store Connect
- **Bundle ID**: `com.pinkflag.safetyapp`
- **Products**:
  - `pink_flag_3_searches` - $1.99
  - `pink_flag_10_searches` - $4.99
  - `pink_flag_25_searches` - $9.99

### RevenueCat
- **Project**: PinkFlag
- **API Key**: `appl_IRhHyHobKGcoteGnlLRWUFgnIos`
- **Offering ID**: `default`
- **Bundle ID**: `com.pinkflag.safetyapp`

### Supabase
- **Project URL**: `https://qjbtmrbbjivniveptdjl.supabase.co`
- **Webhook URL**: `https://qjbtmrbbjivniveptdjl.supabase.co/functions/v1/revenuecat-webhook`
- **Tables**: `profiles`, `credit_transactions`

---

## Next Steps

1. **✅ Immediate** - Keep using mock purchases for development
2. **📋 This Week** - Create "default" offering in RevenueCat Dashboard
3. **🧪 Before Launch** - Deploy webhook and test with sandbox
4. **🚀 Launch** - Switch to real purchases and submit to App Store

---

**Document Version**: 1.0
**Last Updated**: November 10, 2025
**Maintained by**: Pink Flag Development Team

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

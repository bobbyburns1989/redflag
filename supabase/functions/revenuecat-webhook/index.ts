/**
 * RevenueCat Webhook Handler for Pink Flag
 *
 * This Supabase Edge Function receives webhook events from RevenueCat
 * when users make in-app purchases, and adds credits to their accounts.
 *
 * Deploy:
 *   supabase functions deploy revenuecat-webhook --project-ref qjbtmrbbjivniveptdjl
 *
 * Set webhook secret:
 *   supabase secrets set REVENUECAT_WEBHOOK_SECRET=your_secret_here --project-ref qjbtmrbbjivniveptdjl
 *
 * Test:
 *   Send test event from RevenueCat Dashboard → Integrations → Webhooks
 *
 * Logs:
 *   supabase functions logs revenuecat-webhook
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-revenuecat-signature',
}

// Get webhook secret from environment (optional - for signature verification)
const REVENUECAT_WEBHOOK_SECRET = Deno.env.get('REVENUECAT_WEBHOOK_SECRET') ?? ''

interface RevenueCatEvent {
  event: {
    type: string
    app_user_id: string
    product_id: string
    transaction_id: string
    price_in_purchased_currency: number
    currency: string
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // SECURITY: Verify webhook signature if secret is configured
    const signature = req.headers.get('X-RevenueCat-Signature')

    // Get raw body for signature verification
    const body = await req.text()

    // Verify signature (if secret is configured)
    if (REVENUECAT_WEBHOOK_SECRET && REVENUECAT_WEBHOOK_SECRET.length > 0) {
      if (!signature) {
        console.error('❌ [WEBHOOK] Missing signature header')
        return new Response(
          JSON.stringify({ error: 'Unauthorized - missing signature' }),
          {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 401,
          }
        )
      }

      // RevenueCat uses HMAC-SHA256 for webhook signatures
      const key = await crypto.subtle.importKey(
        'raw',
        new TextEncoder().encode(REVENUECAT_WEBHOOK_SECRET),
        { name: 'HMAC', hash: 'SHA-256' },
        false,
        ['sign']
      )

      const signatureBytes = await crypto.subtle.sign(
        'HMAC',
        key,
        new TextEncoder().encode(body)
      )

      const expectedSignature = Array.from(new Uint8Array(signatureBytes))
        .map(b => b.toString(16).padStart(2, '0'))
        .join('')

      if (signature !== expectedSignature) {
        console.error('❌ [WEBHOOK] Invalid signature')
        console.error(`Expected: ${expectedSignature}`)
        console.error(`Received: ${signature}`)
        return new Response(
          JSON.stringify({ error: 'Unauthorized - invalid signature' }),
          {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 401,
          }
        )
      }

      console.log('✅ [WEBHOOK] Signature verified')
    } else {
      console.warn('⚠️  [WEBHOOK] Signature verification disabled (no secret configured)')
    }

    // Parse RevenueCat webhook payload
    const payload: RevenueCatEvent = JSON.parse(body)
    console.log('📨 [WEBHOOK] Received RevenueCat event:', {
      type: payload.event.type,
      user: payload.event.app_user_id,
      product: payload.event.product_id,
    })

    // Extract event details
    const eventType = payload.event.type
    const userId = payload.event.app_user_id
    const productId = payload.event.product_id
    const transactionId = payload.event.transaction_id

    // Only process purchase events
    const purchaseEvents = ['INITIAL_PURCHASE', 'RENEWAL', 'NON_RENEWING_PURCHASE']
    if (!purchaseEvents.includes(eventType)) {
      console.log(`⏭️  [WEBHOOK] Ignoring non-purchase event: ${eventType}`)
      return new Response(
        JSON.stringify({ received: true, message: 'Non-purchase event ignored' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    }

    // Determine credits and price based on product ID
    // UPDATED: v1.2.0 variable credit system uses 10x multiplier
    // - Name search costs 10 credits ($0.20 via Offenders.io)
    // - Phone search costs 2 credits ($0.018 via Twilio)
    // - Image search costs 4 credits ($0.04 via TinEye)
    let creditsToAdd = 0
    let expectedPrice = 0.0

    switch (productId) {
      case 'pink_flag_3_searches':
        // Was 3 credits, now 30 credits (10x for variable costs)
        creditsToAdd = 30
        expectedPrice = 1.99
        break
      case 'pink_flag_10_searches':
        // Was 10 credits, now 100 credits (10x for variable costs)
        creditsToAdd = 100
        expectedPrice = 4.99
        break
      case 'pink_flag_25_searches':
        // Was 25 credits, now 250 credits (10x for variable costs)
        creditsToAdd = 250
        expectedPrice = 9.99
        break
      default:
        console.error(`❌ [WEBHOOK] Unknown product ID: ${productId}`)
        return new Response(
          JSON.stringify({ error: 'Unknown product ID' }),
          {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400,
          }
        )
    }

    console.log(`💎 [WEBHOOK] Processing ${creditsToAdd} credits for user ${userId}`)

    // Initialize Supabase Admin client (bypasses RLS)
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    )

    // SECURITY: Use database function with built-in duplicate protection
    // This prevents the same purchase from being processed twice
    const { data: result, error: creditError } = await supabaseAdmin
      .rpc('add_credits_from_purchase', {
        p_user_id: userId,
        p_credits_to_add: creditsToAdd,
        p_revenuecat_transaction_id: transactionId,
        p_notes: `Purchase of ${creditsToAdd} credits via ${productId}`,
      })

    if (creditError) {
      console.error('❌ [WEBHOOK] Error adding credits:', creditError)
      throw new Error(`Failed to add credits: ${creditError.message}`)
    }

    // Check if this was a duplicate transaction
    if (result.duplicate) {
      console.log(`⚠️  [WEBHOOK] Duplicate transaction ignored: ${transactionId}`)
      console.log(`📊 [WEBHOOK] User already has ${result.credits} credits`)

      return new Response(
        JSON.stringify({
          success: true,
          message: 'Duplicate transaction - already processed',
          user_id: userId,
          transaction_id: transactionId,
          duplicate: true,
          credits: result.credits,
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    }

    // Transaction was successfully processed
    console.log(`✅ [WEBHOOK] Credits added: ${result.credits_added}`)
    console.log(`📊 [WEBHOOK] New balance: ${result.credits}`)
    console.log(`✅ [WEBHOOK] Transaction recorded with duplicate protection`)

    // Return success response
    return new Response(
      JSON.stringify({
        success: true,
        message: 'Purchase processed successfully',
        user_id: userId,
        product_id: productId,
        credits_added: result.credits_added,
        new_credits: result.credits,
        transaction_id: transactionId,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('❌ [WEBHOOK] Fatal error:', error)

    // Return error response
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})

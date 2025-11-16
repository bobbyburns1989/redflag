# RevenueCat Webhook Edge Function

This Supabase Edge Function handles webhook events from RevenueCat to add credits to user accounts when in-app purchases are completed.

## Deployment

```bash
# Login to Supabase CLI
supabase login

# Deploy the function
supabase functions deploy revenuecat-webhook --project-ref qjbtmrbbjivniveptdjl
```

## Configuration

### In RevenueCat Dashboard:

1. Go to **Integrations** → **Webhooks**
2. Click **Add Webhook**
3. Enter webhook URL:
   ```
   https://qjbtmrbbjivniveptdjl.supabase.co/functions/v1/revenuecat-webhook
   ```
4. Select events to send:
   - `INITIAL_PURCHASE`
   - `RENEWAL`
   - `NON_RENEWING_PURCHASE`
5. Save and send test event to verify

## Testing

### Send Test Event from RevenueCat

1. Go to RevenueCat Dashboard → Integrations → Webhooks
2. Find your webhook
3. Click **Send Test Event**
4. Select event type: `INITIAL_PURCHASE`
5. Check logs to verify

### View Logs

```bash
# Real-time logs
supabase functions logs revenuecat-webhook --follow

# Recent logs
supabase functions logs revenuecat-webhook
```

### Test with cURL

```bash
curl -X POST https://qjbtmrbbjivniveptdjl.supabase.co/functions/v1/revenuecat-webhook \
  -H "Content-Type: application/json" \
  -d '{
    "event": {
      "type": "INITIAL_PURCHASE",
      "app_user_id": "YOUR_USER_ID",
      "product_id": "pink_flag_3_searches",
      "transaction_id": "test_transaction_123",
      "price_in_purchased_currency": 1.99,
      "currency": "USD"
    }
  }'
```

## Product ID Mapping

| Product ID | Credits | Price |
|-----------|---------|-------|
| `pink_flag_3_searches` | 3 | $1.99 |
| `pink_flag_10_searches` | 10 | $4.99 |
| `pink_flag_25_searches` | 25 | $9.99 |

## Error Handling

The function will:
- ✅ Return 200 for successful purchases
- ✅ Return 200 for non-purchase events (ignored)
- ❌ Return 400 for unknown product IDs
- ❌ Return 404 if user profile not found
- ❌ Return 500 for server errors

All errors are logged for debugging.

## Troubleshooting

### Credits Not Added

1. Check function logs for errors
2. Verify user ID exists in `profiles` table
3. Verify product ID matches expected values
4. Check webhook event was received (RevenueCat Dashboard)

### Webhook Not Firing

1. Verify webhook URL is configured in RevenueCat
2. Test with "Send Test Event" in dashboard
3. Check function is deployed: `supabase functions list`
4. Verify function logs show no deployment errors

### Transaction Not Recorded

This is non-fatal. Credits are still added even if transaction logging fails.
Check `credit_transactions` table schema has required columns.

## Security

- Uses Supabase Service Role Key (bypasses RLS)
- Only processes purchase events
- Validates product IDs
- Logs all errors for audit trail

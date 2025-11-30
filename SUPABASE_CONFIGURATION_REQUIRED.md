# ✅ Supabase Configuration Required

**Date**: November 30, 2025
**Status**: **Backend Ready** - Need to run SQL schema in Supabase
**Priority**: **CRITICAL** - Required before testing/deployment

---

## 🎯 What You Need to Do in Supabase

### **Step 1: Run SQL Schema in Supabase SQL Editor**

You need to run **ONE SQL file** to create the missing database functions that the backend requires.

#### **File to Run**:
📁 `schemas/CREDIT_DEDUCTION_SCHEMA.sql`

#### **How to Run**:

1. **Open Supabase Dashboard**:
   - Go to https://app.supabase.com
   - Select your Pink Flag project

2. **Open SQL Editor**:
   - Click **SQL Editor** in left sidebar
   - Click **New Query**

3. **Copy & Paste the SQL**:
   - Open `schemas/CREDIT_DEDUCTION_SCHEMA.sql` in your code editor
   - Copy the entire file contents
   - Paste into Supabase SQL Editor

4. **Execute the SQL**:
   - Click **Run** (or press Cmd/Ctrl + Enter)
   - Wait for "Success. No rows returned" message
   - ✅ Functions created!

---

## 🔐 What This SQL Schema Does

The schema creates **2 critical functions** that the backend uses:

### **1. `deduct_credit_for_search()`**

**Purpose**: Atomically validates and deducts credits BEFORE performing a search.

**What it does**:
1. Locks the user's credit balance (prevents race conditions)
2. Checks if user has sufficient credits
3. If insufficient: Returns error with current balance (HTTP 402)
4. If sufficient: Deducts credits and creates search record
5. Returns search_id and remaining credits

**Prevents**:
- ❌ Users manipulating credit balance via app inspection
- ❌ Race conditions (two searches at same time)
- ❌ Negative credit balances
- ❌ Free searches by modifying the app

### **2. `update_search_results()`**

**Purpose**: Updates search record with actual results count after API call completes.

**What it does**:
1. Updates the search record with results count
2. Updates search_type from 'pending' to actual type ('name', 'image', 'phone')
3. Used for search history and analytics

---

## 📋 Backend Dependencies on These Functions

Your backend code already calls these functions:

### **Called by `credit_service.py`**:

```python
# Line 110: check_and_deduct_credit()
response = self.supabase.rpc(
    "deduct_credit_for_search",  # ⚠️ Must exist in Supabase
    {
        "p_user_id": user_id,
        "p_query": query,
        "p_results_count": 0,
        "p_cost": cost,
    }
).execute()
```

```python
# Line 167: update_search_results()
response = self.supabase.rpc(
    "update_search_results",  # ⚠️ Must exist in Supabase
    {
        "p_search_id": search_id,
        "p_results_count": results_count,
        "p_search_type": search_type,
    }
).execute()
```

### **Used by All Search Endpoints**:

1. **Name Search** (`backend/routers/search.py:68`)
2. **Image Search** (`backend/routers/image_search.py:101`)
3. **Phone Lookup** (`backend/routers/phone_lookup.py:110`)

---

## ✅ Verification After Running SQL

After running the schema, verify the functions were created:

### **In Supabase SQL Editor**:

```sql
-- Verify deduct_credit_for_search exists
SELECT proname, prosrc
FROM pg_proc
WHERE proname = 'deduct_credit_for_search';

-- Verify update_search_results exists
SELECT proname, prosrc
FROM pg_proc
WHERE proname = 'update_search_results';
```

**Expected Result**: Both queries should return 1 row each.

---

## 🚀 After Running the SQL Schema

Once you've run the SQL schema in Supabase, you're ready to:

### **Step 2: Install Python Dependencies**

```bash
cd /Users/robertburns/Projects/RedFlag/backend
source venv/bin/activate
pip install -r requirements.txt
```

**New Dependencies Installed**:
- `supabase==2.4.0` - Supabase client for backend
- `python-jose[cryptography]==3.3.0` - JWT token validation
- `slowapi==0.1.9` - Rate limiting

### **Step 3: Test Locally**

```bash
# Terminal 1: Start backend
cd backend
source venv/bin/activate
python main.py

# Terminal 2: Start Flutter app
cd safety_app
flutter run
```

### **Test Scenarios**:

#### **✅ Test 1: Search with Sufficient Credits**
1. Ensure test user has credits (check Supabase table)
2. Perform name/image/phone search in app
3. **Expected**: Search succeeds, credit deducted
4. Check `searches` table - new record created
5. Check `credit_transactions` table - deduction recorded

#### **✅ Test 2: Search with Insufficient Credits**
1. Set test user credits to 0 in Supabase
2. Attempt any search in app
3. **Expected**: Error message "Insufficient credits" (HTTP 402)
4. Credits should NOT go negative

#### **✅ Test 3: API Failure Triggers Refund**
1. User with 1 credit performs search
2. If API returns 503/500/timeout
3. **Expected**: Credit refunded automatically
4. Check `searches.refunded = TRUE`
5. Check `credit_transactions` - refund transaction created

#### **✅ Test 4: Race Condition Prevention**
1. User with 1 credit
2. Trigger 2 searches simultaneously (if possible)
3. **Expected**: Only 1 search succeeds, other gets "insufficient credits"
4. Credit balance should be exactly 0, not -1

### **Step 4: Set Fly.io Secrets**

Before deploying to production:

```bash
flyctl secrets set \
  SUPABASE_JWT_SECRET="e0We7dHAQYVq4/XB+xOh4iZGsmPr6dpbvMYug/wSQtAIDKW6cTel3HK1HBQpyIrp8rWxfg4RtxmUt86SG9Otow==" \
  SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqYnRtcmJiaml2bml2ZXB0ZGpsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjQzOTg0MywiZXhwIjoyMDc4MDE1ODQzfQ.aJAe8N-oT-xmh1Dh_rfjUpKGjlCqk44b7zoWQUj4MII" \
  SUPABASE_URL="https://qjbtmrbbjivniveptdjl.supabase.co" \
  SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqYnRtcmJiaml2bml2ZXB0ZGpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0Mzk4NDMsImV4cCI6MjA3ODAxNTg0M30.xltmKOa23l0KBSrDGOCQ8xJ7jQbxRxzeBjgJ_NtbH0I"
```

### **Step 5: Deploy to Fly.io**

```bash
cd backend
flyctl deploy
```

**Deployment takes ~3-5 minutes**

### **Step 6: Verify Production**

```bash
# Test endpoint is working
curl https://pink-flag-api.fly.dev/api/search/test

# Should return: {"message": "Search API is working", ...}
```

Then test in production app to ensure:
- ✅ Authentication works
- ✅ Credits are deducted
- ✅ Searches return results
- ✅ Refunds work on failures

---

## 🐛 Troubleshooting

### **Error: "function deduct_credit_for_search does not exist"**

**Cause**: SQL schema not run in Supabase
**Solution**: Run `schemas/CREDIT_DEDUCTION_SCHEMA.sql` in Supabase SQL Editor

---

### **Error: "JWT secret not configured"**

**Cause**: Backend `.env` missing `SUPABASE_JWT_SECRET`
**Solution**: Already fixed - your `.env` now has the correct value

---

### **Error: "Service role key not configured"**

**Cause**: Backend `.env` missing `SUPABASE_SERVICE_ROLE_KEY`
**Solution**: Already fixed - your `.env` now has the correct value

---

### **Error: HTTP 402 "Insufficient credits"**

**Cause**: User actually has 0 credits
**Solution**: This is correct behavior! Add credits to user in Supabase:

```sql
UPDATE users
SET credits = credits + 10
WHERE id = 'USER_ID_HERE'::UUID;
```

---

### **Credits not being deducted**

**Possible causes**:
1. ❌ SQL schema not run → Run `CREDIT_DEDUCTION_SCHEMA.sql`
2. ❌ Backend calling wrong function → Check `credit_service.py` line 110
3. ❌ RPC permissions not granted → Check schema grants at bottom of SQL file

---

### **Credits deducted but not refunded on error**

**Check**:
1. Verify `refund_credit_for_failed_search` function exists (from `CREDIT_REFUND_SCHEMA.sql`)
2. Check backend logs for refund errors
3. Look at `searches.refunded` column - should be TRUE
4. Check `credit_transactions` for refund records

---

## 📊 Database Tables Used

### **Tables Modified/Read by These Functions**:

1. **`users`** - Credit balance updated here
2. **`searches`** - Search history created/updated here
3. **`credit_transactions`** - Audit trail of all credit changes

### **Expected Table Structure**:

```sql
-- users table
users (
  id UUID PRIMARY KEY,
  credits INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMP
)

-- searches table
searches (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  query TEXT,
  search_type TEXT,  -- 'name', 'image', 'phone', or 'pending'
  results_count INT DEFAULT 0,
  refunded BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)

-- credit_transactions table
credit_transactions (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  transaction_type TEXT,  -- 'deduct', 'refund', 'purchase'
  credits INT,
  status TEXT,
  provider TEXT,
  created_at TIMESTAMP
)
```

---

## 📈 Security Impact

### **Before** (Client-Side Credit Validation):
- ❌ Users could modify app to bypass credit checks
- ❌ Race conditions possible (negative balances)
- ❌ No audit trail of credit changes
- ❌ No automatic refunds on API failures

### **After** (Server-Side Credit Validation):
- ✅ **Impossible** to bypass credit checks (server enforces)
- ✅ Atomic transactions prevent race conditions
- ✅ Complete audit trail in `credit_transactions`
- ✅ Automatic refunds on 503/500/timeout errors
- ✅ Search history tracked server-side
- ✅ Fair billing guaranteed

---

## 🎯 Summary: What You Need to Do

### **In Supabase** (5 minutes):
1. ✅ Open SQL Editor
2. ✅ Run `schemas/CREDIT_DEDUCTION_SCHEMA.sql`
3. ✅ Verify functions created

### **Locally** (1 hour):
1. ✅ Install dependencies: `pip install -r requirements.txt`
2. ✅ Test all scenarios (sufficient credits, insufficient, refunds)
3. ✅ Verify credit transactions in Supabase

### **Production** (30 minutes):
1. ✅ Set Fly.io secrets
2. ✅ Deploy backend: `flyctl deploy`
3. ✅ Test in production app

---

## 🎉 Once Complete

Your Pink Flag app will have **enterprise-grade credit validation** that:

- **Prevents fraud**: Users cannot manipulate credits
- **Fair billing**: Automatic refunds on failures
- **Audit trail**: All credit changes tracked
- **Race condition safe**: Atomic transactions
- **Production ready**: Scalable and secure

---

**Next Action**: Run `schemas/CREDIT_DEDUCTION_SCHEMA.sql` in Supabase! 🚀

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

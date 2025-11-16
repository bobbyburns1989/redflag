# Pink Flag Monetization: RevenueCat + Supabase

**Version**: 3.0 (The Ultimate Stack)
**Date**: November 6, 2025
**Estimated Timeline**: 2-3 weeks (fastest option!)
**Complexity**: Low (both are managed services)

---

## The Ultimate Tech Stack

### Frontend
- **Flutter** 3.32.8 - Mobile app framework
- **supabase_flutter** - Supabase client SDK
- **purchases_flutter** - RevenueCat SDK

### Backend (Managed Services)
- **Supabase** - Database + Auth + API + Real-time + Edge Functions
- **RevenueCat** - In-App Purchases + Receipt Validation + Analytics

### Why This is THE BEST Solution

✅ **Fastest Development**: 2-3 weeks total (vs 6 weeks manual)
✅ **No Backend Code**: Supabase auto-generates REST API
✅ **No Auth Code**: Supabase Auth handles everything
✅ **No IAP Code**: RevenueCat handles all purchase logic
✅ **Real-time Updates**: Credits sync instantly across devices
✅ **Free Tier**: Both services free until you scale
✅ **Production-Ready**: Enterprise-grade security and reliability
✅ **Zero Ops**: No servers to manage, auto-scaling

---

## Pricing (Updated)

### RevenueCat
- Free: Up to $2,500/month revenue (~800 purchases)
- Paid: $300/month after that

### Supabase
- Free: Up to 50k MAU, 500MB DB, 2GB bandwidth
- Pro: $25/month (only when you need more)

### Your Costs
| Phase | Monthly Cost | Revenue Threshold |
|-------|--------------|-------------------|
| Launch (Month 1-3) | $0 | Up to $2,500 |
| Growth (Month 4-6) | $25 (Supabase Pro) | $2,500-5,000 |
| Scale (Month 6+) | $325 (both paid) | $5,000+ |

**You'll be profitable at every stage!**

---

## Phase 1: Supabase Setup (Week 1)

### 1.1 Create Supabase Project

**Steps**:
1. Go to https://supabase.com/
2. Sign up (GitHub login recommended)
3. Create new project: **"pink-flag"**
4. Choose region: **US West (Oregon)** (closest to your users)
5. Set database password (save in password manager!)
6. Wait 2 minutes for project to provision

**Save these values** (you'll need them):
- Project URL: `https://xxxxx.supabase.co`
- Anon (public) key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
- Service role key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (keep secret!)

### 1.2 Create Database Schema

**In Supabase Dashboard** → **SQL Editor** → **New Query**:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (Supabase auth.users already exists, this is our custom data)
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    credits INTEGER DEFAULT 1,  -- Free search on signup
    revenuecat_user_id TEXT UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Credit transactions (audit log)
CREATE TABLE public.credit_transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    credits_change INTEGER NOT NULL,  -- +3, +10, +25 for purchase; -1 for search
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('purchase', 'search', 'bonus', 'admin')),
    revenuecat_transaction_id TEXT,
    balance_after INTEGER NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Searches (optional, for analytics)
CREATE TABLE public.searches (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    query TEXT NOT NULL,
    filters JSONB,
    results_count INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_profiles_email ON public.profiles(email);
CREATE INDEX idx_profiles_revenuecat ON public.profiles(revenuecat_user_id);
CREATE INDEX idx_credit_transactions_user_id ON public.credit_transactions(user_id);
CREATE INDEX idx_credit_transactions_created_at ON public.credit_transactions(created_at);
CREATE INDEX idx_searches_user_id ON public.searches(user_id);
CREATE INDEX idx_searches_created_at ON public.searches(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.searches ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Users can only see their own data
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can view own transactions"
    ON public.credit_transactions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view own searches"
    ON public.searches FOR SELECT
    USING (auth.uid() = user_id);

-- Function: Create profile on user signup (trigger)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, credits, revenuecat_user_id)
    VALUES (
        NEW.id,
        NEW.email,
        1,  -- Free search
        NEW.id::TEXT  -- Use Supabase user ID as RevenueCat user ID
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: Auto-create profile when user signs up
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Function: Deduct credit for search
CREATE OR REPLACE FUNCTION public.deduct_credit_for_search(
    p_user_id UUID,
    p_query TEXT,
    p_results_count INTEGER DEFAULT 0
)
RETURNS JSON AS $$
DECLARE
    v_current_credits INTEGER;
    v_new_balance INTEGER;
    v_search_id UUID;
BEGIN
    -- Get current credits
    SELECT credits INTO v_current_credits
    FROM public.profiles
    WHERE id = p_user_id
    FOR UPDATE;  -- Lock row

    -- Check if user has credits
    IF v_current_credits < 1 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'insufficient_credits',
            'credits', v_current_credits
        );
    END IF;

    -- Deduct credit
    UPDATE public.profiles
    SET credits = credits - 1,
        updated_at = NOW()
    WHERE id = p_user_id
    RETURNING credits INTO v_new_balance;

    -- Log search
    INSERT INTO public.searches (user_id, query, results_count)
    VALUES (p_user_id, p_query, p_results_count)
    RETURNING id INTO v_search_id;

    -- Log transaction
    INSERT INTO public.credit_transactions (
        user_id,
        credits_change,
        transaction_type,
        balance_after
    ) VALUES (
        p_user_id,
        -1,
        'search',
        v_new_balance
    );

    RETURN json_build_object(
        'success', true,
        'credits', v_new_balance,
        'search_id', v_search_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Add credits from purchase
CREATE OR REPLACE FUNCTION public.add_credits_from_purchase(
    p_user_id UUID,
    p_credits_to_add INTEGER,
    p_revenuecat_transaction_id TEXT,
    p_notes TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_new_balance INTEGER;
BEGIN
    -- Check if transaction already processed (prevent duplicates)
    IF EXISTS (
        SELECT 1 FROM public.credit_transactions
        WHERE revenuecat_transaction_id = p_revenuecat_transaction_id
    ) THEN
        -- Already processed, return current balance
        SELECT credits INTO v_new_balance
        FROM public.profiles
        WHERE id = p_user_id;

        RETURN json_build_object(
            'success', true,
            'duplicate', true,
            'credits', v_new_balance
        );
    END IF;

    -- Add credits
    UPDATE public.profiles
    SET credits = credits + p_credits_to_add,
        updated_at = NOW()
    WHERE id = p_user_id
    RETURNING credits INTO v_new_balance;

    -- Log transaction
    INSERT INTO public.credit_transactions (
        user_id,
        credits_change,
        transaction_type,
        revenuecat_transaction_id,
        balance_after,
        notes
    ) VALUES (
        p_user_id,
        p_credits_to_add,
        'purchase',
        p_revenuecat_transaction_id,
        v_new_balance,
        p_notes
    );

    RETURN json_build_object(
        'success', true,
        'credits', v_new_balance,
        'credits_added', p_credits_to_add
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Click "Run"** to execute.

### 1.3 Configure Authentication

**In Supabase Dashboard** → **Authentication** → **Providers**:

1. **Email**: Already enabled by default ✅
2. **Email Confirmation**:
   - For MVP: **Disable** (faster testing)
   - For production: **Enable** (recommended)
3. **Social Providers** (optional for future):
   - Apple (required for App Store if you want "Sign in with Apple")
   - Google (optional)

**Authentication Settings**:
- JWT expiry: 3600 seconds (1 hour)
- Minimum password length: 8 characters
- Site URL: `pink-flag://` (deep link for app)

### 1.4 Test Database Connection

**In SQL Editor**, run:
```sql
-- Test query
SELECT * FROM public.profiles LIMIT 10;

-- Should return empty table (no users yet)
```

**Estimated Time**: 2-3 hours

---

## Phase 2: RevenueCat Setup (Week 1)

### 2.1 Create RevenueCat Account & Project

**Steps**:
1. Go to https://www.revenuecat.com/
2. Sign up (email or GitHub)
3. Create new project: **"Pink Flag"**
4. Platform: **iOS** (can add Android later)

### 2.2 Configure Products (Same as Before)

**In RevenueCat Dashboard** → **Products**:

Create 3 products matching App Store Connect:

| Product ID | Display Name | Credits | Price |
|------------|--------------|---------|-------|
| `pink_flag_3_searches` | 3 Searches | 3 | $1.99 |
| `pink_flag_10_searches` | 10 Searches (Best Value) | 10 | $4.99 |
| `pink_flag_25_searches` | 25 Searches | 25 | $9.99 |

### 2.3 Configure Offerings

**RevenueCat Dashboard** → **Offerings**:

1. Create offering: **"default"**
2. Add packages:
   - `three_searches` → pink_flag_3_searches
   - `ten_searches` → pink_flag_10_searches (mark as default)
   - `twenty_five_searches` → pink_flag_25_searches

### 2.4 Link to App Store Connect

(Same process as RevenueCat-only plan - see previous document)

**Estimated Time**: 2-3 hours

---

## Phase 3: Supabase Edge Function for Webhooks (Week 1)

### 3.1 Install Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Or with npm
npm install -g supabase
```

### 3.2 Create Edge Function for RevenueCat Webhook

```bash
# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref xxxxx  # Your project ID

# Create edge function
supabase functions new revenuecat-webhook
```

**Edit `supabase/functions/revenuecat-webhook/index.ts`**:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const REVENUECAT_WEBHOOK_SECRET = Deno.env.get("REVENUECAT_WEBHOOK_SECRET")!;

// Product ID to credits mapping
const PRODUCT_CREDITS_MAP: { [key: string]: number } = {
  "pink_flag_3_searches": 3,
  "pink_flag_10_searches": 10,
  "pink_flag_25_searches": 25,
};

serve(async (req) => {
  try {
    // 1. Verify webhook signature
    const authHeader = req.headers.get("Authorization");
    if (authHeader !== `Bearer ${REVENUECAT_WEBHOOK_SECRET}`) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      );
    }

    // 2. Parse webhook event
    const event = await req.json();
    console.log("RevenueCat webhook received:", event);

    const eventType = event.event?.type;
    const userId = event.event?.app_user_id;
    const productId = event.event?.product_id;
    const transactionId = event.event?.transaction_id;

    // 3. Check if this is a purchase event
    if (
      !["INITIAL_PURCHASE", "NON_RENEWING_PURCHASE"].includes(eventType) ||
      !userId ||
      !productId ||
      !transactionId
    ) {
      console.log("Event ignored (not a relevant purchase)");
      return new Response(
        JSON.stringify({ status: "ignored" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    // 4. Get credits to add
    const creditsToAdd = PRODUCT_CREDITS_MAP[productId];
    if (!creditsToAdd) {
      console.error(`Unknown product ID: ${productId}`);
      return new Response(
        JSON.stringify({ error: "Unknown product" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // 5. Initialize Supabase client (with service role key for admin access)
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 6. Add credits using our database function
    const { data, error } = await supabase.rpc("add_credits_from_purchase", {
      p_user_id: userId,
      p_credits_to_add: creditsToAdd,
      p_revenuecat_transaction_id: transactionId,
      p_notes: `Purchase: ${productId}`,
    });

    if (error) {
      console.error("Database error:", error);
      return new Response(
        JSON.stringify({ error: "Database error", details: error }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    console.log("Credits added successfully:", data);

    return new Response(
      JSON.stringify({ status: "success", data }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Webhook handler error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
```

### 3.3 Set Edge Function Secrets

```bash
# Set RevenueCat webhook secret (generate random string)
supabase secrets set REVENUECAT_WEBHOOK_SECRET=your-random-secret-here

# Supabase URL and service key are auto-set by Supabase
```

### 3.4 Deploy Edge Function

```bash
supabase functions deploy revenuecat-webhook --no-verify-jwt
```

**Output**:
```
Deployed Function revenuecat-webhook:
https://xxxxx.supabase.co/functions/v1/revenuecat-webhook
```

### 3.5 Configure RevenueCat Webhook URL

**RevenueCat Dashboard** → **Project Settings** → **Webhooks**:

1. **Webhook URL**: `https://xxxxx.supabase.co/functions/v1/revenuecat-webhook`
2. **Authorization Header**: `Bearer your-random-secret-here`
3. **Events to Send**: Check "INITIAL_PURCHASE" and "NON_RENEWING_PURCHASE"
4. Click **Save**

**Test webhook**:
```bash
curl -X POST https://xxxxx.supabase.co/functions/v1/revenuecat-webhook \
  -H "Authorization: Bearer your-secret" \
  -H "Content-Type: application/json" \
  -d '{
    "event": {
      "type": "INITIAL_PURCHASE",
      "app_user_id": "test-user-id",
      "product_id": "pink_flag_3_searches",
      "transaction_id": "test-transaction-123"
    }
  }'
```

**Estimated Time**: 3-4 hours

---

## Phase 4: Flutter Integration (Week 2)

### 4.1 Add Packages

**Update `pubspec.yaml`**:
```yaml
dependencies:
  flutter:
    sdk: flutter

  # Supabase
  supabase_flutter: ^2.3.4

  # RevenueCat
  purchases_flutter: ^6.27.0

  # Existing packages
  http: ^1.2.0
  provider: ^6.1.1
  url_launcher: ^6.2.4
  google_fonts: ^6.1.0
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0
```

Run:
```bash
cd safety_app
flutter pub get
```

### 4.2 Initialize Supabase

**Update `lib/main.dart`**:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://xxxxx.supabase.co',
    anonKey: 'your-anon-key',
  );

  runApp(const MyApp());
}

// Global Supabase client
final supabase = Supabase.instance.client;
```

### 4.3 Create Authentication Service

**File**: `lib/services/auth_service.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'revenuecat_service.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  /// Sign up with email/password
  Future<AuthResult> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.failed('Sign up failed');
      }

      // Initialize RevenueCat with Supabase user ID
      await RevenueCatService().initialize(response.user!.id);

      return AuthResult.success(response.user!);
    } catch (e) {
      return AuthResult.failed(e.toString());
    }
  }

  /// Sign in with email/password
  Future<AuthResult> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.failed('Sign in failed');
      }

      // Initialize RevenueCat
      await RevenueCatService().initialize(response.user!.id);

      return AuthResult.success(response.user!);
    } catch (e) {
      return AuthResult.failed(e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get user credits from database
  Future<int> getUserCredits() async {
    if (!isAuthenticated) return 0;

    final response = await _supabase
        .from('profiles')
        .select('credits')
        .eq('id', currentUser!.id)
        .single();

    return response['credits'] as int;
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}

class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult.success(this.user)
      : success = true,
        error = null;

  AuthResult.failed(this.error)
      : success = false,
        user = null;
}
```

### 4.4 Create Search Service with Credit Gating

**File**: `lib/services/search_service.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/search_result.dart';
import 'api_service.dart';

class SearchService {
  final _supabase = Supabase.instance.client;
  final _apiService = ApiService();

  /// Perform search (deducts credit automatically)
  Future<SearchResult> searchByName({
    required String firstName,
    String? lastName,
    String? phoneNumber,
    String? zipCode,
    String? age,
    String? state,
  }) async {
    // 1. Get current user
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Must be logged in to search');
    }

    // 2. Check credits and deduct in one transaction
    final query = lastName != null ? '$firstName $lastName' : firstName;

    final response = await _supabase.rpc('deduct_credit_for_search', params: {
      'p_user_id': user.id,
      'p_query': query,
      'p_results_count': 0,  // Will update after search
    });

    if (response['success'] == false) {
      if (response['error'] == 'insufficient_credits') {
        throw InsufficientCreditsException(response['credits']);
      }
      throw Exception('Failed to deduct credit');
    }

    // 3. Perform actual search with external API
    try {
      final searchResult = await _apiService.searchByName(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        zipCode: zipCode,
        age: age,
        state: state,
      );

      // 4. Update search record with results count
      await _supabase.from('searches').update({
        'results_count': searchResult.totalResults,
      }).eq('id', response['search_id']);

      // 5. Return results with updated credit count
      searchResult.creditsRemaining = response['credits'];
      return searchResult;
    } catch (e) {
      // Search failed, but credit already deducted
      // Could implement credit refund here if desired
      rethrow;
    }
  }

  /// Get user's current credits
  Future<int> getCredits() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    final response = await _supabase
        .from('profiles')
        .select('credits')
        .eq('id', user.id)
        .single();

    return response['credits'] as int;
  }

  /// Listen to credit changes in real-time
  Stream<int> watchCredits() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .map((data) => data.first['credits'] as int);
  }
}

class InsufficientCreditsException implements Exception {
  final int currentCredits;
  InsufficientCreditsException(this.currentCredits);

  @override
  String toString() => 'Insufficient credits. Current balance: $currentCredits';
}
```

### 4.5 Update Search Screen

**File**: `lib/screens/search_screen.dart`

```dart
// Add stream listener for real-time credits
StreamSubscription<int>? _creditsSubscription;

@override
void initState() {
  super.initState();

  // Listen to credits in real-time
  _creditsSubscription = SearchService().watchCredits().listen((credits) {
    setState(() {
      _userCredits = credits;
    });
  });
}

@override
void dispose() {
  _creditsSubscription?.cancel();
  super.dispose();
}

Future<void> _performSearch() async {
  setState(() => _isLoading = true);

  try {
    final results = await SearchService().searchByName(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      // ... other filters
    );

    // Navigate to results
    Navigator.pushNamed(context, '/results', arguments: results);
  } on InsufficientCreditsException catch (e) {
    _showOutOfCreditsDialog();
  } catch (e) {
    _showErrorSnackbar(e.toString());
  } finally {
    setState(() => _isLoading = false);
  }
}

void _showOutOfCreditsDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Out of Credits'),
      content: Text('You need credits to perform searches. Would you like to purchase more?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/store');
          },
          child: Text('Get Credits'),
        ),
      ],
    ),
  );
}
```

**Estimated Time**: 4-5 days

---

## Phase 5: Store UI (Same as Before)

(Use RevenueCat integration from previous plan - no changes needed!)

**Estimated Time**: 2-3 days

---

## Phase 6: Testing (Week 3)

### 6.1 Test Supabase Auth
- [ ] Register new user
- [ ] Verify profile created with 1 credit
- [ ] Login with existing user
- [ ] Logout

### 6.2 Test Credits System
- [ ] Perform search with credits → Deduct 1 credit
- [ ] Try search with 0 credits → Show dialog
- [ ] Credits update in real-time (open app on 2 devices)

### 6.3 Test RevenueCat Purchases
- [ ] Purchase 3 searches → Credits +3
- [ ] Purchase 10 searches → Credits +10
- [ ] Restore purchases → Credits persist
- [ ] Test webhook (check Supabase logs)

### 6.4 Edge Cases
- [ ] Network error during search
- [ ] App killed during purchase
- [ ] Duplicate webhook delivery

**Estimated Time**: 3-4 days

---

## Final Architecture

```
┌─────────────────────────────────────────┐
│         Flutter App (Pink Flag)          │
├─────────────────────────────────────────┤
│                                          │
│  ┌──────────────────┐  ┌──────────────┐ │
│  │ Supabase Client  │  │ RevenueCat   │ │
│  │                  │  │ Client       │ │
│  │ • Auth           │  │              │ │
│  │ • Database       │  │ • Purchase   │ │
│  │ • Real-time      │  │ • Restore    │ │
│  └────────┬─────────┘  └──────┬───────┘ │
│           │                   │         │
└───────────┼───────────────────┼─────────┘
            │                   │
            ▼                   ▼
  ┌──────────────────┐  ┌──────────────┐
  │    Supabase      │  │  RevenueCat  │
  │    Platform      │◄─┤   Platform   │
  ├──────────────────┤  └──────────────┘
  │ PostgreSQL       │         │
  │ Auth             │         │ Webhook
  │ Real-time        │         │
  │ Edge Function◄───┼─────────┘
  │ (webhook)        │
  └──────────────────┘
```

---

## Total Cost Breakdown

### Development Time
- Week 1: Supabase + RevenueCat setup
- Week 2: Flutter integration
- Week 3: Testing + Polish
**Total: 2-3 weeks**

### Monthly Operating Costs
| Service | Free Tier | Paid Tier | Threshold |
|---------|-----------|-----------|-----------|
| Supabase | $0 | $25/mo | 50k MAU |
| RevenueCat | $0 | $300/mo | $2.5k revenue |
| **Total** | **$0** | **$325/mo** | **After scale** |

### Revenue Breakeven
- At $0 costs: Need ~0 purchases (profitable immediately!)
- At $325 costs: Need ~980 purchases (~$3,250 revenue)

**You'll hit RevenueCat's free tier limit ($2,500) before needing to pay for Supabase!**

---

## Why This is Better Than FastAPI

| Feature | FastAPI | Supabase | Winner |
|---------|---------|----------|--------|
| Auth | Build yourself | Built-in | Supabase ✅ |
| Database | Set up PostgreSQL | Managed | Supabase ✅ |
| API | Write endpoints | Auto-generated | Supabase ✅ |
| Real-time | Build with WebSockets | Built-in | Supabase ✅ |
| Hosting | Deploy yourself | Managed | Supabase ✅ |
| Scaling | Configure yourself | Automatic | Supabase ✅ |
| Cost (small) | $40/mo | $0/mo | Supabase ✅ |
| Dev Time | 4 weeks | 2 weeks | Supabase ✅ |

**Supabase wins on every metric!**

---

## Next Steps

1. **Create Supabase account** (5 minutes)
2. **Create RevenueCat account** (5 minutes)
3. **Review this plan** and approve
4. **Start Phase 1** (Supabase setup)

**Ready to start?** This is the optimal solution for your use case!

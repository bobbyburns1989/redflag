# Pink Flag Monetization with RevenueCat

**Version**: 2.0 (RevenueCat Edition)
**Date**: November 6, 2025
**Estimated Timeline**: 3-4 weeks (reduced from 6 weeks!)
**Complexity**: Medium (RevenueCat handles the hard parts)

---

## Why RevenueCat? 🎉

RevenueCat is a **massive simplification** over manual IAP implementation:

### What RevenueCat Handles For You:
✅ **Receipt validation** (no need to build this!)
✅ **Server-side purchase verification** (automatic)
✅ **Entitlements management** (credits tracking)
✅ **Cross-platform support** (iOS + Android ready)
✅ **Restore purchases** (built-in)
✅ **Analytics dashboard** (conversion, revenue, churn)
✅ **Webhooks** (notify your backend of purchases)
✅ **Sandbox testing** (easier than Apple's sandbox)
✅ **Customer support tools** (refunds, subscription management)

### What You Still Build:
- User authentication (email/password)
- Credits UI in app
- Search gating logic
- Backend integration via webhooks

### Cost:
- **Free tier**: Up to $2,500/month in tracked revenue (~800 purchases)
- **Paid tier**: $300/month after that (you'll be profitable by then!)

---

## Pricing Model (Same as Before)

- **Free**: 1 search for new users
- **Tier 1**: $1.99 for 3 searches ($0.66/search)
- **Tier 2**: $4.99 for 10 searches ($0.50/search) - **Best Value**
- **Tier 3**: $9.99 for 25 searches ($0.40/search)

---

## Updated Implementation Phases

## Phase 1: RevenueCat Setup & Configuration (Week 1)

### 1.1 Create RevenueCat Account

**Steps**:
1. Go to https://www.revenuecat.com/
2. Sign up for free account
3. Create new project: "Pink Flag"
4. Choose iOS platform (can add Android later)

### 1.2 Configure Products in RevenueCat

**In RevenueCat Dashboard**:

1. Navigate to **Products** tab
2. Click **+ Create New Product**
3. Create 3 products:

| Product ID | Display Name | Price | Credits | Type |
|------------|--------------|-------|---------|------|
| `pink_flag_3_searches` | 3 Searches | $1.99 | 3 | Consumable |
| `pink_flag_10_searches` | 10 Searches | $4.99 | 10 | Consumable |
| `pink_flag_25_searches` | 25 Searches | $9.99 | 25 | Consumable |

4. For each product, add **Custom Entitlement**:
   - Entitlement ID: `credits`
   - Custom Attribute: `credits_amount` = 3, 10, or 25

### 1.3 Configure App Store Connect

**Steps**:
1. Go to App Store Connect → My Apps
2. Create app if not exists: "Pink Flag" (Bundle ID: com.pinkflag.app)
3. Navigate to **In-App Purchases** section
4. Create 3 In-App Purchases (match RevenueCat product IDs exactly):

**Product 1**:
- Product ID: `pink_flag_3_searches`
- Type: Consumable
- Reference Name: "3 Searches"
- Price: Tier 3 ($1.99)
- Localization: English (US)
  - Display Name: "3 Searches"
  - Description: "Unlock 3 searches to check public offender registries"

**Product 2**:
- Product ID: `pink_flag_10_searches`
- Type: Consumable
- Reference Name: "10 Searches"
- Price: Tier 8 ($4.99)
- Description: "Best Value! 10 searches for personal safety awareness"

**Product 3**:
- Product ID: `pink_flag_25_searches`
- Type: Consumable
- Reference Name: "25 Searches"
- Price: Tier 13 ($9.99)
- Description: "Maximum value! 25 searches for extended use"

5. Submit each product for review
6. **Important**: Products must be "Ready to Submit" before testing!

### 1.4 Link App Store Connect to RevenueCat

**In RevenueCat Dashboard**:
1. Navigate to **Project Settings** → **Apple App Store**
2. Download the **App-Specific Shared Secret** from App Store Connect:
   - App Store Connect → My Apps → Pink Flag
   - Features → In-App Purchases
   - Click "App-Specific Shared Secret" → Generate
3. Paste Shared Secret into RevenueCat
4. Upload **Service Key** (for StoreKit 2):
   - App Store Connect → Users and Access → Keys
   - Click + (add key) → Name: "RevenueCat"
   - Access: App Manager
   - Download .p8 file
   - Upload to RevenueCat

**Estimated Time**: 1-2 days

---

## Phase 2: Database & User Authentication (Week 1-2)

### 2.1 Simplified Database Schema

**With RevenueCat, we need LESS database complexity!**

```sql
-- Users table (simplified)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    revenuecat_user_id VARCHAR(255) UNIQUE NOT NULL,  -- Links to RevenueCat
    credits INTEGER DEFAULT 1,  -- Free search
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_revenuecat_user_id (revenuecat_user_id)
);

-- Credit transactions (audit log)
CREATE TABLE credit_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    credits_change INTEGER NOT NULL,  -- +3, +10, +25 for purchases; -1 for searches
    transaction_type VARCHAR(20) NOT NULL,  -- purchase/search/bonus/admin
    revenuecat_transaction_id VARCHAR(255),  -- From webhook
    balance_after INTEGER NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    INDEX idx_user_id (user_id)
);

-- Searches table (optional, for analytics)
CREATE TABLE searches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    query TEXT NOT NULL,
    results_count INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    INDEX idx_user_id (user_id)
);
```

**Note**: We DON'T need a `purchases` table because RevenueCat stores all purchase data!

### 2.2 Backend Authentication Endpoints (Same as Before)

```python
POST /api/auth/register
  Request: { email, password }
  Response: {
    user_id,
    email,
    credits: 1,  # Free search
    access_token,
    revenuecat_user_id  # Important! Send to Flutter for RevenueCat.configure()
  }

POST /api/auth/login
  Request: { email, password }
  Response: {
    user_id,
    email,
    credits,
    access_token,
    revenuecat_user_id
  }

GET /api/auth/me
  Request: {} (requires auth token)
  Response: { user_id, email, credits }
```

### 2.3 RevenueCat Webhook Endpoint (NEW!)

**This is the magic** - RevenueCat notifies your backend when purchases happen.

```python
POST /api/webhooks/revenuecat
  Headers: {
    Authorization: Bearer <webhook_secret>  # From RevenueCat dashboard
  }
  Request: {
    event: {
      type: "INITIAL_PURCHASE" | "RENEWAL" | "NON_RENEWING_PURCHASE",
      app_user_id: "user_uuid",  # Your user ID
      product_id: "pink_flag_3_searches",
      transaction_id: "apple_transaction_id",
      price: 1.99,
      currency: "USD",
      purchased_at_ms: 1699300000000
    }
  }
```

**Webhook Handler Logic**:
```python
@app.post("/api/webhooks/revenuecat")
async def handle_revenuecat_webhook(
    event: dict,
    authorization: str = Header(None)
):
    # 1. Verify webhook signature (security!)
    if not verify_webhook_signature(authorization):
        raise HTTPException(401, "Invalid signature")

    # 2. Extract data
    event_type = event["event"]["type"]
    user_id = event["event"]["app_user_id"]
    product_id = event["event"]["product_id"]
    transaction_id = event["event"]["transaction_id"]

    # 3. Map product to credits
    credits_map = {
        "pink_flag_3_searches": 3,
        "pink_flag_10_searches": 10,
        "pink_flag_25_searches": 25,
    }
    credits_to_add = credits_map.get(product_id, 0)

    # 4. Add credits to user (in database transaction)
    with database.transaction():
        user = get_user_by_id(user_id)
        user.credits += credits_to_add

        # Log transaction
        create_credit_transaction(
            user_id=user_id,
            credits_change=credits_to_add,
            transaction_type="purchase",
            revenuecat_transaction_id=transaction_id,
            balance_after=user.credits
        )

    # 5. Return success
    return {"status": "ok"}
```

**Important**: Set webhook URL in RevenueCat dashboard:
- RevenueCat Dashboard → Project Settings → Webhooks
- URL: `https://your-backend.com/api/webhooks/revenuecat`
- Secret: Generate random string, save in `.env`

**Estimated Time**: 3-4 days

---

## Phase 3: Flutter Integration (Week 2-3)

### 3.1 Add RevenueCat Flutter Package

**Update `pubspec.yaml`**:
```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  http: ^1.2.0
  provider: ^6.1.1

  # RevenueCat (replaces in_app_purchase!)
  purchases_flutter: ^6.27.0

  # Authentication & Security
  flutter_secure_storage: ^9.0.0
  jwt_decoder: ^2.0.1

  # Existing packages...
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

### 3.2 Create RevenueCat Service

**File**: `lib/services/revenuecat_service.dart`

```dart
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String _apiKey = 'your_revenuecat_public_sdk_key';

  /// Initialize RevenueCat
  Future<void> initialize(String userId) async {
    await Purchases.setLogLevel(LogLevel.debug);  // For development

    PurchasesConfiguration configuration = PurchasesConfiguration(_apiKey)
      ..appUserID = userId;  // YOUR user ID (from backend)

    await Purchases.configure(configuration);
  }

  /// Load available products
  Future<List<StoreProduct>> getProducts() async {
    try {
      Offerings offerings = await Purchases.getOfferings();

      if (offerings.current != null) {
        return offerings.current!.availablePackages
            .map((package) => package.storeProduct)
            .toList();
      }
      return [];
    } catch (e) {
      print('Error loading products: $e');
      return [];
    }
  }

  /// Purchase a product
  Future<PurchaseResult> purchaseProduct(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);

      // Check if purchase was successful
      if (customerInfo.entitlements.all['credits']?.isActive ?? false) {
        return PurchaseResult.success(customerInfo);
      } else {
        return PurchaseResult.failed('Purchase not active');
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled();
      } else {
        return PurchaseResult.failed(e.message ?? 'Unknown error');
      }
    }
  }

  /// Restore purchases
  Future<CustomerInfo> restorePurchases() async {
    return await Purchases.restorePurchases();
  }

  /// Get current customer info (includes entitlements)
  Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }

  /// Sync with backend after purchase
  Future<int> syncCreditsWithBackend(String userId) async {
    // Call your backend to get updated credit balance
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/users/credits'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['credits'];
    }
    throw Exception('Failed to sync credits');
  }
}

// Result wrapper
class PurchaseResult {
  final bool success;
  final bool cancelled;
  final String? error;
  final CustomerInfo? customerInfo;

  PurchaseResult.success(this.customerInfo)
      : success = true, cancelled = false, error = null;

  PurchaseResult.cancelled()
      : success = false, cancelled = true, error = null, customerInfo = null;

  PurchaseResult.failed(this.error)
      : success = false, cancelled = false, customerInfo = null;
}
```

### 3.3 Configure RevenueCat Offerings

**In RevenueCat Dashboard** → **Offerings**:

1. Create new Offering: **"default"** (this is what `getOfferings()` returns)
2. Add 3 Packages:

| Package Identifier | Product | Position |
|-------------------|---------|----------|
| `three_searches` | pink_flag_3_searches | 1 |
| `ten_searches` | pink_flag_10_searches | 2 (Default) |
| `twenty_five_searches` | pink_flag_25_searches | 3 |

3. Set **"ten_searches"** as default (will be highlighted in UI)

### 3.4 Update Authentication Flow

**Modify `lib/services/auth_service.dart`**:

```dart
Future<AuthResult> register(String email, String password) async {
  // 1. Call backend to create user
  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/register'),
    body: jsonEncode({'email': email, 'password': password}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // 2. Save token
    await secureStorage.write(key: 'access_token', value: data['access_token']);

    // 3. Initialize RevenueCat with user ID
    await RevenueCatService().initialize(data['revenuecat_user_id']);

    return AuthResult.success(
      User(
        id: data['user_id'],
        email: data['email'],
        credits: data['credits'],
      ),
    );
  } else {
    return AuthResult.failed('Registration failed');
  }
}
```

**Estimated Time**: 4-5 days

---

## Phase 4: Store UI (Week 3)

### 4.1 Create Store Screen

**File**: `lib/screens/store_screen.dart`

```dart
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final RevenueCatService _rcService = RevenueCatService();
  List<Package> _packages = [];
  bool _loading = true;
  int _currentCredits = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCurrentCredits();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);

    try {
      Offerings offerings = await Purchases.getOfferings();

      if (offerings.current != null) {
        setState(() {
          _packages = offerings.current!.availablePackages;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading products: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _loadCurrentCredits() async {
    // Call backend to get current credits
    final credits = await ApiService().getUserCredits();
    setState(() => _currentCredits = credits);
  }

  Future<void> _purchasePackage(Package package) async {
    setState(() => _loading = true);

    final result = await _rcService.purchaseProduct(package);

    if (result.success) {
      // Purchase successful!
      // RevenueCat webhook will notify backend to add credits

      // Wait a moment for webhook to process
      await Future.delayed(Duration(seconds: 2));

      // Sync credits from backend
      final newCredits = await _rcService.syncCreditsWithBackend(userId);

      setState(() {
        _currentCredits = newCredits;
        _loading = false;
      });

      // Show success message
      showCustomSnackbar(
        context,
        'Purchase successful! You now have $_currentCredits credits.',
        SnackbarType.success,
      );
    } else if (result.cancelled) {
      setState(() => _loading = false);
      // User cancelled, no message needed
    } else {
      setState(() => _loading = false);

      showCustomSnackbar(
        context,
        'Purchase failed: ${result.error}',
        SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Get More Searches'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppSpacing.screenPaddingAll,
              children: [
                // Current credits display
                Container(
                  padding: AppSpacing.cardPaddingAll,
                  decoration: BoxDecoration(
                    gradient: AppColors.pinkGradient,
                    borderRadius: AppDimensions.borderRadiusLg,
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        '$_currentCredits Credits',
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                AppSpacing.verticalSpaceLg,

                // Package cards
                ..._packages.map((package) => _buildPackageCard(package)),

                AppSpacing.verticalSpaceMd,

                // Restore purchases button
                CustomButton(
                  text: 'Restore Purchases',
                  onPressed: _restorePurchases,
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.medium,
                  icon: Icons.restore,
                ),
              ],
            ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final product = package.storeProduct;
    final isDefault = package.identifier == 'ten_searches';  // Best value

    // Extract credits from package (you can also use custom attributes)
    int credits = 3;  // Default
    if (package.identifier == 'ten_searches') credits = 10;
    if (package.identifier == 'twenty_five_searches') credits = 25;

    final pricePerSearch = (product.price / credits).toStringAsFixed(2);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: AppDimensions.borderRadiusLg,
        border: Border.all(
          color: isDefault ? AppColors.primaryPink : AppColors.softPink,
          width: isDefault ? 2 : 1,
        ),
        boxShadow: isDefault ? AppColors.softPinkShadow : AppColors.subtleShadow,
      ),
      child: Column(
        children: [
          // Best value badge
          if (isDefault)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.pinkGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'BEST VALUE',
                    style: AppTextStyles.overline.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: AppSpacing.cardPaddingAll,
            child: Column(
              children: [
                // Credits amount
                Text(
                  '$credits Searches',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryPink,
                  ),
                ),
                AppSpacing.verticalSpaceXs,

                // Price
                Text(
                  product.priceString,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.deepPink,
                  ),
                ),
                AppSpacing.verticalSpaceXs,

                // Price per search
                Text(
                  '\$$pricePerSearch per search',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mediumText,
                  ),
                ),
                AppSpacing.verticalSpaceSm,

                // Buy button
                CustomButton(
                  text: 'Buy Now',
                  onPressed: () => _purchasePackage(package),
                  variant: isDefault ? ButtonVariant.primary : ButtonVariant.secondary,
                  size: ButtonSize.large,
                  icon: Icons.shopping_cart,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Future<void> _restorePurchases() async {
    setState(() => _loading = true);

    try {
      await _rcService.restorePurchases();

      // Sync credits from backend
      final newCredits = await _rcService.syncCreditsWithBackend(userId);

      setState(() {
        _currentCredits = newCredits;
        _loading = false;
      });

      showCustomSnackbar(
        context,
        'Purchases restored! You have $_currentCredits credits.',
        SnackbarType.success,
      );
    } catch (e) {
      setState(() => _loading = false);

      showCustomSnackbar(
        context,
        'Failed to restore purchases',
        SnackbarType.error,
      );
    }
  }
}
```

### 4.2 Add Credits Widget to App Bar

**File**: `lib/widgets/credits_display.dart`

```dart
class CreditsDisplay extends StatelessWidget {
  final int credits;
  final VoidCallback onTap;

  const CreditsDisplay({
    super.key,
    required this.credits,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppColors.pinkGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.softPinkShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              '$credits',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Usage in `search_screen.dart`**:
```dart
AppBar(
  title: Text('Search'),
  actions: [
    Padding(
      padding: EdgeInsets.only(right: 16),
      child: CreditsDisplay(
        credits: _userCredits,
        onTap: () {
          Navigator.pushNamed(context, '/store');
        },
      ),
    ),
  ],
)
```

**Estimated Time**: 3-4 days

---

## Phase 5: Testing (Week 4)

### 5.1 RevenueCat Sandbox Testing

**Much Easier than Apple Sandbox!**

**Steps**:
1. RevenueCat Dashboard → Project Settings → Sandbox
2. Enable Sandbox Mode
3. In app, purchases will use sandbox automatically (no App Store login needed!)

**Test Flow**:
```
1. Register new user → Verify 1 free credit
2. Perform 1 search → Credit deducted to 0
3. Try to search again → "Out of credits" message
4. Go to Store screen → See 3 packages
5. Purchase "3 Searches" → Success (sandbox, no real charge)
6. Wait 2 seconds → Credits updated to 3
7. Perform 2 searches → Credits at 1
8. Test restore purchases → Credits persist
```

### 5.2 Webhook Testing

**Use ngrok to test locally**:
```bash
# Terminal 1: Start backend
cd backend
source venv/bin/activate
python main.py

# Terminal 2: Start ngrok
ngrok http 8000

# Output: https://abc123.ngrok.io → Forwarding to localhost:8000
```

**Update RevenueCat webhook URL**:
- Dashboard → Project Settings → Webhooks
- URL: `https://abc123.ngrok.io/api/webhooks/revenuecat`

**Test webhook manually**:
```bash
curl -X POST https://abc123.ngrok.io/api/webhooks/revenuecat \
  -H "Authorization: Bearer your-webhook-secret" \
  -H "Content-Type: application/json" \
  -d '{
    "event": {
      "type": "INITIAL_PURCHASE",
      "app_user_id": "test-user-id",
      "product_id": "pink_flag_3_searches",
      "transaction_id": "test-transaction-123",
      "price": 1.99,
      "currency": "USD"
    }
  }'
```

**Verify**:
- Check database: User credits increased by 3
- Check logs: Transaction recorded

### 5.3 Production Testing Checklist

Before App Store submission:

- [ ] Products created in App Store Connect (all 3)
- [ ] Products approved (status: "Ready to Submit")
- [ ] RevenueCat configured with production API key
- [ ] Webhook URL set to production backend (HTTPS)
- [ ] Database backups configured
- [ ] Authentication working (register, login, logout)
- [ ] Free search granted on signup
- [ ] Search deducts 1 credit
- [ ] Out of credits gate working
- [ ] All 3 purchase tiers working
- [ ] Restore purchases working
- [ ] Credits persist after app restart
- [ ] Privacy Policy updated (RevenueCat collects data)
- [ ] App Store description mentions IAPs

**Estimated Time**: 3-4 days

---

## Updated Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter App (iOS)                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌───────────────────┐  ┌──────────────┐ │
│  │ Auth Service │  │ RevenueCat Service│  │  API Service │ │
│  │              │  │                   │  │              │ │
│  │ - Register   │  │ - Initialize      │  │ - Search     │ │
│  │ - Login      │  │ - getProducts()   │  │ - getCredits │ │
│  │ - Logout     │  │ - purchase()      │  │              │ │
│  └──────┬───────┘  │ - restore()       │  └──────┬───────┘ │
│         │          └─────────┬─────────┘         │         │
│         │                    │                   │         │
│         └────────────────────┼───────────────────┘         │
│                              │                             │
└──────────────────────────────┼─────────────────────────────┘
                               │
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
    ┌──────────────┐  ┌────────────────┐  ┌──────────────┐
    │   Backend    │  │   RevenueCat   │  │ App Store    │
    │   (FastAPI)  │  │   Platform     │  │   Connect    │
    ├──────────────┤  ├────────────────┤  └──────────────┘
    │              │  │                │
    │ /auth/*      │  │ - Receipts     │
    │ /search      │  │ - Entitlements │
    │ /credits     │  │ - Analytics    │
    │              │  │ - Webhooks     │
    │ /webhooks/   │◄─┤                │
    │  revenuecat  │  │                │
    └──────┬───────┘  └────────────────┘
           │
           ▼
    ┌──────────────┐
    │  PostgreSQL  │
    │              │
    │ - users      │
    │ - credits    │
    │ - searches   │
    └──────────────┘
```

**Key Difference**: RevenueCat handles all purchase logic, validation, and receipt verification. Your backend just receives webhook notifications!

---

## Simplified Database Schema (with RevenueCat)

```sql
-- Users (simplified - no purchases table needed!)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    revenuecat_user_id VARCHAR(255) UNIQUE NOT NULL,
    credits INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP
);

-- Credit transactions (audit only)
CREATE TABLE credit_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    credits_change INTEGER NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    revenuecat_transaction_id VARCHAR(255),
    balance_after INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Searches (optional analytics)
CREATE TABLE searches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    query TEXT NOT NULL,
    results_count INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**That's it!** No complex purchase validation tables.

---

## Cost Breakdown (Updated)

### One-Time Costs
| Item | Cost | Notes |
|------|------|-------|
| Apple Developer Account | $99/year | Required |

### Monthly Operating Costs
| Item | Cost | Notes |
|------|------|-------|
| RevenueCat | $0-300 | Free until $2,500/month revenue (~800 purchases) |
| Database (PostgreSQL) | $0-25 | Railway/Render free tier |
| Backend Hosting | $0-15 | Railway/Render free tier |
| Search API | Variable | $0.20/search (user pays) |
| **Total** | **$0-340/month** | $300 for RevenueCat only after success! |

**Break-even (including RevenueCat)**:
- Before $2,500/month revenue: ~$40/month costs → Need ~120 purchases
- After $2,500/month revenue: ~$340/month costs → Need ~1,000 purchases (but you're making $2,500+!)

**You'll be profitable long before RevenueCat costs kick in!**

---

## Timeline Comparison

| Phase | Manual IAP | With RevenueCat | Time Saved |
|-------|-----------|----------------|------------|
| Setup | 2 days | 1 day | 1 day |
| Backend Purchase Logic | 5 days | 2 days | 3 days |
| Flutter IAP Integration | 6 days | 4 days | 2 days |
| Receipt Validation | 3 days | 0 days | 3 days |
| Testing | 7 days | 4 days | 3 days |
| **Total** | **6 weeks** | **3-4 weeks** | **2+ weeks** |

---

## Key Benefits of RevenueCat

✅ **Faster Development**: 2+ weeks saved
✅ **Less Code to Maintain**: ~1,000 fewer lines of code
✅ **Better Security**: RevenueCat handles receipt validation (prevents fraud)
✅ **Built-in Analytics**: Dashboard shows revenue, churn, LTV
✅ **Easier Testing**: Sandbox mode simpler than Apple's
✅ **Cross-platform Ready**: Add Android later with same code
✅ **Customer Support Tools**: Manage refunds, see purchase history
✅ **Webhook Infrastructure**: Reliable, automatic notifications
✅ **No Server Downtime Issues**: RevenueCat handles scaling

---

## Next Steps

1. **Create RevenueCat Account** (5 minutes)
   - https://app.revenuecat.com/signup
   - Free tier, no credit card required

2. **Review This Plan** and decide:
   - Database: PostgreSQL or SQLite?
   - Analytics: Add Firebase or just use RevenueCat?
   - Timeline: Start Phase 1 now or next week?

3. **Once Approved, I'll**:
   - Set up RevenueCat project
   - Configure products and offerings
   - Start backend implementation

---

**Ready to proceed with RevenueCat?** This is genuinely the best approach for your use case. Let me know and I'll start Phase 1!

# Pink Flag Monetization Implementation Plan

**Version**: 1.0
**Date**: November 6, 2025
**Estimated Timeline**: 4-6 weeks
**Complexity**: High (Authentication + IAP + Backend Integration)

---

## Executive Summary

This document outlines the complete implementation plan to monetize Pink Flag with a credits-based in-app purchase system.

### Pricing Model
- **Free**: 1 search for new users
- **Tier 1**: $1.99 for 3 searches ($0.66/search)
- **Tier 2**: $4.99 for 10 searches ($0.50/search) - **Best Value**
- **Tier 3**: $9.99 for 25 searches ($0.40/search)

### Key Metrics
- **API cost**: $0.20 per search
- **Net margin** (after Apple's 30% cut):
  - Tier 1: $0.26/search (56% margin)
  - Tier 2: $0.15/search (43% margin)
  - Tier 3: $0.10/search (33% margin)

---

## Current Architecture Analysis

### Flutter App (Frontend)
- **Framework**: Flutter 3.32.8, Dart 3.8.1
- **Current State**: Anonymous usage (no user accounts)
- **API Service**: Simple REST client at `lib/services/api_service.dart`
- **State Management**: Provider pattern
- **Key Dependencies**: http, provider, url_launcher, google_fonts, flutter_animate

### Backend (FastAPI)
- **Framework**: FastAPI (Python)
- **Current Endpoints**:
  - `POST /api/search/name` - Main search endpoint ($0.20 per call)
  - `GET /health` - Health check
- **Architecture**: Modular (routers/, services/)
- **No Database**: Currently stateless
- **No Authentication**: Open API

### Critical Gaps to Address
1. ❌ No user authentication system
2. ❌ No database for user/credits/purchase tracking
3. ❌ No IAP (In-App Purchase) integration
4. ❌ No purchase validation backend
5. ❌ No rate limiting or abuse prevention
6. ❌ No analytics or tracking

---

## Implementation Phases

## Phase 1: Database & User Management (Week 1)

### 1.1 Choose and Setup Database
**Recommended**: PostgreSQL (production-grade, free tier on Render/Railway)

**Alternative**: SQLite (simpler for MVP, but harder to scale)

**Tasks**:
- [ ] Install PostgreSQL locally for development
- [ ] Add SQLAlchemy ORM to backend requirements
- [ ] Create database connection manager
- [ ] Set up migrations system (Alembic)

**Files to Create**:
```
backend/
├── database.py           # Database connection setup
├── models/
│   ├── __init__.py
│   ├── user.py          # User model
│   ├── purchase.py      # Purchase history model
│   └── credit.py        # Credits transaction log
└── alembic/             # Database migrations
```

### 1.2 Define Data Models

**User Model**:
```python
class User:
    id: UUID (primary key)
    email: str (unique, indexed)
    password_hash: str
    created_at: datetime
    last_login: datetime
    credits: int (default: 1 for free search)
    is_active: bool
    email_verified: bool
```

**Purchase Model**:
```python
class Purchase:
    id: UUID (primary key)
    user_id: UUID (foreign key)
    product_id: str (e.g., "3_searches", "10_searches", "25_searches")
    transaction_id: str (Apple transaction ID, unique)
    credits_added: int
    amount_usd: Decimal
    purchase_date: datetime
    receipt_data: text (encrypted)
    validation_status: str (pending/verified/failed)
```

**CreditTransaction Model**:
```python
class CreditTransaction:
    id: UUID (primary key)
    user_id: UUID (foreign key)
    credits_change: int (positive for purchase, negative for usage)
    transaction_type: str (purchase/search/refund/admin)
    reference_id: UUID (purchase_id or search_id)
    balance_after: int
    created_at: datetime
    notes: str (optional)
```

### 1.3 Create User Authentication Endpoints

**Backend Endpoints to Implement**:
```python
POST /api/auth/register
  Request: { email, password }
  Response: { user_id, email, credits, access_token }

POST /api/auth/login
  Request: { email, password }
  Response: { user_id, email, credits, access_token }

POST /api/auth/logout
  Request: { } (requires auth token)
  Response: { success: true }

GET /api/auth/me
  Request: { } (requires auth token)
  Response: { user_id, email, credits, created_at }

POST /api/auth/refresh
  Request: { refresh_token }
  Response: { access_token }

POST /api/auth/reset-password
  Request: { email }
  Response: { success: true, message }
```

**Security Considerations**:
- Use bcrypt for password hashing
- Implement JWT (JSON Web Tokens) for authentication
- Add rate limiting (max 5 login attempts per 15 minutes)
- Store refresh tokens securely (httpOnly cookies or encrypted storage)

**Estimated Time**: 3-4 days

---

## Phase 2: Flutter Authentication UI (Week 1-2)

### 2.1 Add Required Flutter Packages

**Update `pubspec.yaml`**:
```yaml
dependencies:
  # Authentication & Security
  flutter_secure_storage: ^9.0.0  # Secure token storage
  jwt_decoder: ^2.0.1             # JWT token parsing
  crypto: ^3.0.3                  # Encryption utilities

  # Existing packages...
  http: ^1.2.0
  provider: ^6.1.1
```

### 2.2 Create Authentication Service

**File**: `lib/services/auth_service.dart`

**Key Methods**:
```dart
Future<AuthResult> register(String email, String password)
Future<AuthResult> login(String email, String password)
Future<void> logout()
Future<User?> getCurrentUser()
Future<bool> isAuthenticated()
Future<String?> getAccessToken()
Future<void> refreshToken()
```

### 2.3 Create Authentication Screens

**Files to Create**:
```
lib/screens/auth/
├── login_screen.dart          # Email/password login
├── register_screen.dart       # New user signup
├── forgot_password_screen.dart # Password reset
└── verify_email_screen.dart   # Email verification (optional for MVP)
```

**Design Requirements**:
- Match existing pink gradient theme
- Form validation (email format, password strength)
- Show/hide password toggle
- Loading states during API calls
- Error handling with friendly messages

### 2.4 Update App Navigation Flow

**New Flow**:
```
Splash Screen
    ↓
Onboarding (first time only)
    ↓
Check Authentication
    ├─ Not Authenticated → Login/Register Screen
    └─ Authenticated → Home Screen
```

**Update Files**:
- `lib/main.dart` - Add auth check in initialization
- `lib/screens/onboarding_screen.dart` - Route to login after completion

**Estimated Time**: 4-5 days

---

## Phase 3: Credits System & Purchase Validation (Week 2)

### 3.1 Backend Purchase Validation Endpoint

Apple's StoreKit provides transaction receipts that MUST be validated server-side to prevent fraud.

**Endpoint**: `POST /api/purchases/validate`

**Request**:
```json
{
  "user_id": "uuid",
  "transaction_id": "apple_transaction_id",
  "receipt_data": "base64_encoded_receipt",
  "product_id": "3_searches" | "10_searches" | "25_searches"
}
```

**Process**:
1. Validate JWT token (user authentication)
2. Send receipt to Apple's verifyReceipt API
3. Check transaction hasn't been processed before (prevent replay attacks)
4. Add credits to user account
5. Log purchase in database
6. Return updated credit balance

**Response**:
```json
{
  "success": true,
  "credits_added": 3,
  "new_balance": 4,
  "purchase_id": "uuid"
}
```

**Apple Receipt Validation**:
- Sandbox URL: `https://sandbox.itunes.apple.com/verifyReceipt`
- Production URL: `https://buy.itunes.apple.com/verifyReceipt`
- Must handle both for testing/production

### 3.2 Credits Management Endpoints

**Get User Credits**:
```python
GET /api/users/credits
  Response: { credits: 5, last_updated: "2025-11-06T10:00:00Z" }
```

**Check Credit Availability** (before search):
```python
GET /api/users/credits/check
  Response: { has_credits: true, credits: 5 }
```

### 3.3 Update Search Endpoint with Credit Gating

**Modify**: `POST /api/search/name`

**New Logic**:
1. Require authentication (JWT token)
2. Check user has credits ≥ 1
3. If no credits → return 402 Payment Required
4. Perform search (existing logic)
5. Deduct 1 credit
6. Log transaction
7. Return results + updated credit balance

**Response**:
```json
{
  "results": [...],
  "query": "John Doe",
  "credits_remaining": 4
}
```

**Estimated Time**: 3-4 days

---

## Phase 4: In-App Purchases (StoreKit) (Week 3)

### 4.1 Configure App Store Connect

**Prerequisites**:
- Apple Developer Account ($99/year)
- App Store Connect access
- Tax forms completed

**Steps**:
1. Create App ID in App Store Connect (com.pinkflag.app)
2. Create In-App Purchase Products:

| Product ID | Type | Price | Credits |
|------------|------|-------|---------|
| `pink_flag_3_searches` | Consumable | $1.99 | 3 |
| `pink_flag_10_searches` | Consumable | $4.99 | 10 |
| `pink_flag_25_searches` | Consumable | $9.99 | 25 |

3. Add product descriptions:
   - Display Name: "3 Searches", "10 Searches", "25 Searches"
   - Description: "Unlock [X] searches to check public registries"
4. Upload screenshot for review (can be simple)
5. Submit for review (required before testing)

**Note**: Products must be approved before testing in sandbox!

### 4.2 Add StoreKit Flutter Package

**Update `pubspec.yaml`**:
```yaml
dependencies:
  in_app_purchase: ^3.1.13  # Official Flutter IAP package
  in_app_purchase_storekit: ^0.3.6+7  # iOS-specific
```

**iOS Configuration**:

Update `ios/Runner/Info.plist`:
```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>your-ad-network-id.skadnetwork</string>
    </dict>
</array>
```

### 4.3 Implement IAP Service

**File**: `lib/services/iap_service.dart`

**Key Components**:
```dart
class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;

  // Initialize connection
  Future<bool> initialize()

  // Load available products from App Store
  Future<List<ProductDetails>> loadProducts()

  // Initiate purchase flow
  Future<void> buyProduct(ProductDetails product)

  // Restore previous purchases
  Future<void> restorePurchases()

  // Listen to purchase updates
  Stream<List<PurchaseDetails>> get purchaseStream

  // Validate purchase with backend
  Future<bool> validatePurchase(PurchaseDetails purchase)

  // Complete purchase (after validation)
  Future<void> completePurchase(PurchaseDetails purchase)
}
```

**Purchase Flow**:
```
User taps "Buy 3 Searches"
    ↓
Show Apple payment sheet
    ↓
User authenticates (Face ID/Touch ID/Password)
    ↓
Apple processes payment
    ↓
Receive PurchaseDetails with receipt
    ↓
Send receipt to backend for validation
    ↓
Backend validates with Apple → adds credits
    ↓
Update UI with new credit balance
    ↓
Complete transaction (tell Apple purchase is finished)
```

**Error Handling**:
- User cancels → Show message, don't deduct credits
- Payment fails → Show error, log for support
- Validation fails → Retry 3 times, then show support contact
- Network error → Queue for retry when connection restored

**Estimated Time**: 5-6 days

---

## Phase 5: Store/Credits UI (Week 3-4)

### 5.1 Create Store Screen

**File**: `lib/screens/store_screen.dart`

**Layout**:
```
┌─────────────────────────────┐
│   Your Credits: 2 🔍        │
├─────────────────────────────┤
│                             │
│   ┌───────────────────┐     │
│   │   3 Searches      │     │
│   │   $1.99           │     │
│   │   [Buy Now]       │     │
│   └───────────────────┘     │
│                             │
│   ┌───────────────────┐     │
│   │   10 Searches     │     │
│   │   $4.99           │     │
│   │   💎 BEST VALUE   │     │
│   │   [Buy Now]       │     │
│   └───────────────────┘     │
│                             │
│   ┌───────────────────┐     │
│   │   25 Searches     │     │
│   │   $9.99           │     │
│   │   [Buy Now]       │     │
│   └───────────────────┘     │
│                             │
│   [Restore Purchases]       │
└─────────────────────────────┘
```

**Features**:
- Display current credit balance prominently
- Show price per search for each tier
- Highlight "Best Value" tier with badge/gradient
- Loading states during purchase
- Success/error animations
- "Restore Purchases" button (required by Apple)

### 5.2 Credits Widget (Global)

**File**: `lib/widgets/credits_display.dart`

**Purpose**: Show credits in app bar across all screens

**Design**:
```
┌────────────────────────────┐
│  Pink Flag    🔍 2 credits │  ← App Bar
└────────────────────────────┘
```

**Interaction**: Tap to open store screen

### 5.3 Update Search Screen with Credit Gate

**File**: `lib/screens/search_screen.dart`

**Logic**:
```dart
Future<void> _performSearch() async {
  // Check credits first
  if (userCredits < 1) {
    _showNoCreditDialog();  // Modal: "Out of credits! Buy more?"
    return;
  }

  // Existing search logic...
  final results = await apiService.searchByName(...);

  // Update credit display after successful search
  setState(() {
    userCredits = results.creditsRemaining;
  });
}
```

**No Credits Dialog**:
- Show current balance: 0
- Call to action: "Get more searches to continue"
- Buttons: [Cancel] [Go to Store]

### 5.4 Update Onboarding

**File**: `lib/screens/onboarding_screen.dart`

**Add New Page** (before "Get Started"):
```
Page 6: How Credits Work
- Icon: wallet/credit card
- Title: "Search with Credits"
- Description:
  "Every new user gets 1 free search!
   Additional searches can be purchased:
   • 3 searches for $1.99
   • 10 searches for $4.99 (Best Value!)
   • 25 searches for $9.99"
```

**Estimated Time**: 4-5 days

---

## Phase 6: Testing & Quality Assurance (Week 4-5)

### 6.1 Sandbox Testing Setup

**Create Sandbox Tester Accounts**:
1. Go to App Store Connect → Users and Access → Sandbox Testers
2. Create 2-3 test accounts (e.g., test1@pinkflag.com)
3. **Important**: These must be NEW email addresses, not associated with existing Apple IDs

**Testing Device Setup**:
1. Sign out of production App Store on test device
2. Don't sign in to sandbox until prompted by app
3. When making purchase, use sandbox tester credentials

### 6.2 Test Cases

**Authentication Tests**:
- [ ] Register new user → Verify 1 free credit
- [ ] Login with existing user → Credits persist
- [ ] Logout → Clears auth token
- [ ] Invalid credentials → Show error
- [ ] Weak password → Show validation error
- [ ] Email already exists → Show error

**IAP Tests**:
- [ ] Load products → All 3 tiers appear
- [ ] Purchase $1.99 tier → 3 credits added
- [ ] Purchase $4.99 tier → 10 credits added
- [ ] Purchase $9.99 tier → 25 credits added
- [ ] Cancel purchase → No credits added
- [ ] Network error during purchase → Retry works
- [ ] Restore purchases → Credits restored correctly
- [ ] Receipt validation fails → Show error, don't add credits

**Credits System Tests**:
- [ ] Perform search with credits → Deduct 1 credit
- [ ] Perform search with 0 credits → Show purchase prompt
- [ ] Credits persist after app restart
- [ ] Credits sync across devices (if same account)
- [ ] Multiple purchases stack correctly

**Edge Cases**:
- [ ] Airplane mode during purchase → Handles gracefully
- [ ] App terminated during purchase → Completes on relaunch
- [ ] Duplicate receipt submission → Rejected
- [ ] Invalid receipt → Error handled
- [ ] Server down during validation → Retry logic works

### 6.3 Production Validation

**Backend Deployment Checklist**:
- [ ] Switch Apple receipt validation to production URL
- [ ] Enable HTTPS only (no HTTP)
- [ ] Database backups configured
- [ ] Monitoring/alerting set up
- [ ] Rate limiting enabled (prevent abuse)
- [ ] Logs sanitized (no sensitive data)

**App Store Submission Checklist**:
- [ ] IAP products approved in App Store Connect
- [ ] Privacy Policy updated (collect email, purchase history)
- [ ] Terms of Service created
- [ ] App Review Notes: Provide test account for reviewers
- [ ] Screenshots show purchase flow
- [ ] Description mentions in-app purchases

**Estimated Time**: 5-7 days

---

## Phase 7: Analytics & Monitoring (Week 5-6)

### 7.1 Add Analytics Tracking

**Recommended Tool**: Firebase Analytics (free tier)

**Events to Track**:
```dart
// User Events
analytics.logSignUp(method: 'email');
analytics.logLogin(method: 'email');

// Purchase Events
analytics.logPurchase(
  value: 1.99,
  currency: 'USD',
  items: [{'item_id': '3_searches', 'quantity': 1}]
);

// Credit Events
analytics.logEvent(name: 'search_performed', parameters: {
  'credits_before': 5,
  'credits_after': 4,
});

// Engagement Events
analytics.logEvent(name: 'no_credits_prompt_shown');
analytics.logEvent(name: 'store_viewed');
analytics.logEvent(name: 'purchase_cancelled');
```

**Key Metrics Dashboard**:
- Daily Active Users (DAU)
- User retention (Day 1, Day 7, Day 30)
- Purchase conversion rate
- Average revenue per user (ARPU)
- Credits usage patterns
- Failed purchase rate

### 7.2 Backend Monitoring

**Add Sentry or Similar**:
- Error tracking
- Performance monitoring
- User session recording

**Custom Metrics**:
- API response times
- Purchase validation success rate
- Credit balance distribution
- Search API cost tracking

**Estimated Time**: 3-4 days

---

## Technical Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App (iOS)                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │ Auth Service │  │  IAP Service │  │  API Service    │   │
│  │              │  │              │  │                 │   │
│  │ - Register   │  │ - Buy        │  │ - searchByName  │   │
│  │ - Login      │  │ - Restore    │  │ - getUserCredits│   │
│  │ - Logout     │  │ - Validate   │  │                 │   │
│  └──────┬───────┘  └──────┬───────┘  └────────┬────────┘   │
│         │                 │                    │            │
│         └─────────────────┼────────────────────┘            │
│                           │                                 │
└───────────────────────────┼─────────────────────────────────┘
                            │
                            │ HTTPS/JWT
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                     Backend (FastAPI)                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────┐  ┌──────────────────┐                 │
│  │ Auth Router     │  │ Purchase Router  │                 │
│  │ /api/auth/*     │  │ /api/purchases/* │                 │
│  └────────┬────────┘  └────────┬─────────┘                 │
│           │                    │                            │
│  ┌────────▼────────────────────▼─────────┐                 │
│  │         Database (PostgreSQL)         │                 │
│  │  - users                              │                 │
│  │  - purchases                          │                 │
│  │  - credit_transactions                │                 │
│  └───────────────────────────────────────┘                 │
│                                                              │
└───────────────────────────┬──────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐  ┌─────────────────┐  ┌──────────────┐
│ Apple StoreKit│  │ Apple Receipt   │  │ Offender API │
│ (IAP)         │  │ Validation API  │  │ ($0.20/call) │
└───────────────┘  └─────────────────┘  └──────────────┘
```

---

## Database Schema

```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    credits INTEGER DEFAULT 1,  -- Free search on signup
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP,
    INDEX idx_email (email)
);

-- Purchases table
CREATE TABLE purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    product_id VARCHAR(50) NOT NULL,  -- "3_searches", "10_searches", "25_searches"
    transaction_id VARCHAR(255) UNIQUE NOT NULL,  -- Apple transaction ID
    credits_added INTEGER NOT NULL,
    amount_usd DECIMAL(10,2) NOT NULL,
    receipt_data TEXT NOT NULL,  -- Encrypted
    validation_status VARCHAR(20) DEFAULT 'pending',  -- pending/verified/failed
    purchase_date TIMESTAMP DEFAULT NOW(),
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_id (transaction_id)
);

-- Credit transactions table (audit log)
CREATE TABLE credit_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    credits_change INTEGER NOT NULL,  -- +3 for purchase, -1 for search
    transaction_type VARCHAR(20) NOT NULL,  -- purchase/search/refund/admin
    reference_id UUID,  -- Links to purchase_id or search_id
    balance_after INTEGER NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);

-- Searches table (optional, for analytics)
CREATE TABLE searches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    query TEXT NOT NULL,
    filters JSONB,  -- Store filters as JSON
    results_count INTEGER,
    api_cost DECIMAL(10,4) DEFAULT 0.20,
    created_at TIMESTAMP DEFAULT NOW(),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);
```

---

## Security Considerations

### 1. Authentication Security
- ✅ Use bcrypt with salt rounds ≥ 12 for password hashing
- ✅ Implement JWT with short expiration (15 minutes access token, 7 days refresh token)
- ✅ Store tokens in flutter_secure_storage (encrypted)
- ✅ Implement rate limiting on auth endpoints
- ✅ Add CAPTCHA on registration (optional, for abuse prevention)

### 2. Purchase Security
- ✅ Always validate receipts server-side (never trust client)
- ✅ Check for duplicate transactions (prevent replay attacks)
- ✅ Encrypt receipt data at rest
- ✅ Log all purchase attempts for audit trail
- ✅ Implement idempotency keys for purchase requests

### 3. API Security
- ✅ Require authentication on all protected endpoints
- ✅ Implement rate limiting (10 searches per minute per user)
- ✅ Use HTTPS only in production
- ✅ Sanitize all user inputs (prevent SQL injection)
- ✅ Add CORS restrictions (only allow app origin)

### 4. Credit Security
- ✅ Use database transactions (ACID) when deducting credits
- ✅ Prevent negative credit balances (check before deduction)
- ✅ Log all credit changes with audit trail
- ✅ Implement reconciliation checks (credits = purchases - searches)

---

## Risk Mitigation

### Risk 1: Users Abuse Free Search
**Mitigation**:
- Limit to 1 free search per email (check on registration)
- Add device fingerprinting (optional, privacy implications)
- Monitor for patterns (same IP, multiple accounts)

### Risk 2: Purchase Validation Fails
**Mitigation**:
- Implement retry logic (3 attempts with exponential backoff)
- Queue failed validations for manual review
- Provide support contact in error messages
- Log all failures for debugging

### Risk 3: Apple Rejects IAP Implementation
**Mitigation**:
- Follow Apple's IAP guidelines strictly
- Test thoroughly in sandbox before submission
- Provide clear refund policy
- Add "Restore Purchases" button (required)

### Risk 4: Database Costs Explode
**Mitigation**:
- Start with free tier (Railway, Render, Supabase)
- Implement data retention policy (delete old searches after 90 days)
- Monitor database size weekly
- Add indexes on frequently queried columns

### Risk 5: Backend API Costs Too High
**Mitigation**:
- Cache common searches (if applicable)
- Implement rate limiting
- Monitor cost per user
- Adjust pricing if margins too thin

---

## Cost Breakdown

### One-Time Costs
| Item | Cost | Notes |
|------|------|-------|
| Apple Developer Account | $99/year | Required for App Store |
| **Total** | **$99** | Annual recurring |

### Monthly Operating Costs (Estimated)
| Item | Cost | Notes |
|------|------|-------|
| Database Hosting (PostgreSQL) | $0-25 | Railway/Render free tier → $25/month |
| Backend Hosting (FastAPI) | $0-15 | Railway/Render free tier → $15/month |
| Search API Costs | Variable | $0.20 per search (passed to user) |
| **Total** | **$0-40/month** | Scales with usage |

### Revenue Projections (Conservative)
| Scenario | Users | Purchases/Month | Revenue | Net Profit |
|----------|-------|-----------------|---------|------------|
| Launch (Month 1) | 100 | 20 | $60 | $20 |
| Growth (Month 3) | 500 | 100 | $300 | $260 |
| Steady State (Month 6) | 1,000 | 250 | $750 | $710 |

**Break-even**: ~100 purchases per month (~$300 revenue)

---

## Success Metrics

### Phase 1 (Launch - Month 1)
- [ ] 100+ registered users
- [ ] 50+ purchases
- [ ] <5% purchase failure rate
- [ ] Average 2.5 searches per paying user

### Phase 2 (Growth - Month 3)
- [ ] 500+ registered users
- [ ] 20% conversion rate (free → paid)
- [ ] 250+ purchases
- [ ] Average $3.50 ARPU (average revenue per user)

### Phase 3 (Optimization - Month 6)
- [ ] 1,000+ registered users
- [ ] 30% conversion rate
- [ ] Average 5 searches per user
- [ ] 60%+ users choose "Best Value" tier

---

## Next Steps

### Immediate Actions (This Week)
1. **Review and approve this plan** with stakeholders
2. **Set up development environment**:
   - Install PostgreSQL
   - Create sandbox Apple account
   - Set up backend development database
3. **Update project documentation** with this plan

### Week 1 Tasks (Starting Now)
1. ✅ Complete architecture analysis (done)
2. [ ] Set up PostgreSQL database
3. [ ] Create user/purchase models
4. [ ] Implement authentication endpoints
5. [ ] Begin Flutter auth UI

### Decision Points
- **Database Choice**: PostgreSQL vs SQLite? (Recommend PostgreSQL)
- **Analytics Tool**: Firebase vs Mixpanel vs PostHog?
- **Error Tracking**: Sentry vs Bugsnag?
- **Hosting**: Railway vs Render vs AWS?

---

## Appendix

### A. Required Flutter Packages
```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  http: ^1.2.0
  provider: ^6.1.1

  # Authentication & Security
  flutter_secure_storage: ^9.0.0
  jwt_decoder: ^2.0.1
  crypto: ^3.0.3

  # In-App Purchases
  in_app_purchase: ^3.1.13
  in_app_purchase_storekit: ^0.3.6+7

  # Analytics (optional but recommended)
  firebase_core: ^2.24.2
  firebase_analytics: ^10.7.4

  # Existing
  url_launcher: ^6.2.4
  google_fonts: ^6.1.0
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0
```

### B. Required Backend Packages
```
# Add to requirements.txt
fastapi==0.104.1
uvicorn==0.24.0
python-dotenv==1.0.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.9  # PostgreSQL driver
alembic==1.12.1         # Database migrations
python-jose[cryptography]==3.3.0  # JWT
passlib[bcrypt]==1.7.4  # Password hashing
python-multipart==0.0.6
httpx==0.25.2           # For Apple receipt validation
sentry-sdk==1.38.0      # Error tracking (optional)
```

### C. Environment Variables
```bash
# Backend .env file
DATABASE_URL=postgresql://user:password@localhost:5432/pinkflag
SECRET_KEY=your-secret-key-here  # Generate with: openssl rand -hex 32
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=7

# Apple IAP
APPLE_RECEIPT_VALIDATION_URL=https://sandbox.itunes.apple.com/verifyReceipt
APPLE_SHARED_SECRET=your-shared-secret-from-app-store-connect

# External APIs
OFFENDER_API_KEY=your-api-key
OFFENDER_API_URL=https://api.example.com
```

### D. Useful Resources
- [Apple In-App Purchase Guide](https://developer.apple.com/in-app-purchase/)
- [StoreKit Testing Guide](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox)
- [Flutter IAP Plugin Docs](https://pub.dev/packages/in_app_purchase)
- [FastAPI + SQLAlchemy Tutorial](https://fastapi.tiangolo.com/tutorial/sql-databases/)
- [JWT Best Practices](https://auth0.com/blog/a-look-at-the-latest-draft-for-jwt-bcp/)

---

**Document Version**: 1.0
**Last Updated**: November 6, 2025
**Next Review**: Week 2 (after Phase 1 completion)

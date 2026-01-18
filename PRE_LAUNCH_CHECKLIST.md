# Pink Flag - Pre-Launch Checklist & User Journey Map

**Created**: November 29, 2025
**Purpose**: Complete user journey mapping and pre-launch requirements
**Status**: Preparing for App Store Launch

---

## 🗺️ Complete User Journey Map

### Phase 1: Discovery & Download (App Store)

#### User Actions:
1. **Discovers Pink Flag** (via search, recommendation, ad, word-of-mouth)
2. **Views App Store listing**
   - Reads app name: "Pink Flag"
   - Sees tagline: "Stay Safe, Stay Aware"
   - Views screenshots
   - Reads description
   - Checks reviews/ratings
3. **Downloads app** (free download)
4. **Opens app for first time**

#### Current Status:
- ❓ **App Store Listing** - Needs verification
  - [ ] App name: "Pink Flag"
  - [ ] Subtitle/tagline configured
  - [ ] Screenshots uploaded (all required sizes)
  - [ ] App description written
  - [ ] Keywords optimized
  - [ ] App icon uploaded (1024x1024)
  - [ ] Privacy policy URL added
  - [ ] Support URL added
  - [ ] Marketing URL (optional)
  - [ ] Age rating set (17+ likely due to content)
  - [ ] Category: Health & Fitness or Lifestyle

#### Gaps to Address:
- **Screenshots**: Need 6.5", 5.5" iPhone screenshots
- **App Preview Video**: Optional but recommended
- **Promotional Text**: 170 characters (can update without review)
- **Description**: 4000 characters max
- **What's New**: Release notes for v1.1.8

---

### Phase 2: Onboarding (First Launch)

#### User Actions:
1. **Sees splash screen** with Pink Flag logo (2.5 seconds)
2. **Views 5-page onboarding flow**:
   - Page 1: Welcome & purpose
   - Page 2: Legal disclaimers
   - Page 3: Ethical use guidelines
   - Page 4: Privacy policy
   - Page 5: False positive warnings
3. **Taps "Get Started"**
4. **Reaches authentication screen**

#### Current Status:
- ✅ Splash screen implemented
- ✅ Onboarding flow complete
- ✅ Legal disclaimers present
- ✅ Privacy policy accessible

#### Gaps to Address:
- [ ] Onboarding can be skipped on subsequent launches
- [ ] "Skip" button for returning users?
- [ ] First-time user flag in database

---

### Phase 3: Authentication & Account Creation

#### User Actions:
1. **Views login/signup screen**
2. **Taps "Sign in with Apple" button** (ONLY option)
3. **Authenticates with Face ID/Touch ID**
4. **Grants permissions** (if requested)
5. **Account created automatically** in Supabase
6. **Receives 1 free search credit**

#### Current Status:
- ✅ Apple Sign-In implemented (only auth method)
- ✅ Supabase integration active
- ✅ 1 free credit granted on signup
- ✅ Credit abuse protection (Apple ID required)

#### Gaps to Address:
- [ ] **Apple Developer Account**: Verify Sign in with Apple is configured
  - [ ] Enable "Sign in with Apple" capability in App Store Connect
  - [ ] Configure service ID
  - [ ] Add domain verification
  - [ ] Test with real Apple ID (not sandbox)
- [ ] Error handling for auth failures
- [ ] Network error handling
- [ ] Terms acceptance checkbox? (or assumed by using app)

---

### Phase 4: First Search Experience

#### User Actions:
1. **Lands on Search screen** (main screen)
2. **Sees credit balance** in top badge (shows "1 credit")
3. **Chooses search type** via 3-tab control:
   - Name Search (default)
   - Phone Lookup
   - Image Search
4. **Fills out search form**:
   - **Name Search**: First name, Last name (required) + Age, State, Phone, ZIP (optional)
   - **Phone Search**: 10-digit US phone number
   - **Image Search**: Camera, Gallery, or URL
5. **Taps "Search" button**
6. **Sees loading indicator** (~2 seconds)
7. **Credit deducted** (1 credit used, 0 remaining)

#### Current Status:
- ✅ 3-tab search interface implemented
- ✅ All 3 search modes functional
- ✅ Credit badge displays real-time balance
- ✅ Loading states implemented
- ✅ Credit deduction working

#### Gaps to Address:
- [ ] First-time user tutorial/tooltips?
- [ ] Example searches shown?
- [ ] "How it works" help screen?

---

### Phase 5: Viewing Results

#### User Actions:
1. **Views results screen** with findings:
   - **Name Search**: List of potential matches with details (name, age, location, offense, distance)
   - **Phone Search**: Caller info, carrier, line type, fraud risk
   - **Image Search**: Number of matches, domains where image appears
2. **Reads disclaimers** on results screen
3. **Scrolls through results**
4. **Taps external links** (if applicable)
5. **Backs out to search again**

#### Current Status:
- ✅ Results screens implemented for all 3 search types
- ✅ Disclaimers present
- ✅ Clean card-based UI
- ✅ Distance calculation (if ZIP provided)

#### Gaps to Address:
- [ ] Share results functionality?
- [ ] Save/export results? (conflicts with privacy policy)
- [ ] Report incorrect information?

---

### Phase 6: Out of Credits (Paywall)

#### User Actions:
1. **Attempts search with 0 credits**
2. **Sees "Out of Credits" dialog**
   - Message: "You need credits to perform searches"
   - Button: "Buy Credits"
3. **Taps "Buy Credits"**
4. **Navigates to Store screen**

#### Current Status:
- ✅ Credit gating implemented in all 3 search services
- ✅ Out of credits detection working
- ✅ Navigation to Store screen

#### Gaps to Address:
- [ ] Dialog design and messaging optimized for conversion
- [ ] A/B test different messages?
- [ ] Show "Last used: X searches" to create urgency?

---

### Phase 7: In-App Purchase Flow

#### User Actions:
1. **Views Store screen** with 3 credit packages:
   - **3 Searches**: $1.99 (best for trying out)
   - **10 Searches**: $4.99 (most popular)
   - **25 Searches**: $9.99 (best value)
2. **Reads package details**
3. **Taps package to select**
4. **Reviews purchase in Apple payment sheet**
5. **Confirms with Face ID/Touch ID**
6. **Payment processed by Apple**
7. **RevenueCat webhook fires**
8. **Credits added to account** via Supabase Edge Function
9. **Sees success message** "25 credits added!"
10. **Returns to Search screen** with new balance

#### Current Status:
- ✅ Store screen implemented
- ✅ RevenueCat integrated (production mode)
- ✅ USE_MOCK_PURCHASES = false
- ✅ 3 product packages configured
- ✅ Webhook Edge Function deployed
- ✅ Credit addition working
- ✅ Sandbox testing verified ✅

#### Gaps to Address:
- [ ] **RevenueCat Dashboard Verification**:
  - [ ] "default" offering exists
  - [ ] All 3 products added to offering
  - [ ] Product IDs match App Store Connect exactly
  - [ ] Webhook URL configured
- [ ] **App Store Connect Verification**:
  - [ ] All 3 in-app purchases created
  - [ ] Products submitted for review
  - [ ] Products approved and "Ready to Submit"
  - [ ] Product IDs match RevenueCat:
    - `pink_flag_3_searches`
    - `pink_flag_10_searches`
    - `pink_flag_25_searches`
  - [ ] Pricing configured ($1.99, $4.99, $9.99)
- [ ] **Purchase Restoration**:
  - [ ] Test restore purchases flow
  - [ ] Verify credits aren't duplicated
- [ ] **Error Handling**:
  - [ ] Network error during purchase
  - [ ] Payment declined
  - [ ] Webhook failure (retry logic?)
  - [ ] User cancels purchase

---

### Phase 8: Ongoing Usage & Retention

#### User Actions:
1. **Performs multiple searches** over time
2. **Checks credit balance** regularly
3. **Buys more credits** when needed
4. **Accesses emergency resources** if needed
5. **Visits Settings** to:
   - View transaction history
   - View search history
   - Change password (if using email auth - N/A for Apple-only)
   - View About screen
   - Sign out

#### Current Status:
- ✅ Settings screen implemented
- ✅ Transaction history screen
- ✅ Search history screen
- ✅ About Pink Flag screen
- ✅ Sign out functionality

#### Gaps to Address:
- [ ] Push notifications for:
  - Credits running low?
  - Special offers?
  - Safety alerts?
- [ ] Email marketing (if we collect emails - we don't currently)
- [ ] Re-engagement strategy for churned users

---

### Phase 9: Credit Refunds (Edge Case)

#### User Actions:
1. **Performs search** that triggers API failure (503, 500, timeout)
2. **Sees error message** explaining issue
3. **Credit automatically refunded** via RPC function
4. **Sees refund in transaction history** with reason
5. **Can retry search** with refunded credit

#### Current Status:
- ✅ Refund system code complete (all 3 search services)
- ✅ Database schema applied
- ✅ RPC function created
- ✅ UI displays refund badges
- ✅ Refund logic tested in sandbox

#### Gaps to Address:
- [ ] Test with real API failures in production
- [ ] Monitor refund patterns
- [ ] Set up alerts for high refund rates

---

## 🚨 Critical Pre-Launch Checklist

### 1. App Store Connect Setup (CRITICAL)

#### App Information
- [ ] **App Name**: "Pink Flag" (exact, must be available)
- [ ] **Subtitle**: "Stay Safe, Stay Aware" (30 characters max)
- [ ] **Bundle ID**: `com.pinkflag.app` (matches Xcode)
- [ ] **SKU**: Unique identifier for your app
- [ ] **Primary Language**: English (U.S.)
- [ ] **Category**:
  - Primary: Health & Fitness or Lifestyle
  - Secondary: (optional)
- [ ] **Age Rating**: Complete questionnaire (likely 17+ due to mature content)
- [ ] **Copyright**: "© 2025 Pink Flag App"

#### App Privacy
- [ ] **Privacy Policy URL**: https://www.customapps.us/pinkflag/privacy
  - [ ] Verify URL is live and accessible
  - [ ] Content accurate and complete
- [ ] **Privacy Nutrition Labels**:
  - [ ] Data collection: Name, Email (from Apple Sign-In)
  - [ ] Data usage: Account creation, Search history
  - [ ] Data linked to user: Yes (credit transactions, searches)
  - [ ] Data tracking: No (we don't track across apps)

#### Pricing & Availability
- [ ] **Price**: Free (with in-app purchases)
- [ ] **Availability**: United States only (initially)
- [ ] **Release**: Automatically release after approval

#### Version Information
- [ ] **Version**: 1.1.8
- [ ] **Build**: 14
- [ ] **Copyright**: "© 2025 Pink Flag App"
- [ ] **What's New**: Release notes (4000 characters max)

#### App Review Information
- [ ] **Contact Information**:
  - [ ] First Name: [Your Name]
  - [ ] Last Name: [Your Last Name]
  - [ ] Phone Number: [Support Number]
  - [ ] Email: support@customapps.us
- [ ] **Sign-In Required**: Yes (Apple Sign-In)
- [ ] **Demo Account**: Not needed (Apple Sign-In uses reviewer's account)
- [ ] **Notes**: Explain the app's purpose, emphasize legal/ethical use

#### Screenshots (REQUIRED)
- [ ] **6.7" Display (iPhone 15 Pro Max)**: 3-10 screenshots
  - [ ] Screenshot 1: Onboarding/Welcome
  - [ ] Screenshot 2: Search screen
  - [ ] Screenshot 3: Results screen
  - [ ] Screenshot 4: Store screen
  - [ ] Screenshot 5: Settings screen
- [ ] **6.5" Display (iPhone 11 Pro Max, XS Max)**: 3-10 screenshots
- [ ] **5.5" Display (iPhone 8 Plus)**: 3-10 screenshots (if supporting older devices)

#### App Icon
- [ ] **1024x1024 icon** uploaded (no transparency, no alpha channel)
- [ ] Matches app icon in Xcode project

---

### 2. In-App Purchases Setup (CRITICAL)

#### RevenueCat Dashboard
- [ ] **Account created** at https://app.revenuecat.com
- [ ] **Project created**: "Pink Flag"
- [ ] **App configured**: iOS app with Bundle ID
- [ ] **API Key**: Copied to `app_config.dart` (line 48)
- [ ] **Products created**:
  - [ ] pink_flag_3_searches - $1.99
  - [ ] pink_flag_10_searches - $4.99
  - [ ] pink_flag_25_searches - $9.99
- [ ] **Offering created**: "default"
- [ ] **Products added to offering** in correct order
- [ ] **Webhook configured**:
  - [ ] URL: Your Supabase Edge Function URL
  - [ ] Authorization: Bearer token (if needed)
  - [ ] Test webhook delivery

#### App Store Connect - In-App Purchases
- [ ] **Navigate to**: App Store Connect > My Apps > Pink Flag > Features > In-App Purchases
- [ ] **Create 3 Non-Consumable or Consumable IAPs**:

  **Product 1: 3 Searches**
  - [ ] Product ID: `pink_flag_3_searches` (MUST match app_config.dart)
  - [ ] Reference Name: "3 Searches"
  - [ ] Price: $1.99 USD
  - [ ] Display Name (all languages): "3 Searches"
  - [ ] Description: "Perform 3 background checks"
  - [ ] Screenshot: Not required for consumables
  - [ ] Cleared for Sale: Yes

  **Product 2: 10 Searches**
  - [ ] Product ID: `pink_flag_10_searches`
  - [ ] Reference Name: "10 Searches"
  - [ ] Price: $4.99 USD
  - [ ] Display Name: "10 Searches"
  - [ ] Description: "Perform 10 background checks (Most Popular)"
  - [ ] Cleared for Sale: Yes

  **Product 3: 25 Searches**
  - [ ] Product ID: `pink_flag_25_searches`
  - [ ] Reference Name: "25 Searches"
  - [ ] Price: $9.99 USD
  - [ ] Display Name: "25 Searches"
  - [ ] Description: "Perform 25 background checks (Best Value)"
  - [ ] Cleared for Sale: Yes

- [ ] **Submit all products for review** (done with app submission)

---

### 3. Apple Developer Account Setup (CRITICAL)

#### Capabilities
- [ ] **Sign in with Apple** enabled in:
  - [ ] Xcode project capabilities
  - [ ] App ID in Developer Portal
  - [ ] Bundle ID matches
- [ ] **In-App Purchase** capability enabled
- [ ] **Push Notifications** (if using) enabled

#### Certificates & Provisioning
- [ ] **Development Certificate**: Created and installed
- [ ] **Production Certificate**: Created for App Store
- [ ] **Provisioning Profile**: App Store profile created
- [ ] **Xcode signing**: "Automatically manage signing" enabled OR manual signing configured

#### Testing
- [ ] **TestFlight** (optional but recommended):
  - [ ] App uploaded to TestFlight
  - [ ] Internal testing with team
  - [ ] External testing with beta testers
  - [ ] Feedback gathered and addressed

---

### 4. Backend Verification (CRITICAL)

#### Fly.io Backend
- [ ] **Status**: https://pink-flag-api.fly.dev/health returns `{"status":"healthy"}`
- [ ] **CORS**: Allows requests from iOS app
- [ ] **Rate Limiting**: Configured and tested
- [ ] **Error Logging**: Sentry/logging service configured
- [ ] **Monitoring**: Uptime monitoring set up
- [ ] **Secrets**: All API keys in environment variables (not code)

#### Supabase Database
- [ ] **Production instance** running (not development)
- [ ] **Database password** updated to strong production password
- [ ] **Row Level Security (RLS)** enabled on all tables:
  - [ ] profiles table
  - [ ] credit_transactions table
  - [ ] searches table
- [ ] **RLS policies** tested and verified:
  - [ ] Users can only see their own data
  - [ ] Credit refund RPC function works
- [ ] **Webhook Edge Function** deployed and accessible:
  - [ ] URL: https://[project].supabase.co/functions/v1/revenuecat-webhook
  - [ ] Test webhook with POST request
  - [ ] Verify credits are added

#### API Keys & Secrets
- [ ] **Offenders.io API Key**: Active and tested
- [ ] **TinEye API Key**: Active with remaining credits
- [ ] **Sent.dm API Key**: Active (check status.sent.dm)
- [ ] **Supabase Keys**: Production keys in app
- [ ] **RevenueCat API Key**: Production key in app
- [ ] **.env files**: Not committed to git

---

### 5. Legal & Compliance (CRITICAL)

#### Privacy Policy
- [ ] **URL live**: https://www.customapps.us/pinkflag/privacy
- [ ] **Content accurate**:
  - [ ] Data collection explained
  - [ ] Apple Sign-In described
  - [ ] Search history policy (not stored persistently)
  - [ ] Credit transaction storage
  - [ ] Third-party API usage disclosed
  - [ ] CCPA/GDPR compliance (if applicable)
- [ ] **Last updated date**: Current

#### Terms of Service
- [ ] **URL live**: https://www.customapps.us/pinkflag/terms
- [ ] **Content includes**:
  - [ ] Acceptable use policy
  - [ ] Prohibited uses (harassment, vigilantism)
  - [ ] Disclaimers about data accuracy
  - [ ] Liability limitations
  - [ ] Refund policy
  - [ ] Account termination policy
- [ ] **Last updated date**: Current

#### App Store Guidelines Compliance
- [ ] **Guideline 5.1.1 (Data Collection)**: Privacy policy in place ✅
- [ ] **Guideline 4.0 (Design)**: App uses native iOS design ✅
- [ ] **Guideline 3.1.1 (In-App Purchase)**: Using Apple's IAP system ✅
- [ ] **Guideline 2.3.8 (Metadata)**: Accurate app description
- [ ] **Guideline 1.4.4 (Harmful Content)**: Disclaimers prevent misuse ✅
- [ ] **Guideline 5.1.5 (Location Services)**: Not using GPS ✅

---

### 6. Code Quality & Testing (HIGH PRIORITY)

#### Code Verification
- [x] **flutter analyze**: 0 errors, 0 warnings ✅
- [ ] **flutter test**: All tests passing (if tests exist)
- [ ] **No debug code**: Remove print statements, test data
- [ ] **No hardcoded secrets**: All keys in config
- [ ] **Error handling**: All API calls have try/catch
- [ ] **Loading states**: All async operations show loading UI
- [ ] **Empty states**: All screens handle "no data" gracefully

#### Device Testing
- [ ] **iPhone SE (2020)**: Small screen testing
- [ ] **iPhone 15**: Standard screen
- [ ] **iPhone 15 Pro Max**: Large screen
- [ ] **iOS 13.0**: Minimum supported version (if targeting 13+)
- [ ] **iOS 17**: Latest version
- [ ] **Portrait orientation**: All screens work
- [ ] **Dark mode**: App respects system preference (if supported)

#### Functional Testing
- [ ] **Onboarding flow**: Complete 5-page flow
- [ ] **Apple Sign-In**: Sign up new account
- [ ] **1 free credit**: Granted on signup
- [ ] **Name search**: Successful search with results
- [ ] **Phone search**: Successful phone lookup
- [ ] **Image search**: Upload image and get results
- [ ] **Out of credits**: Dialog appears when 0 credits
- [ ] **Purchase flow**: Buy each package (sandbox)
- [ ] **Credit addition**: Credits added after purchase
- [ ] **Transaction history**: Shows purchases
- [ ] **Search history**: Shows searches (if implemented)
- [ ] **Settings screens**: All navigation works
- [ ] **Sign out**: Returns to login screen
- [ ] **Network errors**: Graceful error messages
- [ ] **API failures**: Credit refund triggers

#### Edge Cases
- [ ] **No network connection**: Appropriate error message
- [ ] **Slow network**: Loading indicators don't freeze
- [ ] **Multiple rapid taps**: Buttons disabled during processing
- [ ] **App backgrounding**: State preserved correctly
- [ ] **Force quit & reopen**: State restored
- [ ] **Purchase interruption**: Credits still added if payment succeeded
- [ ] **Simultaneous purchases**: Race conditions handled

---

### 7. Performance & Optimization (MEDIUM PRIORITY)

#### App Performance
- [ ] **Startup time**: < 3 seconds to usable screen
- [ ] **Search response**: < 3 seconds average
- [ ] **Image loading**: Cached and optimized
- [ ] **Memory usage**: No leaks in Instruments
- [ ] **Battery usage**: No excessive drain
- [ ] **App size**: < 50 MB (currently ~15 MB ✅)

#### API Performance
- [ ] **Backend response time**: < 500ms average
- [ ] **Database queries**: Optimized with indexes
- [ ] **Caching**: Results cached where appropriate (if any)
- [ ] **Rate limiting**: Prevents abuse

---

### 8. Marketing & App Store Optimization (LOW PRIORITY - Post-Launch)

#### App Store Listing Optimization
- [ ] **Keywords**: Researched and optimized
  - Suggested: safety, background check, sex offender, registry, dating safety, phone lookup, reverse image
- [ ] **Screenshots**: High quality, show key features
- [ ] **Preview Video**: 15-30 second demo (optional)
- [ ] **Promotional Text**: Compelling 170-character hook

#### Launch Preparation
- [ ] **Press Kit**: Screenshots, description, story
- [ ] **Landing Page**: www.customapps.us/pinkflag
- [ ] **Social Media**: Accounts created
- [ ] **Launch Email**: Prepare announcement
- [ ] **Support Email**: support@customapps.us monitored

---

## ⚠️ Blocking Issues (Must Fix Before Launch)

### 🔴 CRITICAL BLOCKERS

1. **App Store Connect App Record**
   - Status: ❓ Unknown if created
   - Action: Create app record in App Store Connect
   - Owner: Developer
   - ETA: 30 minutes

2. **In-App Purchases in App Store Connect**
   - Status: ❓ Unknown if created
   - Action: Create 3 IAP products matching exact Product IDs
   - Owner: Developer
   - ETA: 1 hour

3. **Screenshots for All Device Sizes**
   - Status: ❓ Unknown if created
   - Action: Generate screenshots for 6.7", 6.5", 5.5" displays
   - Owner: Developer
   - ETA: 2 hours

4. **Privacy Policy & Terms URLs**
   - Status: ✅ URLs defined in code
   - Action: Verify URLs are live and accessible
   - Owner: Developer
   - ETA: 15 minutes

5. **Apple Sign-In Configuration**
   - Status: ✅ Code implemented
   - Action: Enable in App Store Connect + test with real Apple ID
   - Owner: Developer
   - ETA: 30 minutes

6. **Archive & Upload to App Store Connect**
   - Status: ❓ Not done
   - Action: Archive app in Xcode, upload to App Store Connect
   - Owner: Developer
   - ETA: 1 hour

### 🟡 HIGH PRIORITY (Should Fix)

7. **Sandbox IAP Testing with Real Product IDs**
   - Status: ✅ Tested with sandbox, but need to verify real Product IDs exist
   - Action: Create products in App Store Connect, re-test
   - Owner: Developer
   - ETA: 1 hour

8. **Production Database Password**
   - Status: ⚠️ Currently using weak password
   - Action: Update to strong password before launch
   - Owner: Developer
   - ETA: 15 minutes

9. **Error Handling for Purchase Failures**
   - Status: ⚠️ May not handle all edge cases
   - Action: Test and improve error messages
   - Owner: Developer
   - ETA: 2 hours

10. **RevenueCat Webhook Verification**
    - Status: ✅ Deployed, but not tested with real purchases
    - Action: Test with TestFlight real purchase
    - Owner: Developer
    - ETA: 30 minutes

---

## 📊 Launch Readiness Score

### Current Status: ~60% Ready

**Completed (60 points)**:
- ✅ Code complete (15 points)
- ✅ Backend deployed (10 points)
- ✅ Database configured (10 points)
- ✅ RevenueCat integrated (10 points)
- ✅ All features implemented (15 points)

**Remaining (40 points)**:
- ❌ App Store Connect setup (15 points)
- ❌ IAP products created (10 points)
- ❌ Screenshots generated (5 points)
- ❌ Testing complete (5 points)
- ❌ App submitted (5 points)

---

## 🚀 Launch Timeline Estimate

### If Starting Today (November 29, 2025)

**Day 1 (Today) - 6 hours**:
1. Create App Store Connect app record (30 min)
2. Create 3 IAP products (1 hour)
3. Generate screenshots for all sizes (2 hours)
4. Verify privacy policy & terms URLs (15 min)
5. Configure Apple Sign-In in App Store Connect (30 min)
6. Update database password (15 min)
7. Test complete user flow on device (1.5 hours)

**Day 2 - 4 hours**:
1. Archive app in Xcode (30 min)
2. Upload to App Store Connect (30 min)
3. Fill out all App Store metadata (2 hours)
4. Submit for review (30 min)

**Day 3-7 - Apple Review**:
- Wait for Apple review (typically 1-3 days)
- Respond to any questions or rejections
- Make fixes if needed

**Day 7-10 - Launch**:
- App approved and live on App Store! 🎉

**Total Time to Launch**: 10-14 days (including Apple review time)

---

## ✅ Next Immediate Actions

### Action 1: Verify Current Deployment Status
**Before proceeding, clarify**:
- [ ] Is the app currently live on App Store? (user said yes, but asking "what's needed before launch")
- [ ] Is the app in TestFlight only?
- [ ] Is the app submitted and in review?
- [ ] Or is the app ready to submit but not yet submitted?

### Action 2: If NOT Yet Live - Complete Blockers
**Work through critical blockers**:
1. Create App Store Connect app record
2. Create IAP products
3. Generate screenshots
4. Submit app

### Action 3: If ALREADY Live - Post-Launch Monitoring
**Focus on**:
1. Monitor crash reports
2. Track purchases
3. Respond to reviews
4. Gather user feedback

---

## 📞 Questions for Clarification

1. **Is the app actually live on the App Store right now?** (Earlier you said yes, but now asking pre-launch requirements)
2. **Do you have screenshots ready for the App Store listing?**
3. **Have you created the 3 IAP products in App Store Connect?**
4. **Is the privacy policy URL live and accessible?**
5. **Have you tested Apple Sign-In with a real Apple ID (not sandbox)?**
6. **Do you have a paid Apple Developer account ($99/year)?**
7. **Have you created the app record in App Store Connect?**

---

**Created**: November 29, 2025
**Status**: Awaiting clarification on current deployment status

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

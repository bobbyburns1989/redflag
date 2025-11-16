# Settings Screen Implementation Plan

**Created**: November 10, 2025
**Status**: Planning Phase - Awaiting Approval
**Priority**: High (Required for App Store submission)

---

## 📋 Executive Summary

Implement a comprehensive Settings screen to provide users with account management, credit tracking, purchase history, and required App Store compliance features (privacy policy, delete account, etc.).

---

## 🎯 Goals

### Primary Objectives
1. **Credit Management** - View balance, transaction history, quick access to store
2. **Account Management** - Email display, password change, sign out, delete account
3. **App Store Compliance** - Privacy policy, terms of service, required disclosures
4. **User Experience** - Search history, app preferences, support access

### Success Criteria
- ✅ Users can view and manage their credits
- ✅ Users can restore purchases
- ✅ Users can delete their account (App Store requirement)
- ✅ Privacy policy and terms are accessible
- ✅ Clean, intuitive UI matching Pink Flag aesthetic

---

## 🏗️ Architecture

### Navigation Structure

**Option 1: Third Bottom Tab** (RECOMMENDED)
```
Bottom Navigation:
├── Search (existing)
├── Resources (existing)
└── Settings (NEW)
```

**Pros:**
- Most accessible for users
- Standard iOS/Android pattern
- Easy to discover
- No extra navigation steps

**Cons:**
- Adds one more tab
- Slightly more crowded bottom nav

---

### Settings Screen Layout

```
Settings
│
├── 👤 Account Section
│   ├── User Email Display
│   ├── Change Password
│   └── Sign Out
│
├── 💳 Credits & Purchases
│   ├── Current Balance (prominent)
│   ├── Buy More Credits (→ Store)
│   ├── Restore Purchases
│   └── Transaction History
│
├── 🔍 Search History
│   ├── View Past Searches
│   └── Clear History
│
├── 📚 Legal & Support
│   ├── Privacy Policy
│   ├── Terms of Service
│   ├── About Pink Flag
│   └── App Version
│
└── ⚠️ Danger Zone
    └── Delete Account
```

---

## 📁 File Structure

### New Files to Create
```
safety_app/lib/screens/
└── settings_screen.dart          # Main settings screen

safety_app/lib/screens/settings/
├── change_password_screen.dart   # Change password form
├── transaction_history_screen.dart  # Purchase history
├── search_history_screen.dart    # Past searches
├── privacy_policy_screen.dart    # Display privacy policy
├── terms_screen.dart             # Display terms
└── delete_account_screen.dart    # Account deletion flow
```

### Files to Modify
```
safety_app/lib/main.dart
├── Add Settings screen to routes
└── Add third tab to HomeScreen

safety_app/lib/widgets/custom_bottom_nav.dart
└── Update to support 3 tabs
```

---

## 🎨 UI/UX Design

### Settings Screen Components

#### 1. Account Section
```dart
- Avatar/Profile Icon
- Email: user@example.com
- Change Password → (new screen)
- Sign Out (with confirmation)
```

#### 2. Credits Card (Prominent)
```dart
Container with gradient background:
  - Large credit number
  - "searches remaining"
  - "Buy More Credits" button (pink gradient)
  - "Restore Purchases" link
  - "View History" link
```

#### 3. Section List Items
```dart
ListTile with:
  - Leading icon
  - Title
  - Subtitle (optional)
  - Trailing arrow
  - Tap action
```

#### 4. Danger Zone
```dart
Red-bordered container:
  - Warning icon
  - "Delete Account" text
  - Disclaimer about data deletion
```

---

## 🔧 Implementation Steps

### Phase 1: Core Setup (30 min)
1. ✅ Create `settings_screen.dart` with basic structure
2. ✅ Add Settings tab to bottom navigation
3. ✅ Update navigation in `main.dart`
4. ✅ Add Settings icon to `CustomBottomNav`

### Phase 2: Account Management (45 min)
1. ✅ Display user email from Supabase
2. ✅ Implement Sign Out functionality
3. ✅ Create Change Password screen
4. ✅ Integrate with AuthService

### Phase 3: Credits Management (30 min)
1. ✅ Display current credit balance (reuse existing logic)
2. ✅ "Buy More Credits" button → Store screen
3. ✅ "Restore Purchases" button (call RevenueCat)
4. ✅ Create Transaction History screen
5. ✅ Query Supabase credit_transactions table

### Phase 4: Search History (30 min)
1. ✅ Create Search History screen
2. ✅ Query Supabase searches table
3. ✅ Display past searches with dates
4. ✅ "Clear History" button with confirmation

### Phase 5: Legal & Support (30 min)
1. ✅ Create Privacy Policy screen (display markdown)
2. ✅ Create Terms of Service screen
3. ✅ Add "About Pink Flag" with version info
4. ✅ Link to support email

### Phase 6: Delete Account (45 min)
1. ✅ Create Delete Account confirmation flow
2. ✅ Implement Supabase user deletion
3. ✅ Delete all user data (GDPR compliance)
4. ✅ Sign out and return to onboarding

### Phase 7: Testing & Polish (30 min)
1. ✅ Test all navigation flows
2. ✅ Verify data updates
3. ✅ Test on different screen sizes
4. ✅ Ensure Pink Flag aesthetic consistency

**Total Estimated Time: 3.5 hours**

---

## 🔐 Security & Privacy Considerations

### Data Deletion (GDPR Compliance)
When user deletes account:
1. Delete user profile from `profiles` table
2. Delete credit transactions from `credit_transactions` table
3. Delete search history from `searches` table
4. Delete Supabase auth user
5. Revoke RevenueCat customer data (optional)

### Password Change
- Require current password
- Validate new password strength
- Use Supabase Auth API
- Show success/error messages

### Privacy Policy & Terms
- Store as markdown files in assets
- Display in WebView or markdown renderer
- Include links to online versions
- Version tracking

---

## 📊 Database Queries Needed

### Transaction History
```sql
SELECT * FROM credit_transactions
WHERE user_id = current_user_id
ORDER BY created_at DESC
LIMIT 50;
```

### Search History
```sql
SELECT * FROM searches
WHERE user_id = current_user_id
ORDER BY created_at DESC
LIMIT 100;
```

### Delete All User Data
```sql
-- Delete in order to respect foreign keys
DELETE FROM searches WHERE user_id = current_user_id;
DELETE FROM credit_transactions WHERE user_id = current_user_id;
DELETE FROM profiles WHERE id = current_user_id;
-- Then delete auth user via Supabase API
```

---

## 🎨 Design Mockup (Text)

```
┌─────────────────────────────────────┐
│ ← Settings                          │  Pink gradient header
├─────────────────────────────────────┤
│                                      │
│ 👤 user@example.com                 │
│ Change Password               →     │
│ ─────────────────────────────────── │
│                                      │
│ 💎 YOUR CREDITS                     │  Prominent card
│    ╔══════════════════════════════╗ │  with gradient
│    ║         5                     ║ │  background
│    ║   searches remaining          ║ │
│    ║                               ║ │
│    ║  [Buy More Credits]           ║ │  Pink button
│    ║  Restore | View History       ║ │
│    ╚══════════════════════════════╝ │
│                                      │
│ 🔍 SEARCH HISTORY                   │
│ View Past Searches            →     │
│                                      │
│ 📚 LEGAL & SUPPORT                  │
│ Privacy Policy                →     │
│ Terms of Service              →     │
│ About Pink Flag               →     │
│                                      │
│ ⚠️  DANGER ZONE                     │
│ ╔══════════════════════════════════╗│  Red border
│ ║ ⚠️  Delete Account                ║│
│ ║ Permanently delete your data     ║│
│ ╚══════════════════════════════════╝│
│                                      │
│ Sign Out                             │  Bottom button
└─────────────────────────────────────┘
```

---

## ✅ App Store Compliance Checklist

### Required Features
- [x] Privacy Policy accessible in-app
- [x] Terms of Service accessible in-app
- [x] Delete Account functionality (GDPR)
- [x] Restore Purchases button
- [x] Sign Out functionality
- [ ] Contact/Support information
- [ ] App version display

### Recommended Features
- [ ] Transaction history
- [ ] Search history management
- [ ] Password change
- [ ] Clear cache/data

---

## 🚀 Deployment Plan

### Testing Checklist
- [ ] All navigation works correctly
- [ ] Credit balance updates in real-time
- [ ] Store screen accessible from Settings
- [ ] Restore purchases works
- [ ] Transaction history loads correctly
- [ ] Search history loads correctly
- [ ] Privacy policy displays correctly
- [ ] Terms display correctly
- [ ] Delete account works and removes all data
- [ ] Sign out works and returns to onboarding
- [ ] Password change works
- [ ] UI matches Pink Flag aesthetic
- [ ] Works on iPhone SE, iPhone 15 Pro Max
- [ ] No console errors or warnings

### Rollout Strategy
1. **Phase 1**: Implement and test locally
2. **Phase 2**: Test on TestFlight with internal testers
3. **Phase 3**: Fix bugs and polish
4. **Phase 4**: Include in App Store submission

---

## 📝 Notes

### RevenueCat Store Issue
- Store screen currently shows "Coming Soon" because offerings aren't loading
- Need to configure products in RevenueCat dashboard:
  - Product IDs: `pink_flag_3_searches`, `pink_flag_10_searches`, `pink_flag_25_searches`
  - Entitlements: Map to credit amounts
  - Offerings: Create "Default" offering with all packages
- This should be fixed before Settings implementation

### Alternative: Settings Icon in AppBar
If you prefer not to add a third tab, we could:
- Add gear icon in top-right of Search screen
- Opens Settings as modal/push screen
- Less discoverable but cleaner navigation

---

## 🤔 Open Questions for Approval

1. **Navigation**: Third bottom tab (recommended) or gear icon in app bar?
2. **Transaction History**: Show all transactions or just last 50?
3. **Search History**: Show all searches or allow filters (date range)?
4. **Privacy Policy**: Display in-app or open in browser?
5. **Delete Account**: Require password confirmation or just email?

---

**Status**: Ready for review and approval
**Next Step**: Await user approval, then begin Phase 1 implementation

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

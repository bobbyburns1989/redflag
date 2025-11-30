# Settings Screen - Placeholder Features Build Plan

**Created**: November 10, 2025
**Status**: Planning Phase - Awaiting Approval
**Priority**: Medium-High (Required for App Store submission)

---

## 📋 Overview

This document outlines the implementation plan for all placeholder features in the Settings screen. These features range from simple informational screens to complex flows involving data deletion and payment processing.

---

## 🎯 Placeholder Features to Implement

### Current Status
- ✅ Settings screen structure complete
- ✅ Account section with sign out functional
- ✅ Credits display functional
- ⏳ 8 placeholder features remaining

### Remaining Features
1. **Change Password** - Form to update user password
2. **Restore Purchases** - RevenueCat purchase restoration
3. **Transaction History** - Display past credit purchases
4. **Search History** - Display past searches
5. **Privacy Policy** - Display privacy policy text
6. **Terms of Service** - Display terms text
7. **About Pink Flag** - App information screen
8. **Delete Account** - Multi-step account deletion flow

---

## 📊 Priority Matrix

### Priority 1: App Store Required (CRITICAL)
- ✅ Sign Out (already done)
- 🔴 **Privacy Policy** - Required for App Store
- 🔴 **Terms of Service** - Required for App Store
- 🔴 **Delete Account** - Required for GDPR compliance
- 🔴 **Restore Purchases** - Required for in-app purchases

### Priority 2: User Value (HIGH)
- 🟡 **Change Password** - Security & account management
- 🟡 **Transaction History** - Financial transparency
- 🟡 **Search History** - User convenience

### Priority 3: Nice to Have (MEDIUM)
- 🟢 **About Pink Flag** - App information

---

## 🏗️ Implementation Plan

---

## Feature 1: Privacy Policy Screen

### Complexity: LOW
**Estimated Time**: 30 minutes

### Requirements
- Display Pink Flag privacy policy
- Scrollable text
- Option to open in browser (optional)

### Implementation

**Files to Create**:
```
/safety_app/lib/screens/settings/privacy_policy_screen.dart
/safety_app/assets/legal/privacy_policy.md (or .txt)
```

**Approach**:
1. Create simple scrollable screen with markdown or plain text
2. Load content from assets or display hardcoded text
3. Add "Last Updated" date
4. Optional: Add "Open in Browser" button with url_launcher

**UI Components**:
```dart
- AppBar with title
- ScrollView with padding
- Rich text or markdown widget
- Optional: External link button
```

**Content Needed**:
- Privacy policy text (you'll need to provide or we use template)
- Data collection practices
- Third-party services (Supabase, RevenueCat, Offenders.io)
- User rights (GDPR, CCPA)

---

## Feature 2: Terms of Service Screen

### Complexity: LOW
**Estimated Time**: 20 minutes

### Requirements
- Display terms of service
- Scrollable text
- Similar to Privacy Policy

### Implementation

**Files to Create**:
```
/safety_app/lib/screens/settings/terms_screen.dart
/safety_app/assets/legal/terms.md (or .txt)
```

**Approach**:
1. Nearly identical to Privacy Policy screen
2. Different content
3. Can reuse most code

**Content Needed**:
- Terms of service text
- Acceptable use policy
- Disclaimer about data accuracy
- Liability limitations

---

## Feature 3: About Pink Flag Screen

### Complexity: LOW
**Estimated Time**: 45 minutes

### Requirements
- App name, version, build number
- Developer information
- Links to website, support email
- Third-party licenses
- Credits/acknowledgments

### Implementation

**Files to Create**:
```
/safety_app/lib/screens/settings/about_screen.dart
```

**Approach**:
1. Fetch version from package_info_plus
2. Display app logo
3. Show version and build number
4. Links to support, website
5. Show third-party packages used
6. Copyright notice

**UI Components**:
```dart
- App logo
- Version info
- Tappable links (email, website)
- Licenses button
- Credits section
```

**External Packages Needed**:
```yaml
package_info_plus: ^8.0.0  # For version info
```

---

## Feature 4: Restore Purchases

### Complexity: LOW-MEDIUM
**Estimated Time**: 30 minutes

### Requirements
- Call RevenueCat restore method
- Show loading state
- Display success/error messages
- Update credit balance

### Implementation

**Files to Modify**:
```
/safety_app/lib/screens/settings_screen.dart
```

**Approach**:
1. Call `_revenueCatService.restorePurchases()`
2. Show loading dialog
3. Handle success: show snackbar, refresh credits
4. Handle error: show error message
5. Handle no purchases: inform user

**Code Changes**:
```dart
Future<void> _restorePurchases() async {
  // Show loading
  showDialog(context, LoadingDialog());

  // Call RevenueCat
  final result = await RevenueCatService().restorePurchases();

  // Dismiss loading
  Navigator.pop(context);

  // Handle result
  if (result.success) {
    CustomSnackbar.showSuccess(context, 'Purchases restored!');
    _loadUserData(); // Refresh credits
  } else {
    CustomSnackbar.showError(context, result.error);
  }
}
```

**Testing Requirements**:
- Need App Store Sandbox tester account
- Test with previous purchases
- Test with no purchases

---

## Feature 5: Change Password Screen

### Complexity: MEDIUM
**Estimated Time**: 1.5 hours

### Requirements
- Form with three fields:
  - Current password
  - New password
  - Confirm new password
- Validation
- Call Supabase update user
- Success/error handling

### Implementation

**Files to Create**:
```
/safety_app/lib/screens/settings/change_password_screen.dart
```

**Approach**:
1. Create form with 3 password fields
2. Validate:
   - Current password required
   - New password ≥ 8 characters
   - Passwords match
3. Call `supabase.auth.updateUser(password: newPassword)`
4. Show success and navigate back
5. Handle errors

**UI Components**:
```dart
- 3x CustomTextField (password type)
- Password visibility toggles
- Validation messages
- Submit button
- Loading state
```

**Security Considerations**:
- Don't show current password in plain text
- Validate password strength
- Clear fields on success
- Re-authenticate if session expired

**Supabase API**:
```dart
await supabase.auth.updateUser(
  UserAttributes(password: newPassword)
);
```

---

## Feature 6: Transaction History Screen

### Complexity: MEDIUM
**Estimated Time**: 2 hours

### Requirements
- Query `credit_transactions` table
- Display list of purchases
- Show date, amount, credits added
- Empty state if no transactions

### Implementation

**Files to Create**:
```
/safety_app/lib/screens/settings/transaction_history_screen.dart
/safety_app/lib/models/transaction.dart (if not exists)
```

**Database Query**:
```sql
SELECT
  id,
  user_id,
  transaction_type,
  credits,
  amount,
  provider,
  provider_transaction_id,
  created_at
FROM credit_transactions
WHERE user_id = current_user_id
ORDER BY created_at DESC
LIMIT 100;
```

**Approach**:
1. Create Transaction model
2. Query Supabase on screen load
3. Display in ListView with cards
4. Show transaction details:
   - Date/time
   - Credits purchased
   - Amount paid
   - Transaction ID
5. Pull-to-refresh
6. Empty state with message

**UI Components**:
```dart
- ListView.builder
- Transaction card widget
- Date formatter
- Empty state widget
- Pull-to-refresh
- Loading state
```

**Card Design**:
```
┌─────────────────────────────────┐
│ 💎 10 Credits Added             │
│ $2.99                           │
│ Nov 10, 2025 11:30 AM           │
│ Transaction: rc_abc123          │
└─────────────────────────────────┘
```

---

## Feature 7: Search History Screen

### Complexity: MEDIUM
**Estimated Time**: 2 hours

### Requirements
- Query `searches` table
- Display list of past searches
- Show date, name searched, results count
- Clear history button
- Delete individual searches

### Implementation

**Files to Create**:
```
/safety_app/lib/screens/settings/search_history_screen.dart
```

**Database Query**:
```sql
SELECT
  id,
  user_id,
  query,
  results_count,
  created_at
FROM searches
WHERE user_id = current_user_id
ORDER BY created_at DESC
LIMIT 100;
```

**Approach**:
1. Query searches from Supabase
2. Display in ListView
3. Show search details:
   - Name searched
   - Date/time
   - Results count
4. Swipe to delete individual search
5. "Clear All" button with confirmation
6. Empty state
7. Pull-to-refresh

**UI Components**:
```dart
- ListView with Dismissible
- Search card widget
- Date formatter
- "Clear All" button in AppBar
- Confirmation dialog
- Empty state
```

**Features**:
- Tap search to repeat (navigate to results)
- Swipe left to delete
- Clear all with confirmation

**Privacy Note**:
- Inform users searches are stored
- Easy to clear
- Option to disable in settings (future)

---

## Feature 8: Delete Account Flow

### Complexity: HIGH
**Estimated Time**: 3 hours

### Requirements
- Multi-step confirmation flow
- Warning about permanent deletion
- Password confirmation
- Delete all user data:
  - searches
  - credit_transactions
  - profiles
  - auth user
- Sign out and return to onboarding

### Implementation

**Files to Create**:
```
/safety_app/lib/screens/settings/delete_account_screen.dart
```

**Deletion Flow**:
```
Step 1: Warning Screen
├── Explain what will be deleted
├── Mention data cannot be recovered
└── "Continue" button

Step 2: Confirmation
├── "Type DELETE to confirm"
├── Password re-entry
└── Final "Delete Account" button

Step 3: Processing
├── Show loading dialog
├── Delete in order:
│   1. searches (foreign key dependent)
│   2. credit_transactions (foreign key dependent)
│   3. profiles
│   4. auth user (via Supabase API)
└── Sign out and navigate to onboarding
```

**Database Operations**:
```dart
Future<void> deleteUserAccount(String userId) async {
  try {
    // 1. Delete searches
    await supabase
      .from('searches')
      .delete()
      .eq('user_id', userId);

    // 2. Delete transactions
    await supabase
      .from('credit_transactions')
      .delete()
      .eq('user_id', userId);

    // 3. Delete profile
    await supabase
      .from('profiles')
      .delete()
      .eq('id', userId);

    // 4. Delete auth user
    await supabase.auth.admin.deleteUser(userId);

    // 5. Sign out
    await supabase.auth.signOut();

  } catch (e) {
    throw Exception('Failed to delete account: $e');
  }
}
```

**UI Screens**:

**Screen 1 - Warning**:
```dart
- Red warning icon
- Bold title: "Delete Account"
- List of what will be deleted:
  - All search history
  - All transaction history
  - Account credentials
  - This action cannot be undone
- "Continue" button (red)
- "Cancel" button
```

**Screen 2 - Confirmation**:
```dart
- Text field: "Type DELETE to confirm"
- Password field
- "Delete My Account" button (disabled until confirmed)
- "Cancel" button
```

**Security Considerations**:
- Require password re-entry
- Typed confirmation ("DELETE")
- Multiple confirmation screens
- No accidental deletion
- Clear about permanence

**Error Handling**:
- Network errors
- Database errors
- Partial deletion (rollback?)
- Inform user if any step fails

**Testing**:
- Test on sandbox account
- Verify all data deleted
- Verify auth user removed
- Verify navigation to onboarding

---

## 📦 External Dependencies Needed

### New Packages to Add
```yaml
# pubspec.yaml

dependencies:
  # ... existing dependencies ...

  package_info_plus: ^8.0.0      # For About screen (version info)
  flutter_markdown: ^0.7.0       # Optional: For privacy policy/terms
```

### Assets to Create
```
safety_app/assets/
└── legal/
    ├── privacy_policy.md
    └── terms_of_service.md
```

---

## 📅 Implementation Timeline

### Phase 1: App Store Required (CRITICAL) - 5 hours
**Priority**: Complete before submission

1. **Privacy Policy Screen** (30 min)
2. **Terms of Service Screen** (20 min)
3. **Restore Purchases** (30 min)
4. **Delete Account Flow** (3 hours)

**Subtotal**: 4.5 hours

### Phase 2: High Value Features - 4.5 hours
**Priority**: Complete this week

5. **Change Password Screen** (1.5 hours)
6. **Transaction History Screen** (2 hours)
7. **Search History Screen** (2 hours)

**Subtotal**: 5.5 hours

### Phase 3: Nice to Have - 45 minutes
**Priority**: Complete when time allows

8. **About Pink Flag Screen** (45 min)

**Subtotal**: 45 minutes

### Total Estimated Time: ~10 hours

---

## 🎯 Recommended Implementation Order

### Option A: App Store First (RECOMMENDED)
**Goal**: Get ready for App Store submission ASAP

1. Privacy Policy (30 min)
2. Terms of Service (20 min)
3. Delete Account (3 hrs)
4. Restore Purchases (30 min)
5. About Pink Flag (45 min)

**Then later**:
6. Change Password (1.5 hrs)
7. Transaction History (2 hrs)
8. Search History (2 hrs)

**Benefits**:
- App Store submission ready quickly
- Legal compliance done first
- Can submit TestFlight build sooner

---

### Option B: User Value First
**Goal**: Maximize user experience

1. Restore Purchases (30 min)
2. Change Password (1.5 hrs)
3. Transaction History (2 hrs)
4. Search History (2 hrs)
5. About Pink Flag (45 min)

**Then legal**:
6. Privacy Policy (30 min)
7. Terms of Service (20 min)
8. Delete Account (3 hrs)

**Benefits**:
- Users get useful features first
- Can test monetization flow sooner
- Better app experience during testing

---

### Option C: Quick Wins First
**Goal**: Show progress quickly

1. About Pink Flag (45 min)
2. Privacy Policy (30 min)
3. Terms of Service (20 min)
4. Restore Purchases (30 min)
5. Change Password (1.5 hrs)
6. Transaction History (2 hrs)
7. Search History (2 hrs)
8. Delete Account (3 hrs)

**Benefits**:
- Fast early progress
- Easy features done first
- Build momentum

---

## 📝 Content Requirements

### Privacy Policy Content Needed
- App name and developer info
- Data collected:
  - Email (Supabase Auth)
  - Search queries (stored in DB)
  - Purchase history (RevenueCat)
- Third-party services:
  - Supabase (database, auth)
  - RevenueCat (payments)
  - Offenders.io (search API)
  - Apple (App Store, payments)
- Data usage
- Data retention
- User rights (access, delete, opt-out)
- Contact information

### Terms of Service Content Needed
- Acceptable use policy
- Data accuracy disclaimer
- Liability limitations
- Age requirements
- Account termination
- Modifications to terms
- Governing law

---

## 🧪 Testing Plan

### Manual Testing Checklist

**Privacy Policy**:
- [ ] Screen displays correctly
- [ ] Text is readable
- [ ] Scrolling works
- [ ] Links work (if any)

**Terms of Service**:
- [ ] Screen displays correctly
- [ ] Text is readable
- [ ] Scrolling works

**About**:
- [ ] Version number displays correctly
- [ ] Links work
- [ ] Licenses accessible

**Restore Purchases**:
- [ ] Loading state shows
- [ ] Success message appears
- [ ] Credits update correctly
- [ ] Error handling works

**Change Password**:
- [ ] Validation works
- [ ] Password updates successfully
- [ ] Error messages display
- [ ] Can sign in with new password

**Transaction History**:
- [ ] Purchases display correctly
- [ ] Dates formatted properly
- [ ] Empty state shows when no transactions
- [ ] Pull-to-refresh works

**Search History**:
- [ ] Searches display correctly
- [ ] Delete works
- [ ] Clear all works
- [ ] Empty state shows

**Delete Account**:
- [ ] Warning screen appears
- [ ] Confirmation required
- [ ] Password verification works
- [ ] All data deleted
- [ ] User signed out
- [ ] Cannot sign in with old credentials

---

## ⚠️ Risks & Mitigation

### Risk 1: Content Not Ready
**Problem**: Privacy policy/terms text not available
**Mitigation**: Use template, mark as "Coming Soon" for now
**Impact**: Medium - required for App Store

### Risk 2: Delete Account Complexity
**Problem**: Multiple database tables, foreign keys
**Mitigation**: Test thoroughly on sandbox, add rollback logic
**Impact**: High - data loss if broken

### Risk 3: RevenueCat Not Configured
**Problem**: Can't test Restore Purchases
**Mitigation**: Implement UI first, test when configured
**Impact**: Low - can complete later

### Risk 4: Time Estimates
**Problem**: Features may take longer than estimated
**Mitigation**: Prioritize App Store required features
**Impact**: Medium - may delay submission

---

## 📞 Questions for Approval

1. **Implementation Order**: Option A (App Store First), B (User Value), or C (Quick Wins)?
2. **Privacy Policy/Terms**: Do you have content, or should we use templates?
3. **About Screen**: What information should we include? (Website, support email, etc.)
4. **Search History**: Should we allow users to repeat searches from history?
5. **Delete Account**: Should we require email confirmation in addition to password?
6. **Timeline**: Implement all at once, or phase over multiple sessions?

---

## 📊 Success Criteria

**Phase 1 Complete When**:
- [ ] All 8 features implemented
- [ ] No "Coming Soon" placeholders
- [ ] All features tested manually
- [ ] Documentation updated
- [ ] No build errors or warnings

**App Store Ready When**:
- [ ] Privacy Policy complete
- [ ] Terms of Service complete
- [ ] Delete Account working
- [ ] Restore Purchases working
- [ ] All legal compliance met

---

**Status**: Ready for approval
**Next Step**: Await user approval on implementation order and questions

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

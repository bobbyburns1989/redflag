# Planned Features - Future Implementation

This document tracks features that are currently **placeholders** in the Settings screen and are planned for future implementation.

## Status: Intentional Placeholders

The following features are **intentionally** marked as "Coming soon" in the app. They are not bugs or incomplete work - they are planned features for future releases.

---

## 📋 Planned Features List

### 1. Transaction History
**Location:** `lib/screens/settings_screen.dart:198`
**Status:** Placeholder
**Description:** View complete purchase history with credits, amounts, dates, and transaction IDs.

**Planned Implementation:**
- New screen: `lib/screens/settings/transaction_history_screen.dart`
- Query `credit_transactions` table from Supabase
- Display list of purchases with:
  - Date/time
  - Credits purchased
  - Amount paid
  - Transaction ID
  - Payment provider (RevenueCat/Mock)
- Sort by date (newest first)
- Pull-to-refresh functionality

---

### 2. Search History
**Location:** `lib/screens/settings_screen.dart:215`
**Status:** Placeholder
**Description:** View past searches performed by the user.

**Planned Implementation:**
- New screen: `lib/screens/settings/search_history_screen.dart`
- Query `searches` table from Supabase
- Display list of searches with:
  - Date/time
  - Search parameters (name, age, location, etc.)
  - Number of results found
  - Option to re-run search
- Sort by date (newest first)
- Pull-to-refresh functionality
- Optional: Delete individual search history items

---

### 3. Change Password
**Location:** `lib/screens/settings_screen.dart:317`
**Status:** Placeholder
**Description:** Allow users to change their account password.

**Planned Implementation:**
- New screen: `lib/screens/settings/change_password_screen.dart`
- Form fields:
  - Current password (required)
  - New password (required, min 8 chars)
  - Confirm new password (required, must match)
- Password strength indicator
- Use Supabase `auth.updateUser()` API
- Validation:
  - Verify current password first
  - Ensure new password meets requirements
  - Ensure new password differs from current
- Success feedback with automatic logout (force re-login)

---

### 4. About Pink Flag
**Location:** `lib/screens/settings_screen.dart:256`
**Status:** Placeholder
**Description:** Display app information and credits.

**Planned Implementation:**
- New screen: `lib/screens/settings/about_screen.dart`
- Display:
  - App name and logo
  - Current version number (from pubspec.yaml)
  - Build number
  - Brief description of app purpose
  - Links to:
    - Website (if available)
    - Support email
    - Privacy Policy (already implemented)
    - Terms of Service (already implemented)
  - Copyright notice
  - Third-party licenses (Flutter's LicensePage)
  - Optional: Credits/acknowledgments section

---

## 🎯 Implementation Priority

**Phase 1 (High Priority):**
1. Change Password - Security/user request feature
2. Transaction History - Transparency for purchases

**Phase 2 (Medium Priority):**
3. About Pink Flag - App Store best practice
4. Search History - User convenience

---

## 📝 Implementation Notes

### Database Tables Already Available:
- ✅ `searches` table exists (for Search History)
- ✅ `credit_transactions` table exists (for Transaction History)
- ✅ Supabase auth APIs available (for Change Password)

### No Database Changes Needed:
All required database infrastructure is already in place. Implementation only requires:
- Creating new screen widgets
- Adding navigation routes
- Implementing UI and business logic
- Writing queries to existing tables

---

## 🔍 Current Behavior

When users tap these features, they see a SnackBar message:
- "Transaction history - Coming soon"
- "Search history - Coming soon"
- "Change password - Coming soon"
- "About Pink Flag - Coming soon"

This is **intentional** and communicates to users that these features are planned but not yet available.

---

## ✅ Production Readiness

These placeholder features do **not** affect the app's production readiness:
- ✅ All core functionality works (authentication, search, purchases)
- ✅ App is fully functional without these features
- ✅ Clear user communication via "Coming soon" messages
- ✅ No broken navigation or crashes
- ✅ Standard practice for v1.0 releases

---

**Last Updated:** November 10, 2025
**Document Created:** Production refactoring (Option A)

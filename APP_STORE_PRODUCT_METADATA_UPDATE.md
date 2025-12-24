# App Store Connect - Product Metadata Update Guide

**Date**: December 19, 2025
**Updated**: December 22, 2025
**Purpose**: Update in-app purchase product titles/descriptions to reflect variable credit system (v1.2.0+)
**Status**: ✅ **COMPLETE** - All products updated in App Store Connect

---

## 🎯 Overview

**Problem**: Product metadata still shows old "Searches" terminology instead of new "Credits" system.

**Current State** (App Store Connect):
- Products say "3 Searches", "10 Searches", "25 Searches"
- Descriptions reference search counts, not credit amounts

**Desired State**:
- Products say "30 Credits", "100 Credits", "250 Credits"
- Descriptions explain variable cost per search type (name=10, phone=2, image=4)

---

## 📋 Product Updates Required

### Product 1: pink_flag_3_searches

**Current**:
- **Display Name**: "3 Searches"
- **Description**: "$1.99 for 3 Searches"

**Update To**:
- **Display Name**: "30 Credits"
- **Description**: "30 credits - 3 name searches OR 15 phone searches OR 7 image searches"

---

### Product 2: pink_flag_10_searches

**Current**:
- **Display Name**: "10 Searches"
- **Description**: "$4.99 for 10 Searches"

**Update To**:
- **Display Name**: "100 Credits"
- **Description**: "100 credits - 10 name searches OR 50 phone searches OR 25 image searches"

---

### Product 3: pink_flag_25_searches

**Current**:
- **Display Name**: "25 Searches"
- **Description**: "$9.99 for 25 Searches"

**Update To**:
- **Display Name**: "250 Credits"
- **Description**: "250 credits - 25 name searches OR 125 phone searches OR 62 image searches"

---

## 🛠️ Step-by-Step Instructions

### Step 1: Access App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Sign in with your Apple Developer account
3. Click **My Apps**
4. Select **Pink Flag**

### Step 2: Navigate to In-App Purchases
1. Click **Features** tab (left sidebar)
2. Click **In-App Purchases**
3. You should see 3 products listed:
   - `pink_flag_3_searches`
   - `pink_flag_10_searches`
   - `pink_flag_25_searches`

### Step 3: Update Each Product

**For EACH of the 3 products:**

1. Click on the product name to open details
2. Scroll to **Localization** section
3. Click **Edit** next to "English (U.S.)" (or your primary language)
4. Update the following fields:
   - **Display Name**: Use new name from table above
   - **Description**: Use new description from table above
5. Click **Save**
6. Repeat for all 3 products

### Step 4: Submit for Review (if required)

**Note**: Metadata-only changes may not require full app review, but check:

1. After updating all 3 products, check for any warnings/notifications
2. If Apple requires submission:
   - Click **Submit for Review**
   - Explain: "Updating product names to reflect variable credit system - no price or functionality changes"
3. If no submission needed:
   - Changes go live immediately ✅

### Step 5: Verify RevenueCat Sync

**Wait 2-4 hours**, then:

1. Go to RevenueCat Dashboard → Products
2. Verify product names synced from App Store Connect
3. If not synced, manually trigger: Dashboard → Settings → Sync

---

## ✅ Verification Checklist

After completing updates:

- [x] All 3 products updated in App Store Connect (Dec 22, 2025)
- [x] Display names show "Credits" (not "Searches")
- [x] Descriptions explain variable search costs
- [x] No errors or warnings in App Store Connect
- [x] Changes saved (no review required for metadata-only)
- [ ] RevenueCat dashboard reflects new product names (wait 2-4 hours)
- [ ] Test purchase in app shows new product names

---

## 📱 What Users Will See

**Before** (old metadata):
```
┌─────────────────────────────┐
│  🔍 25 Searches             │
│  $9.99 for 25 Searches      │
│  [Purchase]                 │
└─────────────────────────────┘
```

**After** (new metadata):
```
┌─────────────────────────────┐
│  💎 250 Credits             │
│  250 credits - 25 name      │
│  searches OR 125 phone      │
│  searches OR 62 image       │
│  searches                   │
│  $9.99                      │
│  [Purchase]                 │
└─────────────────────────────┘
```

---

## ⏱️ Expected Timeline

| Step | Time |
|------|------|
| Update products in App Store Connect | 10 minutes |
| Apple review (if required) | 1-2 days |
| RevenueCat sync | 2-4 hours |
| **Total** | **10 min - 2 days** |

---

## 🚨 Important Notes

### Product IDs Stay the Same
- **DO NOT** change product IDs (`pink_flag_*_searches`)
- Only update display names and descriptions
- Product IDs must match what's in your code/webhook

### Price Changes
- **DO NOT** change prices ($1.99, $4.99, $9.99)
- Price changes require full app review

### Multiple Localizations
If you support multiple languages:
- Update product metadata for each language
- Keep terminology consistent across all languages

---

## 🆘 Troubleshooting

### "Cannot Edit Product"
- Product may be in review state
- Wait for review to complete, then edit

### "Changes Require App Update"
- Metadata-only changes should NOT require app update
- If prompted, contact Apple Support

### RevenueCat Not Syncing
- Wait 4 hours, then manually trigger sync
- RevenueCat Dashboard → Settings → Sync Products

---

## 📊 Impact Assessment

### Before Fix:
- ❌ Users see "25 Searches" (confusing with variable costs)
- ❌ No indication that searches have different costs
- ❌ Unclear value proposition

### After Fix:
- ✅ Users see "250 Credits" (clear unit of currency)
- ✅ Description explains variable search costs
- ✅ Clear value: "25 name OR 125 phone OR 62 image"
- ✅ Informed purchase decisions

---

## 📞 Support

**Questions?**
- App Store Connect Help: https://developer.apple.com/contact/
- RevenueCat Docs: https://docs.revenuecat.com/docs/ios-products-and-entitlements

---

**Last Updated**: December 22, 2025
**Status**: ✅ **COMPLETE** - Product metadata updated
**Next Review**: After RevenueCat sync (2-4 hours from Dec 22, 2025)

---

## 📋 Completion Summary (December 22, 2025)

All 3 products successfully updated in App Store Connect:

✅ **pink_flag_3_searches**: Now shows "30 Credits" with usage examples
✅ **pink_flag_10_searches**: Now shows "100 Credits" with usage examples
✅ **pink_flag_25_searches**: Now shows "250 Credits" with usage examples

**Next Steps**:
1. Wait 2-4 hours for RevenueCat to sync the new product names
2. Test in production app - store screen should show updated names
3. Monitor user feedback for pricing clarity improvements
4. See `RELEASE_NOTES_v1.2.5.md` for complete documentation

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

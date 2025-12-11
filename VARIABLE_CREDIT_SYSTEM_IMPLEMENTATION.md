# Variable Credit System Implementation Plan
**Pink Flag v1.2.0 - Variable Credit Costs**

**Date Created:** 2025-12-04
**Status:** 🔄 In Progress
**Target Version:** v1.2.0

---

## 📋 Executive Summary

Implementing variable credit costs based on actual API expenses to ensure sustainable margins and fair pricing.

**Key Changes:**
- 10x credit multiplier (3 → 30, 10 → 100, 25 → 250)
- Variable search costs based on real API pricing
- Name searches are most expensive (Offenders.io costs $0.20/call)
- Phone searches are cheapest (Twilio costs $0.018/call)

---

## 💰 Cost Analysis

### Actual API Costs (Verified)

| API Provider | Cost per Call | Notes |
|--------------|---------------|-------|
| **Offenders.io** | $0.20 | After 50 free searches/month |
| **TinEye** | $0.04 | $200 for 5,000 searches |
| **Twilio** | $0.018 | Line Type + Caller Name |

### Revenue per Credit

**100-credit package ($4.99):**
- Gross: $4.99
- Apple's 30% cut: -$1.50
- Net revenue: $3.49
- **Per credit: $0.0349**

---

## 🎯 New Credit System

### Credit Packages (10x Multiplier)

| Old Package | New Package | Price | Cost/Credit |
|-------------|-------------|-------|-------------|
| 3 searches | **30 credits** | $1.99 | $0.0466 |
| 10 searches | **100 credits** | $4.99 | $0.0349 |
| 25 searches | **250 credits** | $9.99 | $0.0279 |

### Variable Search Costs (FINAL - User-Friendly Pricing)

| Search Type | Credits | User Pays (gross) | Net Revenue (70%) | API Cost | Profit | Margin |
|-------------|---------|-------------------|-------------------|----------|--------|--------|
| **Name Search** | 10 | $0.50 | $0.35 | $0.20 | $0.15 | 43% ⚠️ |
| **Phone Search** | 2 | $0.10 | $0.07 | $0.018 | $0.05 | 74% ✅ |
| **Image Search** | 4 | $0.20 | $0.14 | $0.04 | $0.10 | 71% ✅ |

**Note:** Using Option A - charge consistent rates regardless of Offenders.io free tier

**⚠️ Margin Warning:** Name search has thin 43% margin. Monitor Offenders.io pricing closely.

---

## 📊 Impact Analysis

### Example User Journey (100-credit package - $4.99)

**Old System:**
- 100 searches total (any type)
- If all name searches: $20.00 API cost → **LOSING MONEY**
- If all phone searches: $1.80 API cost → $1.69 profit (48%)

**New System (User-Friendly Pricing):**
- 10 name searches (100 credits) = $2.00 API cost → $1.49 profit (43%)
- 25 image searches (100 credits) = $1.00 API cost → $2.49 profit (71%)
- 50 phone searches (100 credits) = $0.90 API cost → $2.59 profit (74%)

**Result:** Sustainable margins with much better user value.

---

## 🚀 Implementation Checklist

### Phase 1: Backend Updates ✅

**Files to Update:**
- [x] `backend/services/credit_service.py` - Add support for variable costs
- [x] `backend/routers/search.py` - Changed cost=1 to cost=10
- [x] `backend/routers/phone_lookup.py` - Changed cost=1 to cost=2
- [x] `backend/routers/image_search.py` - Changed cost=1 to cost=4

**Database Changes:**
- [x] Migration script to multiply existing credits by 10

### Phase 2: Frontend Updates 📱

**Purchase Package Updates:**
- [x] `safety_app/lib/models/purchase_package.dart`
  - Updated mock packages: 30, 100, 250 credits
  - Updated searchCount logic
- [ ] Update RevenueCat product IDs (if needed)

**UI Updates:**
- [x] App config updated with credit costs (10/2/4)
- [ ] Search screen - show credit cost per search type
- [ ] Results screen - show credits deducted
- [ ] Settings screen - show credit balance prominently
- [ ] Add tooltips explaining variable costs

### Phase 3: Documentation 📚

- [x] Update README.md with new credit costs
- [ ] Update API documentation
- [ ] Create user-facing FAQ about credit costs
- [ ] Update App Store description

### Phase 4: Testing 🧪

- [ ] Test name search (10 credits deducted)
- [ ] Test phone search (2 credits deducted)
- [ ] Test image search (4 credits deducted)
- [ ] Test insufficient credits scenarios
- [ ] Test credit refunds for failed searches
- [ ] Verify existing user credits migrated correctly

---

## 🔄 Migration Strategy

### Existing User Credits

**Option A: Instant Migration (Recommended)**
- Run SQL script to multiply all user credits by 10
- Users with 5 credits → 50 credits
- No change in purchasing power

**Option B: Gradual Migration**
- Old credits work at old rates until depleted
- New purchases use new system
- More complex to implement

**Recommendation:** Use Option A for simplicity

### Migration SQL

```sql
-- Multiply all existing user credits by 10
UPDATE profiles
SET credits = credits * 10,
    updated_at = NOW()
WHERE credits > 0;

-- Add migration log entry
INSERT INTO credit_transactions (
  user_id,
  transaction_type,
  credits,
  status,
  provider,
  created_at
)
SELECT
  user_id,
  'system_migration',
  credits * 0.9, -- 90% of new balance (the added amount)
  'completed',
  'credit_system_v2_migration',
  NOW()
FROM profiles
WHERE credits > 0;
```

---

## 📱 UI/UX Changes

### Search Screen Updates

**Before:**
```
🔍 Name Search
Cost: 1 credit
```

**After:**
```
🔍 Name Search
Cost: 10 credits (comprehensive background check)
📞 Phone Search
Cost: 2 credits (quick caller ID lookup)
🖼️ Image Search
Cost: 4 credits (reverse image verification)
```

### Purchase Screen Updates

**Before:**
```
10 Searches - $4.99
Best Value!
```

**After:**
```
100 Credits - $4.99
10 name searches OR 50 phone searches OR 25 image searches
Best Value!
```

### Credit Balance Display

**Prominent display:**
```
💎 150 credits
≈ 15 name searches OR 75 phone searches OR 37 image searches
```

---

## ⚠️ Risks & Mitigation

### Risk 1: User Confusion
**Risk:** Users don't understand why searches cost different amounts
**Mitigation:**
- Clear tooltips explaining value
- "Learn More" link in app
- FAQ page on website

### Risk 2: Existing Users Feel Cheated
**Risk:** Users think their credits are worth less
**Mitigation:**
- 10x migration maintains purchasing power
- Clear communication: "Your 5 credits are now 50 credits!"

### Risk 3: Backend Refund Logic
**Risk:** Refunds need to return correct credit amounts
**Mitigation:**
- `refund_credit_for_failed_search` already supports `p_amount` parameter
- Just pass the cost amount when calling refund

---

## 🎯 Success Metrics

**Financial:**
- Maintain >70% profit margin on all search types
- Reduce API cost as % of revenue
- Zero loss-making searches

**User Behavior:**
- Monitor which search types users prefer
- Track credit purchase patterns
- Watch for complaints about pricing

**Technical:**
- Zero credit calculation errors
- All refunds work correctly
- Database migration completes successfully

---

## 📅 Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| **Planning & Documentation** | 1 hour | ✅ Complete |
| **Backend Implementation** | 2 hours | 🔄 In Progress |
| **Frontend Implementation** | 3 hours | ⏳ Pending |
| **Database Migration** | 30 min | ⏳ Pending |
| **Testing** | 2 hours | ⏳ Pending |
| **Documentation Updates** | 1 hour | ⏳ Pending |
| **App Store Update** | 1 week | ⏳ Pending |

**Total Estimated Time:** 9.5 hours development + 1 week review

---

## 🚦 Rollout Plan

### Stage 1: Development (This Session)
- Implement backend changes
- Update frontend UI
- Run database migration in dev

### Stage 2: Testing (Next Session)
- Comprehensive testing on simulator
- Test all search types
- Verify refunds work correctly

### Stage 3: Staging Deploy
- Deploy to Fly.io staging
- Test with real APIs
- Verify RevenueCat webhook still works

### Stage 4: Production Deploy
- Deploy backend to production
- Submit app to App Store
- Announce changes to users

---

## 📞 Communication Plan

### In-App Messaging
```
🎉 Credit System Update!

We've updated our credit system to be more fair and transparent:

• Name Search: 10 credits (comprehensive background check)
• Image Search: 4 credits (reverse image lookup)
• Phone Search: 2 credits (caller ID lookup)

Don't worry - we've multiplied your existing credits by 10,
so your purchasing power remains the same!

Learn More →
```

### Email to Existing Users (Optional)
- Explain the change
- Reassure them about credit migration
- Highlight improved sustainability

---

## 🔗 Related Files

**Backend:**
- `backend/services/credit_service.py`
- `backend/routers/search.py`
- `backend/routers/phone_lookup.py`
- `backend/routers/image_search.py`

**Frontend:**
- `safety_app/lib/models/purchase_package.dart`
- `safety_app/lib/services/purchase_handler.dart`
- `safety_app/lib/screens/search_screen.dart`
- `safety_app/lib/screens/settings_screen.dart`

**Database:**
- `schemas/VARIABLE_CREDIT_MIGRATION.sql` (new)

---

## ✅ Definition of Done

Feature is complete when:
- [ ] All backend endpoints use correct credit costs
- [ ] Purchase packages show 30/100/250 credits
- [ ] UI displays cost before each search
- [ ] Existing credits migrated successfully
- [ ] All tests pass
- [ ] Documentation updated
- [ ] App Store submission ready

---

**Last Updated:** 2025-12-04
**Next Review:** After implementation
**Owner:** Development Team

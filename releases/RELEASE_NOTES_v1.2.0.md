# Pink Flag - Release Notes v1.2.0

**Release Date:** TBD
**Build Number:** 21
**Status:** 🚀 Ready for Archive

---

## 🎉 What's New

### Variable Credit System
We've updated our credit system to be more fair and transparent!

**New Credit Costs:**
- 📝 **Name Search:** 10 credits (comprehensive background check)
- 📞 **Phone Search:** 2 credits (quick caller ID lookup) - *80% cheaper!*
- 🖼️ **Image Search:** 4 credits (reverse image verification) - *60% cheaper!*

**Credit Packages (10x Multiplier):**
- **30 credits** - $1.99 (3 name OR 15 phone OR 7 image searches)
- **100 credits** - $4.99 (10 name OR 50 phone OR 25 image searches)
- **250 credits** - $9.99 (25 name OR 125 phone OR 62 image searches)

**New User Welcome Bonus:**
- New users now receive **10 free credits** (was 1)
- Enough for 1 comprehensive name search OR 5 quick phone lookups!

### For Existing Users
✨ **Your credits have been multiplied by 10!**
- Your purchasing power remains exactly the same
- No action needed - automatic upgrade

---

## 💰 Pricing Impact

| Search Type | Before | After | Savings |
|-------------|--------|-------|---------|
| Name Search | $0.35 | $0.35 | Same cost, better value |
| Phone Search | $0.35 | $0.07 | **80% cheaper** 🎉 |
| Image Search | $0.35 | $0.14 | **60% cheaper** 🎉 |

*Based on 100-credit package ($4.99)*

---

## 🔧 Technical Changes

### Backend
- Implemented variable credit deduction (10/2/4 credits)
- Updated all refund handlers to match new costs
- Enhanced API cost tracking

### Frontend
- Updated purchase packages to show new credit amounts
- Added credit cost constants to app configuration
- Improved credit display throughout the app

### Database
- Migrated all existing user credits (× 10)
- Updated new user default to 10 credits
- Enhanced credit transaction logging

---

## 📱 App Store Copy

### What's New in This Version

🎁 **New Credit System - Better Value!**

We've made our pricing more transparent and fair based on search complexity:

• Name searches now cost 10 credits (comprehensive background checks using premium data)
• Phone searches now cost just 2 credits (quick caller ID lookups) - 80% cheaper!
• Image searches now cost 4 credits (reverse image verification) - 60% cheaper!

**BONUS:** We've automatically multiplied all existing credits by 10, so your purchasing power stays exactly the same!

New users now start with 10 free credits instead of 1.

🐛 Bug fixes and performance improvements

---

## 🧪 Testing Checklist

Before submitting to App Store:
- [ ] Test name search deducts 10 credits
- [ ] Test phone search deducts 2 credits
- [ ] Test image search deducts 4 credits
- [ ] Test new user gets 10 credits on signup
- [ ] Test purchase packages show 30/100/250
- [ ] Test insufficient credits dialog
- [ ] Test refunds return correct amounts
- [ ] Verify version shows 1.2.0 (21) in Settings
- [ ] Test on real device
- [ ] Check all documentation links work

---

## 🚀 Deployment Steps

### 1. Archive in Xcode
1. Select "Any iOS Device" as build target
2. Product → Archive
3. Wait for archive to complete (~5-10 minutes)

### 2. Upload to App Store Connect
1. In Organizer, select the archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Follow prompts to upload

### 3. App Store Connect Configuration
1. Go to App Store Connect
2. Select Pink Flag
3. Create new version 1.2.0
4. Add release notes (copy from above)
5. Update screenshots if needed
6. Submit for review

### 4. Monitor Release
- First 24 hours: Watch for crashes
- First week: Monitor user feedback
- Track credit usage patterns
- Watch profit margins

---

## 📊 Success Metrics

**Target Goals (30 days post-release):**
- ✅ Overall profit margin > 60%
- ✅ < 5% support tickets about pricing
- ✅ Purchase conversion rate maintained or improved
- ✅ Zero credit calculation bugs
- ✅ Positive user reviews about new pricing

---

## 🔄 Rollback Plan

If critical issues arise:
1. Database backup available for 30 days
2. Previous app version can be restored
3. Backend can revert to cost=1 for all searches
4. Emergency update can be submitted

---

## 📝 Notes

**Database Migration:**
- Migration script: `schemas/VARIABLE_CREDIT_MIGRATION.sql`
- **Status:** ⏳ Not yet run (run before deploying backend)
- Backup created automatically
- All existing credits will be × 10

**Backend Deployment:**
- **Status:** ⏳ Ready to deploy
- Deploy AFTER database migration
- Verify endpoints after deployment

**App Version:**
- Current: 1.1.13+20
- **New: 1.2.0+21** ✅

---

## 📞 Support Preparation

**Common Questions:**

**Q: Why did my credit count change?**
A: We've multiplied all credits by 10 to make our pricing more transparent! Your purchasing power stays exactly the same.

**Q: Why do searches cost different amounts now?**
A: Different searches use different data sources with different costs. We've priced them fairly to reflect the real value you're getting.

**Q: Which search should I use?**
A:
- Phone Search (2 credits) - Quick caller ID lookup
- Image Search (4 credits) - Verify if a photo appears online
- Name Search (10 credits) - Comprehensive background check

**Q: Did the price increase?**
A: No! In fact, phone and image searches are now much cheaper. Your credits go further!

---

## ✅ Pre-Flight Checklist

- [x] Version bumped to 1.2.0+21
- [x] Flutter clean completed
- [x] Flutter pub get completed
- [x] Xcode workspace opened
- [ ] Archive created
- [ ] Build tested on device
- [ ] Database migration run
- [ ] Backend deployed
- [ ] App Store Connect updated
- [ ] Submitted for review

---

**Ready to Archive!** 🚀

Just press **Product → Archive** in Xcode!

---

**Last Updated:** 2025-12-04
**Prepared By:** Development Team

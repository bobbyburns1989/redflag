# FBI Wanted Integration - Testing Guide

**Version**: 1.2.0 (In Development)
**Date**: November 28, 2025
**Status**: Ready for Testing ✅

---

## ✅ Pre-Testing Checklist

- ✅ Database schema applied (`ENHANCED_SEARCH_SCHEMA.sql`)
- ✅ Code compiles successfully (only 1 minor warning)
- ✅ Dependencies installed (`url_launcher` already present)
- ✅ FBI Wanted model created
- ✅ Search service updated
- ✅ Results screen UI updated
- ✅ Warning banner implemented

---

## 🧪 Test Scenarios

### Test 1: Search with FBI Match (Expected: Warning Banner)

**Test Name**: "John Dimitrion"

**Steps**:
1. Open Pink Flag app
2. Go to Name Search tab
3. Enter:
   - First Name: `John`
   - Last Name: `Dimitrion`
4. Tap "Search" (1 credit will be deducted)
5. Wait for results screen

**Expected Result**:
- ✅ Red gradient warning banner appears at TOP of results
- ✅ Shows "⚠️ FBI MOST WANTED" title
- ✅ Displays FBI wanted photo (if available)
- ✅ Shows "White-Collar Crime" category badge
- ✅ Displays reward amount ("Up to $10,000")
- ✅ "View FBI Details" button is visible
- ✅ Disclaimer text at bottom

**What to Check**:
- Banner animation (should fade in and slide down)
- Photo loads correctly
- Text is readable (white on red gradient)
- Button is clickable

---

### Test 2: View FBI Details Dialog

**Prerequisites**: Complete Test 1 first

**Steps**:
1. From results screen with FBI warning banner
2. Tap "View FBI Details" button

**Expected Result**:
- ✅ Dialog opens with full details
- ✅ Shows name: "JOHN MICHAEL DIMITRION"
- ✅ Shows aliases (if any)
- ✅ Shows physical description:
  - Sex: Male
  - Height: 5'7"
  - Weight: 185-200 lbs
  - Hair: Black
  - Eyes: Brown
- ✅ Shows date of birth
- ✅ Shows case summary
- ✅ "View on FBI.gov" button present

**What to Check**:
- All fields display correctly
- Dialog is scrollable
- "Close" button works
- Dialog has proper title with warning icon

---

### Test 3: FBI.gov Link

**Prerequisites**: Complete Test 2 first

**Steps**:
1. From FBI details dialog
2. Tap "View on FBI.gov" button

**Expected Result**:
- ✅ External browser opens
- ✅ FBI.gov wanted poster page loads
- ✅ URL is: `https://www.fbi.gov/wanted/wcc/john-michael-dimitrion`
- ✅ App remains in background (doesn't close)

**What to Check**:
- Link opens in Safari (iOS) or default browser
- FBI website loads successfully
- No app crashes

---

### Test 4: Search with NO FBI Match (Expected: No Warning)

**Test Name**: "Jane Smith"

**Steps**:
1. Go back to search screen
2. Enter:
   - First Name: `Jane`
   - Last Name: `Smith`
3. Tap "Search" (1 credit)
4. Wait for results

**Expected Result**:
- ✅ NO FBI warning banner appears
- ✅ Only shows sex offender results (if any)
- ✅ Normal results screen
- ✅ No red warning

**What to Check**:
- Banner is completely absent (not just hidden)
- Results screen looks normal
- No FBI-related UI elements visible

---

### Test 5: FBI API Graceful Failure

**Test Scenario**: FBI API is down or slow

**Steps**:
1. Turn OFF WiFi and cellular data
2. Try searching "John Dimitrion"
3. Wait for results

**Expected Result**:
- ✅ Search FAILS gracefully
- ✅ User sees error message about network
- ✅ Credit is REFUNDED (v1.1.7 refund system)
- ✅ App doesn't crash

**What to Check**:
- Error message is user-friendly
- No technical stack traces shown
- Refund appears in transaction history

---

### Test 6: Database Tracking

**Prerequisites**: Complete several searches (with and without FBI matches)

**Steps**:
1. Open Supabase dashboard
2. Go to Table Editor → `searches` table
3. Check recent searches

**Expected Result**:
- ✅ `fbi_match` column exists
- ✅ `fbi_match` = TRUE for "John Dimitrion" search
- ✅ `fbi_match` = FALSE for "Jane Smith" search
- ✅ Timestamps are correct
- ✅ User ID is tracked

**SQL Query to Run**:
```sql
SELECT
  id,
  user_id,
  query,
  fbi_match,
  created_at
FROM searches
ORDER BY created_at DESC
LIMIT 10;
```

---

## 🎯 Success Criteria

All tests must pass:
- ✅ FBI warning banner displays for matches
- ✅ No banner for non-matches
- ✅ Details dialog works
- ✅ FBI.gov link opens
- ✅ Database tracks matches correctly
- ✅ No crashes or errors
- ✅ Graceful degradation works
- ✅ Same 1 credit cost

---

## 🐛 Known FBI API Quirks

1. **Common Names Return Many Results**:
   - "John" returns 46+ matches
   - We take the FIRST active wanted person
   - This is intentional (better safe than sorry)

2. **"Located" Persons Filtered Out**:
   - FBI API includes already-caught persons
   - We filter `status = 'located'`
   - Only show active fugitives

3. **"Information" Posters Filtered**:
   - FBI has "seeking information" posters (not wanted persons)
   - We filter `poster_classification = 'information'`
   - Only show actual wanted criminals

4. **Null Fields**:
   - FBI API has many optional fields
   - All fields defensively parsed
   - Missing data shows as blank (not error)

---

## 📊 Analytics to Monitor

After testing, check these metrics in Supabase:

```sql
-- FBI match rate
SELECT
  COUNT(*) FILTER (WHERE fbi_match = TRUE) as fbi_matches,
  COUNT(*) as total_searches,
  (COUNT(*) FILTER (WHERE fbi_match = TRUE)::FLOAT / COUNT(*) * 100) as match_rate
FROM searches
WHERE created_at > NOW() - INTERVAL '1 day';
```

**Expected**:
- FBI match rate: < 1% (most searches won't match)
- If rate is high, check if filtering is working

---

## 🔍 Debugging Tips

### If FBI Banner Doesn't Appear:

1. **Check search_service.dart line 76**:
   ```dart
   _checkFBIWanted(firstName, lastName),
   ```
   - Verify this line is executing

2. **Add debug print**:
   ```dart
   final fbiResult = results[1] as FBIWantedResult;
   print('FBI Result: ${fbiResult.isMatch}'); // Add this
   ```

3. **Check FBI API directly**:
   ```bash
   curl "https://api.fbi.gov/wanted/v1/list?title=John%20Dimitrion"
   ```

### If Dialog Doesn't Open:

1. **Check results_screen.dart line 536**:
   ```dart
   onPressed: () => _showFBIDetails(fbiResult),
   ```

2. **Check for navigation context issues**

### If FBI.gov Link Doesn't Work:

1. **Verify url_launcher installed**:
   ```bash
   flutter pub get
   ```

2. **Check iOS Info.plist** (may need LSApplicationQueriesSchemes)

3. **Try different launch mode**:
   ```dart
   await launchUrl(url, mode: LaunchMode.inAppBrowserView);
   ```

---

## 📝 Test Results Template

Copy this and fill in results:

```
FBI INTEGRATION TEST RESULTS
Date: [DATE]
Tester: [NAME]
Device: [iOS/Android VERSION]

Test 1 - FBI Match Search: [ ] PASS / [ ] FAIL
  Notes: _______________________

Test 2 - Details Dialog: [ ] PASS / [ ] FAIL
  Notes: _______________________

Test 3 - FBI.gov Link: [ ] PASS / [ ] FAIL
  Notes: _______________________

Test 4 - No Match Search: [ ] PASS / [ ] FAIL
  Notes: _______________________

Test 5 - Graceful Failure: [ ] PASS / [ ] FAIL
  Notes: _______________________

Test 6 - Database Tracking: [ ] PASS / [ ] FAIL
  Notes: _______________________

Overall Status: [ ] APPROVED / [ ] NEEDS FIXES

Issues Found:
1. _______________________
2. _______________________
3. _______________________
```

---

## 🚀 Next Steps After Testing

### If All Tests Pass ✅:
1. Update version to 1.2.0+14 (Week 1 complete!)
2. Create release notes
3. Commit changes
4. (Optional) Proceed to Week 2: License Verification

### If Issues Found ❌:
1. Document issues in template above
2. Prioritize critical vs. minor bugs
3. Fix issues
4. Re-test

---

## 💡 Additional Test Cases (Optional)

### Edge Cases:

1. **Long Names**: Search "Alexander Maximilian Von Rothschild"
   - Check text truncation in banner

2. **Special Characters**: Search "O'Brien"
   - Check URL encoding

3. **Multiple Searches**: Run 5+ searches rapidly
   - Check for rate limiting
   - Check parallel execution doesn't break

4. **Low Credit**: Search with only 1 credit left
   - Verify FBI check still runs
   - Verify refund works if API fails

---

## 🎨 UI/UX Checklist

- [ ] Warning banner is eye-catching (red gradient)
- [ ] Text is legible (white on dark red)
- [ ] Photo displays at good quality
- [ ] Button is easy to tap (44pt touch target)
- [ ] Animation is smooth (not jarring)
- [ ] Disclaimer is visible and clear
- [ ] Dialog is easy to read
- [ ] FBI.gov link is obvious
- [ ] Works on small screens (SE/Mini)
- [ ] Works on large screens (Pro Max/Plus)
- [ ] Dark mode compatible (if enabled)

---

## 📞 Support Info

**If you encounter issues**:
1. Check Flutter console for errors
2. Check Xcode console for iOS-specific errors
3. Check Supabase logs for database errors
4. Check FBI API status: https://api.fbi.gov/wanted/v1/list

**FBI API Documentation**:
- Base URL: https://api.fbi.gov/wanted/v1
- No authentication required
- No rate limits
- Always returns JSON

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com)

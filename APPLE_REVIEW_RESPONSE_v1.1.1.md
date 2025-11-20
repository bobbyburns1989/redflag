# Response to Apple App Review - v1.1.1

**Submission ID**: 17008210-0396-4953-ba1b-d16471112c8c
**Review Date**: November 18, 2025
**Issue**: Guideline 5.1.1 - Legal - Privacy - Data Collection and Storage

---

## 📧 RESPONSE TO SEND IN APP STORE CONNECT

**Copy this into the "Reply to App Review" section:**

```
Hello,

Thank you for your continued feedback on Pink Flag. We understand your concern regarding Guideline 5.1.1 and have made significant changes to address this issue.

WHAT WE HAVE CHANGED IN VERSION 1.1.1:

We have completely removed the search history feature that was storing search data locally on the device. The app no longer stores, collects, or saves any search information whatsoever.

Previous version (1.0.4):
• Stored search history locally on device using Hive database
• User could review past searches
• Search results were saved to device storage

New version (1.1.1 - being submitted now):
• No search history feature - completely removed from codebase
• No local storage of search data - Hive dependency removed entirely
• Search results are displayed temporarily and immediately discarded when user navigates away
• No data about searched individuals is stored anywhere (local or remote)

HOW THE APP NOW FUNCTIONS:

Pink Flag is a search tool that queries publicly available government sex offender registries (maintained by state and federal agencies under Megan's Law) and temporarily displays results to users. The app functions similarly to using a web browser to access these public government websites.

1. User enters a name/location
2. App queries public government registry API
3. Results are displayed on screen temporarily
4. User navigates away → results are immediately discarded
5. Nothing is saved or stored

WHAT WE STORE:
• User email and hashed password (authentication only)
• Search credit balance (for in-app purchase tracking only)

WHAT WE DO NOT STORE:
• Search queries or search history
• Search results or offender information
• Any personally identifiable information about searched individuals
• No aggregated data from public sources
• No profile building of any kind

CLARIFICATION ON "BUILDING PROFILES":

We respectfully want to clarify that Pink Flag does not "build individual profiles" as stated in the rejection. The app queries existing public government databases that are legally required to be accessible under federal and state Megan's Law statutes. We do not:

• Collect data from multiple sources and aggregate it
• Create new profiles or dossiers on individuals
• Store or save any information about searched individuals
• Combine data from different sources
• Track or monitor individuals over time

The app simply provides a mobile interface to search publicly accessible government registries, similar to how a web browser accesses public websites. The information displayed comes entirely from official government sources and is shown temporarily without any storage or processing.

SIMILAR APPS ON THE APP STORE:

There are several similar apps currently available on the iOS App Store that provide access to public records databases, including:

• Family Watchdog (sex offender registry search)
• Offender Locator (registry search)
• Public records search apps
• Background check apps

These apps serve legitimate safety purposes by providing mobile access to legally public information.

OUR REQUEST:

We believe version 1.1.1 fully addresses the privacy concerns raised in your review. We have:

1. Removed all data storage related to searches
2. Made searches completely ephemeral (temporary display only)
3. Updated our app description to accurately reflect these changes
4. Updated our privacy policy to clarify what is and isn't stored

We respectfully request reconsideration of Pink Flag v1.1.1 for approval. The app serves a legitimate safety purpose by providing convenient mobile access to legally public government databases, without collecting, storing, or building any profiles.

If there are additional changes needed to comply with App Store guidelines, we would greatly appreciate specific guidance on what modifications would make the app acceptable for the App Store.

Would it be possible to schedule the phone call you offered to discuss this matter further? We want to ensure we fully understand your concerns and make any necessary changes to bring Pink Flag into compliance.

Thank you for your time and consideration.

Best regards,
Pink Flag Development Team
```

---

## 🔄 ALTERNATIVE: SHORTER VERSION

If you prefer a more concise response:

```
Hello,

Thank you for your feedback. We have made significant changes in version 1.1.1 to address Guideline 5.1.1:

CHANGES MADE:
• Completely removed search history feature
• Removed all local data storage (Hive dependency deleted)
• Search results now displayed temporarily only and immediately discarded
• No search information stored anywhere (local or remote)

HOW IT WORKS NOW:
Pink Flag queries publicly available government sex offender registries and temporarily displays results. When users navigate away, results are discarded. Nothing is saved.

CLARIFICATION:
The app does not "build profiles" - it provides mobile access to existing public government databases (required under Megan's Law), similar to using a web browser to access public websites. No data collection, aggregation, or storage occurs.

We believe v1.1.1 fully addresses your concerns. If additional changes are needed, please provide specific guidance. We would also appreciate the phone call you offered to discuss this further.

Thank you,
Pink Flag Team
```

---

## 📞 IF YOU WANT TO REQUEST THE PHONE CALL

Add this at the end of your response:

```
Additionally, we would like to request the phone call from Apple Review that you offered in your message. We believe a conversation would help us better understand your specific concerns and ensure we can bring Pink Flag into full compliance with App Store guidelines.

Please let us know your availability for a call within the next 3-5 business days.

Thank you.
```

---

## ⚠️ IMPORTANT NOTES

### Before Sending This Response:

1. **You MUST submit version 1.1.1** first (not 1.0.4)
   - The response references changes in v1.1.1
   - If you send this response but submit v1.0.4, it will be rejected again
   - Archive and upload v1.1.1 from Xcode (which is open and ready)

2. **Update the app description** in App Store Connect with the new description (from APPLE_REVIEW_SUBMISSION_v1.1.1.md)

3. **Add reviewer notes** when submitting v1.1.1 (copy from APPLE_REVIEW_SUBMISSION_v1.1.1.md)

### Timing:

**Option A**: Submit v1.1.1 first, then reply
1. Archive and upload v1.1.1 in Xcode
2. Update description in App Store Connect
3. Submit v1.1.1 for review
4. Send this response via "Reply to App Review"

**Option B**: Reply first to explain changes
1. Send this response via "Reply to App Review"
2. Immediately archive and upload v1.1.1
3. Submit v1.1.1 for review

I recommend **Option A** - submit v1.1.1 first, then send the response explaining the changes.

---

## 🎯 KEY ARGUMENTS IN THE RESPONSE

1. **Concrete Changes**: Specific list of what was removed
2. **How It Works Now**: Clear explanation of ephemeral nature
3. **Clarification**: Explains we don't "build profiles", just query existing public databases
4. **Legal Basis**: References Megan's Law (public registries are legally required)
5. **Comparison**: Notes similar apps exist on App Store
6. **Cooperative Tone**: Asks for guidance if more changes needed
7. **Request for Call**: Takes them up on their offer to discuss

---

## 🤔 REALISTIC EXPECTATIONS

**Honest Assessment**: There's a chance Apple may still reject this because:

- The core functionality (displaying offender information) may be what they consider "profile building"
- Even temporary display might violate their interpretation of the guideline
- They may have a blanket policy against sex offender registry apps

**If They Reject Again**, your options are:

1. **Appeal** - Request escalation to App Review Board
2. **Phone Call** - Discuss with Apple representative
3. **Pivot** - Change app to general safety resources (no search)
4. **Android Only** - Release on Google Play instead

But it's worth trying with v1.1.1 and this response first!

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

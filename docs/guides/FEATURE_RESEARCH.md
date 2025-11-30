# Pink Flag - Feature Research & Experimental Ideas

**Last Updated**: January 29, 2025
**Status**: Research & Planning Stage
**Priority**: Low (Post-v1.2)

---

## Overview

This document tracks experimental features, research findings, and potential future enhancements for Pink Flag. None of these features are currently implemented or in active development.

---

## 🚨 High-Priority Research

### 1. FBI Most Wanted API Integration

**Status**: ⏳ Testing in Progress
**Complexity**: Medium
**Value**: High
**Cost**: FREE

#### Overview
Integrate FBI's Most Wanted API to provide national-level offender data alongside state registries.

#### Research Findings
- **API**: `https://api.fbi.gov/wanted/v1/list`
- **Coverage**: National most wanted criminals
- **Rate Limit**: Unknown, needs testing
- **Data Quality**: High - official FBI data
- **Update Frequency**: Real-time

#### Implementation Challenges
- Data format differs from Offenders.io
- Need unified result format
- API reliability unknown
- May require separate search flow

#### Test Results
See: `FBI_API_TEST_RESULTS.md` and `FBI_TESTING_GUIDE.md` (in archive)

#### Next Steps
1. Test API reliability over 1 month
2. Design unified result format
3. Create feature flag for FBI integration
4. User testing with combined results

---

### 2. Enhanced Search Capabilities

**Status**: 📝 Design Phase
**Complexity**: High
**Value**: High
**Cost**: Development time only

#### Proposed Enhancements

**Multi-State Search**:
- Search all states simultaneously
- Aggregate results from multiple registries
- Challenge: API rate limits, cost

**Fuzzy Name Matching**:
- Handle misspellings (John vs Jon)
- Nickname matching (William → Bill)
- Challenge: False positives

**Advanced Filters**:
- Offense type categorization
- Registration date range
- Distance radius (currently ZIP-based)
- Challenge: Not all APIs support filters

#### Database Schema
See: `ENHANCED_SEARCH_SCHEMA.sql`

#### Implementation Plan
See: `ENHANCED_SEARCH_IMPLEMENTATION_PLAN.md` and `ENHANCED_SEARCH_PLAN_SUMMARY.md` (in archive)

---

## 💡 Medium-Priority Research

### 3. Marriage & Divorce Records Integration

**Status**: 🔍 Research Only
**Complexity**: Very High
**Value**: Medium
**Cost**: Varies by data provider

#### Research Summary
- **Public Records**: Varies by state, no unified API
- **Commercial APIs**: Expensive, inconsistent coverage
- **Legal Complexity**: Privacy laws differ by state
- **Data Quality**: Often outdated or incomplete

#### Challenges
- No free/affordable API found
- Legal compliance complex
- User demand unclear
- Integration difficult

#### Decision
**NOT RECOMMENDED** - Cost and complexity outweigh value

See archived research: `MARRIAGE_DIVORCE_RECORDS_RESEARCH.md`

---

### 4. Free Alternative Data Sources

**Status**: 🔍 Research Only
**Complexity**: High
**Value**: Low
**Cost**: FREE but unreliable

#### Evaluated Sources
1. **StateRegistry.com** - Free but inconsistent
2. **FamilyWatchdog.us** - Limited API access
3. **NSOPW.gov** - No official API
4. **Individual State APIs** - 50 different integrations

#### Findings
- Free sources lack APIs or documentation
- Data quality inferior to Offenders.io
- Maintenance burden too high
- Reliability concerns

#### Decision
**NOT RECOMMENDED** - Stick with Offenders.io

See archived research: `FREE_DATA_SOURCES_RESEARCH.md`

---

## 🔮 Low-Priority Ideas

### 5. Social Media Profile Search

**Concept**: Search for social media profiles linked to a person

**Challenges**:
- API access expensive/restricted
- Legal gray area
- Privacy concerns
- Rate limiting

**Status**: Idea only, not researched

---

### 6. Background Check Integration

**Concept**: Full background checks (criminal history, employment, etc.)

**Challenges**:
- Expensive ($30-100 per check)
- Requires more regulatory compliance
- Longer processing time (hours/days)
- Different user intent

**Status**: Out of scope for Pink Flag

---

### 7. Geolocation Alerts

**Concept**: Notify users when registered offenders are nearby

**Challenges**:
- Requires GPS permission
- Battery drain concerns
- Privacy implications
- Potential for harassment

**Status**: Ethically questionable, not pursuing

---

### 8. Community Reporting System

**Concept**: Allow users to report suspicious behavior

**Challenges**:
- Moderation workload high
- Legal liability concerns
- Potential for abuse
- False reports

**Status**: Requires significant resources, not feasible

---

## 📊 Research Priority Matrix

| Feature | Value | Complexity | Cost | Priority |
|---------|-------|-----------|------|----------|
| FBI API | High | Medium | FREE | HIGH ⭐ |
| Enhanced Search | High | High | Low | MEDIUM |
| Marriage Records | Medium | Very High | High | LOW ❌ |
| Free Data Sources | Low | High | FREE | LOW ❌ |
| Social Media | Medium | High | High | LOW |
| Background Checks | High | High | Very High | OUT OF SCOPE |
| Geolocation Alerts | Medium | Medium | Low | DECLINED |
| Community Reports | Low | Very High | Medium | DECLINED |

---

## 🎯 Recommended Next Steps

### Immediate (Next Sprint)
1. **FBI API Integration**
   - Continue reliability testing
   - Design unified result format
   - Create feature flag
   - User testing plan

### Short-Term (Next Quarter)
2. **Enhanced Search - Phase 1**
   - Fuzzy name matching research
   - Multi-state search feasibility study
   - Cost analysis for expanded API usage

### Long-Term (6+ Months)
3. **Advanced Features**
   - Subscription tier with unlimited searches
   - Premium features (multi-state, advanced filters)
   - API partnership negotiations

---

## 📚 Archived Research Documents

All detailed research has been moved to `docs/archive/`:

**FBI Integration**:
- `FBI_API_TEST_RESULTS.md`
- `FBI_INTEGRATION_PROGRESS.md`
- `FBI_TESTING_GUIDE.md`

**Enhanced Search**:
- `ENHANCED_SEARCH_IMPLEMENTATION_PLAN.md`
- `ENHANCED_SEARCH_PLAN_SUMMARY.md`
- `ENHANCED_SEARCH_SCHEMA.sql`

**Data Sources**:
- `FREE_DATA_SOURCES_RESEARCH.md`
- `MARRIAGE_DIVORCE_RECORDS_RESEARCH.md`

---

## 💬 Feature Requests

### User-Requested Features
- [ ] Save favorite searches
- [ ] Export results to PDF
- [ ] Share results with contacts
- [ ] Dark mode (UI, not feature research)
- [ ] Android version

### Tracking
Feature requests are tracked in:
- GitHub Issues (when implemented)
- User feedback emails
- App Store reviews

---

## 🚫 Features We Won't Build

**And Why:**

1. **Vigilante Tools** - Against app's ethical mission
2. **Location Tracking** - Privacy/harassment concerns
3. **Public Shaming** - Legal liability
4. **Unverified Data** - Accuracy requirements
5. **Profile Building** - Apple Guideline 5.1.1 violation

---

## 📝 Research Methodology

### How We Evaluate Features

**Criteria**:
1. **User Value**: Does it solve a real problem?
2. **Technical Feasibility**: Can we build it reliably?
3. **Legal Compliance**: Is it legal in all 50 states?
4. **Ethical Alignment**: Does it support safety without enabling harm?
5. **Cost/Benefit**: Is the ROI positive?
6. **Maintenance**: Can we support it long-term?

**Decision Framework**:
- All 6 criteria = High Priority ⭐
- 4-5 criteria = Medium Priority
- 2-3 criteria = Low Priority
- 0-1 criteria = Declined ❌

---

## 🔬 Ongoing Research

### Active Investigations
- None currently - focus on v1.2 core features

### Paused Research
- FBI API (awaiting stability confirmation)
- Enhanced Search (design phase)

### Abandoned Research
- Marriage records (too complex)
- Free data sources (quality issues)

---

## 📞 Submit Research Ideas

Have a feature idea? Document it here:

**Template**:
```markdown
### Feature Name

**Proposed By**: [Name/Email]
**Date**: [Date]
**Problem**: [What problem does this solve?]
**Solution**: [How would it work?]
**Value**: [Why is this important?]
**Challenges**: [What makes this difficult?]
```

---

## 📊 Success Metrics for Research

**How We Measure Research Success**:
- ✅ Clear go/no-go decision within 2 weeks
- ✅ Documented findings for future reference
- ✅ Cost analysis completed
- ✅ Technical feasibility confirmed
- ✅ Legal review completed (if needed)

---

**Remember**: Not every idea needs to be built. Good research often tells us what *not* to build.

---

**Built with ❤️ using Claude Code**

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

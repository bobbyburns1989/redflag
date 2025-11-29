# Marriage & Divorce Records API Research

**Date**: November 28, 2025
**Research Topic**: How to access marriage/divorce records for Pink Flag app
**Status**: Preliminary research complete

---

## Executive Summary

Marriage and divorce records are public records in most US states, but accessing them programmatically via API is challenging. Most providers target enterprise/law enforcement markets with custom pricing (quote-based), not consumer app developers.

### Key Findings:
- ✅ **Records Are Public**: Marriage/divorce records are generally public under FOIA
- ⚠️ **API Access Limited**: Few providers offer developer-friendly APIs
- 💰 **Pricing Opaque**: Most services require "contact sales" for pricing
- 🎯 **Enterprise Focus**: Services target law enforcement, legal firms, and enterprise
- 📊 **Data Completeness**: Coverage varies significantly by state/county

---

## API Provider Options

### 1. **Enformion** (Most Promising)

**Website**: https://go.enformion.com

**What They Offer**:
- Divorce Search API with comprehensive data
- Marriage Search API with records lookup
- Court Records API including family court data
- People Search API that includes marital status

**Data Available**:
- Marriage records: Names, dates, location, certificate numbers
- Divorce records: Petitioner/respondent names, filing dates, county
- Court records: Family court proceedings, legal filings

**Pricing**:
- ❌ Not publicly listed
- 💬 "Talk to Sales for premium product pricing"
- ✅ Free trial available

**Pros**:
- Dedicated marriage/divorce APIs
- Modern API infrastructure (likely RESTful)
- Free trial to test data quality
- B2B focused (may have flexible pricing)

**Cons**:
- No transparent pricing
- Requires sales contact
- Likely expensive for consumer app
- Unknown data coverage by state

**Integration Difficulty**: Medium
**Best For**: If budget allows and need comprehensive data

---

### 2. **Spokeo Business API**

**Website**: https://www.spokeo.com/business/api
**Contact**: apisupport@spokeo.com | (888) 585-2370

**What They Offer**:
- Contact enrichment API (phone, email, address, social)
- Property lookup API
- Identity verification capabilities
- Marriage/divorce records (as part of broader people search)

**Data Available**:
- 250M+ unique profiles
- Marital status as part of person profile
- Marriage/divorce history if available in public databases
- Related court records

**Pricing**:
- ❌ Not publicly listed
- 💬 Must contact API support team
- 📊 Likely usage-based (per lookup)

**Pros**:
- Modern API infrastructure
- Good documentation
- Developer-friendly support team
- Data enrichment beyond just marriage/divorce

**Cons**:
- Marriage/divorce not the primary focus
- May not have comprehensive divorce details
- No free tier mentioned
- Pricing unknown

**Integration Difficulty**: Low-Medium (good docs)
**Best For**: If you want multiple data points beyond just marriage/divorce

---

### 3. **BeenVerified API** (Limited Access)

**Website**: Google Form for API access request
**Status**: Limited release to qualifying developers

**What They Offer**:
- OAuth-based API
- Background check data including marriage/divorce
- Court records access
- Social media and dating profiles

**Data Available**:
- Marriage records when available
- Divorce records from public databases
- Associated court records
- Dating profile connections

**Pricing**:
- ❌ Not available (must qualify for API access first)
- 🔒 Limited release program

**Pros**:
- Comprehensive background data
- Marriage/divorce included in results
- OAuth security protocol

**Cons**:
- Very limited API access (must qualify)
- Application process required
- Unknown approval criteria
- Pricing completely opaque
- May prioritize enterprise customers

**Integration Difficulty**: High (limited access)
**Best For**: Not recommended unless you already have API access

---

### 4. **TLOxp (TransUnion)**

**Website**: https://www.tlo.com

**What They Offer**:
- 10,000+ public and proprietary databases
- Batch and API processing capabilities
- Marriage/divorce records as part of comprehensive searches
- Asset and relationship insights

**Data Available**:
- Marriage records
- Divorce records
- Bankruptcy records
- Property searches
- Comprehensive person data

**Pricing**:
- ❌ Not publicly listed
- 🏢 Enterprise/law enforcement focus
- 💰 Likely very expensive

**Pros**:
- Extremely comprehensive data (10,000+ sources)
- Daily database refreshes
- Batch processing capabilities
- TransUnion backing (trusted source)

**Cons**:
- Enterprise/law enforcement market
- Likely very expensive
- May require specific qualifications
- Overkill for simple marriage/divorce lookup
- Complex integration

**Integration Difficulty**: High
**Best For**: Enterprise apps with large budgets

---

### 5. **LexisNexis Public Records**

**Website**: https://www.lexisnexis.com/en-us/products/public-records.page

**What They Offer**:
- 84+ billion public records
- 10,000+ diverse source types
- Indexed marriage/divorce records from selected states
- Legal industry focus

**Data Available**:
- Marriage records (selected states/counties)
- Divorce records (selected states/counties)
- Court records
- Comprehensive legal data

**Pricing**:
- ❌ Subscription-based (not pay-per-lookup)
- 💰 Requires LexisNexis Agreement
- 🏢 Legal industry pricing (expensive)

**Pros**:
- Most comprehensive data available
- Trusted legal industry source
- High data quality and accuracy

**Cons**:
- Very expensive subscription model
- Legal industry focus (not consumer apps)
- Requires subscription agreement
- Overkill for consumer app needs
- Complex licensing

**Integration Difficulty**: Very High
**Best For**: Legal/enterprise applications only

---

### 6. **National Public Data** (Free, but unclear API)

**Website**: https://nationalpublicdata.com/marriage-divorce.html

**What They Offer**:
- Marriage and Divorce XML API mentioned
- Current and historical records
- Multiple state coverage
- Free people search (consumer facing)

**Data Available**:
- Marriage: Bride/groom names, ages, county, date, certificate numbers
- Divorce: Petitioner/respondent names, county, dates
- Historical records available

**Pricing**:
- ✅ Website claims "100% free"
- ❓ XML API pricing unclear
- ⚠️ Company history concerns (2024 data breach involving former owner)

**Pros**:
- Potentially free or very cheap
- XML API format mentioned
- Specific to marriage/divorce
- Historical data available

**Cons**:
- Company reputation issues (data breach history with previous owner)
- API documentation not found
- Data quality unknown
- Reliability concerns
- Current site is just a free directory (not commercial API service)

**Integration Difficulty**: Unknown (no docs found)
**Best For**: Risky - not recommended due to reliability/reputation concerns

---

### 7. **FastPeopleSearch** (Consumer Only)

**Website**: https://fastpeoplesearch.io

**What They Offer**:
- Free people search service
- Marriage and divorce records available
- Contact details, addresses, criminal records
- Public court records

**Data Available**:
- Marital status
- Divorce records from federal, state, county courts
- Related public records

**Pricing**:
- ✅ Basic search is 100% free
- 💰 Premium options may exist for deeper data

**Pros**:
- Free basic service
- Easy to access via website
- Divorce records specifically mentioned

**Cons**:
- ❌ No API found
- Consumer-facing only (not for developers)
- No commercial licensing
- Would require web scraping (not recommended/legal)

**Integration Difficulty**: N/A (no API)
**Best For**: Manual lookups only, not app integration

---

### 8. **VitalChek** (Government Official Records)

**Website**: https://www.vitalchek.com

**What They Offer**:
- Official government vital records ordering
- 450+ agencies trust VitalChek
- Birth, death, marriage, divorce certificates
- Powered by LexisNexis

**Data Available**:
- Official marriage certificates
- Official divorce decrees
- Government-issued documents

**Pricing**:
- 💰 $8.00 processing fee per transaction (example from NY)
- 💰 + State/county fees (varies)
- 💰 + $15.50 UPS return delivery (optional)

**Pros**:
- Official government documents
- Trusted by 450+ agencies
- Comprehensive state coverage

**Cons**:
- ❌ No API for developers
- Consumer ordering service only
- Fee per certificate (not scalable)
- Requires physical document delivery
- Not designed for app integration

**Integration Difficulty**: N/A (no API)
**Best For**: Ordering official documents, not programmatic access

---

## State/Government Direct Access

### PACER (Federal Courts)

**Website**: https://pacer.uscourts.gov

**What It Offers**:
- Public Access to Court Electronic Records
- Federal court records including divorce cases
- Electronic access to case information

**Pricing**:
- 💰 $0.10 per page
- 💰 $3.00 cap per document
- ✅ Free if quarterly charges < $30

**Pros**:
- Official federal court records
- Direct government access
- Low cost

**Cons**:
- Federal courts only (most divorces are state/county)
- Per-page pricing model
- No clean API (screen scraping would be needed)
- Limited to federal jurisdiction

**Integration Difficulty**: High (no formal API)
**Best For**: Federal court research, not typical divorce records

---

### State Vital Records Offices

**Access Method**: Direct state/county requests

**What's Available**:
- Official marriage licenses
- Official divorce decrees
- Birth/death certificates

**Pricing**:
- 💰 $10-$50 per certificate (varies by state)
- 💰 Processing fees
- 💰 Shipping costs

**Pros**:
- Official government records
- Legally valid documents
- Most authoritative source

**Cons**:
- ❌ No APIs (50 different state systems)
- Manual requests required
- Slow turnaround (days to weeks)
- Not scalable
- Fee per record

**Integration Difficulty**: Impossible (no APIs)
**Best For**: Individual record requests, not app integration

---

## Legal & Privacy Considerations

### Public Records Laws

**Federal**:
- ✅ Freedom of Information Act (FOIA) - Records must be publicly accessible
- ⚠️ Some restrictions for sensitive information

**State Level**:
- ✅ Most states consider marriage/divorce records public
- ⚠️ Some states limit access to protect personal information
- ⚠️ Varying levels of restriction by state

### Privacy Concerns

**What's Restricted**:
- Social Security Numbers (often redacted)
- Financial details in divorce settlements (may be sealed)
- Child custody information (often sealed)
- Domestic violence cases (often sealed or restricted)

**What's Public**:
- Names of parties
- Date of marriage/divorce
- Location (county/state)
- Basic case information

### FCRA Compliance

If using for background checks or employment, must comply with:
- Fair Credit Reporting Act (FCRA)
- Proper disclosure and consent
- Dispute resolution procedures
- Accuracy requirements

**Pink Flag Consideration**: Since Pink Flag is a safety app (not employment screening), FCRA may not fully apply, but ethical data usage still important.

---

## Cost Analysis

### Estimated Pricing Models

Based on industry research (not confirmed):

**Enterprise APIs** (TLOxp, LexisNexis):
- 💰 $10,000 - $50,000+ annual subscription
- 💰 + $0.50 - $5.00 per lookup
- 🏢 Minimum commitments likely

**B2B APIs** (Enformion, Spokeo):
- 💰 $500 - $5,000 setup fee (maybe)
- 💰 $0.25 - $2.00 per lookup (estimated)
- 📊 Volume-based pricing tiers

**Consumer Services** (BeenVerified, Intelius):
- 💰 $1.00 - $5.00 per search (retail)
- ❌ No documented API access

**Government Direct**:
- 💰 $10 - $50 per official certificate
- ❌ Not scalable

### For Pink Flag App

**Current Credit Pricing**:
- 1 credit = $0.66 - $0.99 (depending on package)
- 1 search = 1 credit

**Viability**:
- ✅ Could work if API cost is $0.25-$0.50 per lookup
- ⚠️ Tight margins if API cost is $1.00+
- ❌ Not viable if API cost is $2.00+

**Recommendation**: Negotiate volume pricing with Enformion or Spokeo

---

## Data Quality Considerations

### Coverage Completeness

**Factors Affecting Coverage**:
- State digitization levels (some states more digitized than others)
- County participation in databases
- Historical vs. recent records (recent records more complete)
- Rural vs. urban areas (urban areas better covered)

**Expected Coverage**:
- ✅ Major metros: 80-95% coverage
- ⚠️ Medium cities: 60-80% coverage
- ❌ Rural counties: 30-60% coverage
- 📊 Historical records (pre-2000): Spotty

### Data Freshness

**Update Frequency**:
- Enterprise APIs (TLOxp): Daily updates
- B2B APIs (Enformion): Weekly to daily
- Consumer APIs: Monthly to weekly
- Free sources: Varies widely

**Lag Time**:
- Recent marriages/divorces: 30-90 days typical
- Some records appear in days
- Some take 6+ months

---

## Integration Recommendations

### Recommended Approach

**Phase 1: Research & Testing** (Current)
1. ✅ Contact Enformion for API access and pricing quote
2. ✅ Contact Spokeo Business API team for pricing
3. ✅ Request free trials from both
4. ✅ Compare data quality, coverage, and cost

**Phase 2: Pilot Integration** (If pricing works)
1. Build marriage/divorce search service (similar to phone_search_service.dart)
2. Integrate chosen API
3. Add to 4th tab in search screen (Name | Phone | Image | Records)
4. Test with beta users
5. Monitor usage and costs

**Phase 3: Production** (If viable)
1. Negotiate volume pricing based on usage data
2. Implement credit refund system (already built for v1.1.7!)
3. Launch to all users
4. Track ROI and user satisfaction

### Technical Integration

**Estimated Implementation Time**: 8-12 hours

**Files to Create**:
- `lib/models/marriage_divorce_result.dart` (150 lines)
- `lib/services/marriage_divorce_service.dart` (300 lines with refund logic)
- `lib/screens/marriage_divorce_results_screen.dart` (400 lines)

**Files to Modify**:
- `lib/screens/search_screen.dart` (add 4th tab)
- `lib/config/app_config.dart` (add API key)
- Database schema (add marriage_divorce search type)

**Reusable Code**:
- ✅ Credit deduction system (already built)
- ✅ Refund logic pattern (already built for v1.1.7)
- ✅ Search history tracking (already built)
- ✅ Transaction history UI (already built)

---

## Alternatives to Consider

### Option 1: Skip Marriage/Divorce, Focus on Criminal Records

**Rationale**:
- Criminal records more relevant to safety app mission
- May be cheaper to access
- Higher user value for safety screening

**Providers**:
- FastPeopleSearch already provides this (via Offenders.io backend)
- Could enhance existing name search results

### Option 2: Partner with Existing Background Check Service

**Approach**:
- White-label existing service (BeenVerified, Spokeo, etc.)
- Revenue share model
- They handle all data sourcing

**Pros**:
- No API integration needed
- No data sourcing costs
- Professional UX

**Cons**:
- Less control over UX
- Revenue sharing reduces margins
- User leaves your app

### Option 3: Manual Request Service

**Approach**:
- Users request specific records
- Manual fulfillment by team
- Higher price point (5-10 credits)

**Pros**:
- No API costs
- Can source from government directly
- Official documents

**Cons**:
- Not scalable
- Slow turnaround
- Manual labor intensive

---

## Risk Assessment

### Technical Risks

**API Reliability**:
- ⚠️ Phone lookup API (Sent.dm) currently down (503)
- ⚠️ Additional API = additional failure points
- ✅ Refund system mitigates this (v1.1.7)

**Data Quality**:
- ⚠️ Coverage varies by state/county
- ⚠️ Users may expect results that don't exist
- ⚠️ False negatives could damage trust

### Business Risks

**Cost Uncertainty**:
- ⚠️ No transparent pricing = hard to forecast costs
- ⚠️ Minimum commitments may be required
- ⚠️ Volume pricing changes could hurt margins

**User Demand**:
- ❓ Is there demand for marriage/divorce records in safety app?
- ❓ Do users care more about criminal history?
- ❓ Will users pay extra credits for this feature?

### Legal Risks

**Permissible Use**:
- ⚠️ Some API providers restrict consumer app use
- ⚠️ Terms of service may prohibit certain uses
- ⚠️ Must comply with privacy laws (CCPA, GDPR for EU users)

**Liability**:
- ⚠️ Inaccurate data could lead to liability
- ⚠️ Stalking/harassment concerns (need proper disclaimers)
- ⚠️ FCRA compliance if data used for decisions

---

## Next Steps

### Immediate Actions (This Week)

1. **Contact Enformion**
   - Request API documentation
   - Request pricing quote for marriage/divorce APIs
   - Sign up for free trial
   - Test data quality and coverage

2. **Contact Spokeo Business**
   - Email: apisupport@spokeo.com
   - Call: (888) 585-2370
   - Request pricing for marriage/divorce data
   - Ask about API documentation and integration examples

3. **Evaluate Alternatives**
   - Survey users: Do they want marriage/divorce records?
   - Compare to criminal records demand
   - Consider ROI vs. development time

### Decision Criteria

**Proceed If**:
- ✅ API cost < $0.50 per lookup (for viable margins)
- ✅ Coverage > 70% for major metros
- ✅ User demand exists (survey results positive)
- ✅ No prohibitive legal restrictions
- ✅ API reliability acceptable

**Don't Proceed If**:
- ❌ API cost > $1.00 per lookup
- ❌ Coverage < 50% nationally
- ❌ Low user demand
- ❌ Legal/compliance issues
- ❌ API unreliable

---

## Conclusion

### Summary

Marriage and divorce records are technically accessible but challenging to integrate:

**Pros**:
- ✅ Records are public and legal to access
- ✅ Some APIs exist (Enformion, Spokeo)
- ✅ Could differentiate Pink Flag from competitors
- ✅ Reuse existing credit/refund infrastructure

**Cons**:
- ❌ Opaque pricing (all require sales contact)
- ❌ Likely expensive ($0.50-$2.00+ per lookup estimated)
- ❌ Coverage varies significantly by state
- ❌ Additional API reliability risk
- ❌ Unclear user demand

### Recommendation

**Short Term (Next 2 Weeks)**:
1. Contact Enformion and Spokeo for quotes
2. Survey existing users about feature demand
3. Calculate ROI based on pricing quotes
4. Make go/no-go decision

**Medium Term (If Go)**:
1. Start with free trial integration
2. Beta test with small user group
3. Monitor costs and usage carefully
4. Scale if metrics positive

**Long Term Alternative**:
Consider focusing development efforts on:
- Enhanced criminal record integration
- Location-based safety features
- Social media background checks
- More relevant safety features

**Bottom Line**: Worth exploring pricing/demand, but not guaranteed to be viable. Prioritize features with clearer user safety value and better cost structure.

---

## Resources

### API Provider Contacts

**Enformion**:
- Website: https://go.enformion.com
- Sales: Via website contact form
- Free Trial: Available on website

**Spokeo Business**:
- Website: https://www.spokeo.com/business/api
- Email: apisupport@spokeo.com
- Phone: (888) 585-2370

**BeenVerified**:
- API Request Form: Google Form (limited access)
- Limited release program

### Documentation Links

- PACER: https://pacer.uscourts.gov
- VitalChek: https://www.vitalchek.com
- State Vital Records: Varies by state
- FOIA Guide: https://www.foia.gov

### Industry Research

- Private investigator reviews of data services
- Background check comparison sites
- Developer API directories (ProgrammableWeb)

---

**Research Conducted By**: Claude Code
**For**: Pink Flag Safety App
**Date**: November 28, 2025
**Status**: Pending pricing quotes from Enformion and Spokeo

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

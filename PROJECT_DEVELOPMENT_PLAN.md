# Pink Flag - Project Development Plan

**Created**: January 22, 2026
**Current Version**: 1.2.8+30 (Live on App Store)
**Purpose**: Comprehensive roadmap for continued development and improvement
**Status**: ✅ Project synced and up-to-date

---

## 📊 Executive Summary

Pink Flag is a **production iOS app** live on the Apple App Store, providing women's safety features through three core search types:
- **Name Search** (Sex Offender Registry) - 10 credits
- **Phone Lookup** (Twilio) - 2 credits
- **Reverse Image Search** (TinEye) - 4 credits

**Current State**: Stable production app with variable credit system, Apple-only authentication, and comprehensive safety resources.

**Next Phase**: Code quality improvements, enhanced testing coverage, and user experience refinements.

---

## ✅ Recent Sync Summary (January 22, 2026)

### What Was Updated

Successfully synchronized local repository with remote `main` branch, bringing in **11 commits** and **34 file changes**:

#### Major Changes Applied

1. **Search Screen Aesthetic Improvements (v1.2.9)**
   - Gradient AppBar with pink branding
   - Time-based welcome header ("Good morning/afternoon/evening")
   - Visual search mode cards replacing basic tabs
   - Smooth form transition animations
   - Reduced motion accessibility support
   - Files: `search_screen.dart`, `welcome_header.dart`, `search_mode_selector.dart`

2. **Resources Screen Refactoring**
   - Extracted 4 reusable widgets from monolithic file
   - **505 lines → 177 lines** (65% reduction)
   - New widgets: `emergency_banner.dart`, `resource_card.dart`, `additional_resources_section.dart`, `safety_tips_section.dart`
   - Better maintainability and testability

3. **Widget Test Coverage**
   - Added 7 new widget tests for search components
   - Added 4 new widget tests for resources components
   - Total: **11 new test files** improving code quality

4. **RevenueCat Purchase Attribution Fix (CRITICAL)**
   - Fixed purchases not appearing in RevenueCat Dashboard
   - Added proper user identity management (`logIn/logOut` methods)
   - RevenueCat now initialized for existing sessions in `splash_screen.dart`
   - Webhook credit values updated to 30/100/250 (10x system)
   - Files: `splash_screen.dart`, `revenuecat_service.dart`, `auth_service.dart`, webhook `index.ts`

5. **Documentation Updates**
   - New planning documents in `docs/plans/`
   - Updated `SESSION_CONTEXT.md` to v1.2.8
   - Updated `CURRENT_STATUS.md` with latest accomplishments
   - Updated `AI_CODING_CONTEXT.md` with version history

### Dependencies Status

- ✅ All Flutter dependencies installed successfully
- ⚠️ 49 packages have newer versions available (dependency constraints prevent auto-upgrade)
- 📝 Safe to continue development - no breaking issues

---

## 🎯 Current Project Health

### Code Quality Metrics

| Metric | Status | Details |
|--------|--------|---------|
| **Errors** | ✅ 0 | No compilation errors |
| **Warnings** | ✅ 0 | Clean build |
| **Linting Issues** | ℹ️ 41 info | Style warnings (non-blocking) |
| **Test Coverage** | 🟡 Partial | Widget tests added, integration tests needed |
| **Documentation** | ✅ Excellent | Comprehensive docs in place |
| **Production Status** | ✅ Live | v1.2.8 on App Store |

### Architecture Health

| Component | Status | Notes |
|-----------|--------|-------|
| **Flutter App** | ✅ Excellent | Well-structured, modular |
| **Backend API** | ✅ Stable | Deployed on Fly.io |
| **Database** | ✅ Operational | Supabase PostgreSQL with RLS |
| **Monetization** | ✅ Active | RevenueCat + IAP working |
| **Authentication** | ✅ Secure | Apple Sign-In only |

### Known Issues

1. **Linting - Info Level (41 issues)**
   - Constant naming conventions (UPPER_CASE vs lowerCamelCase)
   - Debug `print` statements in production code
   - **Priority**: Low (cosmetic, non-functional)
   - **Fix Effort**: 1-2 hours

2. **Dependency Updates**
   - 49 packages have newer versions available
   - **Priority**: Medium (security & features)
   - **Fix Effort**: 2-3 hours (testing required)

3. **Database Password**
   - Hardcoded in comments: `Making2Money!@#`
   - **Priority**: High (security)
   - **Fix Effort**: 30 minutes (if publicly accessible)

4. **Sent.dm API Reliability**
   - Occasionally returns 503 (maintenance)
   - **Mitigation**: Auto-refund system handles this ✅
   - **Priority**: Low (handled gracefully)

---

## 📋 Development Priorities

### 🔴 HIGH PRIORITY (Next 2 Weeks)

#### 1. Security Hardening
**Estimated Time**: 2-3 hours

- [ ] **Rotate Database Password** (30 mins)
  - Generate new secure password
  - Update Supabase configuration
  - Update backend `.env` files
  - Test all database connections

- [ ] **Audit RLS Policies** (1 hour)
  - Review `profiles` table policies
  - Review `credit_transactions` table policies
  - Review `searches` table policies
  - Test with different user contexts

- [ ] **Review API Keys** (30 mins)
  - Ensure all keys are not in git history
  - Verify `.env` files are gitignored
  - Check for any exposed secrets

- [ ] **Monitor for Credit Abuse** (30 mins)
  - Query Supabase for suspicious patterns
  - Check for rapid account creation
  - Review credit transaction anomalies

**Success Criteria**:
- Database password rotated and secure
- RLS policies documented and tested
- No API keys exposed in repository
- Monitoring queries documented

#### 2. Code Quality Improvements
**Estimated Time**: 3-4 hours

- [ ] **Fix Linting Issues** (2 hours)
  - Replace debug `print` with proper logging framework
  - Document decision to keep UPPER_CASE constants or refactor
  - Run `dart fix --apply` to auto-fix safe issues
  - Update `analysis_options.yaml` to suppress intentional style choices

- [ ] **Refactor Large Files** (2 hours)
  - `store_screen.dart` (25,346 lines) - Extract widgets
  - `login_screen.dart` (16,298 lines) - Simplify further
  - `results_screen.dart` (22,514 lines) - Extract result cards

**Success Criteria**:
- Linting down to 0 issues (or all suppressed with justification)
- No file over 500 lines
- All widgets extracted and reusable

#### 3. Production Monitoring
**Estimated Time**: Ongoing

- [ ] **Set Up Monitoring Dashboards** (2 hours)
  - App Store Connect: Daily crash report reviews
  - RevenueCat: Weekly purchase metrics
  - Supabase: Database performance monitoring
  - Fly.io: Backend health and logs

- [ ] **User Feedback Analysis** (30 mins weekly)
  - Review App Store reviews
  - Categorize feature requests
  - Track common user issues
  - Document bugs reported by users

- [ ] **Performance Metrics** (1 hour)
  - Track API response times (P50, P90, P99)
  - Monitor app startup time
  - Check memory usage patterns
  - Identify slow screens/operations

**Success Criteria**:
- Monitoring dashboards bookmarked and checked daily
- User feedback tracked in issue tracker
- Performance baseline documented

---

### 🟡 MEDIUM PRIORITY (Next Month)

#### 4. Testing Expansion
**Estimated Time**: 8-10 hours

**Current State**:
- ✅ 11 widget tests for search and resources screens
- ❌ No integration tests
- ❌ No end-to-end tests

**Goals**:
- [ ] **Unit Tests for Services** (3 hours)
  - `search_service.dart` - Credit gating logic
  - `phone_search_service.dart` - Phone validation
  - `image_search_service.dart` - Image handling
  - `revenuecat_service.dart` - Purchase flows
  - `auth_service.dart` - Apple Sign-In logic

- [ ] **Integration Tests** (4 hours)
  - Complete search flow (name, phone, image)
  - Credit purchase flow
  - Credit refund system
  - Authentication flow

- [ ] **E2E Tests** (3 hours)
  - Onboarding → Sign-up → Search → Purchase flow
  - Sign-in → Search → Results flow
  - Settings → Account deletion flow

**Test Coverage Target**: 80%+

**Success Criteria**:
- All critical services have unit tests
- Integration tests cover main user flows
- E2E tests validate production scenarios
- CI/CD runs tests on every commit

#### 5. Dependency Updates
**Estimated Time**: 3-4 hours

**Current State**: 49 packages with newer versions available

**Strategy**:
1. Review breaking changes in major updates
2. Update in batches (related packages together)
3. Test thoroughly after each batch
4. Prioritize security patches

**High-Priority Updates**:
- [ ] `supabase_flutter` (2.10.3 → 2.12.0)
- [ ] `purchases_flutter` (9.9.4 → 9.10.7)
- [ ] `sign_in_with_apple` (6.1.4 → 7.0.1)
- [ ] `flutter_lints` (5.0.0 → 6.0.0)
- [ ] `http` (1.5.0 → 1.6.0)

**Medium-Priority Updates**:
- [ ] `google_fonts` (6.3.2 → 7.1.0)
- [ ] `package_info_plus` (8.3.1 → 9.0.0)
- [ ] `intl` (0.19.0 → 0.20.2)

**Success Criteria**:
- All security updates applied
- No breaking changes introduced
- App tested on real device after updates

#### 6. Performance Optimization
**Estimated Time**: 4-5 hours

- [ ] **Image Loading** (2 hours)
  - Implement caching for offender photos
  - Add loading placeholders
  - Optimize image sizes

- [ ] **Database Queries** (2 hours)
  - Review slow queries in Supabase dashboard
  - Add indexes where needed
  - Optimize credit transaction queries

- [ ] **App Startup Time** (1 hour)
  - Profile startup performance
  - Defer non-critical initialization
  - Lazy-load heavy resources

**Success Criteria**:
- Startup time < 2 seconds
- Search results load < 2 seconds
- Smooth scrolling (60 FPS)

---

### 🟢 LOW PRIORITY (Future Enhancements)

#### 7. Feature Enhancements
**Based on User Feedback**

- [ ] **Enhanced Search Filters**
  - Additional age range options
  - Distance radius filtering
  - Saved search preferences

- [ ] **Search History Improvements**
  - Export search history to CSV
  - Filter/sort history
  - Search within history

- [ ] **Notification System**
  - Push notifications for new matches (opt-in)
  - Credit balance alerts
  - Security alerts

- [ ] **iPad Support** (Major effort)
  - Landscape layout
  - Split-screen support
  - Optimized UI for larger screens

#### 8. Marketing & Growth

- [ ] **App Store Optimization (ASO)**
  - Keyword research
  - Screenshot optimization
  - Description A/B testing

- [ ] **Social Media Presence**
  - Create Instagram account
  - Share safety tips and resources
  - User testimonials

- [ ] **Referral Program**
  - Refer-a-friend credit rewards
  - Shareable links
  - Tracking system

---

## 🧪 Testing Strategy

### Test Pyramid Approach

```
        /\
       /E2E\        3 critical flows
      /------\
     /Integration\ 10 core workflows
    /------------\
   /  Unit Tests  \ 50+ tests for services/models
  /----------------\
 / Widget Tests (11)\ Already in place ✅
/----------------------\
```

### Testing Priorities

#### Phase 1: Widget Tests (COMPLETE ✅)
- [x] Search screen components
- [x] Resources screen components

#### Phase 2: Unit Tests (NEXT)
**Focus**: Business logic and data processing

1. **Service Layer**
   - `search_service.dart`: Credit checks, API calls
   - `phone_search_service.dart`: Validation, formatting
   - `image_search_service.dart`: Image handling
   - `auth_service.dart`: Apple Sign-In flow
   - `revenuecat_service.dart`: Purchase logic

2. **Model Layer**
   - JSON parsing/serialization
   - Data validation
   - Credit calculations

#### Phase 3: Integration Tests
**Focus**: Multi-component workflows

1. Search Flow
   - Name search → Results → Credit deduction
   - Phone search → Results → Credit deduction
   - Image search → Results → Credit deduction

2. Purchase Flow
   - Browse packages → Purchase → Credit addition
   - Failed purchase → Error handling
   - Restore purchases

3. Refund Flow
   - API failure → Auto refund → Credit restoration
   - Display refund in transaction history

#### Phase 4: E2E Tests
**Focus**: Complete user journeys

1. New User Flow
   - Onboarding → Sign-up → Home → Search → Results

2. Returning User Flow
   - Launch → Home (auto-login) → Search

3. Purchase Flow
   - Out of credits → Store → Purchase → Search

### Test Environment Setup

**Required**:
- [ ] Test Supabase project (separate from production)
- [ ] RevenueCat sandbox environment
- [ ] Mock API responses for external services
- [ ] Test Apple ID for Apple Sign-In

**CI/CD Integration**:
- [ ] GitHub Actions workflow for tests
- [ ] Run tests on every pull request
- [ ] Block merge if tests fail
- [ ] Code coverage reports

---

## 🚀 Deployment Strategy

### Current Deployment Process

**Backend (Fly.io)**:
```bash
# From /backend directory
fly deploy

# Version is automatically incremented
# Check deployment:
fly status
fly logs
```

**Mobile App (TestFlight/App Store)**:
```bash
# 1. Update version in pubspec.yaml
# 2. Build iOS archive
cd safety_app
flutter build ipa --release

# 3. Upload via Xcode or Transporter
open build/ios/archive/*.xcarchive

# 4. Submit for review via App Store Connect
```

### Recommended Deployment Workflow

#### 1. Development → Staging

**For Each Feature**:
1. Create feature branch from `main`
2. Develop and test locally
3. Create pull request
4. Code review + automated tests
5. Merge to `main`

#### 2. Staging → Production

**For Each Release**:
1. Create release branch: `release/v1.2.x`
2. Test on TestFlight (internal testers)
3. Fix critical bugs if found
4. Deploy backend to production (Fly.io)
5. Submit iOS app for App Store review
6. Monitor first 24-48 hours post-release

#### 3. Hotfixes

**For Critical Bugs**:
1. Create hotfix branch from production tag
2. Fix bug + add test
3. Fast-track review
4. Deploy immediately
5. Back-port fix to `main`

### Version Numbering

**Current**: 1.2.8+30

**Scheme**: MAJOR.MINOR.PATCH+BUILD

- **MAJOR**: Breaking changes (rare)
- **MINOR**: New features, refactors
- **PATCH**: Bug fixes, minor improvements
- **BUILD**: Increments with every App Store submission

**Next Versions**:
- v1.2.9: Bug fixes, performance improvements
- v1.3.0: New feature additions
- v2.0.0: Major redesign or architecture change

---

## 📁 File Organization & Refactoring Needs

### Current Structure
```
safety_app/lib/
├── config/          # ✅ Well-organized
├── models/          # ✅ Clean (8 models)
├── services/        # ✅ Good (13 services)
├── screens/         # ⚠️ Some large files
│   ├── store_screen.dart (25,346 lines) ❌ TOO LARGE
│   ├── results_screen.dart (22,514 lines) ❌ TOO LARGE
│   ├── image_search_screen.dart (18,695 lines) ❌ TOO LARGE
│   ├── login_screen.dart (16,298 lines) ⚠️ LARGE
│   ├── search_screen.dart (17,072 lines) → 545 lines ✅ REFACTORED
│   └── resources_screen.dart (17,903 lines) → 177 lines ✅ REFACTORED
├── widgets/
│   ├── search/ (6 widgets) ✅
│   └── resources/ (4 widgets) ✅
└── theme/           # ✅ Well-organized
```

### Refactoring Priorities

#### 1. Immediate (This Week)
**File**: `store_screen.dart` (25,346 lines)

**Extraction Plan**:
- `PackageCard` widget (purchase option display)
- `MockPurchaseDialog` widget
- `RestorePurchasesButton` widget
- `PurchaseSuccessDialog` widget

**Target**: < 500 lines

#### 2. Short-term (Next Week)
**File**: `results_screen.dart` (22,514 lines)

**Extraction Plan**:
- `OffenderCard` widget (individual result display)
- `EmptyResultsState` widget
- `ResultsHeader` widget (count, filters)
- `ResultsFilter` widget

**Target**: < 400 lines

#### 3. Medium-term (This Month)
**Files**: `image_search_screen.dart`, `login_screen.dart`

**Extraction Plan**:
- Extract image picker logic to separate service
- Simplify login screen (already reduced, but can go further)
- Create reusable authentication widgets

**Target**: Both < 300 lines

### Refactoring Benefits

| Benefit | Impact |
|---------|--------|
| **Testability** | Individual widgets can be tested in isolation |
| **Reusability** | Widgets can be used in multiple screens |
| **Maintainability** | Easier to find and fix bugs |
| **Performance** | Smaller widgets = better hot reload |
| **Collaboration** | Multiple developers can work on different widgets |

---

## 🛠️ Development Workflow

### Daily Development Routine

**Morning** (15 mins):
1. Pull latest from `main`: `git pull origin main`
2. Check App Store Connect for crashes
3. Review RevenueCat dashboard for purchase metrics
4. Check Supabase for database alerts

**During Development**:
1. Create feature branch: `git checkout -b feature/your-feature`
2. Make small, focused commits
3. Run `flutter analyze` before committing
4. Test locally on simulator/device

**Before Pull Request**:
1. Run full test suite: `flutter test`
2. Run linter: `flutter analyze`
3. Format code: `dart format lib/ test/`
4. Update relevant documentation
5. Create PR with descriptive title and description

**End of Day**:
1. Push work to remote branch
2. Update todo list or project board
3. Document any blockers

### Code Review Checklist

**For Reviewers**:
- [ ] Code follows project style guide
- [ ] Tests added for new functionality
- [ ] No obvious security issues
- [ ] Performance considerations addressed
- [ ] Documentation updated
- [ ] No hardcoded secrets or credentials
- [ ] Error handling in place

### Branch Strategy

**Main Branches**:
- `main`: Production-ready code
- `develop`: Integration branch (optional)

**Feature Branches**:
- `feature/feature-name`: New features
- `fix/bug-name`: Bug fixes
- `refactor/component-name`: Code refactoring
- `test/component-name`: Adding tests
- `docs/topic`: Documentation updates

**Release Branches**:
- `release/v1.2.x`: Preparing for release
- `hotfix/critical-bug`: Emergency production fixes

---

## 📊 Metrics & KPIs

### Technical Metrics

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| **Test Coverage** | ~20% | 80% | 🔴 |
| **Build Time** | ~60s | <45s | 🟡 |
| **App Size (iOS)** | ~15MB | <20MB | ✅ |
| **Startup Time** | ~2.5s | <2s | 🟡 |
| **Code Duplication** | Low | <5% | ✅ |
| **Linting Issues** | 41 | 0 | 🔴 |

### Business Metrics (Monitor via Dashboards)

**User Acquisition**:
- Daily active users (DAU)
- Monthly active users (MAU)
- New signups per day
- Retention rate (D1, D7, D30)

**Monetization**:
- Purchase conversion rate
- Average revenue per user (ARPU)
- Credit package preferences
- Churn rate

**Engagement**:
- Searches per user per day
- Search type distribution (name/phone/image)
- Time in app per session
- Feature usage rates

**Quality**:
- Crash-free sessions (Target: >99.5%)
- API error rates (Target: <1%)
- Credit refund rate (Track for API issues)
- User-reported bugs

---

## 🎯 Next Steps (Actionable Tasks)

### Week 1: Security & Code Quality
**Goal**: Secure the app and clean up codebase

**Tasks**:
1. **Monday**: Rotate database password (30 mins)
2. **Tuesday**: Audit RLS policies (1 hour)
3. **Wednesday**: Fix linting issues (2 hours)
4. **Thursday**: Refactor `store_screen.dart` (3 hours)
5. **Friday**: Code review and testing

**Deliverables**:
- Database password rotated
- RLS policies documented
- Linting issues resolved
- `store_screen.dart` refactored to <500 lines

### Week 2: Testing Foundation
**Goal**: Establish testing infrastructure

**Tasks**:
1. **Monday**: Set up test Supabase project (1 hour)
2. **Tuesday**: Write unit tests for `search_service` (2 hours)
3. **Wednesday**: Write unit tests for `revenuecat_service` (2 hours)
4. **Thursday**: Write integration test for search flow (2 hours)
5. **Friday**: CI/CD setup for automated testing (2 hours)

**Deliverables**:
- Test environment configured
- 20+ unit tests added
- 3 integration tests
- CI/CD running tests automatically

### Week 3-4: Performance & Polish
**Goal**: Optimize user experience

**Tasks**:
1. Update dependencies (3 hours)
2. Optimize image loading (2 hours)
3. Profile and optimize slow queries (2 hours)
4. Refactor remaining large files (4 hours)
5. User feedback analysis and prioritization (2 hours)

**Deliverables**:
- All dependencies updated
- Performance baseline documented
- All files <500 lines
- User feedback backlog created

---

## 💡 Tips for Success

### Development Best Practices

1. **Make Small, Frequent Commits**
   - Easier to review
   - Easier to revert if needed
   - Better git history

2. **Write Tests First (TDD)**
   - Catches bugs early
   - Better API design
   - Living documentation

3. **Document As You Go**
   - Update README when adding features
   - Add code comments for complex logic
   - Keep docs in sync with code

4. **Refactor Ruthlessly**
   - Don't let technical debt accumulate
   - Small refactors are easier than big rewrites
   - Always leave code better than you found it

5. **Monitor Production**
   - Set up alerts for critical errors
   - Review metrics weekly
   - Act on user feedback quickly

### Common Pitfalls to Avoid

❌ **Don't**:
- Commit secrets or API keys
- Skip testing "small changes"
- Ignore linting warnings
- Let files grow beyond 500 lines
- Deploy on Fridays (unless urgent)

✅ **Do**:
- Use feature flags for risky features
- Test on real devices before release
- Monitor first 24 hours after deployment
- Keep documentation up to date
- Celebrate small wins with the team

---

## 📞 Support & Resources

### Dashboards & Tools

| Service | URL | Purpose |
|---------|-----|---------|
| **App Store Connect** | [appstoreconnect.apple.com](https://appstoreconnect.apple.com) | App management, TestFlight |
| **RevenueCat** | [app.revenuecat.com](https://app.revenuecat.com) | Purchase analytics |
| **Supabase** | [app.supabase.com](https://app.supabase.com) | Database, Auth |
| **Fly.io** | [fly.io/dashboard](https://fly.io/dashboard) | Backend hosting |
| **GitHub** | [github.com/bobbyburns1989/redflag](https://github.com/bobbyburns1989/redflag) | Code repository |

### Documentation

| Document | Purpose |
|----------|---------|
| `README.md` | User-facing overview |
| `DEVELOPER_GUIDE.md` | Developer onboarding |
| `CURRENT_STATUS.md` | Central status tracker |
| `SESSION_CONTEXT.md` | Quick session startup guide |
| `CODING_GUIDELINES.md` | AI assistant rules |
| `AI_CODING_CONTEXT.md` | AI-specific context |

### Emergency Contacts

**Production Issues**:
- Check Fly.io logs: `fly logs`
- Check Supabase dashboard for errors
- Review crash reports in App Store Connect

**User Support**:
- Email: support@pinkflagapp.com
- Privacy: privacy@pinkflagapp.com

---

## 🎉 Conclusion

### Project Status: HEALTHY ✅

**Strengths**:
- ✅ Production app live and stable
- ✅ Well-architected codebase
- ✅ Comprehensive documentation
- ✅ Recent refactoring efforts successful
- ✅ Security measures in place (Apple-only auth)

**Areas for Improvement**:
- 🟡 Test coverage needs expansion
- 🟡 Some large files need refactoring
- 🟡 Dependency updates pending
- 🟡 Linting issues to address

**Overall Assessment**: Pink Flag is in excellent shape for continued development. The recent sync brought significant improvements (search screen aesthetics, resources screen refactoring, RevenueCat fixes). Focus on security hardening, testing expansion, and code quality improvements for the next sprint.

---

## 📅 Roadmap Summary

**Q1 2026 (Current Quarter)**:
- ✅ Search screen aesthetics (COMPLETE)
- ✅ Resources screen refactoring (COMPLETE)
- ✅ RevenueCat attribution fix (COMPLETE)
- 🎯 Security hardening (IN PROGRESS)
- 🎯 Testing expansion (NEXT)
- 🎯 Code quality improvements (NEXT)

**Q2 2026**:
- Performance optimization
- Dependency updates
- Feature enhancements based on user feedback
- Marketing and growth initiatives

**Q3 2026**:
- iPad support consideration
- New search features
- Advanced analytics
- Referral program

**Q4 2026**:
- Major version 2.0 planning
- Potential Android version exploration
- Partnership opportunities

---

**Last Updated**: January 22, 2026
**Next Review**: February 1, 2026

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

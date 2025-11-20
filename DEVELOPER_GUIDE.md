# Pink Flag - Developer Guide

> **Last Updated**: November 19, 2025
> **Current Version**: 1.1.2 (Build 8) - Critical Bug Fixes
> **Status**: Production Ready - Auth persistence, purchase flow, credit counter fixes
> **Code Quality**: Production-ready (0 errors, 0 warnings, 38 info notices)
> **Device Support**: iPhone only (iPad removed in v1.0.1)
> **Critical Fixes**: Auth persistence, purchase timeout (21s→78s), credit counter auto-updates

## 📚 Essential Documentation

**Start here for specific needs:**
- **[CODING_GUIDELINES.md](./CODING_GUIDELINES.md)** - Working with Claude Code AI assistant
- **[APP_STORE_RELEASE_GUIDE.md](./APP_STORE_RELEASE_GUIDE.md)** - Complete App Store submission checklist
- **[APPLE_REVIEW_SUBMISSION_v1.1.1.md](./APPLE_REVIEW_SUBMISSION_v1.1.1.md)** - Current submission details and updated app description
- **[APPLE_REVIEW_RESPONSE_v1.1.1.md](./APPLE_REVIEW_RESPONSE_v1.1.1.md)** - Response to Apple's Guideline 5.1.1 rejection
- **[AESTHETIC_ENHANCEMENT_PROGRESS.md](./AESTHETIC_ENHANCEMENT_PROGRESS.md)** - UI/UX enhancement history
- **[LEGAL_URLS.md](./LEGAL_URLS.md)** - Privacy Policy and Terms of Service URLs

## 📋 Quick Context

**Pink Flag** (formerly "Safety First") is a women's safety mobile app that allows users to search public sex offender registries anonymously. The app emphasizes ethical use, privacy, and personal safety awareness.

### Key Philosophy
- **Anonymous & Private**: No login, no tracking, no data collection
- **Ethical by Design**: Prominent disclaimers prevent misuse
- **Safety First**: Integrated emergency resources
- **Cross-Platform**: Single Flutter codebase for iOS and Android

---

## 🎯 Current Project State

### App Branding
- **Name**: Pink Flag
- **Tagline**: "Stay Safe, Stay Aware"
- **Theme**: Pink gradient (hot pink #EC4899 → soft pink #FBD5E8)
- **Logo**: Custom-painted pink flag with cream background

### Recent Major Changes (November 2025)
1. **Rebranded** from "Safety First" to "Pink Flag"
2. **Added Splash Screen** with animated pink flag logo
3. **Enhanced Search**: Added Age and State optional filters
4. **Optimized Layout**: Entire form fits on single screen without scrolling
5. **Last Name Required**: Changed from optional to required for better accuracy
6. **Code Quality** (Nov 6, 2025): Fixed all 42 deprecation warnings (`withOpacity` → `withValues`)
7. **Documentation** (Nov 6, 2025): Added comprehensive App Store Release Guide and Coding Guidelines
8. **🚨 CRITICAL** (Nov 18, 2025): **REMOVED Search History Feature** to comply with Apple Guideline 5.1.1 - No profile building allowed
9. **🔧 REFACTORING** (Nov 18, 2025): Refactored `store_screen.dart` (695 → 251 lines, 64% reduction) and `auth_service.dart` (361 → 89 lines + 3 services, 77% reduction)
10. **📱 RELEASE** (Nov 18, 2025): Version 1.1.1 (Build 7) prepared for Apple resubmission with updated app description
11. **🐛 BUG FIXES** (Nov 19, 2025): **v1.1.2** - Fixed auth persistence (users skip onboarding on return), extended purchase timeout (21s→78s), credit counter auto-updates
12. **🎨 UI REVAMP** (Nov 20, 2025): Modern/minimal aesthetic overhaul of Search and Results screens - white AppBars, floating cards, softer styling, outlined icons

### What's Working
- ✅ Splash screen with animations (2.5s delay → onboarding)
- ✅ 5-page onboarding flow with legal/ethical education (updated privacy messaging)
- ✅ Search form with 6 fields (2 required, 4 optional)
- ✅ Backend API integration with Offenders.io
- ✅ Results display with card-based UI (ephemeral, not stored)
- ✅ Emergency resources screen with tap-to-call
- ✅ Bottom navigation between Search, Resources, and Settings
- ✅ **Privacy-first**: No search history stored anywhere (local or remote)

---

## 🏗️ Architecture Overview

### Tech Stack

**Frontend (Mobile App)**
```
Flutter 3.32.8
├── Dart 3.8.1
├── Material Design 3
├── Provider (state management)
├── HTTP (API calls)
└── url_launcher (emergency calling)
```

**Backend (API Server)**
```
Python 3.11+
├── FastAPI (web framework)
├── Uvicorn (ASGI server)
├── httpx (async HTTP client)
├── Pydantic (data validation)
└── python-dotenv (environment variables)
```

**External APIs**
- **Primary**: Offenders.io API (900k+ records, daily updates)
- **Fallback**: CrimeoMeter API (optional)
- **Mock Data**: Available when no API keys configured

### Project Structure

```
RedFlag/
├── safety_app/                    # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart             # App entry + navigation
│   │   ├── models/               # Data models
│   │   │   ├── offender.dart
│   │   │   └── search_result.dart
│   │   ├── screens/              # UI Screens
│   │   │   ├── splash_screen.dart      # NEW: Pink Flag splash
│   │   │   ├── onboarding_screen.dart  # 5-page flow
│   │   │   ├── search_screen.dart      # Main search form
│   │   │   ├── results_screen.dart     # Search results
│   │   │   └── resources_screen.dart   # Emergency resources
│   │   ├── services/             # Business Logic
│   │   │   └── api_service.dart        # API communication
│   │   └── theme/                # Design System
│   │       └── app_colors.dart         # Pink theme colors
│   ├── pubspec.yaml              # Package name: pink_flag
│   └── test/                     # Unit tests
│
├── backend/                       # Python FastAPI Backend
│   ├── main.py                   # FastAPI app + CORS
│   ├── routers/
│   │   └── search.py             # Search endpoints + filtering
│   ├── services/
│   │   └── offender_api.py       # External API integration
│   ├── requirements.txt          # Python dependencies
│   ├── Dockerfile                # Container definition
│   └── .env                      # API keys (gitignored)
│
├── README.md                      # User-facing documentation
├── DEVELOPER_GUIDE.md            # This file
└── docker-compose.yml            # Docker orchestration
```

---

## 🔑 Key Components Explained

### 1. Splash Screen (`splash_screen.dart`)
**Purpose**: Beautiful branded entry point with animations

**Key Features**:
- Custom-painted pink flag icon using `CustomPainter`
- Fade-in + scale animations using `AnimationController`
- Cream gradient background (#F5EBE0 → #FFF7F0)
- Auto-navigation to onboarding after 2.5 seconds
- No user interaction required

**Code Location**: `safety_app/lib/screens/splash_screen.dart`

### 2. Search Form (`search_screen.dart`)
**Purpose**: Main user interaction point for searching registries

**Required Fields**:
- First Name (min 2 chars)
- Last Name (min 2 chars) - **Changed to required in Nov 2025**

**Optional Fields**:
- Age (18-120, filters within ±5 year range)
- State (2-letter code, e.g., CA, NY, TX)
- Phone Number (10+ digits)
- ZIP Code (5 digits, enables distance calculation)

**Layout Optimization** (Nov 2025):
- **Single-screen design**: No scrolling required
- Compact spacing: 10px between fields (was 16px)
- Hidden character counters: `counterText: ''` on Age/State/ZIP
- Reduced button padding: 12px (was 16px)
- Smaller disclaimer card and fonts

**Validation**:
- Real-time field validation with helpful error messages
- Form-level validation before API call
- Loading states during search
- Error handling with retry option

**Code Location**: `safety_app/lib/screens/search_screen.dart:38-125` (_performSearch method)

### 3. API Service (`api_service.dart`)
**Purpose**: Centralized API communication layer

**Key Method**: `searchByName()`
```dart
Future<SearchResult> searchByName({
  required String firstName,
  String? lastName,      // Required in practice
  String? phoneNumber,
  String? zipCode,
  String? age,           // NEW: Added Nov 2025
  String? state,         // NEW: Added Nov 2025
})
```

**Features**:
- 30-second timeout with custom error handling
- Automatic retry logic on network errors
- Custom exceptions: `ApiException`, `NetworkException`, `ServerException`
- Base URL: `http://localhost:8000/api` (dev) - change for production

**Code Location**: `safety_app/lib/services/api_service.dart`

### 4. Backend Search Router (`search.py`)
**Purpose**: FastAPI endpoint for registry searches

**Endpoint**: `POST /api/search/name`

**Request Model**:
```python
class SearchRequest(BaseModel):
    firstName: str                    # Required
    lastName: str                     # Required
    phoneNumber: Optional[str] = None
    zipCode: Optional[str] = None
    age: Optional[str] = None         # NEW: Post-filters ±5 years
    state: Optional[str] = None       # NEW: Post-filters exact match
```

**Post-Filtering Logic**:
- **Age**: Filters results within ±5 years of target age
- **State**: Case-insensitive exact match (e.g., "CA" matches "ca")
- Applied after fetching from external API

**Code Location**: `backend/routers/search.py:38-62`

### 5. Theme System (`app_colors.dart`)
**Purpose**: Centralized pink-themed color palette

**Primary Colors**:
```dart
static const Color primaryPink = Color(0xFFEC4899);  // Hot Pink
static const Color deepPink = Color(0xFFDB2777);     // Deep Pink
static const Color softPink = Color(0xFFFBD5E8);     // Soft Pink
static const Color lightPink = Color(0xFFFCE7F3);    // Light Pink
static const Color rose = Color(0xFFFDA4AF);         // Rose
static const Color errorRose = Color(0xFFFFF1F2);    // Error Rose
```

**Gradients**:
- `pinkGradient`: Hot Pink → Soft Pink (buttons, accents)
- `appBarGradient`: Deep Pink → Primary Pink (headers)

**Code Location**: `safety_app/lib/theme/app_colors.dart`

---

## 🚀 Setup for New Developers

### Prerequisites
- Flutter 3.32.8+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Dart 3.8.1+
- Python 3.11+
- Xcode (for iOS) or Android Studio (for Android)
- Git

### 1. Clone Repository
```bash
git clone https://github.com/bobbyburns1989/redflag.git
cd RedFlag
```

### 2. Backend Setup
```bash
cd backend

# Create virtual environment
python3 -m venv venv

# Activate (macOS/Linux)
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure API keys
cp .env.example .env
# Edit .env with your Offenders.io API key
# Get key at: https://offenders.io

# Start backend
python main.py
# Backend runs on http://localhost:8000
```

### 3. Flutter App Setup
```bash
cd safety_app

# Install dependencies
flutter pub get

# Verify setup
flutter doctor -v

# List available devices
flutter devices

# Run on iOS Simulator (named "2")
flutter run -d <device-id>

# Or just run on available device
flutter run
```

### 4. Verify Installation
1. Backend: Visit `http://localhost:8000` - should see API info
2. App: Should open with Pink Flag splash screen
3. Complete onboarding (5 pages)
4. Try search: "John Smith" (both names required)

---

## 💻 Development Workflow

### Running the App

**Hot Reload** (fastest):
```bash
# In terminal where flutter run is active
Press 'r'  # Hot reload
Press 'R'  # Hot restart
Press 'q'  # Quit
```

**Debug Mode**:
```bash
flutter run --debug
flutter logs  # View logs
```

**Backend with Auto-Reload**:
```bash
cd backend
source venv/bin/activate
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Code Quality

**Flutter**:
```bash
flutter analyze                    # Lint Dart code (Current: 0 issues ✅)
flutter format lib/ test/          # Format code
flutter test                       # Run unit tests
flutter test --coverage            # Generate coverage
```

**Current Code Quality Status** (as of Nov 6, 2025):
- ✅ **0 errors**
- ✅ **0 warnings**
- ✅ **0 info notices**
- ✅ All deprecation warnings fixed
- ✅ Production-ready

**Python**:
```bash
flake8 --max-line-length=100 .    # Lint Python
black .                            # Format Python
pytest tests/ -v                   # Run tests (when implemented)
```

### Common Tasks

**Add New Screen**:
1. Create file in `safety_app/lib/screens/`
2. Add route in `main.dart` routes map
3. Navigate using `Navigator.pushNamed(context, '/route-name')`

**Add API Endpoint**:
1. Add method to `backend/routers/search.py`
2. Add corresponding method in `safety_app/lib/services/api_service.dart`
3. Update models if needed

**Update Theme**:
1. Modify `safety_app/lib/theme/app_colors.dart`
2. Hot reload to see changes

---

## 🧪 Testing

### Manual Testing Checklist

**Splash Screen**:
- [ ] Pink flag logo appears with animations
- [ ] "PINK FLAG" text and tagline display
- [ ] Auto-navigates to onboarding after 2.5s

**Onboarding**:
- [ ] All 5 pages display correctly
- [ ] Page indicators update
- [ ] "Next" button works on pages 1-4
- [ ] "Get Started" button works on page 5
- [ ] Back button works (pages 2-5)

**Search Form**:
- [ ] All 6 fields render correctly
- [ ] No scrolling required (single screen)
- [ ] Required field validation works (First/Last Name)
- [ ] Optional field validation works (Age 18-120, State 2-letter, ZIP 5-digit)
- [ ] Search button disabled while loading
- [ ] Error messages display correctly
- [ ] Clear Form button works

**Search Results**:
- [ ] Results display in cards
- [ ] All fields shown: name, age, city, state, offense, registration date
- [ ] Empty state displays when no results
- [ ] Age filtering works (±5 years)
- [ ] State filtering works (exact match)

**Emergency Resources**:
- [ ] All hotlines display
- [ ] Tap-to-call works (test on real device)
- [ ] Safety tips display

### Test Accounts
- **Backend Mock Data**: Enabled when no API keys configured
- **Test Names**: "John Smith", "Michael Johnson", "David Williams"
- **Apple Review Demo Account** (Production):
  - Email: `applereview@pinkflag.com`
  - Password: `AppleReview2025!`
  - Credits: 50 (pre-loaded for testing)
  - Created for App Store reviewers in v1.0.1

---

## 📝 Important Notes for New Developers

### 1. iOS Bundle Configuration
- **Bundle ID**: `com.pinkflag.app` (configured in Xcode - matches App Store Connect)
- **Display Name**: Pink Flag (already configured in Info.plist)
- **Device Support**: iPhone only (iPad removed in v1.0.1)
  - `TARGETED_DEVICE_FAMILY = 1` in project.pbxproj
  - iPad orientation settings removed from Info.plist
- **App Store Category**: Lifestyle
- **Age Rating**: 17+ (due to sex offender registry content)
- **No special capabilities required** (no iCloud, no Push Notifications, etc.)

### 2. Legal URLs (App Store Required)
- **Privacy Policy**: https://customapps.us/pinkflag/privacy
- **Terms of Service**: https://customapps.us/pinkflag/terms
- Required for App Store Connect submission
- Must be accessible before submission

### 3. API Keys
- **Offenders.io API key is required** for real data
- Get key at: https://offenders.io
- Add to `backend/.env`: `OFFENDERS_IO_API_KEY=your_key_here`
- **Never commit `.env` files** (already in .gitignore)

### 3. Network Configuration
- **Production**: App uses `https://pink-flag-api.fly.dev/api` (already configured)
- **Local Development**: Change to `http://localhost:8000/api` in `api_service.dart:9`
- **Android Emulator Local Dev**: Use `http://10.0.2.2:8000/api` instead
- Backend is deployed on Fly.io and auto-scales (see PRODUCTION_BACKEND_INFO.md)

### 4. Last Name Field
- **Changed from optional to required** (November 2025)
- Backend requires it: `lastName: str` (not Optional)
- Frontend validates min 2 characters
- Reason: Improves search accuracy, reduces false positives

### 5. Age and State Filtering
- **Post-filtering on backend** (not passed to external API)
- Age: Filters results within ±5 years
- State: Case-insensitive exact match
- May reduce result count significantly

### 6. Layout Philosophy
- **Single-screen design** is critical - no scrolling
- Use compact spacing (10px between fields)
- Hide character counters with `counterText: ''`
- Test on smallest supported device (iPhone SE)

### 7. Color Theme
- All colors defined in `app_colors.dart`
- Use `AppColors.primaryPink`, not hardcoded hex values
- Gradients available: `pinkGradient`, `appBarGradient`
- Shadows available: `softPinkShadow`

### 8. Git Workflow
- Two commits ahead of origin/main (as of Nov 2025):
  - `c01dd47`: Pink Flag rebranding + Age/State fields
  - `f07e2e3`: Single-screen layout optimization
- Remember to `git push` when ready

---

## 🐛 Known Issues & Todos

### Current Issues
- [ ] Flutter dependencies have newer versions available (26 packages)
- [ ] Backend doesn't persist search history (by design - privacy)
- [ ] No unit tests implemented yet
- [ ] No integration tests yet
- [ ] Refactored store_screen needs testing before deployment
- [ ] Refactored auth_service needs testing before deployment

### Recently Fixed (Nov 20, 2025) - UI Aesthetic Revamp
- ✅ **Search Screen**: Modern/minimal redesign with white AppBar, floating card, softer styling
- ✅ **Results Screen**: Matching aesthetic with floating summary card, softer disclaimers
- ✅ **Offender Cards**: Removed borders, softer shadows, outlined icons
- ✅ **Out of Credits Dialog**: Extracted to reusable widget (`lib/widgets/dialogs/out_of_credits_dialog.dart`)
- ✅ **Files Modified**: search_screen.dart (621 lines), results_screen.dart, offender_card.dart

### Recently Fixed (Nov 19, 2025) - v1.1.2
- ✅ **Auth Persistence**: Returning users skip onboarding/login, go straight to home
- ✅ **Purchase Timeout**: Extended from 21s to 78s with progress feedback every 9s
- ✅ **Purchase Fallback**: Dialog with "Restore Now" button if webhook delays
- ✅ **Credit Counter**: Auto-updates after purchases and searches
- ✅ **Files Modified**: splash_screen.dart, store_screen.dart, search_screen.dart

### Recently Fixed (Nov 18, 2025) - v1.1.1
- ✅ Removed search history feature (Apple Guideline 5.1.1 compliance)
- ✅ Refactored store_screen.dart (64% code reduction, modular purchase architecture)
- ✅ Refactored auth_service.dart (77% reduction, split into 3 services)
- ✅ Version updated to 1.1.1+7 for Apple resubmission
- ✅ Updated app description to accurately reflect no search history storage
- ✅ Created comprehensive Apple review response documentation

### Recently Fixed (Nov 6, 2025)
- ✅ Fixed all 42 deprecation warnings (`withOpacity` → `withValues` API migration)
- ✅ Code now uses modern Flutter color API with improved precision
- ✅ Clean flutter analyze output (0 errors, 0 warnings)

### Future Enhancements
- [ ] Complete refactoring: search_screen.dart, resources_screen.dart, settings_screen.dart
- [ ] Add unit tests for PurchaseHandler and auth services
- [ ] Add integration tests for purchase and auth flows
- [ ] Add map view for results
- [ ] Improve loading states with skeleton screens
- [ ] Add dark mode support
- [ ] Internationalization (i18n) for Spanish
- [ ] Backend rate limiting
- [ ] Production deployment guide

### Refactoring Progress
- ✅ **store_screen.dart** - Complete (695 → 251 lines, 64% reduction) - See `REFACTORING_STORE_SCREEN.md`
- ✅ **auth_service.dart** - Complete (361 → 89 lines facade + 3 services, 77% reduction) - See `REFACTORING_AUTH_SERVICE.md`
- [ ] **search_screen.dart** - Pending (595 lines)
- [ ] **resources_screen.dart** - Pending (505 lines)
- [ ] **settings_screen.dart** - Pending (431 lines)

---

## 🆘 Common Problems & Solutions

### "Port 8000 already in use"
```bash
# Find process
lsof -i :8000

# Kill process
kill -9 <PID>
```

### "Flutter doctor shows issues"
```bash
flutter doctor --android-licenses  # Accept licenses
# Follow flutter doctor suggestions
```

### "Network request failed from app"
- Check backend is running: `curl http://localhost:8000/health`
- iOS Simulator: Use `localhost`
- Android Emulator: Use `10.0.2.2`
- Check firewall isn't blocking port 8000

### "Hot reload not working"
- Press 'R' for hot restart (capital R)
- If still broken, restart: `flutter run`

### "Empty search results"
- Check backend logs: `cat backend/backend.log`
- Verify API key in `backend/.env`
- Try common names: "John Smith", "Michael Johnson"
- Remember: Last name is required

---

## 📚 Additional Resources

### Official Documentation
- [Flutter Docs](https://docs.flutter.dev)
- [FastAPI Docs](https://fastapi.tiangolo.com)
- [Material Design 3](https://m3.material.io)
- [Offenders.io API Docs](https://offenders.io/docs)

### Project Documentation
- `README.md`: User-facing documentation
- `DEVELOPER_GUIDE.md`: This file - comprehensive developer onboarding
- `CODING_GUIDELINES.md`: Guidelines for working with Claude Code AI assistant
- `APP_STORE_RELEASE_GUIDE.md`: Complete App Store submission checklist
- `AESTHETIC_ENHANCEMENT_PROGRESS.md`: UI/UX enhancement history and design system
- `SETUP.md`: Detailed setup instructions (if exists)
- `backend/README.md`: Backend-specific docs (if exists)

### Key Files to Review
1. `safety_app/lib/main.dart` - App structure & routing
2. `safety_app/lib/screens/search_screen.dart` - Main search logic
3. `backend/routers/search.py` - API endpoint & filtering
4. `safety_app/lib/theme/app_colors.dart` - Design system

---

## 🤝 Contributing

### Code Style
- **Dart**: Follow [Flutter style guide](https://flutter.dev/docs/development/tools/formatting)
- **Python**: Follow [PEP 8](https://peps.python.org/pep-0008/) with 100-char line limit
- Use `flutter format` and `black` before committing

### Commit Messages
```
<type>: <short description>

<detailed description>

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Pull Request Process
1. Create feature branch: `git checkout -b feature/your-feature`
2. Make changes and test thoroughly
3. Run `flutter analyze` and `flutter test`
4. Commit with descriptive messages
5. Push and create PR on GitHub
6. Request review from maintainers

---

## 📞 Contact & Support

- **GitHub Issues**: https://github.com/bobbyburns1989/redflag/issues
- **Maintainer**: Bobby Burns
- **Project Status**: Active Development

---

**Last Updated**: November 20, 2025
**Document Version**: 1.4
**Next Review**: After App Store approval of v1.1.3

---

## 📖 Release History

- **v1.1.3** (Nov 20, 2025): UI Aesthetic Revamp - Modern/minimal design for Search & Results screens
- **v1.1.2** (Nov 19, 2025): Bug fixes - Auth persistence, purchase timeout, credit counter
- **v1.1.1** (Nov 18, 2025): Removed search history for Apple compliance
- **v1.1.0** (Nov 18, 2025): Refactored store and auth services
- **v1.0.3** (Nov 6, 2025): Fixed deprecation warnings, improved code quality
- **v1.0.1**: iPad support removed, iPhone only
- **v1.0.0**: Initial release - Pink Flag rebranded from Safety First

See [RELEASE_NOTES_v1.1.2.md](RELEASE_NOTES_v1.1.2.md) for detailed changelog.

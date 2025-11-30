# Pink Flag - Women's Safety App

> 🎉 **NOW LIVE ON THE APP STORE!** - A Flutter mobile application for checking public sex offender registries, phone lookups, and reverse image search. Stay Safe, Stay Aware. Built with privacy, ethics, and personal safety in mind.

![Version](https://img.shields.io/badge/version-1.1.8-blue)
![Status](https://img.shields.io/badge/status-LIVE%20ON%20APP%20STORE-success)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey)
![Flutter](https://img.shields.io/badge/Flutter-3.32.8-02569B?logo=flutter)
![Python](https://img.shields.io/badge/Python-3.11+-3776AB?logo=python&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

## 📑 Table of Contents

- [Overview](#-project-overview)
- [Legal & Ethical Notice](#%EF%B8%8F-important-legal--ethical-notice)
- [Features](#-features)
- [Quick Start](#-quick-start)
- [Architecture](#%EF%B8%8F-architecture)
- [API Configuration](#-api-configuration)
- [Development](#-development)
- [Deployment](#-deployment)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

> 📘 **For Developers**: See [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) for comprehensive onboarding, architecture details, and context for starting new sessions.

## 🎯 Project Overview

**Pink Flag v1.1.8 is LIVE on the Apple App Store!** 🎉

Pink Flag empowers women with access to public sex offender registry information, phone number lookups, and reverse image search through a user-friendly mobile application. Stay Safe, Stay Aware.

### 🚀 Production Status

- ✅ **App Store**: LIVE and available for download (iOS)
- ✅ **Backend**: Deployed on Fly.io (https://pink-flag-api.fly.dev)
- ✅ **In-App Purchases**: Active via RevenueCat
- ✅ **All Features**: Name search, Phone lookup, Image search operational
- ✅ **Credit System**: Fully integrated with automatic refunds

### Key Principles

- **🔒 Privacy First**: Apple Sign-In only, no data collection
- **⚖️ Ethical by Design**: Prominent disclaimers prevent misuse
- **🆘 Safety Resources**: Integrated emergency hotlines with tap-to-call
- **🎯 Awareness, Not Vigilantism**: Clear guidance on proper use
- **💰 Fair Monetization**: Credit-based searches with automatic refunds for API failures

### Why This Matters

Access to public safety information should be easy, anonymous, and ethically guided. This app bridges the gap between public records and personal safety awareness.

## ⚠️ Important Legal & Ethical Notice

**THIS APP PROVIDES ACCESS TO PUBLIC RECORDS ONLY**

### Data Limitations

- ❌ Data may be **incomplete, outdated, or contain errors**
- ❌ Name matches are **NOT definitive** - common names have false positives
- ❌ Always **verify independently** through official channels
- ❌ For **awareness ONLY** - not for harassment or discrimination

### Proper Use

- ✅ Personal safety awareness
- ✅ Background research before meeting someone
- ✅ Verification alongside other sources
- ✅ Reporting concerns to proper authorities

### Prohibited Use

- ❌ Harassment or stalking
- ❌ Vigilante action
- ❌ Employment discrimination
- ❌ Housing discrimination
- ❌ Public shaming or doxxing

**Misuse is illegal and harmful. Use responsibly.**

## ✨ Features

### 1. 📚 Educational Onboarding
- **5-page interactive flow** with legal/ethical education
- **Privacy policy** transparency
- **False positive warnings** to prevent misidentification
- **Ethical use guidelines** emphasized throughout

### 2. 🔍 Smart Search
- **Optimized Single-Screen Layout**: Entire form fits on one screen without scrolling
- **Required**:
  - First name (minimum 2 characters)
  - Last name (minimum 2 characters)
- **Optional Filters**:
  - Age (18-120 years, filters results within 5-year range)
  - State (2-letter state code, e.g., CA, NY, TX)
  - Phone number (10+ digits)
  - ZIP code (5 digits) for distance calculation
- **Real-time validation** with helpful error messages
- **Compact design** with reduced spacing and hidden character counters
- **Loading states** for better UX
- **Note**: Both first and last names are required to improve search accuracy and reduce false positives

### 2b. 🖼️ Reverse Image Search
- **Catfish/Scam Detection**: Check if a photo appears elsewhere online
- **Multiple Input Methods**:
  - Camera capture
  - Gallery selection
  - Image URL input
- **Powered by TinEye API**: Searches billions of indexed images
- **Results Display**:
  - Number of matches found
  - List of domains where image appears
  - Direct links to source pages
  - Crawl dates for each match
- **Use Cases**:
  - Verify if a photo is original or stolen
  - Detect fake profiles using stock photos
  - Identify catfishing attempts
- **Cost**: 1 credit per search (same as name search)

### 3. 📋 Results Display
- **Clean card-based UI** for each potential match
- **Detailed Information**:
  - Full name
  - Age
  - City and state
  - Offense description
  - Registration date
  - Distance (if ZIP provided)
- **Verification disclaimers** on every result
- **Empty state messaging** when no results found

### 4. 🆘 Emergency Resources
- **Integrated Hotlines** with tap-to-call:
  - 🚨 911 - Emergency Services
  - 📞 1-800-799-7233 - National Domestic Violence Hotline
  - 📞 1-800-656-4673 - RAINN Sexual Assault Hotline
  - 📞 988 - Suicide Prevention Lifeline
  - 💬 Text HOME to 741741 - Crisis Text Line
- **Additional Resources** for missing children, trafficking, etc.
- **Safety Tips** for personal protection

### 5. 🛡️ Privacy & Security
- **No user accounts** required (authentication for credit-based searches only)
- **No location tracking** (does not use GPS)
- **No search history stored** - searches are completely ephemeral
- **HTTPS API calls** for secure communication
- **Results displayed temporarily** and never saved

## 🚀 Quick Start

### System Requirements

| Component | Requirement |
|-----------|------------|
| **Flutter SDK** | 3.32.8 or later |
| **Dart** | 3.8.1 or later |
| **Python** | 3.11+ |
| **Node.js** | 18+ (optional, for testing) |
| **Docker** | Latest (optional, for containerized backend) |
| **IDE** | VS Code, Android Studio, or Xcode |
| **Mobile Platform** | Android Studio + Emulator OR Xcode + Simulator |

### Installation Steps

#### 1. Clone Repository

```bash
git clone https://github.com/bobbyburns1989/redflag.git
cd redflag
```

#### 2. Backend Setup

**Option A: Using Python Virtual Environment** (Recommended for development)

```bash
cd backend

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # macOS/Linux
# OR
venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Configure API keys
cp .env.example .env
# Edit .env with your API keys (see API Configuration section)

# Start backend
python main.py
```

Backend will be available at: `http://localhost:8000`

**Option B: Using Docker** (Recommended for production)

```bash
cd backend
cp .env.example .env
# Edit .env with your API keys

# Build and run
docker-compose up --build
```

#### 3. Flutter App Setup

```bash
cd safety_app

# Install dependencies
flutter pub get

# Verify setup
flutter doctor -v

# List available devices
flutter devices

# Run on selected device
flutter run

# Or run on specific device
flutter run -d <device-id>
```

#### 4. Verify Installation

1. **Backend**: Visit http://localhost:8000 - should see API info
2. **Flutter App**: Should open with onboarding screen
3. **Test Search**: Complete onboarding, try searching for "John Smith" (both names required)

## 🏗️ Architecture

### Project Structure

```
redflag/
├── 📱 safety_app/              # Flutter Mobile Application
│   ├── lib/
│   │   ├── main.dart           # App entry point & navigation
│   │   ├── models/             # Data models (Offender, SearchResult)
│   │   ├── services/           # API service layer
│   │   ├── screens/            # UI screens (4 main screens)
│   │   └── widgets/            # Reusable widgets
│   ├── android/                # Android configuration
│   ├── ios/                    # iOS configuration
│   ├── test/                   # Unit tests
│   └── pubspec.yaml            # Dependencies
│
├── 🐍 backend/                  # Python FastAPI Backend
│   ├── main.py                 # FastAPI application
│   ├── routers/
│   │   └── search.py           # Search API endpoints
│   ├── services/
│   │   └── offender_api.py     # External API integration
│   ├── Dockerfile              # Container definition
│   ├── requirements.txt        # Python dependencies
│   └── .env                    # API keys (gitignored)
│
├── 📄 Documentation
│   ├── README.md               # This file
│   ├── SETUP.md                # Detailed setup guide
│   └── backend/README.md       # Backend-specific docs
│
└── 🐳 Infrastructure
    ├── docker-compose.yml      # Docker orchestration
    ├── .gitignore              # Git exclusions
    └── .env.example            # Environment template
```

### Technology Stack

**Frontend (Mobile App)**
- **Flutter 3.32.8** - Cross-platform UI framework
- **Dart 3.8.1** - Programming language
- **Provider** - State management
- **HTTP** - API communication
- **url_launcher** - Emergency calling

**Backend (API Server)**
- **FastAPI** - Modern Python web framework
- **Uvicorn** - ASGI server
- **httpx** - Async HTTP client
- **python-dotenv** - Environment management
- **Pydantic** - Data validation

**Infrastructure**
- **Docker** - Containerization
- **Git** - Version control
- **GitHub** - Repository hosting

### Data Flow

```
Name Search:
User Input → Flutter App → FastAPI Backend → Offenders.io API
                                          ↓
User Display ← Results Screen ← API Service ← JSON Response

Image Search:
Image Upload → Flutter App → FastAPI Backend → TinEye API
                                            ↓
User Display ← Results Screen ← API Service ← Match Results
```

## 🔑 API Configuration

### Supported APIs

#### 1. Offenders.io (Primary - Recommended)

- **Coverage**: 900,000+ records
- **Update Frequency**: Daily
- **Features**: Name, DOB, ZIP search
- **Sign Up**: https://offenders.io
- **Cost**: Free tier available

**Configuration:**

1. Create account at https://offenders.io
2. Navigate to API section
3. Copy your API key
4. Add to `backend/.env`:

```env
OFFENDERS_IO_API_KEY=your_actual_api_key_here
```

#### 2. TinEye (Reverse Image Search)

- **Coverage**: Billions of indexed images worldwide
- **Features**: Find where images appear online
- **Sign Up**: https://services.tineye.com/TinEyeAPI
- **Cost**: $200 for 5,000 searches (starter bundle)

**Configuration:**

```env
TINEYE_API_KEY=your_tineye_api_key_here
```

#### 3. CrimeoMeter (Fallback - Optional)

- **Coverage**: United States
- **Features**: Name + ZIP search
- **Sign Up**: https://crimeometer.com
- **Cost**: Free tier available

**Configuration:**

```env
CRIMEOMETER_API_KEY=your_crimeometer_key  # Optional
```

### Environment Configuration

**backend/.env** (create from `.env.example`):

```env
# Primary API
OFFENDERS_IO_API_KEY=your_offenders_io_key_here

# Reverse Image Search API
TINEYE_API_KEY=your_tineye_api_key_here

# Fallback API (optional)
CRIMEOMETER_API_KEY=your_crimeometer_key_here

# Server Config
PORT=8000
HOST=0.0.0.0
```

**Important Notes:**
- ⚠️ `.env` files are **gitignored** - never commit API keys
- ✅ Backend reads keys at startup via `load_dotenv()`
- 🔄 Restart backend after changing `.env`
- 🧪 Without keys, backend returns mock data for testing

### Testing API Configuration

```bash
# Test backend health
curl http://localhost:8000/health

# Test search endpoint
curl -X POST http://localhost:8000/api/search/name \
  -H "Content-Type: application/json" \
  -d '{"firstName":"John","lastName":"Smith"}'

# Should return JSON array of results
```

## 🔧 Development

### Running Tests

```bash
# Flutter unit tests
cd safety_app
flutter test

# Flutter integration tests
flutter test integration_test/

# Backend tests (when implemented)
cd backend
pytest tests/ -v

# Code coverage
flutter test --coverage
```

### Code Quality

```bash
# Analyze Flutter code
flutter analyze

# Format Flutter code
flutter format lib/ test/

# Lint Python code
cd backend
flake8 --max-line-length=100 .
black --check .

# Format Python code
black .
```

### Hot Reload Development

```bash
# Start backend with auto-reload
cd backend
source venv/bin/activate
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Run Flutter with hot reload
cd safety_app
flutter run
# Press 'r' to hot reload
# Press 'R' to hot restart
```

### Debugging

**Flutter DevTools:**
```bash
flutter pub global activate devtools
flutter pub global run devtools
# Open in browser, connect to running app
```

**Backend Logging:**
```python
# Already configured in main.py
import logging
logging.basicConfig(level=logging.INFO)
```

## 🚀 Deployment

### Building Mobile Apps

**Android APK (Debug):**
```bash
cd safety_app
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

**Android APK (Release):**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (Play Store):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS (macOS only):**
```bash
flutter build ios --release
# Follow Xcode signing process
```

### Backend Deployment Options

#### Option 1: Docker (Recommended)

```bash
# Build production image
docker build -t safety-backend:1.0 ./backend

# Run container
docker run -d \
  -p 8000:8000 \
  --env-file backend/.env \
  --name safety-backend \
  safety-backend:1.0
```

#### Option 2: Cloud Platforms

**Railway:**
```bash
# Install Railway CLI
npm install -g @railway/cli

# Deploy
cd backend
railway login
railway init
railway up
```

**Heroku:**
```bash
# Install Heroku CLI
# Create Procfile in backend/:
echo "web: uvicorn main:app --host 0.0.0.0 --port \$PORT" > Procfile

heroku create safety-app-backend
git subtree push --prefix backend heroku main
```

**Google Cloud Run:**
```bash
gcloud run deploy safety-backend \
  --source ./backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Production Checklist

- [ ] Update `lib/services/api_service.dart` with production backend URL
- [ ] Remove `NSAllowsArbitraryLoads` from iOS `Info.plist`
- [ ] Enable HTTPS only in production
- [ ] Update CORS to specific origins in `backend/main.py`
- [ ] Set up API rate limiting
- [ ] Configure production logging
- [ ] Set up error monitoring (Sentry, etc.)
- [ ] Generate app signing keys
- [ ] Test on real devices
- [ ] Prepare privacy policy and terms of service
- [ ] Submit to App Store / Play Store

## 🚨 Troubleshooting

### Common Issues

#### Backend Won't Start

**Problem:** Port 8000 already in use

```bash
# Find process using port
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows
```

**Problem:** ModuleNotFoundError

```bash
# Ensure virtual environment is activated
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate  # Windows

# Reinstall dependencies
pip install -r requirements.txt
```

**Problem:** Environment variables not loading

```bash
# Verify .env file exists
ls -la backend/.env

# Check .env format (no quotes around values)
OFFENDERS_IO_API_KEY=abc123def456  # ✅ Correct
OFFENDERS_IO_API_KEY="abc123"  # ❌ Wrong (remove quotes)
```

#### Flutter Issues

**Problem:** Flutter doctor shows issues

```bash
# Accept Android licenses
flutter doctor --android-licenses

# Install missing components
# Follow flutter doctor suggestions
```

**Problem:** Build fails

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

**Problem:** Hot reload not working

```bash
# Restart app
# Press 'R' in terminal where flutter run is running
```

#### API Issues

**Problem:** 401 Unauthorized from Offenders.io

- Verify API key is correct in `backend/.env`
- Check if key is activated on Offenders.io dashboard
- Restart backend after changing `.env`

**Problem:** Empty search results

- This is normal if no matches found
- Try common full names like "John Smith", "Michael Johnson", "David Williams"
- Check backend logs: `cat backend/backend.log`
- Remember: Both first and last names are required for searches

**Problem:** Network errors from Flutter app

**For Android Emulator:**
- Use `10.0.2.2` instead of `localhost`
- Update `lib/services/api_service.dart`:
  ```dart
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  ```

**For iOS Simulator (Development):**
- Production: Uses `https://pink-flag-api.fly.dev/api` (default)
- Local dev: Change to `localhost` in api_service.dart
- Ensure backend is running locally if testing local development

**For Production:**
- ✅ Backend deployed to Fly.io: https://pink-flag-api.fly.dev
- ✅ Auto-scales and auto-wakes on requests
- ✅ No configuration needed

#### App Crashes

**Problem:** App crashes on startup

```bash
# Check logs
flutter logs

# Run in debug mode
flutter run --debug
```

**Problem:** url_launcher doesn't work

- Verify permissions in `AndroidManifest.xml` and `Info.plist`
- Check device/simulator has calling capability
- Test on real device (simulators may not support tel: URLs)

### Getting Help

1. **Check Documentation**: Review SETUP.md for detailed instructions
2. **Search Issues**: https://github.com/bobbyburns1989/redflag/issues
3. **Create Issue**: Include error messages, screenshots, and steps to reproduce
4. **Flutter Community**: https://flutter.dev/community
5. **FastAPI Community**: https://fastapi.tiangolo.com/help-fastapi/

## 🤝 Contributing

We welcome contributions that align with our ethical mission!

### Contribution Guidelines

**What We're Looking For:**
- 🐛 Bug fixes
- 📚 Documentation improvements
- ✨ Feature enhancements (post-MVP)
- 🧪 Test coverage improvements
- ♿ Accessibility improvements
- 🌍 Internationalization (i18n)

**What We Won't Accept:**
- ❌ Features that enable harassment
- ❌ Removal of ethical disclaimers
- ❌ Privacy-compromising features
- ❌ Data collection without consent

### Development Process

1. **Fork & Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Develop & Test**
   - Write tests for new features
   - Run `flutter analyze` and `flutter test`
   - Ensure code is formatted

3. **Commit**
   ```bash
   git commit -m "feat: add amazing feature

   - Added X functionality
   - Updated Y component
   - Fixed Z issue"
   ```

4. **Push & PR**
   ```bash
   git push origin feature/your-feature-name
   # Open Pull Request on GitHub
   ```

### Code Style

**Dart/Flutter:**
- Follow official [Flutter style guide](https://flutter.dev/docs/development/tools/formatting)
- Use `flutter format` before committing
- Max line length: 80 characters

**Python:**
- Follow [PEP 8](https://peps.python.org/pep-0008/)
- Use type hints
- Max line length: 100 characters
- Use `black` formatter

## 📄 Legal Documents

**Privacy Policy**: https://customapps.us/pinkflag/privacy
**Terms of Service**: https://customapps.us/pinkflag/terms

## 📄 License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2025 Pink Flag App

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🆘 Support & Resources

### For Users in Crisis

- 🚨 **Emergency Services**: 911
- 📞 **National Domestic Violence Hotline**: 1-800-799-7233
- 📞 **RAINN Sexual Assault Hotline**: 1-800-656-4673
- 📞 **Suicide Prevention Lifeline**: 988
- 💬 **Crisis Text Line**: Text HOME to 741741

### For Developers

- **GitHub Repository**: https://github.com/bobbyburns1989/redflag
- **Report Issues**: https://github.com/bobbyburns1989/redflag/issues
- **Flutter Docs**: https://docs.flutter.dev
- **FastAPI Docs**: https://fastapi.tiangolo.com
- **Material Design**: https://m3.material.io

### Additional Resources

- **National Center for Missing & Exploited Children**: 1-800-843-5678
- **Childhelp Hotline**: 1-800-422-4453
- **National Human Trafficking Hotline**: 1-888-373-7888

## ⚖️ Disclaimer

This application provides access to **public records only**. The developers, contributors, and maintainers are not responsible for:

- ❌ Accuracy, completeness, or timeliness of data
- ❌ Actions taken based on information provided
- ❌ Misuse of the application
- ❌ False positives or misidentification
- ❌ Damages resulting from use of this application

**Important:**
- Always verify information through official government channels
- Do not make decisions based solely on this app
- Report concerns to proper authorities, not vigilante action
- Use responsibly, ethically, and legally

**For legal matters, consult with law enforcement and legal professionals.**

## 🙏 Acknowledgments

- **Data Sources**: Public sex offender registries across the United States
- **Framework**: Built with love using Flutter and FastAPI
- **Icons**: Material Design Icons by Google
- **Emergency Resources**: National crisis organizations
- **Community**: Open source contributors and testers

## 📊 Project Stats

- **Lines of Code**: ~5,000+
- **Languages**: Dart, Python
- **Platforms**: iOS, Android
- **Dependencies**: 15+ packages
- **Development Time**: MVP completed in sprints
- **License**: MIT (Open Source)

---

<div align="center">

**Built with ❤️ for personal safety and community awareness**

*This project emphasizes ethical use, privacy, and personal safety.*
*Always verify information through official channels and use responsibly.*

[Report Issue](https://github.com/bobbyburns1989/redflag/issues) • [Request Feature](https://github.com/bobbyburns1989/redflag/issues/new) • [Documentation](https://github.com/bobbyburns1989/redflag/blob/main/SETUP.md)

</div>

# Safety First - Women's Safety App

A cross-platform Flutter mobile application that helps women check public sex offender registries by name search. This MVP focuses on personal safety awareness through anonymous, ethical use of publicly available data.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## 🎯 Project Overview

Safety First is designed for personal safety awareness, providing easy access to public sex offender registry information. The app emphasizes:

- **Anonymous Usage**: No login or personal data collection
- **Ethical Guidelines**: Clear disclaimers about proper use
- **Safety Resources**: Quick access to emergency hotlines
- **Privacy First**: No location tracking in MVP

## ⚠️ Important Legal & Ethical Notice

**This app provides access to PUBLIC RECORDS ONLY.**

- Data may be incomplete, outdated, or contain errors
- Name matches are NOT definitive - verify independently
- For awareness ONLY - not for harassment, vigilante action, or discrimination
- Misuse is illegal and harmful
- Always trust official channels for verification

## 🏗️ Architecture

```
redflag/
├── safety_app/              # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart       # App entry point with navigation
│   │   ├── models/         # Data models
│   │   │   ├── offender.dart
│   │   │   └── search_result.dart
│   │   ├── services/       # API service layer
│   │   │   └── api_service.dart
│   │   ├── screens/        # UI screens
│   │   │   ├── onboarding_screen.dart
│   │   │   ├── search_screen.dart
│   │   │   ├── results_screen.dart
│   │   │   └── resources_screen.dart
│   │   └── widgets/        # Reusable widgets
│   │       └── offender_card.dart
│   ├── android/            # Android configuration
│   ├── ios/                # iOS configuration
│   └── pubspec.yaml        # Flutter dependencies
├── backend/                 # Python FastAPI backend
│   ├── main.py             # FastAPI app
│   ├── routers/
│   │   └── search.py       # Search endpoints
│   ├── services/
│   │   └── offender_api.py # API integration
│   ├── Dockerfile
│   └── requirements.txt
├── docker-compose.yml       # Docker orchestration
└── .env.example            # Environment template
```

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK**: 3.32.8 or later
- **Dart**: 3.8.1 or later
- **Python**: 3.11+ (for backend)
- **Docker Desktop**: (optional, for containerized backend)
- **Android Studio** or **Xcode**: For mobile development
- **Git**: For version control

### 1. Clone the Repository

```bash
git clone https://github.com/bobbyburns1989/redflag.git
cd redflag
```

### 2. Set Up Flutter App

```bash
cd safety_app
flutter pub get
```

### 3. Set Up Python Backend

#### Option A: Using Docker (Recommended)

```bash
# From project root
cd backend
cp .env.example .env
# Edit .env and add your API keys

# Build and run
docker-compose up --build
```

#### Option B: Local Python Environment

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env and add your API keys

# Run server
python main.py
```

The backend will run on `http://localhost:8000`

### 4. Configure API Keys

Sign up for API access:

1. **Offenders.io** (Recommended): https://offenders.io
   - 900k+ records, updated daily
   - Supports name/DOB/ZIP search

2. **CrimeoMeter** (Optional fallback): https://crimeometer.com

Add keys to `backend/.env`:

```env
OFFENDERS_IO_API_KEY=your_key_here
CRIMEOMETER_API_KEY=your_key_here  # Optional
```

### 5. Run the Flutter App

```bash
cd safety_app

# For Android
flutter run

# For iOS (macOS only)
flutter run -d ios

# For specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

## 📱 Features

### 1. Onboarding Flow
- 5-page educational onboarding
- Legal disclaimers and ethical guidelines
- Privacy policy explanation
- False positive warnings

### 2. Search Functionality
- **Required**: First name
- **Optional**: Last name, phone number, ZIP code
- Input validation and error handling
- Loading states during search

### 3. Results Display
- Clean card-based UI for each match
- Shows: Name, age, location, offense type, registration date
- Distance calculation (if ZIP provided)
- Prominent verification disclaimers
- Empty state with reassuring messaging

### 4. Emergency Resources
- **911**: Emergency services
- **1-800-799-7233**: National Domestic Violence Hotline
- **1-800-656-4673**: National Sexual Assault Hotline (RAINN)
- **988**: Suicide Prevention Lifeline
- **741741**: Crisis Text Line
- Tap-to-call functionality
- Additional resources and safety tips

## 🔧 Development

### Running Tests

```bash
# Flutter tests
cd safety_app
flutter test

# Backend tests (when implemented)
cd backend
pytest
```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release
```

### Code Quality

```bash
# Analyze Flutter code
flutter analyze

# Format code
flutter format lib/

# Python linting
cd backend
flake8 .
black .
```

## 🔐 Security Considerations

### API Key Management

- **NEVER** commit `.env` files to Git
- API keys are stored in backend only
- Frontend calls backend proxy (not external APIs directly)
- Use HTTPS in production

### Data Privacy

- No user authentication required
- No personal data storage
- Search history not persisted
- Anonymous API calls

### iOS App Transport Security

The `Info.plist` currently allows HTTP for development:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**For production**: Remove this and use HTTPS only.

## 📊 API Integration

### Backend Endpoints

#### Health Check
```bash
GET http://localhost:8000/health
```

#### Test Search API
```bash
GET http://localhost:8000/api/search/test
```

#### Search by Name
```bash
POST http://localhost:8000/api/search/name
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe",
  "zipCode": "94102"
}
```

### Response Format

```json
[
  {
    "id": "123456",
    "fullName": "John Doe",
    "age": 45,
    "city": "San Francisco",
    "state": "CA",
    "offenseDescription": "Offense details here",
    "registrationDate": "2020-01-15",
    "distance": 2.5,
    "address": "San Francisco, CA"
  }
]
```

## 🚨 Troubleshooting

### Backend Not Starting

```bash
# Check if port 8000 is in use
lsof -i :8000

# Kill process if needed
kill -9 <PID>
```

### Flutter Build Issues

```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

### iOS Permissions Issues

Ensure `Info.plist` includes:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tel</string>
</array>
```

### Android Permissions Issues

Ensure `AndroidManifest.xml` includes:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 📈 MVP Scope

### ✅ Included Features

- Name-based search
- Optional filters (last name, phone, ZIP)
- Results list view
- Emergency resources
- Onboarding flow
- Anonymous usage

### ❌ Future Enhancements (Post-MVP)

- Map visualization
- Location-based search
- GPS/location services
- Radius search
- Push notifications
- User accounts
- Search history persistence
- Favorites/bookmarks

## 🤝 Contributing

This is a personal safety tool. Contributions should:

1. Maintain ethical guidelines
2. Prioritize user privacy
3. Include appropriate disclaimers
4. Not enable harassment or vigilante behavior

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support & Resources

### For Users

- Report issues: https://github.com/bobbyburns1989/redflag/issues
- National Domestic Violence Hotline: 1-800-799-7233
- National Sexual Assault Hotline: 1-800-656-4673
- Emergency: 911

### For Developers

- Flutter Docs: https://docs.flutter.dev
- FastAPI Docs: https://fastapi.tiangolo.com
- Offenders.io API: https://offenders.io/docs

## ⚖️ Disclaimer

This application provides access to public records. The developers are not responsible for:

- Accuracy or completeness of data
- Actions taken based on information provided
- Misuse of the application
- Damages resulting from use of this application

**Use responsibly and ethically. For legal matters, consult with authorities and legal professionals.**

## 🙏 Acknowledgments

- Data provided by public sex offender registries
- Built with Flutter and FastAPI
- Icons from Material Design
- Emergency resources from national organizations

---

**Built with ❤️ for personal safety and awareness**

*This project emphasizes ethical use and personal safety. Always verify information through official channels and use responsibly.*

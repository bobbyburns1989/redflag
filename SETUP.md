# Safety First - Complete Setup Guide

This guide will walk you through setting up the entire Safety First application from scratch.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [System Setup](#system-setup)
3. [Backend Setup](#backend-setup)
4. [Flutter App Setup](#flutter-app-setup)
5. [API Configuration](#api-configuration)
6. [Running the App](#running-the-app)
7. [Common Issues](#common-issues)

## Prerequisites

### Required Software

- **macOS** (for iOS development) or **Windows/Linux** (Android only)
- **Git** - Version control
- **Flutter SDK** - 3.32.8 or later
- **Python** - 3.11 or later
- **Docker Desktop** - Optional but recommended
- **Android Studio** - For Android development
- **Xcode** - For iOS development (macOS only)
- **VS Code** or **Android Studio** - IDE

### Recommended

- Homebrew (macOS) or Chocolatey (Windows) for package management
- Postman or similar for API testing

## System Setup

### 1. Install Homebrew (macOS)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Flutter

#### macOS/Linux

```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Add to PATH (add to ~/.zshrc or ~/.bashrc)
export PATH="$HOME/flutter/bin:$PATH"

# Verify installation
flutter doctor
```

#### Windows

1. Download Flutter SDK from https://flutter.dev
2. Extract to `C:\src\flutter`
3. Add `C:\src\flutter\bin` to PATH
4. Run `flutter doctor`

### 3. Install Python

#### macOS

```bash
brew install python@3.11
python3 --version
```

#### Windows

Download from https://www.python.org/downloads/

#### Linux

```bash
sudo apt update
sudo apt install python3.11 python3-pip
```

### 4. Install Docker Desktop

Download from https://www.docker.com/products/docker-desktop/

### 5. Install Android Studio

1. Download from https://developer.android.com/studio
2. Install Android SDK and emulator
3. Accept Android licenses:

```bash
flutter doctor --android-licenses
```

### 6. Install Xcode (macOS only)

```bash
# From App Store
xcode-select --install

# Open Xcode and install additional components
sudo xcodebuild -license accept
```

## Backend Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/bobbyburns1989/redflag.git
cd redflag
```

### Step 2: Set Up Python Environment

```bash
cd backend

# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate  # macOS/Linux
# or
venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt
```

### Step 3: Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your API keys
nano .env  # or use your preferred editor
```

Add your API keys:

```env
OFFENDERS_IO_API_KEY=your_key_here
CRIMEOMETER_API_KEY=your_key_here  # Optional
PORT=8000
HOST=0.0.0.0
```

### Step 4: Test Backend

```bash
# Run server
python main.py

# In another terminal, test
curl http://localhost:8000/health
```

You should see:
```json
{"status": "healthy"}
```

## Flutter App Setup

### Step 1: Navigate to Flutter Project

```bash
cd ../safety_app
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Verify Flutter Setup

```bash
flutter doctor -v
```

Ensure no critical issues. Common warnings are OK.

### Step 4: List Available Devices

```bash
flutter devices
```

You should see available emulators/simulators or connected devices.

## API Configuration

### Option 1: Offenders.io (Recommended)

1. Go to https://offenders.io
2. Sign up for an account
3. Navigate to API section
4. Copy your API key
5. Add to `backend/.env`:

```env
OFFENDERS_IO_API_KEY=your_actual_key_here
```

### Option 2: CrimeoMeter (Fallback)

1. Go to https://crimeometer.com
2. Sign up for API access
3. Get your API key
4. Add to `backend/.env`:

```env
CRIMEOMETER_API_KEY=your_actual_key_here
```

### Development Mode (No API Keys)

If you don't have API keys yet, the backend will return mock data for testing.

## Running the App

### Step 1: Start Backend

```bash
# Terminal 1
cd backend
source venv/bin/activate  # If not already activated
python main.py
```

Backend should start at `http://localhost:8000`

### Step 2: Start Flutter App

```bash
# Terminal 2
cd safety_app

# For Android emulator
flutter run

# For iOS simulator (macOS only)
flutter run -d ios

# For specific device
flutter run -d <device-id>
```

### Step 3: Test the App

1. App should open with onboarding screen
2. Swipe through 5 pages of disclaimers
3. Click "Get Started"
4. You'll see the search screen
5. Try searching with a name (e.g., "John")
6. View results
7. Test emergency resources by tapping the Resources tab

## Using Docker (Alternative)

### Build and Run Backend

```bash
# From project root
docker-compose up --build
```

Backend will be available at `http://localhost:8000`

### Access Logs

```bash
docker-compose logs -f backend
```

### Stop Services

```bash
docker-compose down
```

## Common Issues

### Issue: Flutter Doctor Shows Issues

**Solution:**
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Install missing components
flutter doctor
# Follow suggestions for each issue
```

### Issue: Backend Port 8000 In Use

**Solution:**
```bash
# Find process using port
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows
```

### Issue: Cannot Connect to Backend from Flutter

**Symptoms:** API calls fail, network errors

**Solutions:**

1. **Check backend is running:**
   ```bash
   curl http://localhost:8000/health
   ```

2. **For Android emulator**, use `10.0.2.2` instead of `localhost`:

   Edit `lib/services/api_service.dart`:
   ```dart
   static const String _baseUrl = 'http://10.0.2.2:8000/api';
   ```

3. **For iOS simulator**, localhost should work

4. **Check firewall settings** - Ensure port 8000 is not blocked

### Issue: iOS Build Fails

**Solution:**
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run -d ios
```

### Issue: Android Build Fails

**Solution:**
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

### Issue: Module Not Found (Python)

**Solution:**
```bash
pip install -r requirements.txt

# If still failing, try upgrading pip
pip install --upgrade pip
pip install -r requirements.txt
```

### Issue: CORS Errors

**Solution:**

Edit `backend/main.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Issue: url_launcher Not Working

**Solution:**

Ensure permissions are set:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<queries>
    <intent>
        <action android:name="android.intent.action.DIAL" />
        <data android:scheme="tel" />
    </intent>
</queries>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tel</string>
</array>
```

## Testing Your Setup

### 1. Backend Health Check

```bash
curl http://localhost:8000/health
```

Expected: `{"status": "healthy"}`

### 2. Backend Search Test

```bash
curl -X POST http://localhost:8000/api/search/name \
  -H "Content-Type: application/json" \
  -d '{"firstName": "John"}'
```

Expected: JSON array of results (or mock data if no API keys)

### 3. Flutter App Test

1. Open app
2. Complete onboarding
3. Search for a name
4. View results
5. Check resources tab
6. Try tap-to-call functionality

## Next Steps

### Development

- Review code in `lib/` directory
- Customize UI/UX in screens
- Add additional features
- Implement analytics (if desired)

### Production Preparation

1. **Get API keys** from offender registries
2. **Update CORS** to specific domains
3. **Enable HTTPS** on backend
4. **Remove** `NSAllowsArbitraryLoads` from iOS Info.plist
5. **Set up** proper error logging
6. **Configure** app signing for stores

### Deployment

- **Backend**: Deploy to AWS, Google Cloud, or Heroku
- **App**: Build and deploy to App Store / Play Store

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [FastAPI Documentation](https://fastapi.tiangolo.com)
- [Offenders.io API Docs](https://offenders.io/docs)
- [Project Issues](https://github.com/bobbyburns1989/redflag/issues)

## Support

If you encounter issues not covered here:

1. Check existing GitHub issues
2. Create a new issue with:
   - Error messages
   - Steps to reproduce
   - Your environment details
   - Screenshots (if applicable)

---

**Happy coding! Stay safe and code responsibly.**

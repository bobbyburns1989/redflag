# RevenueCat Integration Fix - Implementation Plan

**Date**: November 8, 2025
**Status**: Ready to Execute
**Estimated Time**: 15-20 minutes

---

## 📊 Research Summary

### Environment Check ✅
- **Xcode**: 16.4 (Requires: 14.0+) ✅
- **Flutter**: 3.32.8 ✅
- **iOS Minimum**: 13.0 (Requires: 13.0+) ✅
- **Supabase**: Configured and working ✅

### RevenueCat Package Info
- **Latest Version**: 9.9.4
- **Currently in Project**: 6.27.0 (commented out)
- **Required iOS**: 13.0+
- **Required Xcode**: 14.0+

### Root Cause
The project was using an outdated version of `purchases_flutter` (6.27.0) which had StoreKit compatibility issues. The latest version (9.9.4) uses StoreKit 2 APIs and is fully compatible with our environment.

---

## 🎯 Implementation Strategy

### Phase 1: Update Dependencies
1. Update `pubspec.yaml` with latest RevenueCat version
2. Run `flutter pub get`
3. Clean iOS build artifacts

### Phase 2: Update iOS CocoaPods
4. Update CocoaPods repository (this is the key fix - takes 5-10 min)
5. Install iOS dependencies with updated pods
6. Clean Xcode derived data

### Phase 3: Re-enable Code
7. Uncomment RevenueCat service initialization in `auth_service.dart`
8. Uncomment store screen import in `main.dart`
9. Verify no import errors

### Phase 4: Test Build
10. Build and run on simulator
11. Verify no build errors
12. Test signup flow (should grant 1 credit via Supabase)

### Phase 5: Test Monetization Flow
13. Navigate to store screen
14. Verify products load from RevenueCat
15. Test purchase flow (sandbox mode)
16. Verify webhook delivers credits to Supabase

---

## 📋 Detailed Implementation Steps

### Step 1: Update pubspec.yaml
**File**: `/Users/robertburns/Projects/RedFlag/safety_app/pubspec.yaml`

**Change Line 36:**
```yaml
# FROM:
# purchases_flutter: ^6.27.0  # Temporarily disabled

# TO:
purchases_flutter: ^9.9.4
```

### Step 2: Get Flutter Dependencies
```bash
cd /Users/robertburns/Projects/RedFlag/safety_app
flutter pub get
```

### Step 3: Clean Build Artifacts
```bash
flutter clean
```

### Step 4: Update CocoaPods Repository (KEY STEP)
```bash
cd ios
pod repo update
```
**Note**: This takes 5-10 minutes. It downloads the latest pod specifications and resolves dependency conflicts.

### Step 5: Install iOS Dependencies
```bash
pod install
```

### Step 6: Clean Xcode Derived Data
```bash
cd ..
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner*
```

### Step 7: Re-enable RevenueCat in auth_service.dart
**File**: `/Users/robertburns/Projects/RedFlag/safety_app/lib/services/auth_service.dart`

**Uncomment Lines 2, 22, 46:**
```dart
// Line 2 - Uncomment import
import 'revenuecat_service.dart';

// Line 22 - Uncomment in signUp()
await RevenueCatService().initialize(response.user!.id);

// Line 46 - Uncomment in signIn()
await RevenueCatService().initialize(response.user!.id);
```

### Step 8: Re-enable Store Screen in main.dart
**File**: `/Users/robertburns/Projects/RedFlag/safety_app/lib/main.dart`

**Uncomment Lines 9, 56-57:**
```dart
// Line 9 - Uncomment import
import 'screens/store_screen.dart';

// Lines 56-57 - Uncomment route
case '/store':
  return PageTransitions.slideFromBottom(const StoreScreen());
```

### Step 9: Rebuild and Test
```bash
flutter run -d "7B1CA73D-0044-4A0F-960F-93EAA44FECCC"
```

---

## ✅ Success Criteria

### Build Success
- [ ] No compilation errors
- [ ] App launches successfully
- [ ] No runtime crashes

### Supabase Integration
- [ ] User signup grants 1 free credit automatically
- [ ] Credits display correctly in app badge
- [ ] Search deducts credits properly

### RevenueCat Integration
- [ ] Store screen loads without errors
- [ ] Products display from RevenueCat dashboard
- [ ] Purchase flow works in sandbox mode
- [ ] Webhook delivers credits to Supabase after purchase
- [ ] Credits update in real-time across app

---

## 🔄 Rollback Plan

If anything fails:

1. **Revert pubspec.yaml**:
   ```yaml
   # purchases_flutter: ^9.9.4  # Temporarily disabled
   ```

2. **Comment out code again**:
   - `auth_service.dart` - Re-comment RevenueCat calls
   - `main.dart` - Re-comment store screen import

3. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install
   cd .. && flutter run -d "7B1CA73D-0044-4A0F-960F-93EAA44FECCC"
   ```

---

## 📝 Post-Implementation Tasks

1. Update `MONETIZATION_IMPLEMENTATION_STATUS.md`
2. Test full purchase-to-credit flow
3. Configure RevenueCat products in dashboard
4. Set up App Store Connect products
5. Test on real iOS device
6. Document any issues encountered

---

## 🎓 Key Learnings

1. **CocoaPods Repo Update is Critical**: The `pod repo update` command is essential when dealing with native dependency conflicts. It ensures you have the latest pod specifications.

2. **Version Matters**: RevenueCat 6.27.0 → 9.9.4 brought StoreKit 2 support which resolved compatibility issues.

3. **Environment Compatibility**: Always verify Xcode, iOS SDK, and package requirements align before troubleshooting.

4. **Incremental Testing**: Test at each phase (build → basic functionality → monetization) to isolate issues quickly.

---

## 🚀 Ready to Execute

All prerequisites met:
✅ Environment compatible
✅ Supabase working
✅ Plan documented
✅ Rollback strategy defined

**Estimated Total Time**: 15-20 minutes

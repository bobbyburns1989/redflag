# Getting Started: Pink Flag Monetization Implementation

**Last Updated**: November 6, 2025
**Estimated Time**: 2-3 weeks
**Tech Stack**: RevenueCat + Supabase + Flutter

---

## ✅ Prerequisites Checklist

Before you start, make sure you have:

- [ ] Apple Developer Account ($99/year)
- [ ] Access to App Store Connect
- [ ] Flutter SDK installed and working
- [ ] Xcode installed (latest version)
- [ ] Git/GitHub account (for Supabase login)
- [ ] Text editor / IDE (VS Code recommended)

---

## 📋 Step-by-Step Implementation Guide

Follow these steps **in order**. I'll guide you through each one!

---

## STEP 1: Create Supabase Account & Project

### What You're Doing
Setting up your backend database and authentication system (free, managed service)

### Actions

1. **Go to Supabase**:
   - Open browser: https://supabase.com/
   - Click "Start your project"

2. **Sign up** (choose one):
   - **Recommended**: "Continue with GitHub" (easier)
   - Or: Use email/password

3. **Create New Organization** (if first time):
   - Organization name: "Pink Flag" or your name
   - Click "Create organization"

4. **Create New Project**:
   - Project name: `pink-flag`
   - Database Password: **Generate strong password** → **SAVE THIS!** (use password manager)
   - Region: **US West (Oregon)** (or closest to you)
   - Plan: **Free** (starts free automatically)
   - Click "Create new project"

5. **Wait for provisioning** (~2 minutes):
   - You'll see a loading screen
   - Coffee break! ☕

6. **Save Your Project Credentials**:

   When project is ready, go to **Settings** → **API**:

   Copy these values (you'll need them later):

   ```
   Project URL: https://xxxxx.supabase.co
   Anon (public) key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   Service role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

   **Save these in a secure location!** (DO NOT commit to GitHub)

### ✅ Verification
- [ ] Supabase project created
- [ ] Project URL saved
- [ ] Anon key saved
- [ ] Service role key saved

### 📝 Time Required: ~5-10 minutes

**Once done, let me know and I'll guide you to Step 2!**

---

## STEP 2: Set Up Database Schema

### What You're Doing
Creating tables for users, credits, and transactions in your Supabase database

### Actions

1. **Open SQL Editor**:
   - In Supabase dashboard, click **SQL Editor** (left sidebar)
   - Click **+ New query**

2. **Copy the SQL Script**:
   - I'll provide you with a complete SQL script
   - Copy the entire script

3. **Paste and Run**:
   - Paste into SQL Editor
   - Click **Run** (or press Cmd+Enter)

4. **Verify Success**:
   - You should see "Success. No rows returned"
   - This is GOOD! (No errors means it worked)

5. **Check Tables Created**:
   - Click **Table Editor** (left sidebar)
   - You should see 3 tables:
     - `profiles` (user data + credits)
     - `credit_transactions` (audit log)
     - `searches` (search history)

### 🔧 SQL Script to Run

I'll prepare this in the next message - it's the complete database schema from the plan.

### ✅ Verification
- [ ] SQL script ran without errors
- [ ] 3 tables visible in Table Editor
- [ ] Can click on `profiles` table and see column structure

### 📝 Time Required: ~10 minutes

---

## STEP 3: Create RevenueCat Account & Project

### What You're Doing
Setting up the service that handles all in-app purchase logic

### Actions

1. **Go to RevenueCat**:
   - Open browser: https://www.revenuecat.com/
   - Click "Get started for free"

2. **Sign up**:
   - Use email/password or GitHub
   - No credit card required!

3. **Create Project**:
   - Project name: `Pink Flag`
   - Platform: **iOS** (check iOS box)
   - App name: `Pink Flag`
   - Click "Create project"

4. **Save Your RevenueCat API Key**:
   - After project created, you'll see a screen with **Public SDK key**
   - Copy this key: `appl_xxx...` (starts with "appl_")

   ```
   RevenueCat Public API Key (iOS): appl_xxxxxxxxxxxxx
   ```

   **Save this!** You'll need it in Flutter code.

5. **Don't configure products yet** - we'll do that after App Store Connect

### ✅ Verification
- [ ] RevenueCat account created
- [ ] Pink Flag project created
- [ ] iOS API key saved

### 📝 Time Required: ~5 minutes

---

## STEP 4: Configure Products in App Store Connect

### What You're Doing
Creating the 3 in-app purchase products that users can buy

### Prerequisites
- Must have Apple Developer Account ($99/year)
- Must have access to App Store Connect

### Actions

1. **Go to App Store Connect**:
   - Open: https://appstoreconnect.apple.com/
   - Sign in with Apple Developer account

2. **Go to Your App**:
   - Click "My Apps"
   - Find "Pink Flag" (or create if not exists)
   - If creating new app:
     - Bundle ID: `com.pinkflag.app`
     - Name: "Pink Flag"
     - Primary Language: English (US)

3. **Create In-App Purchase #1: 3 Searches**:
   - Click **In-App Purchases** (left sidebar under Features)
   - Click **+ (Create)**
   - Type: **Consumable**
   - Reference Name: `3 Searches`
   - Product ID: `pink_flag_3_searches` (EXACTLY this - copy/paste!)
   - Click **Create**

   Now fill in details:
   - Price Schedule:
     - Click "+ Add Pricing"
     - Price: **Tier 3** ($1.99 USD)
     - Click "Next" → "Publish"

   - Localization (English - US):
     - Display Name: `3 Searches`
     - Description: `Unlock 3 searches to check public offender registries for personal safety awareness`
     - Click "Save"

   - App Store Promotion (Optional):
     - Promotional Image: Can skip for now
     - Click "Save"

   - Review Information:
     - Screenshot: Can be a simple screenshot (required for review)
     - Review Notes: "Consumable credits for search functionality"
     - Click "Save"

   - **Submit for Review** (top right button)
   - Status will change to "Waiting for Review"

4. **Create In-App Purchase #2: 10 Searches**:
   - Click **+ (Create)** again
   - Type: **Consumable**
   - Reference Name: `10 Searches`
   - Product ID: `pink_flag_10_searches` (EXACTLY this!)
   - Price: **Tier 8** ($4.99 USD)
   - Display Name: `10 Searches`
   - Description: `Best Value! 10 searches for extended personal safety checks`
   - Submit for Review

5. **Create In-App Purchase #3: 25 Searches**:
   - Click **+ (Create)** again
   - Type: **Consumable**
   - Reference Name: `25 Searches`
   - Product ID: `pink_flag_25_searches` (EXACTLY this!)
   - Price: **Tier 13** ($9.99 USD)
   - Display Name: `25 Searches`
   - Description: `Maximum value! 25 searches for comprehensive safety awareness`
   - Submit for Review

### Important Notes

- **Product IDs MUST match exactly** (RevenueCat needs these exact IDs)
- **Products must be approved** before you can test (usually 24-48 hours)
- You CAN test in sandbox mode before approval, but it's trickier

### ✅ Verification
- [ ] 3 products created in App Store Connect
- [ ] Product IDs match exactly:
  - `pink_flag_3_searches`
  - `pink_flag_10_searches`
  - `pink_flag_25_searches`
- [ ] All 3 submitted for review
- [ ] Prices correct ($1.99, $4.99, $9.99)

### 📝 Time Required: ~30-45 minutes

---

## STEP 5: Configure Products in RevenueCat

### What You're Doing
Linking your App Store Connect products to RevenueCat

### Actions

1. **Go back to RevenueCat Dashboard**:
   - https://app.revenuecat.com/

2. **Connect to App Store**:
   - Click **Project Settings** (gear icon, bottom left)
   - Click **Apple App Store** tab
   - Click **Connect to App Store Connect**

3. **Get App-Specific Shared Secret** (from App Store Connect):
   - In another tab, go to App Store Connect
   - My Apps → Pink Flag → Features → In-App Purchases
   - Scroll down to "App-Specific Shared Secret"
   - Click **Generate** (if not already generated)
   - Copy the secret (looks like: 1234567890abcdef...)
   - Paste into RevenueCat "App-Specific Shared Secret" field
   - Click **Save**

4. **Upload App Store Connect API Key** (for StoreKit 2):
   - In App Store Connect: Users and Access → Keys → App Store Connect API
   - Click **+ (Generate API Key)**
   - Name: `RevenueCat`
   - Access: **App Manager**
   - Click **Generate**
   - **Download** the .p8 file (you can only download once!)
   - Copy the following info:
     - Issuer ID
     - Key ID
   - Back in RevenueCat:
     - Paste Issuer ID
     - Paste Key ID
     - Upload .p8 file
     - Click **Save**

5. **Create Products in RevenueCat**:
   - In RevenueCat, click **Products** (left sidebar)
   - Click **+ Product**

   **Product 1**:
   - Product Identifier: `pink_flag_3_searches`
   - App Store Product ID: `pink_flag_3_searches` (same)
   - Display Name: `3 Searches`
   - Description: `3 searches for $1.99`
   - Click **Add Product**

   **Product 2**:
   - Product Identifier: `pink_flag_10_searches`
   - App Store Product ID: `pink_flag_10_searches`
   - Display Name: `10 Searches`
   - Description: `10 searches for $4.99`
   - Click **Add Product**

   **Product 3**:
   - Product Identifier: `pink_flag_25_searches`
   - App Store Product ID: `pink_flag_25_searches`
   - Display Name: `25 Searches`
   - Description: `25 searches for $9.99`
   - Click **Add Product**

6. **Create Offering**:
   - Click **Offerings** (left sidebar)
   - Click **+ Offering**
   - Identifier: `default`
   - Description: `Default offering for all users`
   - Click **Create**

   Now add packages:
   - Click **+ Package** inside the `default` offering

   **Package 1**:
   - Identifier: `three_searches`
   - Product: Select `pink_flag_3_searches`
   - Position: 1
   - Click **Add Package**

   **Package 2**:
   - Identifier: `ten_searches`
   - Product: Select `pink_flag_10_searches`
   - Position: 2
   - Check "**Default**" (this is the recommended package!)
   - Click **Add Package**

   **Package 3**:
   - Identifier: `twenty_five_searches`
   - Product: Select `pink_flag_25_searches`
   - Position: 3
   - Click **Add Package**

### ✅ Verification
- [ ] RevenueCat connected to App Store Connect
- [ ] Shared Secret added
- [ ] API Key uploaded
- [ ] 3 products created in RevenueCat
- [ ] 1 offering created with 3 packages
- [ ] `ten_searches` marked as default

### 📝 Time Required: ~20-30 minutes

---

## STEP 6: Create Supabase Edge Function (Webhook Handler)

### What You're Doing
Creating a serverless function that receives purchase notifications from RevenueCat and adds credits to user accounts

### Prerequisites
- Supabase CLI installed
- Terminal/command line access

### Actions

1. **Install Supabase CLI** (if not already installed):

   ```bash
   # macOS
   brew install supabase/tap/supabase

   # Or with npm (if you have Node.js)
   npm install -g supabase
   ```

2. **Login to Supabase**:

   ```bash
   supabase login
   ```

   This will open a browser window to authenticate.

3. **Link to Your Project**:

   ```bash
   cd /Users/robertburns/Projects/RedFlag
   supabase link --project-ref xxxxx
   ```

   Replace `xxxxx` with your Supabase project ID:
   - Find it in Supabase Dashboard → Project Settings → General → Reference ID

4. **Create Edge Function**:

   ```bash
   supabase functions new revenuecat-webhook
   ```

   This creates: `supabase/functions/revenuecat-webhook/index.ts`

5. **I'll create the webhook function code for you** - let me know when you've completed steps 1-4!

### ✅ Verification
- [ ] Supabase CLI installed
- [ ] Logged in to Supabase
- [ ] Project linked
- [ ] Edge function folder created

### 📝 Time Required: ~15 minutes

---

## STEP 7: Add Flutter Packages

### What You're Doing
Adding Supabase and RevenueCat SDKs to your Flutter app

### Actions

1. **Open `pubspec.yaml`**:
   - File location: `/Users/robertburns/Projects/RedFlag/safety_app/pubspec.yaml`

2. **Add new dependencies**:

   Find the `dependencies:` section and add these two lines:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter

     # ADD THESE TWO LINES:
     supabase_flutter: ^2.3.4
     purchases_flutter: ^6.27.0

     # Existing packages below...
     cupertino_icons: ^1.0.8
     http: ^1.2.0
     provider: ^6.1.1
     # ... rest of packages
   ```

3. **Install packages**:

   ```bash
   cd /Users/robertburns/Projects/RedFlag/safety_app
   flutter pub get
   ```

   You should see output:
   ```
   Resolving dependencies...
   + supabase_flutter 2.3.4
   + purchases_flutter 6.27.0
   Changed XX dependencies!
   ```

4. **Verify installation**:

   ```bash
   flutter pub deps | grep -E "(supabase|purchases)"
   ```

   Should show both packages installed.

### ✅ Verification
- [ ] `pubspec.yaml` updated
- [ ] `flutter pub get` ran successfully
- [ ] No errors in terminal

### 📝 Time Required: ~5 minutes

---

## STEP 8: Initialize Supabase in Flutter

### What You're Doing
Connecting your Flutter app to Supabase backend

### Actions

1. **Open `lib/main.dart`**

2. **Add import at top**:

   ```dart
   import 'package:supabase_flutter/supabase_flutter.dart';
   ```

3. **Initialize Supabase in main() function**:

   Find the `main()` function and update it:

   ```dart
   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();

     // ADD THIS: Initialize Supabase
     await Supabase.initialize(
       url: 'YOUR_SUPABASE_URL',  // Replace with your URL from Step 1
       anonKey: 'YOUR_SUPABASE_ANON_KEY',  // Replace with your anon key from Step 1
     );

     runApp(const MyApp());
   }

   // ADD THIS: Global Supabase client
   final supabase = Supabase.instance.client;
   ```

4. **Replace placeholders**:
   - Replace `YOUR_SUPABASE_URL` with your actual Supabase project URL
   - Replace `YOUR_SUPABASE_ANON_KEY` with your actual anon key
   - (The ones you saved in Step 1!)

5. **Test the app runs**:

   ```bash
   flutter run
   ```

   App should launch without errors. If you see errors, check your URL and key are correct.

### ✅ Verification
- [ ] Supabase initialized in main.dart
- [ ] App runs without errors
- [ ] No console warnings about Supabase

### 📝 Time Required: ~10 minutes

---

## Next Steps Summary

After completing Steps 1-8, you'll have:
- ✅ Supabase backend set up with database
- ✅ RevenueCat configured with products
- ✅ App Store Connect products created
- ✅ Flutter app connected to both services

**The remaining steps are:**
- Step 9: Build authentication screens (login/register)
- Step 10: Build store screen for purchases
- Step 11: Update search screen with credit gating
- Step 12: Create webhook handler code
- Step 13: Test everything end-to-end

---

## 🆘 Getting Help

If you get stuck at any step:
1. Take a screenshot of the error
2. Note which step you're on
3. Let me know and I'll help debug!

---

## 📚 Reference Documents

- Full Implementation Plan: `MONETIZATION_PLAN_REVENUECAT_SUPABASE.md`
- Supabase Docs: https://supabase.com/docs
- RevenueCat Docs: https://www.revenuecat.com/docs

---

**Ready to start with Step 1?** Let me know when you've completed each step and I'll guide you to the next one!

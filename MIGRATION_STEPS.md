# Credit Migration - Step-by-Step Guide

**Created:** 2025-12-04
**Status:** Ready to Execute

---

## ✅ Verification Complete

Both scripts have been verified:
- ✅ Uses correct column names (`profiles.id`)
- ✅ Avoids transaction constraint issues
- ✅ Creates backups before making changes
- ✅ Includes verification queries

---

## 🎯 Step-by-Step Instructions

### PART 1: Rollback BetTrndz Project (Undo Mistake)

**⏱️ Time Required:** 2 minutes

1. **Open BetTrndz Supabase Project**
   - Go to: https://supabase.com/dashboard
   - Click on your **BetTrndz** project (NOT Pink Flag)
   - Confirm you're in the right project by checking the URL/project name

2. **Open SQL Editor**
   - In left sidebar, click "SQL Editor"
   - Click "+ New query"

3. **Copy Rollback Script**
   - Open: `/Users/robertburns/Projects/RedFlag/schemas/ROLLBACK_MIGRATION.sql`
   - Select ALL (Cmd+A)
   - Copy (Cmd+C)

4. **Paste and Run**
   - Paste in Supabase SQL Editor (Cmd+V)
   - Click "Run" button (green play button)

5. **Verify Success**
   - You should see 3 result tables:
     - "Rollback Complete" - shows number of users restored
     - "Credits Restored" - should say "✅ All users restored to original credits"
   - If you see ✅, the rollback worked!

---

### PART 2: Run Migration in Pink Flag Project (Correct Project)

**⏱️ Time Required:** 3 minutes

1. **Switch to Pink Flag Project**
   - In Supabase dashboard, click project dropdown (top left)
   - Select your **Pink Flag** project
   - Look for project with reference: `qjbtmrbbjivniveptdjl`
   - OR URL should be: `https://qjbtmrbbjivniveptdjl.supabase.co`

2. **Verify You're in Pink Flag**
   - Check project name shows "Pink Flag" or similar
   - Check URL contains `qjbtmrbbjivniveptdjl`
   - If unsure, click "Settings" and verify project name

3. **Open SQL Editor**
   - In left sidebar, click "SQL Editor"
   - Click "+ New query"

4. **Copy Migration Script**
   - Open: `/Users/robertburns/Projects/RedFlag/schemas/SIMPLE_CREDIT_MIGRATION.sql`
   - Select ALL (Cmd+A)
   - Copy (Cmd+C)

5. **Paste and Run**
   - Paste in Supabase SQL Editor (Cmd+V)
   - Click "Run" button (green play button)

6. **Verify Success**
   - You should see 5 result tables:
     - "Backup Created" - shows your current credits (should be 8)
     - "Before Migration" vs "After Migration" - shows 8 → 80
     - Individual user credits - your row should show: before=8, after=80, multiplier=10
     - "Multiplier Check" - should say "✅ SUCCESS - All credits multiplied by 10"
     - "🎉 Credit Migration Complete" - final confirmation

7. **Look for This in Results:**
   - `total_old_credits`: 8
   - `total_new_credits`: 80
   - `actual_multiplier`: 10.00
   - If you see these numbers, SUCCESS! ✅

---

### PART 3: Hot Reload App

**⏱️ Time Required:** 10 seconds

1. **Go to Your Terminal**
   - Find the terminal where Flutter is running
   - You should see "Flutter run key commands" at the bottom

2. **Press 'r' Key**
   - Just press the letter `r` and hit Enter
   - This hot reloads the app

3. **Check App**
   - Look at the credit badge in your app
   - It should now show **80 credits** (not 8!)

---

## 🎉 Success Criteria

After completing all steps, you should see:
- ✅ BetTrndz credits restored to original values
- ✅ Pink Flag credits multiplied by 10 (8 → 80)
- ✅ App shows 80 credits in the UI
- ✅ Backup tables exist in both projects (for safety)

---

## 🆘 If Something Goes Wrong

### Rollback Failed in BetTrndz
**Error:** "table credit_migration_backup_20251204 does not exist"
**Solution:** The migration might not have run there. Skip Part 1, go to Part 2.

### Migration Failed in Pink Flag
**Error:** Any SQL error
**Solution:**
1. Take a screenshot of the error
2. Don't panic - we have a rollback
3. Share the error with me and I'll fix it

### App Still Shows 8 Credits
**Solutions:**
1. Try hot **restart** instead: Press `R` (capital R) in terminal
2. Stop app (press `q`) and run again: `flutter run`
3. Check you ran migration in the correct Pink Flag project

---

## 📋 Files You'll Need

1. **Rollback Script (Part 1):**
   `/Users/robertburns/Projects/RedFlag/schemas/ROLLBACK_MIGRATION.sql`

2. **Migration Script (Part 2):**
   `/Users/robertburns/Projects/RedFlag/schemas/SIMPLE_CREDIT_MIGRATION.sql`

---

## ⏱️ Total Time Estimate

- Part 1 (Rollback): 2 minutes
- Part 2 (Migration): 3 minutes
- Part 3 (Hot Reload): 10 seconds

**Total: ~5 minutes**

---

## 🔐 Safety Features

- ✅ Backups created before any changes
- ✅ Verification at every step
- ✅ Rollback scripts included
- ✅ No permanent damage possible

---

**Ready to proceed?** Follow the steps above carefully, and you'll have 80 credits in your Pink Flag app in about 5 minutes!

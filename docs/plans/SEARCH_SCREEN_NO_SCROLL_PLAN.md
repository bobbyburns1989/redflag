# Search Screen No-Scroll Plan

**Created**: January 20, 2026
**Status**: PENDING APPROVAL
**Goal**: Fit entire search screen on a single screen with no horizontal or vertical scrolling

---

## Current Issues

### Horizontal Scrolling
- `SearchModeSelector` uses `SingleChildScrollView` with `Axis.horizontal`
- Cards have fixed 100px width, don't adapt to screen
- Total width: ~336px (3 cards × 100px + 2 gaps × 12px + padding)

### Vertical Scrolling
- Content too tall for screen:
  - AppBar: ~56px
  - WelcomeHeader: ~70px
  - Card padding: 48px (24px top + 24px bottom)
  - Mode selector: ~150px
  - Form content: 300-400px+
  - Screen padding: 32px

**Total**: ~650-750px on iPhone SE (667px screen height)

---

## Proposed Changes

### Phase 1: Fix Horizontal Scrolling (Mode Selector)
**File**: `lib/widgets/search/search_mode_selector.dart`

**Changes**:
1. Remove `SingleChildScrollView`
2. Use `Row` with `Expanded` children so cards fill available width equally
3. Reduce card width from fixed 100px to flexible
4. Reduce internal padding from 16px/12px to 12px/8px

**Before**:
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      _buildModeCard(...), // width: 100
      SizedBox(width: 12),
      _buildModeCard(...), // width: 100
      ...
```

**After**:
```dart
Row(
  children: [
    Expanded(child: _buildModeCard(...)), // flexible width
    SizedBox(width: 8),
    Expanded(child: _buildModeCard(...)), // flexible width
    ...
```

---

### Phase 2: Compact Welcome Header
**File**: `lib/widgets/search/welcome_header.dart`

**Option A - Remove entirely**: Delete WelcomeHeader from search_screen.dart
**Option B - Inline into AppBar**: Move greeting to AppBar subtitle
**Option C - Condense**: Single line, smaller text

**Recommendation**: Option A (remove) - saves ~70px, AppBar title already provides context

---

### Phase 3: Reduce Card/Form Spacing
**File**: `lib/screens/search_screen.dart`

**Changes**:
1. Reduce outer padding from 16px to 12px
2. Reduce card padding from 24px to 16px
3. Reduce gap between mode selector and form from 20px to 12px

**Space saved**: ~24px

---

### Phase 4: Compact Mode Cards
**File**: `lib/widgets/search/search_mode_selector.dart`

**Changes**:
1. Remove subtitle text ("Search by name", "Lookup number", etc.)
2. Reduce icon container padding from 10px to 6px
3. Reduce icon size from 24px to 20px
4. Reduce vertical padding from 16px to 10px
5. Reduce gaps between elements

**Estimated height reduction**: 150px → ~90px

---

### Phase 5: Compact Form Elements
**Files**: `name_search_form.dart`, `phone_search_form.dart`, `image_search_form.dart`

**Changes**:
1. Reduce spacing between form fields from 12-16px to 8px
2. Reduce info banner padding from 10px to 8px
3. Reduce button spacing from 12px to 8px
4. Make "Clear" button smaller or remove entirely (user can clear fields individually)

---

## Implementation Order

| Order | Phase | Est. Space Saved | Risk |
|-------|-------|------------------|------|
| 1 | Fix horizontal scroll | N/A | Low |
| 2 | Compact mode cards | ~60px | Low |
| 3 | Remove welcome header | ~70px | Low |
| 4 | Reduce card/form spacing | ~24px | Low |
| 5 | Compact form elements | ~40px | Medium |

**Total estimated vertical savings**: ~190px

---

## Alternative Approach: Keep Scroll but Optimize

If complete no-scroll is not achievable on smaller devices (iPhone SE), alternative:
- Keep `SingleChildScrollView` but ensure content fits on iPhone 14/15 (844px)
- Accept minimal scroll on smaller devices
- Focus on horizontal scroll fix only

---

## Testing Checklist

After implementation:
- [ ] No horizontal scroll on iPhone SE (375px width)
- [ ] No vertical scroll on iPhone 14 (390px width, 844px height)
- [ ] All 3 search modes display correctly
- [ ] Forms remain usable with condensed spacing
- [ ] Accessibility: touch targets still 44px minimum
- [ ] Optional filters still work (Name search)

---

## Rollback Plan

All changes are UI-only:
- Revert commits if issues arise
- Keep original files as reference in git history

---

**Next Step**: Approve this plan, then I'll implement phase by phase.

# Search Screen Aesthetic Improvements Plan

**Created**: January 18, 2026
**Status**: Planning
**Target Version**: 1.2.9
**Estimated Effort**: 3-4 hours

---

## Overview

Enhance the visual appeal and user experience of the main search screen (home screen) through 6 targeted improvements. These changes maintain full functionality while creating a more polished, branded experience.

---

## Current State

**File**: `lib/screens/search_screen.dart` (545 lines)

**Current Design Issues**:
- Plain white AppBar lacks brand presence
- No personalized user greeting
- Basic tab bar with minimal visual hierarchy
- Flat background color
- Generic card styling
- No animations or transitions

---

## Implementation Plan

### Phase 1: Gradient AppBar with Better Branding
**Effort**: 15 minutes
**Impact**: High

**Current Code** (lines 447-468):
```dart
appBar: AppBar(
  title: Text('Search Registry', ...),
  backgroundColor: Colors.white,
  elevation: 0,
  ...
)
```

**Changes**:
1. Replace `backgroundColor: Colors.white` with gradient `flexibleSpace`
2. Change title text color to white
3. Add subtle text shadow for depth
4. Update `CreditBadge` styling for white background contrast

**Implementation**:
```dart
appBar: AppBar(
  title: Text(
    'Search Registry',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
  ),
  flexibleSpace: Container(
    decoration: BoxDecoration(gradient: AppColors.appBarGradient),
  ),
  backgroundColor: Colors.transparent,
  elevation: 0,
  foregroundColor: Colors.white,
  ...
)
```

**Files to Modify**:
- `lib/screens/search_screen.dart`
- `lib/widgets/search/credit_badge.dart` (update for dark background variant)

---

### Phase 2: Welcome Header Section
**Effort**: 30 minutes
**Impact**: High

**New Widget**: `lib/widgets/search/welcome_header.dart`

**Features**:
- Time-based greeting (Good morning/afternoon/evening)
- Friendly prompt text
- Subtle animation on appear

**Implementation**:
```dart
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_greeting!',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'What would you like to search today?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mediumText,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Placement**: Between AppBar and main card in `search_screen.dart`

**Files to Create**:
- `lib/widgets/search/welcome_header.dart`

**Files to Modify**:
- `lib/screens/search_screen.dart`

---

### Phase 3: Visual Search Mode Cards
**Effort**: 45 minutes
**Impact**: High

**Replace**: Current `SearchTabBar` widget

**New Widget**: `lib/widgets/search/search_mode_selector.dart`

**Design**:
```
┌─────────────────────────────────────────────────────┐
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │
│  │   👤        │ │   📞        │ │   🖼️        │   │
│  │   Name      │ │   Phone     │ │   Image     │   │
│  │   Search    │ │   Lookup    │ │   Search    │   │
│  │  10 credits │ │  2 credits  │ │  4 credits  │   │
│  └─────────────┘ └─────────────┘ └─────────────┘   │
└─────────────────────────────────────────────────────┘
```

**Features**:
- Larger touch targets (better UX)
- Icon + title + description + credit cost
- Selected state with pink border/background
- Subtle elevation on selected card
- Smooth transition between selections

**Implementation Structure**:
```dart
class SearchModeSelector extends StatelessWidget {
  final int selectedMode;
  final ValueChanged<int> onModeChanged;

  // Each mode card with:
  // - Icon (large, colored)
  // - Title (Name Search, Phone Lookup, Image Search)
  // - Brief description
  // - Credit cost badge
  // - Selected/unselected styling
}
```

**Files to Create**:
- `lib/widgets/search/search_mode_selector.dart`

**Files to Modify**:
- `lib/screens/search_screen.dart` (replace SearchTabBar import/usage)

**Optional**: Keep `SearchTabBar` as fallback for smaller screens

---

### Phase 4: Subtle Background Pattern
**Effort**: 20 minutes
**Impact**: Medium

**Current**: Flat `AppColors.palePink` background

**Options**:

**Option A - Gradient Background**:
```dart
body: Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.palePink, AppColors.lightPink],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ),
  child: SingleChildScrollView(...),
)
```

**Option B - Subtle Pattern Overlay**:
```dart
body: Stack(
  children: [
    // Background with subtle circles pattern
    Positioned.fill(
      child: CustomPaint(
        painter: SubtlePatternPainter(),
      ),
    ),
    SingleChildScrollView(...),
  ],
)
```

**Recommendation**: Option A (gradient) - simpler, performant, elegant

**Files to Modify**:
- `lib/screens/search_screen.dart`

---

### Phase 5: Improved Card Design
**Effort**: 30 minutes
**Impact**: Medium

**Current Card** (lines 472-484):
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [...],
  ),
  ...
)
```

**Improvements**:

1. **Subtle Gradient Background**:
```dart
decoration: BoxDecoration(
  gradient: LinearGradient(
    colors: [Colors.white, AppColors.softWhite],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: BorderRadius.circular(20),
  border: Border.all(
    color: AppColors.softPink.withOpacity(0.3),
    width: 1,
  ),
  boxShadow: AppColors.cardShadow,
),
```

2. **Better Internal Spacing**:
- Increase padding from 20 to 24
- Add more vertical space between form sections
- Consistent 16px gaps between elements

3. **Rounded Input Fields**:
- Create or update `CustomTextField` with:
  - Rounded corners (12px radius)
  - Subtle inner shadow
  - Soft pink focus border
  - Better placeholder styling

**Files to Modify**:
- `lib/screens/search_screen.dart`
- `lib/widgets/custom_text_field.dart` (if exists, otherwise create)
- `lib/widgets/search/name_search_form.dart`
- `lib/widgets/search/phone_search_form.dart`
- `lib/widgets/search/image_search_form.dart`

---

### Phase 6: Micro-animations
**Effort**: 45 minutes
**Impact**: Medium

**Animations to Add**:

1. **Tab/Mode Switching**:
```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (child, animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  },
  child: _buildCurrentForm(), // Key by _searchMode
)
```

2. **Welcome Header Entrance**:
```dart
WelcomeHeader()
  .animate()
  .fadeIn(duration: 400.ms)
  .slideY(begin: -0.1, end: 0)
```

3. **Card Entrance**:
```dart
// Main card slides up on appear
.animate()
.fadeIn(duration: 500.ms, delay: 200.ms)
.slideY(begin: 0.05, end: 0)
```

4. **Button Press Feedback**:
- Already using `CustomButton` - verify it has scale animation
- Add haptic feedback on tap (already implemented in some places)

5. **Loading Shimmer**:
- Use `shimmer` package (already in dependencies)
- Apply to search button while loading

**Files to Modify**:
- `lib/screens/search_screen.dart`
- `lib/widgets/search/welcome_header.dart`
- `lib/widgets/custom_button.dart` (verify animations)

---

## Implementation Order

| Order | Phase | Effort | Dependencies |
|-------|-------|--------|--------------|
| 1 | Phase 1: Gradient AppBar | 15 min | None |
| 2 | Phase 4: Background Gradient | 20 min | None |
| 3 | Phase 2: Welcome Header | 30 min | None |
| 4 | Phase 5: Card Design | 30 min | None |
| 5 | Phase 3: Visual Mode Cards | 45 min | Phase 2 complete |
| 6 | Phase 6: Micro-animations | 45 min | All others complete |

**Total Estimated Time**: 3-4 hours

---

## Files Summary

### New Files to Create
1. `lib/widgets/search/welcome_header.dart`
2. `lib/widgets/search/search_mode_selector.dart`

### Files to Modify
1. `lib/screens/search_screen.dart` (main changes)
2. `lib/widgets/search/credit_badge.dart` (dark background variant)
3. `lib/widgets/search/name_search_form.dart` (spacing)
4. `lib/widgets/search/phone_search_form.dart` (spacing)
5. `lib/widgets/search/image_search_form.dart` (spacing)

### Optional Modifications
- `lib/widgets/custom_text_field.dart` (enhanced styling)
- `lib/widgets/custom_button.dart` (animation verification)

---

## Testing Checklist

After implementation, verify:

- [ ] Gradient AppBar displays correctly on all devices
- [ ] Credit badge is readable on gradient background
- [ ] Welcome header shows correct time-based greeting
- [ ] All three search modes work correctly
- [ ] Mode switching is smooth with animations
- [ ] Background gradient doesn't affect scrolling performance
- [ ] Card design looks good with all form types
- [ ] Animations don't cause jank or stuttering
- [ ] Dark mode compatibility (if applicable)
- [ ] Accessibility: text contrast meets WCAG standards

---

## Rollback Plan

If issues arise:
1. Each phase is independent - can revert individual changes
2. Keep `SearchTabBar` as backup if `SearchModeSelector` has issues
3. All changes are UI-only - no backend/data changes

---

## Success Metrics

After launch, monitor:
- User engagement (time on search screen)
- Search completion rate
- App Store review sentiment
- Crash reports (ensure no performance issues)

---

**Next Step**: Approve this plan, then I'll implement phase by phase with commits after each phase.

---

*Document created for Pink Flag v1.2.9 aesthetic improvements*

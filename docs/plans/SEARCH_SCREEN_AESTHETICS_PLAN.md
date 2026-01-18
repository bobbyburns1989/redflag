# Search Screen Aesthetic Improvements Plan

**Created**: January 18, 2026
**Updated**: January 18, 2026
**Status**: Planning (Revised)
**Target Version**: 1.2.9
**Estimated Effort**: 3-4 hours

---

## Overview

Enhance the visual appeal and user experience of the main search screen (home screen) through 6 targeted improvements. These changes maintain full functionality while creating a more polished, branded experience.

---

## Design Decisions

| Question | Decision | Rationale |
|----------|----------|-----------|
| Narrow screen mode cards | **Horizontal scroll** | Maintains visual consistency; avoids awkward 2-row layouts |
| Animation approach | **Native Flutter** | Already using `flutter_animate` (in pubspec), but prefer native for core transitions to minimize dependencies |
| Greeting localization | **Generic only** | No user name available; generic greeting is sufficient for MVP |
| Reduced motion | **Respect system setting** | Check `MediaQuery.disableAnimations` for accessibility |

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
4. **Set `systemOverlayStyle: SystemUiOverlayStyle.light`** for status bar icons
5. **Create explicit `CreditBadge.onDark()` variant** instead of implicit styling

**Implementation**:
```dart
appBar: AppBar(
  systemOverlayStyle: SystemUiOverlayStyle.light, // Light status bar icons
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
  actions: [
    CreditBadge.onDark(credits: _currentCredits), // Explicit dark variant
  ],
  ...
)
```

**CreditBadge Update**:
```dart
class CreditBadge extends StatelessWidget {
  final int credits;
  final bool onDarkBackground;

  const CreditBadge({
    super.key,
    required this.credits,
    this.onDarkBackground = false,
  });

  // Named constructor for dark backgrounds
  const CreditBadge.onDark({
    super.key,
    required this.credits,
  }) : onDarkBackground = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: onDarkBackground
            ? Colors.white.withOpacity(0.2)
            : AppColors.lightPink,
        borderRadius: BorderRadius.circular(20),
      ),
      // ... rest with conditional colors
    );
  }
}
```

**Files to Modify**:
- `lib/screens/search_screen.dart`
- `lib/widgets/search/credit_badge.dart` (add `onDark` variant)

---

### Phase 2: Welcome Header Section
**Effort**: 30 minutes
**Impact**: High

**New Widget**: `lib/widgets/search/welcome_header.dart`

**Features**:
- Time-based greeting (Good morning/afternoon/evening)
- Friendly prompt text
- Subtle animation on appear (respects reduced motion)

**Known Limitations** (acceptable for MVP):
- Greeting won't update if screen stays open across time boundaries (e.g., 11:59 AM → 12:01 PM)
- No user name personalization (not available in current auth flow)
- English only (no i18n required for US-only app)

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
    // Respect reduced motion accessibility setting
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Widget content = Padding(
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

    // Only animate if reduced motion is not enabled
    if (reduceMotion) return content;

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 400),
      child: content,
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

**Accessibility & UX Requirements**:
- **Material + InkWell**: Proper tap ripples and feedback
- **Semantics**: Label each card for screen readers
- **Horizontal scroll on narrow screens**: `SingleChildScrollView` with `scrollDirection: Axis.horizontal`
- **Min touch target**: 48x48 dp per Material guidelines

**Implementation Structure**:
```dart
class SearchModeSelector extends StatelessWidget {
  final int selectedMode;
  final ValueChanged<int> onModeChanged;

  const SearchModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildModeCard(
            mode: 0,
            icon: Icons.person_search,
            title: 'Name',
            subtitle: 'Search by name',
            credits: 10,
          ),
          const SizedBox(width: 12),
          _buildModeCard(
            mode: 1,
            icon: Icons.phone,
            title: 'Phone',
            subtitle: 'Lookup number',
            credits: 2,
          ),
          const SizedBox(width: 12),
          _buildModeCard(
            mode: 2,
            icon: Icons.image_search,
            title: 'Image',
            subtitle: 'Reverse search',
            credits: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required int mode,
    required IconData icon,
    required String title,
    required String subtitle,
    required int credits,
  }) {
    final isSelected = selectedMode == mode;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title search, $credits credits',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onModeChanged(mode),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.lightPink : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryPink : AppColors.softPink,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? AppColors.softPinkShadow : null,
            ),
            child: Column(
              children: [
                Icon(icon, size: 32, color: isSelected ? AppColors.primaryPink : AppColors.mediumText),
                const SizedBox(height: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.mediumText)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.palePink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$credits cr', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Fallback Strategy**:
- Keep `SearchTabBar` in codebase (don't delete)
- Use `SearchModeSelector` as primary
- Can revert to `SearchTabBar` if issues arise on specific devices

**Files to Create**:
- `lib/widgets/search/search_mode_selector.dart`

**Files to Modify**:
- `lib/screens/search_screen.dart` (replace SearchTabBar import/usage)

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

3. **Rounded Input Fields with Variant Parameter**:

**IMPORTANT**: To avoid global regressions, add a `style` or `variant` parameter instead of changing defaults.

```dart
enum TextFieldVariant { standard, rounded }

class CustomTextField extends StatelessWidget {
  final TextFieldVariant variant;
  // ... other params

  const CustomTextField({
    this.variant = TextFieldVariant.standard, // Default unchanged
    // ...
  });

  InputDecoration get _decoration {
    switch (variant) {
      case TextFieldVariant.rounded:
        return InputDecoration(
          filled: true,
          fillColor: AppColors.palePink.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryPink, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        );
      case TextFieldVariant.standard:
      default:
        return _existingDecoration; // Keep current styling
    }
  }
}
```

**Usage in search forms only**:
```dart
CustomTextField(
  variant: TextFieldVariant.rounded,
  // ... other params
)
```

**Risk Mitigation**:
- Only search forms use `TextFieldVariant.rounded`
- All other screens continue using `TextFieldVariant.standard` (default)
- No global regressions possible

**Files to Modify**:
- `lib/screens/search_screen.dart`
- `lib/widgets/custom_text_field.dart` (add variant parameter)
- `lib/widgets/search/name_search_form.dart` (use rounded variant)
- `lib/widgets/search/phone_search_form.dart` (use rounded variant)
- `lib/widgets/search/image_search_form.dart` (use rounded variant)

---

### Phase 6: Micro-animations
**Effort**: 45 minutes
**Impact**: Medium

**Dependencies Confirmed**:
- `flutter_animate: ^4.5.0` - Already in pubspec.yaml ✓
- `shimmer: ^3.0.0` - Already in pubspec.yaml ✓

**Accessibility Requirement**:
All animations must respect `MediaQuery.of(context).disableAnimations`.

**Animations to Add**:

1. **Tab/Mode Switching** (Native Flutter - more control):
```dart
// IMPORTANT: Use ValueKey to trigger animation on mode change
// Use AnimatedSize to prevent height jumps between forms
AnimatedSize(
  duration: const Duration(milliseconds: 200),
  child: AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    transitionBuilder: (child, animation) {
      // Respect reduced motion setting
      if (MediaQuery.of(context).disableAnimations) {
        return child;
      }
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      );
    },
    child: _buildCurrentForm(
      key: ValueKey<int>(_searchMode), // CRITICAL: triggers animation
    ),
  ),
)
```

2. **Welcome Header Entrance** (Native Flutter):
```dart
// In WelcomeHeader widget - already handles reduced motion
// See Phase 2 implementation
```

3. **Card Entrance** (Native Flutter):
```dart
// Use TweenAnimationBuilder for one-time entrance
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: 1.0),
  duration: Duration(milliseconds: MediaQuery.of(context).disableAnimations ? 0 : 500),
  builder: (context, value, child) {
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: child,
      ),
    );
  },
  child: /* card content */,
)
```

4. **Button Press Feedback**:
- Already using `CustomButton` - verify it has scale animation
- Add haptic feedback on tap (already implemented in some places)
- `HapticFeedback.lightImpact()` on button press

5. **Loading State** (Native Flutter preferred over shimmer):
```dart
// Simple animated opacity for loading overlay
AnimatedOpacity(
  opacity: _isLoading ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 200),
  child: /* loading indicator */,
)
```

**Why Native Flutter over flutter_animate**:
- More control over accessibility (reduced motion)
- No additional dependency complexity
- flutter_animate already in project but use sparingly
- Easier to maintain and debug

**Files to Modify**:
- `lib/screens/search_screen.dart` (AnimatedSwitcher, AnimatedSize)
- `lib/widgets/search/welcome_header.dart` (entrance animation)
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

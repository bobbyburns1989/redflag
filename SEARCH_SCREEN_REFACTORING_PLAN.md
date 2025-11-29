# search_screen.dart Refactoring Plan

**File**: `safety_app/lib/screens/search_screen.dart`
**Current Size**: 1,364 lines
**Target Size**: ~200 lines (85% reduction)
**Estimated Time**: 3-5 hours
**Risk Level**: Medium (complex state management)
**Date**: November 29, 2025

---

## Current Structure Analysis

### File Breakdown

```
Lines 1-18:    Imports (18 lines)
Lines 20-25:   SearchScreen StatefulWidget (6 lines)
Lines 27-126:  State class setup (100 lines)
  - 28-40:     Controllers & services (13 fields)
  - 42-50:     State variables (9 fields)
  - 53-112:    Lifecycle & credit methods
  - 115-126:   Dispose method
Lines 129-414: Search action methods (286 lines)
  - 129-168:   Image picker methods
  - 177-204:   performImageSearch
  - 231-324:   performSearch (name)
  - 346-410:   performPhoneSearch
  - 351-363:   Clear methods
Lines 417-1,364: BUILD METHOD (947 lines) ⚠️
  - 432-455:   Credit badge (AppBar action)
  - 487-650:   Tab bar (164 lines)
  - 654-962:   Name search form (308 lines)
  - 963-1,093: Phone search form (130 lines)
  - 1,094-1,329: Image search form (235 lines)
```

### State Dependencies

**Shared State** (used by all forms):
- `_searchMode` - Current tab (0=Name, 1=Phone, 2=Image)
- `_isLoading` - Loading indicator
- `_errorMessage` - Error display
- `_currentCredits` - Credit count

**Name Search State**:
- `_formKey`, `_firstNameController`, `_lastNameController`
- `_ageController`, `_stateController`, `_phoneController`, `_zipCodeController`
- `_showOptionalFilters`

**Phone Search State**:
- `_phoneNumberController`

**Image Search State**:
- `_urlController`, `_selectedImage`, `_imagePicker`

### Services Used

- `_searchService` (SearchService) - Name search & credit management
- `_phoneSearchService` (PhoneSearchService) - Phone lookup
- `_imageSearchService` (ImageSearchService) - Image search

---

## Refactoring Strategy

### Goals

1. ✅ **Extract all UI from build() method**
2. ✅ **Create 6 reusable widgets**
3. ✅ **Maintain identical functionality**
4. ✅ **Preserve all state management**
5. ✅ **Enable component testing**
6. ✅ **Improve performance** (only active form rebuilds)

### Extraction Plan

We'll extract in this order (easiest → hardest):

1. **CreditBadge** (easiest - pure UI)
2. **SearchTabBar** (medium - simple callback)
3. **SearchErrorBanner** (easy - simple display)
4. **PhoneSearchForm** (medium - single controller)
5. **ImageSearchForm** (hard - image picker state)
6. **NameSearchForm** (hardest - multiple controllers + expansion)

---

## Phase 1: Setup & Preparation (30 minutes)

### Step 1.1: Create Widget Directory (5 min)

```bash
cd /Users/robertburns/Projects/RedFlag/safety_app
mkdir -p lib/widgets/search
```

**Created Structure**:
```
lib/widgets/search/
├── credit_badge.dart
├── search_tab_bar.dart
├── search_error_banner.dart
├── name_search_form.dart
├── phone_search_form.dart
└── image_search_form.dart
```

### Step 1.2: Create Git Branch (5 min)

```bash
cd /Users/robertburns/Projects/RedFlag
git checkout -b refactor/search-screen-widgets
git add .
git commit -m "checkpoint: before search_screen refactoring"
```

**Purpose**: Easy rollback if needed

### Step 1.3: Take Screenshots (10 min)

**Test on simulator and capture**:
1. Name search form (collapsed filters)
2. Name search form (expanded filters)
3. Phone search form
4. Image search form
5. Error message display
6. Credit badge display

**Purpose**: Visual regression testing after refactoring

### Step 1.4: Document Current Behavior (10 min)

**Create test checklist**:
- [ ] Tab switching works
- [ ] Name search submits correctly
- [ ] Phone search validates format
- [ ] Image picker opens
- [ ] Credit badge updates
- [ ] Error messages display
- [ ] Loading states work
- [ ] Optional filters expand/collapse
- [ ] Form validation triggers
- [ ] Clear buttons work

---

## Phase 2: Extract CreditBadge (30 minutes)

**Difficulty**: Easy
**Lines Affected**: 432-455 (24 lines)
**Dependencies**: None (pure UI)

### Step 2.1: Create Widget File

**File**: `lib/widgets/search/credit_badge.dart`

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Credit balance display badge for AppBar
///
/// Shows current credit count in a pink pill-shaped badge.
/// Pure UI component with no state - receives credits as parameter.
class CreditBadge extends StatelessWidget {
  final int credits;

  const CreditBadge({
    super.key,
    required this.credits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightPink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.toll, size: 16, color: AppColors.primaryPink),
          const SizedBox(width: 6),
          Text(
            '$credits',
            style: TextStyle(
              color: AppColors.primaryPink,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 2.2: Update search_screen.dart

**Replace lines 432-455 with**:

```dart
import '../widgets/search/credit_badge.dart';

// In build() method, AppBar actions:
actions: [
  CreditBadge(credits: _currentCredits),
],
```

### Step 2.3: Test (5 min)

- [ ] Credit badge displays correctly
- [ ] Badge updates when credits change
- [ ] AppBar layout unchanged
- [ ] Hot reload works

**Checkpoint**: `git add . && git commit -m "extract: CreditBadge widget"`

---

## Phase 3: Extract SearchTabBar (45 minutes)

**Difficulty**: Medium
**Lines Affected**: 487-650 (164 lines)
**Dependencies**: `_searchMode` state, callback for tab change

### Step 3.1: Create Widget File

**File**: `lib/widgets/search/search_tab_bar.dart`

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Three-tab segmented control for search modes
///
/// Tabs: Name | Phone | Image
/// Manages tab selection state via callback.
class SearchTabBar extends StatelessWidget {
  final int selectedMode;
  final ValueChanged<int> onModeChanged;

  const SearchTabBar({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.palePink,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTab(
            mode: 0,
            label: 'Name',
            icon: Icons.person_search,
          ),
          _buildTab(
            mode: 1,
            label: 'Phone',
            icon: Icons.phone,
          ),
          _buildTab(
            mode: 2,
            label: 'Image',
            icon: Icons.image_search,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primaryPink : AppColors.mediumText,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryPink : AppColors.mediumText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Step 3.2: Update search_screen.dart

**Replace lines 487-650 with**:

```dart
import '../widgets/search/search_tab_bar.dart';

// In build() Column children (after Form open):
children: [
  SearchTabBar(
    selectedMode: _searchMode,
    onModeChanged: (mode) => setState(() => _searchMode = mode),
  ),
  const SizedBox(height: 16),

  // Rest of forms...
],
```

### Step 3.3: Test (5 min)

- [ ] All 3 tabs clickable
- [ ] Selected tab highlights
- [ ] Tab changes update form below
- [ ] Animation smooth
- [ ] Hot reload works

**Checkpoint**: `git add . && git commit -m "extract: SearchTabBar widget"`

---

## Phase 4: Extract SearchErrorBanner (30 minutes)

**Difficulty**: Easy
**Lines Affected**: Error banners in all 3 forms (~40 lines each)
**Dependencies**: `_errorMessage` state

### Step 4.1: Create Widget File

**File**: `lib/widgets/search/search_error_banner.dart`

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Error message banner for search forms
///
/// Displays error message in a pink banner with icon.
/// Returns empty widget if errorMessage is null.
class SearchErrorBanner extends StatelessWidget {
  final String? errorMessage;

  const SearchErrorBanner({
    super.key,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.palePink,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppColors.deepPink,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: AppColors.deepPink,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
```

### Step 4.2: Update search_screen.dart

**Replace error banners in all 3 forms**:

```dart
import '../widgets/search/search_error_banner.dart';

// In each form (Name, Phone, Image), replace error display with:
SearchErrorBanner(errorMessage: _errorMessage),
```

**Locations**:
- Name search: lines 913-942
- Phone search: lines 1,044-1,073
- Image search: lines 1,280-1,309

### Step 4.3: Test (5 min)

- [ ] Error displays in all 3 forms
- [ ] Error clears when null
- [ ] Styling matches original
- [ ] No layout shifts

**Checkpoint**: `git add . && git commit -m "extract: SearchErrorBanner widget"`

---

## Phase 5: Extract PhoneSearchForm (1 hour)

**Difficulty**: Medium
**Lines Affected**: 963-1,093 (130 lines)
**Dependencies**: Controller, loading state, error state, callbacks

### Step 5.1: Create Widget File

**File**: `lib/widgets/search/phone_search_form.dart`

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../custom_button.dart';
import '../custom_text_field.dart';
import 'search_error_banner.dart';

/// Phone number search form
///
/// Allows users to enter a phone number and perform reverse lookup.
/// Handles validation and displays search/clear buttons.
class PhoneSearchForm extends StatelessWidget {
  final TextEditingController phoneController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const PhoneSearchForm({
    super.key,
    required this.phoneController,
    required this.isLoading,
    this.errorMessage,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Info banner
        Container(
          decoration: BoxDecoration(
            color: AppColors.palePink,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryPink,
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Find caller name and details for any phone number',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mediumText,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Phone number input
        CustomTextField(
          controller: phoneController,
          label: 'Phone Number *',
          hint: '(555) 123-4567',
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          showClearButton: true,
          textCapitalization: TextCapitalization.none,
        ),
        const SizedBox(height: 12),

        // Format help text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.palePink,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: AppColors.primaryPink,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Enter 10-digit US phone number',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.mediumText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Error message
        SearchErrorBanner(errorMessage: errorMessage),

        // Search button
        CustomButton(
          text: 'Search Phone Number',
          onPressed: onSearch,
          variant: ButtonVariant.primary,
          size: ButtonSize.large,
          icon: Icons.search,
          isLoading: isLoading,
        ),
        const SizedBox(height: 12),

        // Clear button
        CustomButton(
          text: 'Clear',
          onPressed: isLoading ? null : onClear,
          variant: ButtonVariant.text,
          size: ButtonSize.medium,
          icon: Icons.refresh_rounded,
        ),
      ],
    );
  }
}
```

### Step 5.2: Update search_screen.dart

**Replace lines 963-1,093 with**:

```dart
import '../widgets/search/phone_search_form.dart';

// In build() conditional forms:
else if (_searchMode == 1) ...[
  PhoneSearchForm(
    phoneController: _phoneNumberController,
    isLoading: _isLoading,
    errorMessage: _errorMessage,
    onSearch: _performPhoneSearch,
    onClear: _clearPhoneForm,
  ),
],
```

### Step 5.3: Test (10 min)

- [ ] Form displays correctly
- [ ] Phone validation works
- [ ] Search button calls `_performPhoneSearch`
- [ ] Clear button works
- [ ] Loading state shows spinner
- [ ] Error messages display

**Checkpoint**: `git add . && git commit -m "extract: PhoneSearchForm widget"`

---

## Phase 6: Extract ImageSearchForm (1.5 hours)

**Difficulty**: Hard
**Lines Affected**: 1,094-1,329 (235 lines)
**Dependencies**: Controllers, image state, image picker, multiple callbacks

### Step 6.1: Create Widget File

**File**: `lib/widgets/search/image_search_form.dart`

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../custom_button.dart';
import '../custom_text_field.dart';
import 'search_error_banner.dart';

/// Image search form
///
/// Allows users to select image from gallery/camera or enter URL.
/// Displays image preview when selected.
class ImageSearchForm extends StatelessWidget {
  final TextEditingController urlController;
  final File? selectedImage;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onPickGallery;
  final VoidCallback onTakePhoto;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const ImageSearchForm({
    super.key,
    required this.urlController,
    this.selectedImage,
    required this.isLoading,
    this.errorMessage,
    required this.onPickGallery,
    required this.onTakePhoto,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Info banner
        Container(
          decoration: BoxDecoration(
            color: AppColors.palePink,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryPink,
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Check if an image appears elsewhere online',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mediumText,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Image selection buttons
        Row(
          children: [
            Expanded(
              child: _buildImagePickerButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: isLoading ? null : onPickGallery,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildImagePickerButton(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: isLoading ? null : onTakePhoto,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Selected image preview
        if (selectedImage != null) ...[
          Stack(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onClear,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // OR divider and URL input (only if no image selected)
        if (selectedImage == null) ...[
          Row(
            children: [
              Expanded(
                child: Container(height: 1, color: AppColors.softPink),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: AppColors.mediumText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(height: 1, color: AppColors.softPink),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: urlController,
            label: 'Image URL',
            hint: 'https://example.com/image.jpg',
            prefixIcon: Icons.link,
            keyboardType: TextInputType.url,
            showClearButton: true,
          ),
          const SizedBox(height: 16),
        ],

        // Error message
        SearchErrorBanner(errorMessage: errorMessage),

        // Search button
        CustomButton(
          text: 'Search Image',
          onPressed: onSearch,
          variant: ButtonVariant.primary,
          size: ButtonSize.large,
          icon: Icons.image_search,
          isLoading: isLoading,
        ),
        const SizedBox(height: 12),

        // Clear button
        CustomButton(
          text: 'Clear',
          onPressed: isLoading ? null : onClear,
          variant: ButtonVariant.text,
          size: ButtonSize.medium,
          icon: Icons.refresh_rounded,
        ),
      ],
    );
  }

  Widget _buildImagePickerButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.palePink,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.softPink),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppColors.primaryPink),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 6.2: Update search_screen.dart

**Replace lines 1,094-1,329 with**:

```dart
import '../widgets/search/image_search_form.dart';

// In build() conditional forms:
else ...[
  ImageSearchForm(
    urlController: _urlController,
    selectedImage: _selectedImage,
    isLoading: _isLoading,
    errorMessage: _errorMessage,
    onPickGallery: _pickFromGallery,
    onTakePhoto: _takePhoto,
    onSearch: _performImageSearch,
    onClear: _clearImageSelection,
  ),
],
```

### Step 6.3: Test (15 min)

- [ ] Gallery picker opens
- [ ] Camera opens
- [ ] Image preview shows
- [ ] Clear button removes image
- [ ] URL input works
- [ ] OR divider shows correctly
- [ ] Search button calls `_performImageSearch`
- [ ] Loading state works

**Checkpoint**: `git add . && git commit -m "extract: ImageSearchForm widget"`

---

## Phase 7: Extract NameSearchForm (2 hours) - MOST COMPLEX

**Difficulty**: Hardest
**Lines Affected**: 654-962 (308 lines)
**Dependencies**: 6 controllers, FormKey, expansion state, validation, callbacks

### Step 7.1: Create Widget File

**File**: `lib/widgets/search/name_search_form.dart`

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../custom_button.dart';
import '../custom_text_field.dart';
import 'search_error_banner.dart';

/// Name search form with optional filters
///
/// Main search form with required fields (first/last name) and
/// optional filters (age, state, phone, ZIP) in expansion panel.
///
/// **State Management Note**:
/// This widget requires a FormKey from parent for validation.
/// Controllers must be provided from parent to maintain state.
class NameSearchForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController ageController;
  final TextEditingController stateController;
  final TextEditingController phoneController;
  final TextEditingController zipCodeController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const NameSearchForm({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.ageController,
    required this.stateController,
    required this.phoneController,
    required this.zipCodeController,
    required this.isLoading,
    this.errorMessage,
    required this.onSearch,
    required this.onClear,
  });

  @override
  State<NameSearchForm> createState() => _NameSearchFormState();
}

class _NameSearchFormState extends State<NameSearchForm> {
  bool _showOptionalFilters = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Disclaimer banner
          Container(
            decoration: BoxDecoration(
              color: AppColors.palePink,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primaryPink,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Results are potential matches. Verify independently.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mediumText,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Required Fields Section
          Text(
            'Required',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.mediumText,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),

          // First name field (required)
          CustomTextField(
            controller: widget.firstNameController,
            label: 'First Name *',
            hint: 'Enter first name',
            prefixIcon: Icons.person,
            textCapitalization: TextCapitalization.words,
            showClearButton: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'First name is required';
              }
              if (value.trim().length < 2) {
                return 'First name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Last name field (required)
          CustomTextField(
            controller: widget.lastNameController,
            label: 'Last Name *',
            hint: 'Enter last name',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            showClearButton: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Last name is required';
              }
              if (value.trim().length < 2) {
                return 'Last name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Optional Filters Section
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 8),
              title: Row(
                children: [
                  Text(
                    'Optional Filters',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mediumText,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.lightPink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '4',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryPink,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: AnimatedRotation(
                turns: _showOptionalFilters ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.mediumText,
                ),
              ),
              initiallyExpanded: _showOptionalFilters,
              onExpansionChanged: (expanded) {
                setState(() => _showOptionalFilters = expanded);
              },
              children: [
                Column(
                  children: [
                    // Row 1: Age + State
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: widget.ageController,
                            label: 'Age',
                            hint: 'Age',
                            prefixIcon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            showClearButton: true,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final age = int.tryParse(value);
                                if (age == null || age < 18 || age > 120) {
                                  return 'Invalid age';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: widget.stateController,
                            label: 'State',
                            hint: 'State',
                            prefixIcon: Icons.map_outlined,
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 2,
                            showClearButton: true,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (value.length != 2) {
                                  return 'Must be 2 letters';
                                }
                                if (!RegExp(r'^[A-Z]{2}$')
                                    .hasMatch(value.toUpperCase())) {
                                  return 'Invalid state';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 2: Phone + ZIP
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: widget.phoneController,
                            label: 'Phone',
                            hint: 'Phone',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            showClearButton: true,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final digitsOnly =
                                    value.replaceAll(RegExp(r'\D'), '');
                                if (digitsOnly.length < 10) {
                                  return 'Invalid phone';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: widget.zipCodeController,
                            label: 'ZIP Code',
                            hint: 'ZIP',
                            prefixIcon: Icons.location_on_outlined,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            showClearButton: true,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (value.length != 5) {
                                  return 'Must be 5 digits';
                                }
                                if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                                  return 'Invalid ZIP';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Error message
          SearchErrorBanner(errorMessage: widget.errorMessage),

          // Search button
          CustomButton(
            text: 'Search Registry',
            onPressed: widget.onSearch,
            variant: ButtonVariant.primary,
            size: ButtonSize.large,
            icon: Icons.search_rounded,
            isLoading: widget.isLoading,
          ),
          const SizedBox(height: 12),

          // Clear button
          CustomButton(
            text: 'Clear Form',
            onPressed: widget.isLoading ? null : widget.onClear,
            variant: ButtonVariant.text,
            size: ButtonSize.medium,
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }
}
```

### Step 7.2: Update search_screen.dart

**Replace lines 654-962 with**:

```dart
import '../widgets/search/name_search_form.dart';

// In build() conditional forms:
if (_searchMode == 0) ...[
  NameSearchForm(
    formKey: _formKey,
    firstNameController: _firstNameController,
    lastNameController: _lastNameController,
    ageController: _ageController,
    stateController: _stateController,
    phoneController: _phoneController,
    zipCodeController: _zipCodeController,
    isLoading: _isLoading,
    errorMessage: _errorMessage,
    onSearch: _performSearch,
    onClear: _clearForm,
  ),
],
```

### Step 7.3: Test (20 min)

- [ ] Both required fields validate
- [ ] Optional filters expand/collapse
- [ ] All 4 optional filters work
- [ ] Age validation (18-120)
- [ ] State validation (2 letters)
- [ ] Phone validation (10 digits)
- [ ] ZIP validation (5 digits)
- [ ] Search button calls `_performSearch`
- [ ] Clear button clears all fields
- [ ] Form validation triggers
- [ ] Loading state works

**Checkpoint**: `git add . && git commit -m "extract: NameSearchForm widget"`

---

## Phase 8: Final Cleanup & Testing (1 hour)

### Step 8.1: Update Imports in search_screen.dart

**Remove unused imports** (lines 10-13):

```dart
// DELETE these (now in extracted widgets):
// import '../theme/app_text_styles.dart';
// import '../widgets/custom_button.dart';
// import '../widgets/custom_text_field.dart';
```

**Add new imports**:

```dart
// Add at top after existing imports
import '../widgets/search/credit_badge.dart';
import '../widgets/search/search_tab_bar.dart';
import '../widgets/search/search_error_banner.dart';
import '../widgets/search/name_search_form.dart';
import '../widgets/search/phone_search_form.dart';
import '../widgets/search/image_search_form.dart';
```

### Step 8.2: Verify Final search_screen.dart Structure

**Expected structure** (~200 lines):

```dart
// Imports (25 lines)
import 'dart:async';
import 'dart:io';
...
import '../widgets/search/image_search_form.dart';

// SearchScreen widget (6 lines)
class SearchScreen extends StatefulWidget { ... }

// State class (170 lines)
class _SearchScreenState extends State<SearchScreen> {
  // Controllers & state (50 lines)
  final _formKey = GlobalKey<FormState>();
  ...
  int _searchMode = 0;
  File? _selectedImage;

  // Lifecycle methods (50 lines)
  @override
  void initState() { ... }
  ...
  @override
  void dispose() { ... }

  // Action methods (70 lines)
  Future<void> _performSearch() { ... }
  Future<void> _performPhoneSearch() { ... }
  Future<void> _performImageSearch() { ... }
  ...
  void _clearForm() { ... }

  // BUILD METHOD (~50 lines) ✅
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.palePink,
      appBar: AppBar(
        title: Text('Search Registry'),
        actions: [CreditBadge(credits: _currentCredits)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(...),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SearchTabBar(
                  selectedMode: _searchMode,
                  onModeChanged: (mode) => setState(() => _searchMode = mode),
                ),
                const SizedBox(height: 16),

                // Form based on mode
                if (_searchMode == 0) ...[
                  NameSearchForm(
                    formKey: _formKey,
                    firstNameController: _firstNameController,
                    lastNameController: _lastNameController,
                    ageController: _ageController,
                    stateController: _stateController,
                    phoneController: _phoneController,
                    zipCodeController: _zipCodeController,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    onSearch: _performSearch,
                    onClear: _clearForm,
                  ),
                ] else if (_searchMode == 1) ...[
                  PhoneSearchForm(
                    phoneController: _phoneNumberController,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    onSearch: _performPhoneSearch,
                    onClear: _clearPhoneForm,
                  ),
                ] else ...[
                  ImageSearchForm(
                    urlController: _urlController,
                    selectedImage: _selectedImage,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    onPickGallery: _pickFromGallery,
                    onTakePhoto: _takePhoto,
                    onSearch: _performImageSearch,
                    onClear: _clearImageSelection,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### Step 8.3: Run Flutter Analyze

```bash
cd /Users/robertburns/Projects/RedFlag/safety_app
flutter analyze
```

**Expected**: No errors or warnings

### Step 8.4: Full Regression Test

**Compare against screenshots from Phase 1.3**:

- [ ] Name search form looks identical
- [ ] Phone search form looks identical
- [ ] Image search form looks identical
- [ ] Tab switching works
- [ ] All interactions work
- [ ] No layout shifts or flickers

**Test all functionality**:
- [ ] Name search: valid input → submits
- [ ] Name search: invalid input → shows error
- [ ] Name search: optional filters work
- [ ] Phone search: valid phone → submits
- [ ] Phone search: invalid phone → shows error
- [ ] Image search: gallery picker works
- [ ] Image search: camera works
- [ ] Image search: URL input works
- [ ] Credit badge updates correctly
- [ ] Error messages display correctly
- [ ] Loading states work
- [ ] Clear buttons work

### Step 8.5: Performance Verification

**Test that only active form rebuilds**:

1. Add debug print to each form widget's build()
2. Switch tabs
3. Verify only selected tab rebuilds

**Expected**: Only active form prints "build()"

### Step 8.6: Hot Reload Test

```bash
# Make a small change (e.g., change button text)
# Press 'r' in terminal
```

**Expected**: Hot reload works, changes appear instantly

**Checkpoint**: `git add . && git commit -m "refactor: search_screen complete - 85% reduction"`

---

## Phase 9: Documentation & Cleanup (30 minutes)

### Step 9.1: Add Widget Documentation

**Add README in widgets/search/**:

**File**: `lib/widgets/search/README.md`

```markdown
# Search Widgets

Reusable form components for the search screen.

## Components

### CreditBadge
- **Purpose**: Display current credit count
- **State**: Stateless (receives credits as param)
- **Location**: AppBar actions

### SearchTabBar
- **Purpose**: 3-tab segmented control (Name/Phone/Image)
- **State**: Stateless (callback for selection)
- **Usage**: Top of search form

### SearchErrorBanner
- **Purpose**: Display error messages
- **State**: Stateless (receives error as param)
- **Usage**: All 3 search forms

### NameSearchForm
- **Purpose**: Name search with optional filters
- **State**: Stateful (manages filter expansion)
- **Controllers**: 6 (firstName, lastName, age, state, phone, zip)
- **Validation**: Form validation for all fields

### PhoneSearchForm
- **Purpose**: Phone number reverse lookup
- **State**: Stateless
- **Controllers**: 1 (phoneNumber)
- **Validation**: 10-digit US phone format

### ImageSearchForm
- **Purpose**: Image reverse search
- **State**: Stateless
- **Controllers**: 1 (url)
- **Features**: Gallery picker, camera, URL input

## State Management

All widgets follow parent-controller pattern:
- Controllers created in parent (SearchScreen)
- Callbacks passed to children
- Forms call parent methods for actions
- Parent manages all state (_isLoading, _errorMessage, etc.)

## Testing

See `test/widgets/search/` for unit tests.
```

### Step 9.2: Update CODEBASE_ANALYSIS_REFACTORING_PLAN.md

**Mark Phase 3 as complete**:

```markdown
### 🔴 #1 PRIORITY: `search_screen.dart` (COMPLETED ✅)

**Before**: 1,364 lines
**After**: ~200 lines
**Reduction**: 85%
**Date Completed**: [Your Date]

**Extracted Widgets**:
- ✅ CreditBadge (24 lines)
- ✅ SearchTabBar (164 lines)
- ✅ SearchErrorBanner (40 lines)
- ✅ NameSearchForm (308 lines)
- ✅ PhoneSearchForm (130 lines)
- ✅ ImageSearchForm (235 lines)

**Total Lines Extracted**: 901 lines
**Remaining in search_screen.dart**: ~200 lines
```

### Step 9.3: Create Summary Document

**File**: `SEARCH_SCREEN_REFACTORING_SUMMARY.md`

```markdown
# search_screen.dart Refactoring Summary

## Overview

Successfully refactored `search_screen.dart` from 1,364 lines to ~200 lines (85% reduction) by extracting UI into 6 reusable widgets.

## Results

### Before
- **Size**: 1,364 lines
- **Structure**: Monolithic build() method (900+ lines)
- **Testability**: Impossible to unit test UI components
- **Performance**: Entire screen rebuilt on any state change
- **Maintainability**: High risk of bugs when making changes

### After
- **Size**: ~200 lines (85% reduction)
- **Structure**: Clean separation - 6 extracted widgets
- **Testability**: Each form testable independently
- **Performance**: Only active form rebuilds
- **Maintainability**: Changes scoped to single component

## Files Created

```
lib/widgets/search/
├── README.md                  (Documentation)
├── credit_badge.dart          (24 lines - AppBar badge)
├── search_tab_bar.dart        (80 lines - Tab switcher)
├── search_error_banner.dart   (40 lines - Error display)
├── name_search_form.dart      (308 lines - Name search)
├── phone_search_form.dart     (130 lines - Phone search)
└── image_search_form.dart     (235 lines - Image search)
```

## Benefits Achieved

✅ **Improved Performance**: Only active form rebuilds on state change
✅ **Better Testability**: Can unit test individual components
✅ **Code Reusability**: Widgets can be used elsewhere
✅ **Easier Maintenance**: Bug fixes scoped to single file
✅ **Clearer Structure**: Obvious where to find code
✅ **Better Reviews**: Smaller diffs, easier to review

## Testing Results

All functionality verified identical to original:
- ✅ Name search form with optional filters
- ✅ Phone search with validation
- ✅ Image search with gallery/camera/URL
- ✅ Tab switching
- ✅ Loading states
- ✅ Error handling
- ✅ Form validation
- ✅ Credit badge updates
- ✅ Hot reload works

## Time Spent

- **Estimated**: 3-5 hours
- **Actual**: [Your Time]

## Next Steps

Consider extracting:
1. `results_screen.dart` (653 lines → ~150 lines)
2. Refund logic duplication (create RefundMixin)

---

**Date**: [Your Date]
**Status**: ✅ Complete
```

**Checkpoint**: `git add . && git commit -m "docs: add refactoring summary"`

---

## Rollback Strategy

### If Issues Arise

**Quick Rollback** (revert all changes):

```bash
git checkout main -- safety_app/lib/screens/search_screen.dart
rm -rf safety_app/lib/widgets/search
git checkout main
```

**Partial Rollback** (keep some widgets):

```bash
# Revert just one widget
git checkout HEAD~1 -- safety_app/lib/widgets/search/name_search_form.dart

# Or revert main file only
git checkout HEAD~1 -- safety_app/lib/screens/search_screen.dart
```

---

## Success Criteria

✅ **All tests pass** (functionality identical)
✅ **Flutter analyze passes** (no errors/warnings)
✅ **Hot reload works** (development flow preserved)
✅ **Performance improved** (only active form rebuilds)
✅ **File size reduced** (1,364 → ~200 lines)
✅ **Code coverage enabled** (widgets are testable)

---

## Post-Refactoring Next Steps

### Immediate (Optional)

1. **Write unit tests** for extracted widgets
   - `test/widgets/search/credit_badge_test.dart`
   - `test/widgets/search/search_tab_bar_test.dart`
   - etc.

2. **Add integration tests** for search flows
   - Name search end-to-end
   - Phone search end-to-end
   - Image search end-to-end

### Future

1. **Extract results_screen.dart** (653 → ~150 lines)
2. **Create RefundMixin** (remove duplication)
3. **Extract common form widgets** (if patterns emerge)

---

## Estimated Timeline

| Phase | Task | Time | Cumulative |
|-------|------|------|------------|
| 1 | Setup & prep | 30 min | 30 min |
| 2 | CreditBadge | 30 min | 1 hour |
| 3 | SearchTabBar | 45 min | 1.75 hours |
| 4 | SearchErrorBanner | 30 min | 2 hours |
| 5 | PhoneSearchForm | 1 hour | 3 hours |
| 6 | ImageSearchForm | 1.5 hours | 4.5 hours |
| 7 | NameSearchForm | 2 hours | 6.5 hours |
| 8 | Cleanup & testing | 1 hour | 7.5 hours |
| 9 | Documentation | 30 min | **8 hours** |

**Total**: ~8 hours (upper end of 3-5 hour estimate)

---

## Risk Mitigation

**Low Risk ✅**:
- CreditBadge, SearchTabBar, SearchErrorBanner
- Pure UI, minimal state

**Medium Risk ⚠️**:
- PhoneSearchForm, ImageSearchForm
- Single controller, straightforward callbacks

**Higher Risk 🔴**:
- NameSearchForm
- Multiple controllers, internal expansion state

**Mitigation**:
- Git checkpoints after each phase
- Test after each extraction
- Keep screenshots for visual regression
- Rollback strategy documented

---

## Questions to Ask User Before Starting

1. **Timing**: Want to do this now or ship v1.1.8 first?
2. **Testing**: Manual testing OK or want automated tests too?
3. **Scope**: Just search_screen or also results_screen?
4. **Branch**: Create feature branch or work on main?

---

**Status**: Plan Complete ✅
**Ready to Execute**: Yes
**Next Action**: User approval to proceed

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

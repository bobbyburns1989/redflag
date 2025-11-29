import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/search_service.dart';
import '../services/image_search_service.dart';
import '../services/phone_search_service.dart' as phone_service;
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dialogs/out_of_credits_dialog.dart';
import '../widgets/page_transitions.dart';
import '../widgets/search/credit_badge.dart';
import '../widgets/search/search_tab_bar.dart';
import '../widgets/search/search_error_banner.dart';
import '../widgets/search/phone_search_form.dart';
import '../widgets/search/image_search_form.dart';
import 'results_screen.dart';
import 'image_results_screen.dart';
import 'phone_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _stateController = TextEditingController();
  final _phoneController = TextEditingController(); // For name search filters
  final _zipCodeController = TextEditingController();
  final _urlController = TextEditingController();
  final _phoneNumberController = TextEditingController(); // For phone search
  final _searchService = SearchService();
  final _imageSearchService = ImageSearchService();
  final _phoneSearchService = phone_service.PhoneSearchService();
  final _imagePicker = ImagePicker();

  bool _isLoading = false;
  String? _errorMessage;
  bool _showOptionalFilters = false;
  int _currentCredits = 0;
  StreamSubscription<int>? _creditsSubscription;

  // Search mode: 0 = Name Search, 1 = Phone Search, 2 = Image Search
  int _searchMode = 0;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh credits when user returns from other screens (like Store)
    if (mounted) {
      _refreshCreditsQuietly();
    }
  }

  /// Refresh credits without showing loading state
  Future<void> _refreshCreditsQuietly() async {
    try {
      final credits = await _searchService.getCurrentCredits();
      if (mounted) {
        setState(() => _currentCredits = credits);
      }
      if (kDebugMode) {
        print('🔄 [SEARCH] Credits refreshed: $credits');
      }
    } catch (e) {
      // Silently fail - real-time stream will update eventually
      if (kDebugMode) {
        print('⚠️ [SEARCH] Failed to refresh credits: $e');
      }
    }
  }

  Future<void> _loadCredits() async {
    if (kDebugMode) {
      print('🔍 [SEARCH] Loading credits...');
    }

    try {
      final credits = await _searchService.getCurrentCredits();
      if (kDebugMode) {
        print('✅ [SEARCH] Loaded credits: $credits');
      }
      setState(() => _currentCredits = credits);

      // Watch for real-time credit changes
      _creditsSubscription = _searchService.watchCredits().listen((credits) {
        if (kDebugMode) {
          print('🔄 [SEARCH] Real-time credit update: $credits');
        }
        if (mounted) {
          setState(() => _currentCredits = credits);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ [SEARCH] Error loading credits: $e');
      }
      // User not logged in or error - credits stay at 0
    }
  }

  @override
  void dispose() {
    _creditsSubscription?.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _stateController.dispose();
    _phoneController.dispose();
    _zipCodeController.dispose();
    _urlController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Image search methods
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _urlController.clear();
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to select image');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _urlController.clear();
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to take photo');
    }
  }

  void _clearImageSelection() {
    setState(() {
      _selectedImage = null;
      _urlController.clear();
      _errorMessage = null;
    });
  }

  Future<void> _performImageSearch() async {
    if (_selectedImage == null && _urlController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please select an image or enter a URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = _selectedImage != null
          ? await _imageSearchService.searchByImage(_selectedImage!)
          : await _imageSearchService.searchByUrl(_urlController.text.trim());

      if (!mounted) return;

      final updatedCredits = await _searchService.getCurrentCredits();
      if (mounted) setState(() => _currentCredits = updatedCredits);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.primaryPink,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.push(
          context,
          PageTransitions.slideAndFade(ImageResultsScreen(result: result)),
        );
      }
    } on InsufficientCreditsException catch (e) {
      if (mounted) {
        setState(() => _currentCredits = e.currentCredits);
        showOutOfCreditsDialog(context, e.currentCredits);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'An unexpected error occurred');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _performSearch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _searchService.searchByName(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        zipCode: _zipCodeController.text.trim().isEmpty
            ? null
            : _zipCodeController.text.trim(),
        age: _ageController.text.trim().isEmpty
            ? null
            : _ageController.text.trim(),
        state: _stateController.text.trim().isEmpty
            ? null
            : _stateController.text.trim(),
      );

      if (!mounted) return;

      // Immediately refresh credits to show deduction
      final updatedCredits = await _searchService.getCurrentCredits();
      if (mounted) {
        setState(() {
          _currentCredits = updatedCredits;
        });
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Found ${result.totalResults} ${result.totalResults == 1 ? 'result' : 'results'}',
            ),
            backgroundColor: AppColors.primaryPink,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      if (mounted) {
        Navigator.push(
          context,
          PageTransitions.slideAndFade(ResultsScreen(searchResult: result)),
        );
      }
    } on InsufficientCreditsException catch (e) {
      if (mounted) {
        // Immediately sync the badge with the accurate credit count
        setState(() {
          _currentCredits = e.currentCredits;
        });
        _showOutOfCreditsDialog(e.currentCredits);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.deepPink,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _performSearch,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred'),
            backgroundColor: AppColors.deepPink,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _ageController.clear();
    _stateController.clear();
    _phoneController.clear();
    _zipCodeController.clear();
    setState(() {
      _errorMessage = null;
    });
  }

  void _clearPhoneForm() {
    _phoneNumberController.clear();
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _performPhoneSearch() async {
    final phoneNumber = _phoneNumberController.text.trim();

    if (phoneNumber.isEmpty) {
      setState(() => _errorMessage = 'Please enter a phone number');
      return;
    }

    // Validate phone format offline first
    if (!_phoneSearchService.validatePhoneFormat(phoneNumber)) {
      setState(() => _errorMessage = 'Please enter a valid 10-digit US phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _phoneSearchService.searchPhoneWithCredit(phoneNumber);

      if (!mounted) return;

      // Refresh credits
      final updatedCredits = await _searchService.getCurrentCredits();
      if (mounted) setState(() => _currentCredits = updatedCredits);

      if (mounted) {
        final callerName = result.callerName ?? 'Unknown';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phone lookup complete: $callerName'),
            backgroundColor: AppColors.primaryPink,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.push(
          context,
          PageTransitions.slideAndFade(PhoneResultsScreen(result: result)),
        );
      }
    } on phone_service.InsufficientCreditsException catch (e) {
      if (mounted) {
        final match = RegExp(r'You have (\d+) credits').firstMatch(e.message);
        final credits = match != null ? int.parse(match.group(1)!) : 0;
        setState(() => _currentCredits = credits);
        showOutOfCreditsDialog(context, credits);
      }
    } on phone_service.PhoneSearchException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } on phone_service.RateLimitException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'An unexpected error occurred');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showOutOfCreditsDialog(int currentCredits) {
    showOutOfCreditsDialog(context, currentCredits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.palePink,
      appBar: AppBar(
        title: Text(
          'Search Registry',
          style: TextStyle(
            color: AppColors.primaryPink,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.darkText,
        actions: [
          CreditBadge(credits: _currentCredits),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.softPink.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SearchTabBar(
                    selectedMode: _searchMode,
                    onModeChanged: (mode) => setState(() => _searchMode = mode),
                  ),
                  const SizedBox(height: 16),

                  // Conditional content based on search mode
                  if (_searchMode == 0) ...[
                    // ======== NAME SEARCH FORM ========
                    // Disclaimer banner
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.palePink,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                      controller: _firstNameController,
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
                      controller: _lastNameController,
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

                    // Optional Filters Section - polished styling
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
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
                          setState(() {
                            _showOptionalFilters = expanded;
                          });
                        },
                        children: [
                          Column(
                            children: [
                              // Row 1: Age + State
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _ageController,
                                      label: 'Age',
                                      hint: 'Age',
                                      prefixIcon: Icons.cake_outlined,
                                      keyboardType: TextInputType.number,
                                      maxLength: 3,
                                      showClearButton: true,
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          final age = int.tryParse(value);
                                          if (age == null ||
                                              age < 18 ||
                                              age > 120) {
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
                                      controller: _stateController,
                                      label: 'State',
                                      hint: 'State',
                                      prefixIcon: Icons.map_outlined,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      maxLength: 2,
                                      showClearButton: true,
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          if (value.length != 2) {
                                            return 'Must be 2 letters';
                                          }
                                          if (!RegExp(
                                            r'^[A-Z]{2}$',
                                          ).hasMatch(value.toUpperCase())) {
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
                                      controller: _phoneController,
                                      label: 'Phone',
                                      hint: 'Phone',
                                      prefixIcon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      showClearButton: true,
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          final digitsOnly = value.replaceAll(
                                            RegExp(r'\D'),
                                            '',
                                          );
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
                                      controller: _zipCodeController,
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
                                          if (!RegExp(
                                            r'^\d{5}$',
                                          ).hasMatch(value)) {
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

                    SearchErrorBanner(errorMessage: _errorMessage),

                    // Search button - prominent
                    CustomButton(
                      text: 'Search Registry',
                      onPressed: _performSearch,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.large,
                      icon: Icons.search_rounded,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 12),

                    // Clear button - subtle
                    CustomButton(
                      text: 'Clear Form',
                      onPressed: _isLoading ? null : _clearForm,
                      variant: ButtonVariant.text,
                      size: ButtonSize.medium,
                      icon: Icons.refresh_rounded,
                    ),
                  ] else if (_searchMode == 1) ...[
                    // ======== PHONE SEARCH FORM ========
                    PhoneSearchForm(
                      phoneNumberController: _phoneNumberController,
                      onSearch: _performPhoneSearch,
                      onClear: _clearPhoneForm,
                      errorMessage: _errorMessage,
                      isLoading: _isLoading,
                    ),
                  ] else ...[
                    // ======== IMAGE SEARCH FORM ========
                    ImageSearchForm(
                      selectedImage: _selectedImage,
                      urlController: _urlController,
                      onPickFromGallery: _pickFromGallery,
                      onTakePhoto: _takePhoto,
                      onClearImage: _clearImageSelection,
                      onSearch: _performImageSearch,
                      errorMessage: _errorMessage,
                      isLoading: _isLoading,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

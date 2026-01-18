import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:image_picker/image_picker.dart';
import '../services/search_service.dart';
import '../services/image_search_service.dart';
import '../services/phone_search_service.dart' as phone_service;
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/dialogs/out_of_credits_dialog.dart';
import '../widgets/page_transitions.dart';
import '../widgets/search/credit_badge.dart';
import '../widgets/search/search_mode_selector.dart';
import '../widgets/search/phone_search_form.dart';
import '../widgets/search/image_search_form.dart';
import '../widgets/search/name_search_form.dart';
import '../widgets/search/welcome_header.dart';
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
      setState(
        () => _errorMessage = 'Please enter a valid 10-digit US phone number',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _phoneSearchService.searchPhoneWithCredit(
        phoneNumber,
      );

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

  /// Builds the current search form based on selected mode.
  /// Uses ValueKey to trigger AnimatedSwitcher transitions.
  Widget _buildCurrentForm() {
    switch (_searchMode) {
      case 0:
        return NameSearchForm(
          key: const ValueKey<int>(0),
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          ageController: _ageController,
          stateController: _stateController,
          phoneController: _phoneController,
          zipCodeController: _zipCodeController,
          showOptionalFilters: _showOptionalFilters,
          onOptionalFiltersChanged: (expanded) {
            setState(() => _showOptionalFilters = expanded);
          },
          onSearch: _performSearch,
          onClear: _clearForm,
          errorMessage: _errorMessage,
          isLoading: _isLoading,
        );
      case 1:
        return PhoneSearchForm(
          key: const ValueKey<int>(1),
          phoneNumberController: _phoneNumberController,
          onSearch: _performPhoneSearch,
          onClear: _clearPhoneForm,
          errorMessage: _errorMessage,
          isLoading: _isLoading,
        );
      case 2:
      default:
        return ImageSearchForm(
          key: const ValueKey<int>(2),
          selectedImage: _selectedImage,
          urlController: _urlController,
          onPickFromGallery: _pickFromGallery,
          onTakePhoto: _takePhoto,
          onClearImage: _clearImageSelection,
          onSearch: _performImageSearch,
          errorMessage: _errorMessage,
          isLoading: _isLoading,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.palePink, AppColors.lightPink],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            title: Text(
              'Search Registry',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
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
            actions: [CreditBadge.onDark(credits: _currentCredits)],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WelcomeHeader(),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, AppColors.softWhite],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.softPink.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SearchModeSelector(
                            selectedMode: _searchMode,
                            onModeChanged: (mode) =>
                                setState(() => _searchMode = mode),
                          ),
                          const SizedBox(height: 20),

                          // Animated form switching with smooth transitions
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                // Respect reduced motion setting
                                if (MediaQuery.of(context).disableAnimations) {
                                  return child;
                                }
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.03, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildCurrentForm(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

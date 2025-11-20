import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/page_transitions.dart';
import 'results_screen.dart';

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
  final _phoneController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _searchService = SearchService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _showOptionalFilters = false;
  int _currentCredits = 0;
  StreamSubscription<int>? _creditsSubscription;

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
    super.dispose();
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

  void _showOutOfCreditsDialog(int currentCredits) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.credit_card_off, color: AppColors.primaryPink),
            const SizedBox(width: 12),
            const Text('Out of Credits'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have $currentCredits credit${currentCredits == 1 ? '' : 's'} remaining.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Purchase more credits to continue searching.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/store');
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Get Credits'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'search_title',
          child: Material(
            color: Colors.transparent,
            child: const Text('Search Registry'),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        foregroundColor: Colors.white,
        actions: [
          // Credit balance display
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '$_currentCredits',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.screenPaddingAll,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Disclaimer card - compact
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightPink,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.softPink, width: 1),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.deepPink,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Results are potential matches. Verify independently.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.deepPink,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Required Fields Section
                Text(
                  'REQUIRED FIELDS',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.primaryPink,
                  ),
                ),
                const SizedBox(height: 4),

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
                const SizedBox(height: 6),

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
                const SizedBox(height: 8),

                // Optional Filters Section
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  title: Text(
                    'OPTIONAL FILTERS',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.primaryPink,
                    ),
                  ),
                  subtitle: _showOptionalFilters
                      ? null
                      : Text(
                          'Tap to show additional search filters',
                          style: AppTextStyles.caption,
                        ),
                  initiallyExpanded: _showOptionalFilters,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _showOptionalFilters = expanded;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      child: Column(
                        children: [
                          // Row 1: Age + State
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _ageController,
                                  label: 'Age',
                                  hint: 'Age',
                                  prefixIcon: Icons.cake,
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  controller: _stateController,
                                  label: 'State',
                                  hint: 'State',
                                  prefixIcon: Icons.map,
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
                          const SizedBox(height: 6),

                          // Row 2: Phone + ZIP
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _phoneController,
                                  label: 'Phone',
                                  hint: 'Phone',
                                  prefixIcon: Icons.phone,
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  controller: _zipCodeController,
                                  label: 'ZIP Code',
                                  hint: 'ZIP',
                                  prefixIcon: Icons.location_on,
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
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Helper text
                Text(
                  '* Required fields',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),

                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.errorRose,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.rose, width: 1),
                    ),
                    padding: AppSpacing.cardPaddingAll,
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.deepPink),
                        AppSpacing.horizontalSpaceSm,
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.deepPink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Search button
                CustomButton(
                  text: 'Search Registry',
                  onPressed: _performSearch,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.medium,
                  icon: Icons.search,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 8),

                // Clear button
                CustomButton(
                  text: 'Clear Form',
                  onPressed: _isLoading ? null : _clearForm,
                  variant: ButtonVariant.outlined,
                  size: ButtonSize.medium,
                  icon: Icons.clear_all,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

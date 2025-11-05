import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/search_result.dart';
import '../theme/app_colors.dart';
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

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
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
      final apiService = ApiService();
      final result = await apiService.searchByName(
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

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${result.totalResults} ${result.totalResults == 1 ? 'result' : 'results'}'),
          backgroundColor: AppColors.primaryPink,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(searchResult: result),
        ),
      );
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Registry'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.appBarGradient,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Disclaimer card
              Card(
                color: AppColors.lightPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.softPink, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.deepPink, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search results are potential matches only. Always verify independently.',
                          style: TextStyle(
                            color: AppColors.deepPink,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

                // First name field (required)
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name *',
                    hintText: 'Enter first name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
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
                const SizedBox(height: 10),

                // Last name field (required)
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name *',
                    hintText: 'Enter last name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
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
                const SizedBox(height: 10),

                // Age field (optional)
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age (Optional)',
                    hintText: 'Enter age',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final age = int.tryParse(value);
                      if (age == null || age < 18 || age > 120) {
                        return 'Please enter a valid age (18-120)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // State field (optional)
                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State (Optional)',
                    hintText: 'e.g., CA, NY, TX',
                    prefixIcon: Icon(Icons.map),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 2,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length != 2) {
                        return 'State must be 2 letters';
                      }
                      if (!RegExp(r'^[A-Z]{2}$').hasMatch(value.toUpperCase())) {
                        return 'Please enter valid state code';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Phone number field (optional)
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    hintText: 'Enter phone number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      // Basic phone validation
                      final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                      if (digitsOnly.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // ZIP code field (optional)
                TextFormField(
                  controller: _zipCodeController,
                  decoration: const InputDecoration(
                    labelText: 'ZIP Code (Optional)',
                    hintText: 'Enter ZIP code',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length != 5) {
                        return 'ZIP code must be 5 digits';
                      }
                      if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                        return 'ZIP code must contain only numbers';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),

                // Helper text
                Text(
                  '* Required fields',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),

                // Error message
                if (_errorMessage != null)
                  Card(
                    color: AppColors.errorRose,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.rose, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppColors.deepPink),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: AppColors.deepPink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 10),

                // Search button
                Container(
                  decoration: BoxDecoration(
                    gradient: _isLoading ? null : AppColors.pinkGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isLoading ? [] : AppColors.softPinkShadow,
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _performSearch,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: _isLoading ? AppColors.lightPink : Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
                            ),
                          )
                        : const Text(
                            'Search Registry',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),

                // Clear button
                OutlinedButton(
                  onPressed: _isLoading ? null : _clearForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.primaryPink, width: 2),
                    foregroundColor: AppColors.primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Clear Form',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

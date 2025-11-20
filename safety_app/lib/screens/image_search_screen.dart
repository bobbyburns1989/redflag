import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_search_service.dart';
import '../services/api_service.dart';
import '../services/search_service.dart' show SearchService, InsufficientCreditsException;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dialogs/out_of_credits_dialog.dart';
import '../widgets/page_transitions.dart';
import 'image_results_screen.dart';

/// Screen for performing reverse image searches
///
/// Users can:
/// - Take a photo with camera
/// - Select from gallery
/// - Enter an image URL
///
/// Results show where the image appears online (catfish/scam detection)
class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  final _imageSearchService = ImageSearchService();
  final _searchService = SearchService();
  final _imagePicker = ImagePicker();
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentCredits = 0;
  StreamSubscription<int>? _creditsSubscription;

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  @override
  void dispose() {
    _creditsSubscription?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadCredits() async {
    try {
      final credits = await _searchService.getCurrentCredits();
      setState(() => _currentCredits = credits);

      _creditsSubscription = _searchService.watchCredits().listen((credits) {
        if (mounted) {
          setState(() => _currentCredits = credits);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading credits: $e');
      }
    }
  }

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
      setState(() {
        _errorMessage = 'Failed to select image. Please try again.';
      });
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
      setState(() {
        _errorMessage = 'Failed to take photo. Please try again.';
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedImage = null;
      _urlController.clear();
      _errorMessage = null;
    });
  }

  Future<void> _performSearch() async {
    // Validate input
    if (_selectedImage == null && _urlController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please select an image or enter a URL';
      });
      return;
    }

    // Validate URL if provided
    if (_selectedImage == null && !_formKey.currentState!.validate()) {
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

      // Refresh credits
      final updatedCredits = await _searchService.getCurrentCredits();
      if (mounted) {
        setState(() => _currentCredits = updatedCredits);
      }

      // Show success message
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
      }

      // Navigate to results
      if (mounted) {
        Navigator.push(
          context,
          PageTransitions.slideAndFade(
            ImageResultsScreen(result: result),
          ),
        );
      }
    } on InsufficientCreditsException catch (e) {
      if (mounted) {
        setState(() => _currentCredits = e.currentCredits);
        showOutOfCreditsDialog(context, e.currentCredits);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.palePink,
      appBar: AppBar(
        title: Text(
          'Image Search',
          style: TextStyle(
            color: AppColors.primaryPink,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.darkText,
        actions: [
          // Credit balance display
          Container(
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
                  '$_currentCredits',
                  style: TextStyle(
                    color: AppColors.primaryPink,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
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
          child: Column(
            children: [
              // Main card
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info banner
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
                    const SizedBox(height: 20),

                    // Image selection buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildPickerButton(
                            icon: Icons.photo_library_outlined,
                            label: 'Gallery',
                            onTap: _isLoading ? null : _pickFromGallery,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPickerButton(
                            icon: Icons.camera_alt_outlined,
                            label: 'Camera',
                            onTap: _isLoading ? null : _takePhoto,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Selected image preview
                    if (_selectedImage != null) ...[
                      Stack(
                        children: [
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _clearSelection,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // OR divider
                    if (_selectedImage == null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.softPink,
                            ),
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
                            child: Container(
                              height: 1,
                              color: AppColors.softPink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // URL input
                      Form(
                        key: _formKey,
                        child: CustomTextField(
                          controller: _urlController,
                          label: 'Image URL',
                          hint: 'https://example.com/image.jpg',
                          prefixIcon: Icons.link,
                          keyboardType: TextInputType.url,
                          showClearButton: true,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final uri = Uri.tryParse(value);
                              if (uri == null || !uri.hasScheme) {
                                return 'Please enter a valid URL';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Error message
                    if (_errorMessage != null) ...[
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
                                _errorMessage!,
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

                    // Search button
                    CustomButton(
                      text: 'Search Image',
                      onPressed: _performSearch,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.large,
                      icon: Icons.image_search,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Help text
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What this does',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildHelpItem(
                      Icons.check_circle_outline,
                      'Finds where the image appears online',
                    ),
                    _buildHelpItem(
                      Icons.check_circle_outline,
                      'Helps detect catfishing and fake profiles',
                    ),
                    _buildHelpItem(
                      Icons.check_circle_outline,
                      'Shows if image is a stock photo',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.palePink,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.softPink,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primaryPink,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primaryPink,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mediumText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

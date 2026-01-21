import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../custom_button.dart';
import '../custom_text_field.dart';
import 'search_error_banner.dart';

/// Image search form widget
///
/// Displays a form for reverse image searching with:
/// - Info banner explaining the feature
/// - Image selection buttons (Gallery and Camera)
/// - Selected image preview with close button
/// - URL input field (alternative to image upload)
/// - Error display
/// - Search and clear buttons
class ImageSearchForm extends StatelessWidget {
  final File? selectedImage;
  final TextEditingController urlController;
  final VoidCallback onPickFromGallery;
  final VoidCallback onTakePhoto;
  final VoidCallback onClearImage;
  final VoidCallback onSearch;
  final String? errorMessage;
  final bool isLoading;
  final bool showClearButton;

  const ImageSearchForm({
    super.key,
    required this.selectedImage,
    required this.urlController,
    required this.onPickFromGallery,
    required this.onTakePhoto,
    required this.onClearImage,
    required this.onSearch,
    required this.errorMessage,
    required this.isLoading,
    this.showClearButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Info banner (compact)
        Container(
          decoration: BoxDecoration(
            color: AppColors.palePink,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryPink,
                size: 13,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Check if an image appears elsewhere online',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mediumText,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Image selection buttons (compact)
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: isLoading ? null : onPickFromGallery,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.palePink,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.softPink),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 20,
                        color: AppColors.primaryPink,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Gallery',
                        style: TextStyle(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: isLoading ? null : onTakePhoto,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.palePink,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.softPink),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 20,
                        color: AppColors.primaryPink,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Camera',
                        style: TextStyle(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Selected image preview (compact)
        if (selectedImage != null) ...[
          Stack(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onClearImage,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // OR divider and URL input (only if no image selected)
        if (selectedImage == null) ...[
          Row(
            children: [
              Expanded(child: Container(height: 1, color: AppColors.softPink)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: AppColors.mediumText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Container(height: 1, color: AppColors.softPink)),
            ],
          ),
          const SizedBox(height: 8),

          CustomTextField(
            controller: urlController,
            label: 'Image URL',
            hint: 'https://example.com/image.jpg',
            prefixIcon: Icons.link,
            keyboardType: TextInputType.url,
            showClearButton: true,
          ),
          const SizedBox(height: 10),
        ],

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

        // Clear button - only show when form has content
        if (showClearButton) ...[
          const SizedBox(height: 8),
          CustomButton(
            text: 'Clear',
            onPressed: isLoading ? null : onClearImage,
            variant: ButtonVariant.text,
            size: ButtonSize.small,
          ),
        ],
      ],
    );
  }
}

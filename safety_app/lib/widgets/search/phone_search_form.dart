import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../custom_button.dart';
import '../custom_text_field.dart';
import 'search_error_banner.dart';

/// Phone search form widget
///
/// Displays a form for searching phone numbers with:
/// - Info banner explaining the feature
/// - Phone number input field
/// - Format help text
/// - Error display
/// - Search and clear buttons
class PhoneSearchForm extends StatelessWidget {
  final TextEditingController phoneNumberController;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final String? errorMessage;
  final bool isLoading;

  const PhoneSearchForm({
    super.key,
    required this.phoneNumberController,
    required this.onSearch,
    required this.onClear,
    required this.errorMessage,
    required this.isLoading,
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
          controller: phoneNumberController,
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
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
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

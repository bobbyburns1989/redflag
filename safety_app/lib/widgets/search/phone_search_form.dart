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
  final bool showClearButton;

  const PhoneSearchForm({
    super.key,
    required this.phoneNumberController,
    required this.onSearch,
    required this.onClear,
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
                  'Find caller name and details for any phone number',
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
        const SizedBox(height: 6),

        // Format help text (compact)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.palePink,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 13, color: AppColors.primaryPink),
              const SizedBox(width: 5),
              Text(
                'Enter 10-digit US phone number',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.mediumText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        SearchErrorBanner(errorMessage: errorMessage),

        // Search button
        CustomButton(
          text: 'Search Phone',
          onPressed: onSearch,
          variant: ButtonVariant.primary,
          size: ButtonSize.large,
          icon: Icons.search,
          isLoading: isLoading,
        ),

        // Clear button - only show when form has content
        if (showClearButton) ...[
          const SizedBox(height: 8),
          CustomButton(
            text: 'Clear',
            onPressed: isLoading ? null : onClear,
            variant: ButtonVariant.text,
            size: ButtonSize.small,
          ),
        ],
      ],
    );
  }
}

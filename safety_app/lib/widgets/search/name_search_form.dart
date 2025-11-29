import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../custom_button.dart';
import '../custom_text_field.dart';
import 'search_error_banner.dart';

/// Name search form widget
///
/// Displays a form for searching people by name with optional filters:
/// - Disclaimer banner explaining results
/// - Required fields (First Name, Last Name)
/// - Optional filters (Age, State, Phone, ZIP Code) in an ExpansionTile
/// - Error display
/// - Search and clear buttons
class NameSearchForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController ageController;
  final TextEditingController stateController;
  final TextEditingController phoneController;
  final TextEditingController zipCodeController;
  final bool showOptionalFilters;
  final ValueChanged<bool> onOptionalFiltersChanged;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final String? errorMessage;
  final bool isLoading;

  const NameSearchForm({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.ageController,
    required this.stateController,
    required this.phoneController,
    required this.zipCodeController,
    required this.showOptionalFilters,
    required this.onOptionalFiltersChanged,
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
          controller: firstNameController,
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
          controller: lastNameController,
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
              turns: showOptionalFilters ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.mediumText,
              ),
            ),
            initiallyExpanded: showOptionalFilters,
            onExpansionChanged: onOptionalFiltersChanged,
            children: [
              Column(
                children: [
                  // Row 1: Age + State
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: ageController,
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
                          controller: stateController,
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
                          controller: phoneController,
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
                          controller: zipCodeController,
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

        SearchErrorBanner(errorMessage: errorMessage),

        // Search button - prominent
        CustomButton(
          text: 'Search Registry',
          onPressed: onSearch,
          variant: ButtonVariant.primary,
          size: ButtonSize.large,
          icon: Icons.search_rounded,
          isLoading: isLoading,
        ),
        const SizedBox(height: 12),

        // Clear button - subtle
        CustomButton(
          text: 'Clear Form',
          onPressed: isLoading ? null : onClear,
          variant: ButtonVariant.text,
          size: ButtonSize.medium,
          icon: Icons.refresh_rounded,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Visual card-based selector for switching between search modes.
///
/// Replaces the simple tab bar with larger, more visual cards showing:
/// - Icon for each search type
/// - Title and brief description
/// - Credit cost badge
///
/// Features:
/// - Horizontal scroll for narrow screens
/// - Material + InkWell for proper tap feedback
/// - Semantics for accessibility
/// - Animated selection state
class SearchModeSelector extends StatelessWidget {
  final int selectedMode;
  final ValueChanged<int> onModeChanged;

  const SearchModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildModeCard(
            context: context,
            mode: 0,
            icon: Icons.person_search,
            title: 'Name',
            subtitle: 'Search by name',
            credits: 10,
          ),
          const SizedBox(width: 12),
          _buildModeCard(
            context: context,
            mode: 1,
            icon: Icons.phone,
            title: 'Phone',
            subtitle: 'Lookup number',
            credits: 2,
          ),
          const SizedBox(width: 12),
          _buildModeCard(
            context: context,
            mode: 2,
            icon: Icons.image_search,
            title: 'Image',
            subtitle: 'Reverse search',
            credits: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required int mode,
    required IconData icon,
    required String title,
    required String subtitle,
    required int credits,
  }) {
    final isSelected = selectedMode == mode;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title search, $credits credits',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onModeChanged(mode),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.lightPink : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primaryPink : AppColors.softPink,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryPink.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with animated color
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryPink.withValues(alpha: 0.15)
                        : AppColors.palePink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isSelected
                        ? AppColors.primaryPink
                        : AppColors.mediumText,
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(
                    color: isSelected
                        ? AppColors.primaryPink
                        : AppColors.darkText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),

                // Subtitle
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mediumText,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Credit cost badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryPink.withValues(alpha: 0.1)
                        : AppColors.palePink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$credits cr',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryPink
                          : AppColors.mediumText,
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

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Compact card-based selector for switching between search modes.
///
/// Displays 3 mode cards in a row showing:
/// - Icon for each search type
/// - Title
/// - Credit cost badge
///
/// Features:
/// - Flexible width cards that fill available space (no scrolling)
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
    return Row(
      children: [
        Expanded(
          child: _buildModeCard(
            context: context,
            mode: 0,
            icon: Icons.person_search,
            title: 'Name',
            credits: 10,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildModeCard(
            context: context,
            mode: 1,
            icon: Icons.phone,
            title: 'Phone',
            credits: 2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildModeCard(
            context: context,
            mode: 2,
            icon: Icons.image_search,
            title: 'Image',
            credits: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required int mode,
    required IconData icon,
    required String title,
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
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.lightPink : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryPink : AppColors.softPink,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      // Stronger glow effect for selected state
                      BoxShadow(
                        color: AppColors.primaryPink.withValues(alpha: 0.25),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with animated color (compact)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryPink.withValues(alpha: 0.15)
                        : AppColors.palePink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? AppColors.primaryPink
                        : AppColors.mediumText,
                  ),
                ),
                const SizedBox(height: 6),

                // Title
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(
                    color: isSelected
                        ? AppColors.primaryPink
                        : AppColors.darkText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),

                // Credit cost badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryPink.withValues(alpha: 0.1)
                        : AppColors.palePink,
                    borderRadius: BorderRadius.circular(8),
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

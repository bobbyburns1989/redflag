import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Segmented control for switching between search modes
///
/// Three tabs: Name Search, Phone Search, Image Search.
/// Displays a pill-style selector with smooth animations.
class SearchTabBar extends StatelessWidget {
  final int selectedMode;
  final ValueChanged<int> onModeChanged;

  const SearchTabBar({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.palePink,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTab(
            mode: 0,
            label: 'Name',
            icon: Icons.person_search,
          ),
          _buildTab(
            mode: 1,
            label: 'Phone',
            icon: Icons.phone,
          ),
          _buildTab(
            mode: 2,
            label: 'Image',
            icon: Icons.image_search,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedMode == mode;

    // Credit costs: Name=10, Phone=2, Image=4
    final creditCost = mode == 0 ? 10 : (mode == 1 ? 2 : 4);

    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? AppColors.primaryPink : AppColors.mediumText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primaryPink : AppColors.mediumText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$creditCost credits',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.primaryPink.withValues(alpha: 0.7) : AppColors.mediumText.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

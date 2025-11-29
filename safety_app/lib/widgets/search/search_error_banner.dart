import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Error banner displayed when a search fails
///
/// Shows error messages in a pink banner with an error icon.
/// Automatically handles null errors (widget returns empty if no error).
class SearchErrorBanner extends StatelessWidget {
  final String? errorMessage;

  const SearchErrorBanner({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) return const SizedBox.shrink();

    return Column(
      children: [
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
                  errorMessage!,
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/search_history_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/offender_card.dart';

class SearchHistoryDetailScreen extends StatelessWidget {
  final SearchHistoryEntry entry;

  const SearchHistoryDetailScreen({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy \'at\' h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search info card
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightPink,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.softPink,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.deepPink,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search performed on',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.deepPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dateFormat.format(entry.timestamp),
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.deepPink,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.softPink),
                const SizedBox(height: 12),
                Text(
                  'Search Query',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.deepPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.searchQuery,
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      entry.resultCount > 0 ? Icons.check_circle : Icons.info,
                      color: entry.resultCount > 0
                          ? AppColors.primaryPink
                          : Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.resultCountText,
                      style: AppTextStyles.h4.copyWith(
                        color: entry.resultCount > 0
                            ? AppColors.primaryPink
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (entry.results.isEmpty) ...[
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Results Found',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'No matches were found for this search',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            Text(
              'RESULTS (${entry.resultCount})',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.primaryPink,
              ),
            ),
            const SizedBox(height: 12),

            // Display all offender results
            ...entry.results.map((offender) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: OffenderCard(offender: offender),
              );
            }),

            // Disclaimer at bottom
            Container(
              decoration: BoxDecoration(
                color: AppColors.errorRose,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.rose,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.deepPink,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This is a saved snapshot. Data may have changed since this search was performed.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.deepPink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

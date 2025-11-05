import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../widgets/offender_card.dart';
import '../theme/app_colors.dart';

class ResultsScreen extends StatelessWidget {
  final SearchResult searchResult;

  const ResultsScreen({
    super.key,
    required this.searchResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.appBarGradient,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search: "${searchResult.query}"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${searchResult.totalResults} ${searchResult.totalResults == 1 ? 'result' : 'results'} found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Important disclaimer
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warningRose,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.rose, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: AppColors.deepPink),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These are potential matches only. Names may belong to different people. Verify independently.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.deepPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results list or empty state
          Expanded(
            child: searchResult.hasResults
                ? ListView.builder(
                    itemCount: searchResult.offenders.length,
                    itemBuilder: (context, index) {
                      return OffenderCard(
                        offender: searchResult.offenders[index],
                      );
                    },
                  )
                : _buildEmptyState(context),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.pinkGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softPinkShadow,
          ),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'New Search',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No registry matches were found for "${searchResult.query}".',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Note: No results does not guarantee safety. Always trust your instincts and take appropriate precautions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/image_search_result.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Screen displaying reverse image search results
///
/// Shows:
/// - Summary of matches found
/// - List of domains/sites where image appears
/// - Links to view the pages
/// - Interpretation guidance (likely original vs. found elsewhere)
class ImageResultsScreen extends StatelessWidget {
  final ImageSearchResult result;

  const ImageResultsScreen({
    super.key,
    required this.result,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.palePink,
      appBar: AppBar(
        title: Text(
          'Search Results',
          style: TextStyle(
            color: AppColors.primaryPink,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.darkText,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.softPink.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary card
            _buildSummaryCard(),
            const SizedBox(height: 16),

            // Results list or empty state
            if (result.hasMatches)
              _buildResultsList()
            else
              _buildNoMatchesCard(),

            const SizedBox(height: 16),

            // Disclaimer
            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final isLikelyOriginal = result.isLikelyOriginal;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Status icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isLikelyOriginal
                  ? Colors.green.withValues(alpha: 0.1)
                  : AppColors.palePink,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              isLikelyOriginal ? Icons.verified_outlined : Icons.warning_amber_rounded,
              size: 32,
              color: isLikelyOriginal ? Colors.green : AppColors.deepPink,
            ),
          ),
          const SizedBox(height: 16),

          // Main message
          Text(
            isLikelyOriginal
                ? 'No Matches Found'
                : '${result.totalMatches} ${result.totalMatches == 1 ? 'Match' : 'Matches'} Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),

          // Interpretation
          Text(
            isLikelyOriginal
                ? 'This image appears to be original or not widely shared online.'
                : 'This image appears on ${result.uniqueDomains.length} ${result.uniqueDomains.length == 1 ? 'website' : 'websites'}.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mediumText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Found On',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: result.results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final match = result.results[index];
              return _buildMatchItem(match);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMatchItem(ImageMatch match) {
    return InkWell(
      onTap: () => _launchUrl(match.pageUrl),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Domain icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.palePink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.language,
                size: 20,
                color: AppColors.primaryPink,
              ),
            ),
            const SizedBox(width: 12),

            // Domain and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.domain,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Found: ${match.formattedCrawlDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumText,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.open_in_new,
              size: 18,
              color: AppColors.mediumText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMatchesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'What this means',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildExplanationItem(
            Icons.check_circle_outline,
            'Image not found in TinEye\'s database',
          ),
          _buildExplanationItem(
            Icons.check_circle_outline,
            'May be an original photo',
          ),
          _buildExplanationItem(
            Icons.info_outline,
            'New images may not be indexed yet',
          ),
          _buildExplanationItem(
            Icons.info_outline,
            'Private social media images often not indexed',
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primaryPink,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mediumText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.palePink,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.primaryPink,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Results depend on TinEye\'s index. Some images may not be found even if they appear online. Use as one tool among many for verification.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mediumText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

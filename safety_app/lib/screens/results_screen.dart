import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/search_result.dart';
import '../models/offender.dart';
import '../models/fbi_wanted_result.dart';
import '../widgets/offender_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../services/haptic_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../theme/app_animations.dart';

class ResultsScreen extends StatefulWidget {
  final SearchResult searchResult;

  const ResultsScreen({super.key, required this.searchResult});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _counterController;
  late Animation<int> _counterAnimation;
  bool _isLoading = true;
  List<Offender> _filteredOffenders = [];
  String _sortBy = 'name'; // 'name', 'age', 'location'

  @override
  void initState() {
    super.initState();
    _filteredOffenders = widget.searchResult.offenders;

    // Animated counter setup
    _counterController = AnimationController(
      duration: AppAnimations.durationMedium,
      vsync: this,
    );

    _counterAnimation =
        IntTween(begin: 0, end: widget.searchResult.totalResults).animate(
          CurvedAnimation(
            parent: _counterController,
            curve: AppAnimations.standardCurve,
          ),
        );

    // Simulate loading and start animations
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _counterController.forward();
      }
    });
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterSheet(),
    );
  }

  void _sortResults(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      switch (sortBy) {
        case 'name':
          _filteredOffenders.sort((a, b) => a.fullName.compareTo(b.fullName));
          break;
        case 'age':
          _filteredOffenders.sort((a, b) {
            final ageA = a.age ?? 0;
            final ageB = b.age ?? 0;
            return ageB.compareTo(ageA);
          });
          break;
        case 'location':
          _filteredOffenders.sort(
            (a, b) => (a.address ?? '').compareTo(b.address ?? ''),
          );
          break;
      }
    });
    Navigator.pop(context);
  }

  Future<void> _refreshResults() async {
    HapticService.instance.mediumImpact();

    // Simulate refresh (in real app, this would re-fetch from API)
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      CustomSnackbar.showSuccess(context, 'Results refreshed successfully');
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
        actions: [
          if (widget.searchResult.hasResults)
            IconButton(
              icon: Icon(Icons.filter_list_rounded, color: AppColors.primaryPink),
              onPressed: _showFilterSheet,
              tooltip: 'Sort & Filter',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.softPink.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search summary with animated counter - floating card style
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search: "${widget.searchResult.query}"',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPink,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: _counterAnimation,
                  builder: (context, child) {
                    return Text(
                      '${_counterAnimation.value} ${_counterAnimation.value == 1 ? 'result' : 'results'} found',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mediumText,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),

          // Important disclaimer - softer styling
          Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.lightPink.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.primaryPink, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'These are potential matches only. Names may belong to different people. Verify independently.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: -0.2, end: 0),

          const SizedBox(height: 8),

          // Results list or empty state with pull-to-refresh
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : RefreshIndicator(
                    onRefresh: _refreshResults,
                    color: AppColors.primaryPink,
                    backgroundColor: Colors.white,
                    child: widget.searchResult.hasResults
                        ? ListView(
                            padding: const EdgeInsets.only(bottom: 16),
                            children: [
                              // FBI WARNING BANNER (if match found)
                              if (widget.searchResult.fbiWanted?.isMatch == true)
                                _buildFBIWantedWarning(widget.searchResult.fbiWanted!)
                                    .animate()
                                    .fadeIn(duration: 500.ms)
                                    .slideY(begin: -0.2, end: 0),

                              // Offender cards
                              ..._filteredOffenders.asMap().entries.map((entry) {
                                final index = entry.key;
                                final offender = entry.value;
                                return OffenderCard(offender: offender)
                                    .animate()
                                    .fadeIn(
                                      duration: 400.ms,
                                      delay: (100 + (index * 50)).ms,
                                    )
                                    .slideX(
                                      begin: 0.2,
                                      end: 0,
                                      curve: Curves.easeOutCubic,
                                    );
                              }),
                            ],
                          )
                        : _buildEmptyState(),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: AppSpacing.screenPaddingAll,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppColors.subtleShadow,
        ),
        child: CustomButton(
          text: 'New Search',
          onPressed: () => Navigator.of(context).pop(),
          variant: ButtonVariant.primary,
          size: ButtonSize.large,
          icon: Icons.search,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: AppSpacing.screenPaddingAll,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: LoadingWidgets.skeletonCard(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          children: [
            AppSpacing.verticalSpaceXxl,
            EmptyState(
              icon: Icons.search_off,
              title: 'No Results Found',
              message:
                  'No registry matches were found for "${widget.searchResult.query}".',
              actionLabel: 'New Search',
              onAction: () => Navigator.of(context).pop(),
              iconColor: AppColors.primaryPink,
            ),
            AppSpacing.verticalSpaceMd,
            Container(
              padding: AppSpacing.cardPaddingAll,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.shade700,
                    size: 24,
                  ),
                  AppSpacing.horizontalSpaceSm,
                  Expanded(
                    child: Text(
                      'Note: No results does not guarantee safety. Always trust your instincts and take appropriate precautions.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSheet() {
    return Container(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sort Results', style: AppTextStyles.h3),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          AppSpacing.verticalSpaceMd,
          _buildSortOption('Name (A-Z)', 'name', Icons.sort_by_alpha),
          _buildSortOption('Age (High to Low)', 'age', Icons.calendar_today),
          _buildSortOption('Location', 'location', Icons.location_on),
          AppSpacing.verticalSpaceMd,
        ],
      ),
    );
  }

  Widget _buildSortOption(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lightPink : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryPink : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primaryPink : Colors.grey.shade600,
        ),
        title: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primaryPink : AppColors.darkText,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: AppColors.primaryPink)
            : null,
        onTap: () => _sortResults(value),
      ),
    );
  }

  /// Build FBI wanted warning banner (OPTIMIZED - 40% smaller)
  Widget _buildFBIWantedWarning(FBIWantedResult fbiResult) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade900,
            Colors.red.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // Reduced from 20
        child: Column(
          children: [
            // Warning title (no circular icon - emoji only)
            const Text(
              '⚠️ FBI MOST WANTED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20, // Reduced from 22
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8), // Reduced from 12

            // Warning message (if exists)
            if (fbiResult.warningMessage != null &&
                fbiResult.warningMessage!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced vertical
                margin: const EdgeInsets.only(bottom: 8), // Reduced from 12
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6), // Reduced from 8
                ),
                child: Text(
                  fbiResult.warningMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12, // Reduced from 13
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Description
            Text(
              'A person with this name appears on the FBI\'s Most Wanted list',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13, // Reduced from 14
              ),
              textAlign: TextAlign.center,
            ),

            // Show photo if available
            if (fbiResult.primaryPhoto != null) ...[
              const SizedBox(height: 10), // Reduced from 16
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  fbiResult.primaryPhoto!,
                  height: 100, // REDUCED from 150 (33% smaller)
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ],

            const SizedBox(height: 8), // Reduced from 16

            // Crime category (more compact)
            if (fbiResult.crimeCategory != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Smaller
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12), // Smaller from 20
                ),
                child: Text(
                  fbiResult.crimeCategory!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11, // Reduced from 12
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: 12), // Reduced from 16

            // View details button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showFBIDetails(fbiResult),
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text('View FBI Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade900,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Reduced
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // Reward info as simple text (not large badge)
            if (fbiResult.formattedReward != null) ...[
              const SizedBox(height: 6), // Reduced from 12
              Text(
                '💰 Reward: ${fbiResult.formattedReward}',
                style: TextStyle(
                  color: Colors.amber.shade300,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Disclaimer (compact, no italic)
            const SizedBox(height: 10), // Reduced from 16
            Text(
              'May not be same person. Verify details.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 10, // Reduced from 11
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Show FBI wanted person details dialog
  void _showFBIDetails(FBIWantedResult fbiResult) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'FBI Most Wanted Details',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (fbiResult.title != null) ...[
                const Text('Name:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(fbiResult.title!),
                const SizedBox(height: 12),
              ],
              if (fbiResult.aliases.isNotEmpty) ...[
                const Text('Aliases:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(fbiResult.aliases.join(', ')),
                const SizedBox(height: 12),
              ],
              if (fbiResult.shortSummary != null) ...[
                const Text('Details:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(fbiResult.shortSummary!),
                const SizedBox(height: 12),
              ],
              if (fbiResult.sex != null) ...[
                Text('Sex: ${fbiResult.sex}'),
                const SizedBox(height: 4),
              ],
              if (fbiResult.race != null) ...[
                Text('Race: ${fbiResult.race}'),
                const SizedBox(height: 4),
              ],
              if (fbiResult.formattedHeight != null) ...[
                Text('Height: ${fbiResult.formattedHeight}'),
                const SizedBox(height: 4),
              ],
              if (fbiResult.formattedWeight != null) ...[
                Text('Weight: ${fbiResult.formattedWeight}'),
                const SizedBox(height: 4),
              ],
              if (fbiResult.formattedDOB != null) ...[
                Text('Date of Birth: ${fbiResult.formattedDOB}'),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (fbiResult.detailsUrl != null)
            ElevatedButton.icon(
              onPressed: () async {
                final url = Uri.parse(fbiResult.detailsUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('View on FBI.gov'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

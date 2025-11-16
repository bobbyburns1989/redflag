import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/search_result.dart';
import '../models/offender.dart';
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
      appBar: AppBar(
        title: const Text('Search Results'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        foregroundColor: Colors.white,
        actions: [
          if (widget.searchResult.hasResults)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterSheet,
              tooltip: 'Sort & Filter',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search summary with animated counter
          Container(
            width: double.infinity,
            padding: AppSpacing.cardPaddingAll,
            decoration: BoxDecoration(
              color: AppColors.lightPink,
              border: Border(
                bottom: BorderSide(color: AppColors.softPink, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search: "${widget.searchResult.query}"',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.primaryPink,
                  ),
                ),
                AppSpacing.verticalSpaceXs,
                AnimatedBuilder(
                  animation: _counterAnimation,
                  builder: (context, child) {
                    return Text(
                      '${_counterAnimation.value} ${_counterAnimation.value == 1 ? 'result' : 'results'} found',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.mediumText,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),

          // Important disclaimer
          Container(
                margin: AppSpacing.screenPaddingAll,
                padding: AppSpacing.cardPaddingAll,
                decoration: BoxDecoration(
                  color: AppColors.warningRose,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.rose, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.deepPink, size: 24),
                    AppSpacing.horizontalSpaceSm,
                    Expanded(
                      child: Text(
                        'These are potential matches only. Names may belong to different people. Verify independently.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.deepPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: -0.2, end: 0),

          // Results list or empty state with pull-to-refresh
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : RefreshIndicator(
                    onRefresh: _refreshResults,
                    color: AppColors.primaryPink,
                    backgroundColor: Colors.white,
                    child: widget.searchResult.hasResults
                        ? ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _filteredOffenders.length,
                            itemBuilder: (context, index) {
                              return OffenderCard(
                                    offender: _filteredOffenders[index],
                                  )
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
                            },
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
}

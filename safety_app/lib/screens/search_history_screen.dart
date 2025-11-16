import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/search_history_entry.dart';
import '../services/search_history_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/custom_card.dart';
import '../widgets/loading_widgets.dart';
import 'search_history_detail_screen.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  final _historyService = SearchHistoryService();
  Map<String, List<SearchHistoryEntry>> _groupedSearches = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final grouped = await _historyService.getGroupedSearches();
      setState(() {
        _groupedSearches = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $e'),
            backgroundColor: AppColors.deepPink,
          ),
        );
      }
    }
  }

  Future<void> _deleteSearch(SearchHistoryEntry entry) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Search'),
        content: Text('Delete search for "${entry.searchQuery}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.primaryPink),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _historyService.deleteSearch(entry.id);
        await _loadHistory();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Search deleted'),
              backgroundColor: AppColors.primaryPink,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting search: $e'),
              backgroundColor: AppColors.deepPink,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearAllHistory() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
          'Are you sure you want to delete all search history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _historyService.clearAllHistory();
        await _loadHistory();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('All history cleared'),
              backgroundColor: AppColors.primaryPink,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing history: $e'),
              backgroundColor: AppColors.deepPink,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search History'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        foregroundColor: Colors.white,
        actions: [
          if (_groupedSearches.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All',
              onPressed: _clearAllHistory,
            ),
        ],
      ),
      body: _isLoading
          ? LoadingWidgets.centered()
          : _groupedSearches.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  color: AppColors.primaryPink,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _calculateItemCount(),
                    itemBuilder: (context, index) => _buildListItem(index),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 100,
            color: AppColors.softPink,
          ),
          const SizedBox(height: 24),
          Text(
            'No Search History',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.primaryPink,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Your past searches will appear here',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateItemCount() {
    int count = 0;
    for (final group in _groupedSearches.entries) {
      count++; // Header
      count += group.value.length; // Items
    }
    return count;
  }

  Widget _buildListItem(int index) {
    int currentIndex = 0;

    for (final group in _groupedSearches.entries) {
      // Check if this is the header
      if (currentIndex == index) {
        return _buildGroupHeader(group.key);
      }
      currentIndex++;

      // Check if this is one of the items in this group
      final groupSize = group.value.length;
      if (index < currentIndex + groupSize) {
        final itemIndex = index - currentIndex;
        return _buildSearchCard(group.value[itemIndex]);
      }
      currentIndex += groupSize;
    }

    return const SizedBox.shrink();
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.overline.copyWith(
          color: AppColors.primaryPink,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchCard(SearchHistoryEntry entry) {
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM d, yyyy');
    final isToday = DateTime.now().day == entry.timestamp.day &&
        DateTime.now().month == entry.timestamp.month &&
        DateTime.now().year == entry.timestamp.year;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      onDismissed: (_) => _deleteSearch(entry),
      child: CustomCard(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: AppColors.softPink,
            child: Icon(
              Icons.search,
              color: AppColors.primaryPink,
            ),
          ),
          title: Text(
            entry.searchQuery,
            style: AppTextStyles.h4,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                isToday
                    ? timeFormat.format(entry.timestamp)
                    : '${dateFormat.format(entry.timestamp)} at ${timeFormat.format(entry.timestamp)}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: entry.resultCount > 0
                      ? AppColors.lightPink
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.resultCountText,
                  style: AppTextStyles.caption.copyWith(
                    color: entry.resultCount > 0
                        ? AppColors.deepPink
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SearchHistoryDetailScreen(entry: entry),
              ),
            );
          },
        ),
      ),
    );
  }
}

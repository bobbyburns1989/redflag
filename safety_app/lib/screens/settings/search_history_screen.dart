import 'package:flutter/material.dart';
import '../../models/search_history_entry.dart';
import '../../services/history_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/loading_widgets.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  final _historyService = HistoryService();
  bool _isLoading = true;
  String? _error;
  List<SearchHistoryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _historyService.fetchSearchHistory();
      if (mounted) {
        setState(() => _entries = results);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to load search history');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Search History'),
        content: const Text(
          'This will permanently remove your search history for this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Clear',
              style: TextStyle(color: AppColors.primaryPink),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _clearHistory();
    }
  }

  Future<void> _clearHistory() async {
    try {
      await _historyService.clearSearchHistory();
      if (mounted) {
        setState(() => _entries = []);
        CustomSnackbar.showSuccess(context, 'Search history cleared');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed to clear search history');
      }
    }
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _timeLabel(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  Widget _buildEntry(SearchHistoryEntry entry) {
    final name = [
      entry.firstName,
      entry.lastName,
    ].where((part) => part != null && part.isNotEmpty).join(' ');
    final queryLabel = name.isNotEmpty
        ? name
        : (entry.query?.toString() ?? 'Search');
    final resultsText = entry.resultsCount != null
        ? '${entry.resultsCount} result${entry.resultsCount == 1 ? '' : 's'}'
        : 'Results pending';

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.softPink.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    queryLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        resultsText,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      if (entry.refunded) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '🔄',
                                style: TextStyle(fontSize: 11),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Refunded',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeLabel(entry.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _isLoading
        ? LoadingWidgets.centered()
        : _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _loadHistory,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          )
        : _entries.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.manage_search_outlined,
                    size: 52,
                    color: AppColors.primaryPink,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No search history yet',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Searches you run will show up here. Only you can see this.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: _buildGroupedList(),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _entries.isEmpty ? null : _confirmClearHistory,
            child: Text(
              'Clear',
              style: TextStyle(
                color: _entries.isEmpty ? Colors.grey : AppColors.primaryPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: AppColors.primaryPink,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.softPink.withValues(alpha: 0.15),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Privacy first',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Only you can see your search history. You can clear it anytime.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedList() {
    final List<Widget> children = [];
    String? lastLabel;

    for (final entry in _entries) {
      final label = _dateLabel(entry.createdAt);
      if (label != lastLabel) {
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
        lastLabel = label;
      }
      children.add(_buildEntry(entry));
    }

    return children;
  }
}

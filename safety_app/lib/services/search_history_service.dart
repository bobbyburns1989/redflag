import 'package:hive_flutter/hive_flutter.dart';
import '../models/search_history_entry.dart';
import '../models/offender.dart';

/// Service for managing local search history using Hive
/// Singleton pattern - only one instance exists
class SearchHistoryService {
  static const String _boxName = 'search_history';
  Box<SearchHistoryEntry>? _box;
  bool _isInitialized = false;

  // Singleton instance
  static final SearchHistoryService _instance = SearchHistoryService._internal();

  // Private constructor
  SearchHistoryService._internal();

  // Factory constructor returns singleton
  factory SearchHistoryService() {
    return _instance;
  }

  /// Initialize Hive and open the search history box
  Future<void> init() async {
    if (_isInitialized) return; // Already initialized

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OffenderAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SearchHistoryEntryAdapter());
    }

    // Open box
    _box = await Hive.openBox<SearchHistoryEntry>(_boxName);
    _isInitialized = true;
  }

  /// Ensure box is open before operations (auto-initialize if needed)
  Future<Box<SearchHistoryEntry>> get _ensureBox async {
    if (!_isInitialized || _box == null || !_box!.isOpen) {
      await init();
    }
    return _box!;
  }

  /// Save a search to history
  Future<void> saveSearch(SearchHistoryEntry entry) async {
    final box = await _ensureBox;
    await box.put(entry.id, entry);
  }

  /// Get all searches sorted by timestamp (newest first)
  Future<List<SearchHistoryEntry>> getAllSearches() async {
    final box = await _ensureBox;
    final searches = box.values.toList();

    // Sort by timestamp descending (newest first)
    searches.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return searches;
  }

  /// Get a single search by ID
  Future<SearchHistoryEntry?> getSearchById(String id) async {
    final box = await _ensureBox;
    return box.get(id);
  }

  /// Delete a single search by ID
  Future<void> deleteSearch(String id) async {
    final box = await _ensureBox;
    await box.delete(id);
  }

  /// Clear all search history
  Future<void> clearAllHistory() async {
    final box = await _ensureBox;
    await box.clear();
  }

  /// Get the count of saved searches
  Future<int> getHistoryCount() async {
    final box = await _ensureBox;
    return box.length;
  }

  /// Watch for changes to the search history
  Stream<List<SearchHistoryEntry>> watchHistory() async* {
    final box = await _ensureBox;

    await for (final _ in box.watch()) {
      final searches = box.values.toList();
      searches.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      yield searches;
    }
  }

  /// Get searches grouped by date category
  Future<Map<String, List<SearchHistoryEntry>>> getGroupedSearches() async {
    final searches = await getAllSearches();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(const Duration(days: 7));

    final grouped = <String, List<SearchHistoryEntry>>{
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Older': [],
    };

    for (final search in searches) {
      final searchDate = DateTime(
        search.timestamp.year,
        search.timestamp.month,
        search.timestamp.day,
      );

      if (searchDate.isAtSameMomentAs(today)) {
        grouped['Today']!.add(search);
      } else if (searchDate.isAtSameMomentAs(yesterday)) {
        grouped['Yesterday']!.add(search);
      } else if (searchDate.isAfter(thisWeek)) {
        grouped['This Week']!.add(search);
      } else {
        grouped['Older']!.add(search);
      }
    }

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  /// Close the box (call when disposing)
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}

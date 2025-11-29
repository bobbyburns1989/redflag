import 'offender.dart';
import 'fbi_wanted_result.dart';

/// Search result with offender data and FBI wanted check
/// **ENHANCED**: Now includes FBI wanted person data
class SearchResult {
  final List<Offender> offenders;
  final String query;
  final DateTime timestamp;
  final int totalResults;
  final FBIWantedResult? fbiWanted; // NEW: FBI wanted check result

  SearchResult({
    required this.offenders,
    required this.query,
    required this.timestamp,
    required this.totalResults,
    this.fbiWanted, // NEW: Optional FBI wanted data
  });

  factory SearchResult.fromResponse(
    List<dynamic> jsonList,
    String searchQuery,
  ) {
    final offenders = jsonList
        .map((json) => Offender.fromJson(json as Map<String, dynamic>))
        .toList();

    return SearchResult(
      offenders: offenders,
      query: searchQuery,
      timestamp: DateTime.now(),
      totalResults: offenders.length,
    );
  }

  bool get hasResults => offenders.isNotEmpty;

  /// Check if search has any warnings (sex offender OR FBI wanted)
  /// NEW: Includes FBI wanted check
  bool get hasWarnings => offenders.isNotEmpty || (fbiWanted?.isMatch ?? false);

  /// Check if search has critical warnings (high-priority FBI wanted)
  /// NEW: FBI high-priority check
  bool get hasCriticalWarning =>
      offenders.isNotEmpty || (fbiWanted?.isHighPriority ?? false);

  @override
  String toString() {
    return 'SearchResult{query: $query, totalResults: $totalResults, fbiMatch: ${fbiWanted?.isMatch ?? false}, timestamp: $timestamp}';
  }
}

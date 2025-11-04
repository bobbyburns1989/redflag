import 'offender.dart';

class SearchResult {
  final List<Offender> offenders;
  final String query;
  final DateTime timestamp;
  final int totalResults;

  SearchResult({
    required this.offenders,
    required this.query,
    required this.timestamp,
    required this.totalResults,
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

  @override
  String toString() {
    return 'SearchResult{query: $query, totalResults: $totalResults, timestamp: $timestamp}';
  }
}

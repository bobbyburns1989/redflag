/// Model representing a user's search history entry.
class SearchHistoryEntry {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? query;
  final int? resultsCount;
  final DateTime createdAt;
  final bool refunded;

  SearchHistoryEntry({
    required this.id,
    required this.createdAt,
    this.firstName,
    this.lastName,
    this.query,
    this.resultsCount,
    this.refunded = false,
  });

  factory SearchHistoryEntry.fromMap(Map<String, dynamic> map) {
    final created = map['created_at'];
    return SearchHistoryEntry(
      id: map['id']?.toString() ?? '',
      firstName: map['first_name']?.toString(),
      lastName: map['last_name']?.toString(),
      query: map['query']?.toString(),
      resultsCount: _parseIntNullable(map['results_count']),
      createdAt: created is DateTime
          ? created
          : DateTime.tryParse(created?.toString() ?? '') ?? DateTime.now(),
      refunded: map['refunded'] as bool? ?? false,
    );
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString());
  }
}

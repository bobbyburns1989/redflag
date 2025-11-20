/// Model for reverse image search results from TinEye API
///
/// Contains information about where an image appears online,
/// useful for detecting catfishing, stolen photos, or stock images.
library;

class ImageSearchResult {
  /// Total number of unique image matches found
  final int totalMatches;

  /// Total number of backlinks (pages where image appears)
  final int totalBacklinks;

  /// List of individual match results
  final List<ImageMatch> results;

  /// User-friendly message about the search results
  final String message;

  /// Timestamp when search was performed
  final DateTime timestamp;

  ImageSearchResult({
    required this.totalMatches,
    required this.totalBacklinks,
    required this.results,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create from API JSON response
  factory ImageSearchResult.fromJson(Map<String, dynamic> json) {
    return ImageSearchResult(
      totalMatches: json['total_matches'] ?? 0,
      totalBacklinks: json['total_backlinks'] ?? 0,
      results:
          (json['results'] as List<dynamic>?)
              ?.map((r) => ImageMatch.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'] ?? 'Search completed',
    );
  }

  /// Check if any matches were found
  bool get hasMatches => totalMatches > 0;

  /// Check if image appears to be original (no matches)
  bool get isLikelyOriginal => totalMatches == 0;

  /// Get unique domains where image was found
  List<String> get uniqueDomains {
    return results.map((r) => r.domain).toSet().toList();
  }
}

/// Individual match result showing where an image appears
class ImageMatch {
  /// Domain where image was found (e.g., "facebook.com")
  final String domain;

  /// Full URL of the page containing the image
  final String pageUrl;

  /// Direct URL to the image file (if available)
  final String? imageUrl;

  /// Date when TinEye crawled/indexed this page
  final DateTime? crawlDate;

  ImageMatch({
    required this.domain,
    required this.pageUrl,
    this.imageUrl,
    this.crawlDate,
  });

  /// Create from API JSON response
  factory ImageMatch.fromJson(Map<String, dynamic> json) {
    return ImageMatch(
      domain: json['domain'] ?? 'Unknown',
      pageUrl: json['page_url'] ?? '',
      imageUrl: json['image_url'],
      crawlDate: json['crawl_date'] != null
          ? DateTime.tryParse(json['crawl_date'])
          : null,
    );
  }

  /// Get formatted crawl date string
  String get formattedCrawlDate {
    if (crawlDate == null) return 'Unknown date';
    return '${crawlDate!.month}/${crawlDate!.day}/${crawlDate!.year}';
  }
}

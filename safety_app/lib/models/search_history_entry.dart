import 'package:hive/hive.dart';
import 'offender.dart';

part 'search_history_entry.g.dart';

@HiveType(typeId: 1)
class SearchHistoryEntry {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String firstName;

  @HiveField(3)
  final String lastName;

  @HiveField(4)
  final String? age;

  @HiveField(5)
  final String? state;

  @HiveField(6)
  final String? phoneNumber;

  @HiveField(7)
  final String? zipCode;

  @HiveField(8)
  final int resultCount;

  @HiveField(9)
  final List<Offender> results;

  SearchHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.firstName,
    required this.lastName,
    this.age,
    this.state,
    this.phoneNumber,
    this.zipCode,
    required this.resultCount,
    required this.results,
  });

  /// Returns a human-readable search query string
  String get searchQuery {
    final parts = <String>['$firstName $lastName'];

    if (age != null && age!.isNotEmpty) {
      parts.add('Age $age');
    }

    if (state != null && state!.isNotEmpty) {
      parts.add(state!);
    }

    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      parts.add('Phone: $phoneNumber');
    }

    if (zipCode != null && zipCode!.isNotEmpty) {
      parts.add('ZIP: $zipCode');
    }

    return parts.join(', ');
  }

  /// Returns a formatted result count string
  String get resultCountText {
    if (resultCount == 0) {
      return 'No results';
    } else if (resultCount == 1) {
      return '1 result';
    } else {
      return '$resultCount results';
    }
  }

  @override
  String toString() {
    return 'SearchHistoryEntry{id: $id, query: $searchQuery, results: $resultCount, timestamp: $timestamp}';
  }
}

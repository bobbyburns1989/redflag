import 'package:flutter/material.dart';

/// Model representing FBI Most Wanted search result
///
/// Used to display FBI wanted person information in search results.
/// Supports graceful handling of null fields from FBI API.
class FBIWantedResult {
  final bool isMatch;
  final String? uid;
  final String? title;
  final String? warningMessage;
  final List<String> aliases;
  final String? description;
  final String? caution;
  final String? reward;
  final int? rewardMin;
  final int? rewardMax;
  final List<String> imageUrls;
  final String? detailsUrl;
  final String? classification;
  final List<String> subjects;
  final List<String> datesOfBirth;
  final String? placeOfBirth;
  final String? sex;
  final String? race;
  final String? hair;
  final String? eyes;
  final int? heightMin;
  final int? heightMax;
  final int? weightMin;
  final int? weightMax;
  final String? nationality;
  final String? status;

  FBIWantedResult({
    required this.isMatch,
    this.uid,
    this.title,
    this.warningMessage,
    this.aliases = const [],
    this.description,
    this.caution,
    this.reward,
    this.rewardMin,
    this.rewardMax,
    this.imageUrls = const [],
    this.detailsUrl,
    this.classification,
    this.subjects = const [],
    this.datesOfBirth = const [],
    this.placeOfBirth,
    this.sex,
    this.race,
    this.hair,
    this.eyes,
    this.heightMin,
    this.heightMax,
    this.weightMin,
    this.weightMax,
    this.nationality,
    this.status,
  });

  /// Create FBIWantedResult from FBI API JSON response
  factory FBIWantedResult.fromJson(Map<String, dynamic> json) {
    return FBIWantedResult(
      isMatch: true,
      uid: json['uid']?.toString(),
      title: json['title']?.toString(),
      warningMessage: json['warning_message']?.toString(),
      aliases: _parseStringList(json['aliases']),
      description: json['description']?.toString(),
      caution: json['caution']?.toString(),
      reward: json['reward_text']?.toString(),
      rewardMin: json['reward_min'] as int?,
      rewardMax: json['reward_max'] as int?,
      imageUrls: _parseImages(json['images']),
      detailsUrl: json['url']?.toString(),
      classification: json['person_classification']?.toString(),
      subjects: _parseStringList(json['subjects']),
      datesOfBirth: _parseStringList(json['dates_of_birth_used']),
      placeOfBirth: json['place_of_birth']?.toString(),
      sex: json['sex']?.toString(),
      race: json['race']?.toString() ?? json['race_raw']?.toString(),
      hair: json['hair']?.toString() ?? json['hair_raw']?.toString(),
      eyes: json['eyes']?.toString() ?? json['eyes_raw']?.toString(),
      heightMin: json['height_min'] as int?,
      heightMax: json['height_max'] as int?,
      weightMin: json['weight_min'] as int?,
      weightMax: json['weight_max'] as int?,
      nationality: json['nationality']?.toString(),
      status: json['status']?.toString(),
    );
  }

  /// Create empty result (no match found)
  factory FBIWantedResult.noMatch() {
    return FBIWantedResult(isMatch: false);
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'isMatch': isMatch,
      'uid': uid,
      'title': title,
      'warningMessage': warningMessage,
      'aliases': aliases,
      'description': description,
      'caution': caution,
      'reward': reward,
      'rewardMin': rewardMin,
      'rewardMax': rewardMax,
      'imageUrls': imageUrls,
      'detailsUrl': detailsUrl,
      'classification': classification,
      'subjects': subjects,
      'datesOfBirth': datesOfBirth,
      'placeOfBirth': placeOfBirth,
      'sex': sex,
      'race': race,
      'hair': hair,
      'eyes': eyes,
      'heightMin': heightMin,
      'heightMax': heightMax,
      'weightMin': weightMin,
      'weightMax': weightMax,
      'nationality': nationality,
      'status': status,
    };
  }

  /// Parse string list from JSON (handles null and various formats)
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  /// Parse image URLs from FBI API images array
  static List<String> _parseImages(dynamic images) {
    if (images == null) return [];
    if (images is List) {
      return images
          .where((img) => img is Map && img['original'] != null)
          .map((img) => img['original'].toString())
          .toList();
    }
    return [];
  }

  /// Get primary photo URL (first image)
  String? get primaryPhoto => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Check if this is a high-priority wanted person
  /// Based on warning message containing "ARMED" or "DANGEROUS"
  bool get isHighPriority {
    if (warningMessage == null) return false;
    final msg = warningMessage!.toUpperCase();
    return msg.contains('ARMED') || msg.contains('DANGEROUS');
  }

  /// Get formatted height range (e.g., "5'7\" - 5'9\"")
  String? get formattedHeight {
    if (heightMin == null && heightMax == null) return null;
    if (heightMin == heightMax && heightMin != null) {
      return _inchesToFeet(heightMin!);
    }
    if (heightMin != null && heightMax != null) {
      return '${_inchesToFeet(heightMin!)} - ${_inchesToFeet(heightMax!)}';
    }
    if (heightMin != null) {
      return _inchesToFeet(heightMin!);
    }
    return null;
  }

  /// Get formatted weight range (e.g., "185-200 lbs")
  String? get formattedWeight {
    if (weightMin == null && weightMax == null) return null;
    if (weightMin == weightMax && weightMin != null) {
      return '$weightMin lbs';
    }
    if (weightMin != null && weightMax != null) {
      return '$weightMin-$weightMax lbs';
    }
    if (weightMin != null) {
      return '$weightMin lbs';
    }
    return null;
  }

  /// Convert inches to feet and inches format (e.g., 67 inches → "5'7\"")
  String _inchesToFeet(int inches) {
    final feet = inches ~/ 12;
    final remainingInches = inches % 12;
    return '$feet\'$remainingInches"';
  }

  /// Get formatted date of birth (first one if multiple)
  String? get formattedDOB {
    return datesOfBirth.isNotEmpty ? datesOfBirth.first : null;
  }

  /// Get crime category from subjects array
  String? get crimeCategory {
    return subjects.isNotEmpty ? subjects.first : null;
  }

  /// Get formatted reward text (handles min/max range)
  String? get formattedReward {
    if (reward != null) return reward;
    if (rewardMax != null && rewardMax! > 0) {
      return 'Up to \$${rewardMax!.toStringAsFixed(0)}';
    }
    if (rewardMin != null && rewardMin! > 0) {
      return 'From \$${rewardMin!.toStringAsFixed(0)}';
    }
    return null;
  }

  /// Check if person has been located (caught)
  bool get isLocated => status?.toLowerCase() == 'located';

  /// Get warning color based on priority
  Color get warningColor {
    if (isHighPriority) return Colors.red.shade900;
    return Colors.red.shade700;
  }

  /// Get description for UI display (prioritizes caution over description)
  String? get displayDescription {
    // Try to extract clean text from caution HTML
    if (caution != null && caution!.isNotEmpty) {
      return _stripHtml(caution!);
    }
    return description;
  }

  /// Strip HTML tags from text (simple version)
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  /// Get short summary for display (first 200 characters of description)
  String? get shortSummary {
    final desc = displayDescription;
    if (desc == null || desc.isEmpty) return null;
    if (desc.length <= 200) return desc;
    return '${desc.substring(0, 197)}...';
  }

  @override
  String toString() {
    if (!isMatch) return 'FBIWantedResult(no match)';
    return 'FBIWantedResult(title: $title, status: $status, isHighPriority: $isHighPriority)';
  }
}

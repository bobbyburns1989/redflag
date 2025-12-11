/// Model representing a phone number lookup result from Twilio Lookup API v2.
///
/// Contains caller identification information, carrier details,
/// line type intelligence, and other phone number data.
class PhoneSearchResult {
  /// The phone number that was searched (E.164 format)
  final String phoneNumber;

  /// National format of the phone number (e.g., "(555) 123-4567")
  final String? nationalFormat;

  /// Caller name (CNAM) if available
  final String? callerName;

  /// Country code (e.g., "US", "CA", "GB")
  final String? countryCode;

  /// Carrier/service provider name
  final String? carrier;

  /// Line type: "mobile", "landline", "voip", "toll-free", etc.
  final String? lineType;

  /// Location information (city, state, region)
  final String? location;

  /// Whether the number is valid and active
  final bool? isValid;

  /// Whether the number has been ported to another carrier
  final bool? isPorted;

  /// Fraud/spam risk score (0.0-1.0, higher = more risky)
  final double? fraudScore;

  /// Spam/scam risk level: "low", "medium", "high"
  final String? riskLevel;

  /// Timestamp when the lookup was performed
  final DateTime timestamp;

  /// Raw response data from API (for debugging)
  final Map<String, dynamic>? rawData;

  PhoneSearchResult({
    required this.phoneNumber,
    this.nationalFormat,
    this.callerName,
    this.countryCode,
    this.carrier,
    this.lineType,
    this.location,
    this.isValid,
    this.isPorted,
    this.fraudScore,
    this.riskLevel,
    DateTime? timestamp,
    this.rawData,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create PhoneSearchResult from Twilio Lookup API v2 response
  factory PhoneSearchResult.fromTwilioResponse(
    Map<String, dynamic> json,
    String searchedPhone,
  ) {
    // Extract data from Twilio Lookup API v2 response format
    final lineTypeIntel = json['line_type_intelligence'] as Map<String, dynamic>?;
    final callerNameData = json['caller_name'] as Map<String, dynamic>?;

    final String? callerName = callerNameData?['caller_name']?.toString();
    final String? nationalFmt = json['national_format']?.toString();
    final String? country = json['country_code']?.toString();
    final String? carrierName = lineTypeIntel?['carrier_name']?.toString();
    final String? type = lineTypeIntel?['type']?.toString();
    final bool? valid = json['valid'] as bool?;

    // Twilio provides detailed location in line_type_intelligence
    String? locationStr;
    if (country != null) {
      locationStr = country;
    }

    return PhoneSearchResult(
      phoneNumber: json['phone_number']?.toString() ?? searchedPhone,
      nationalFormat: nationalFmt,
      callerName: callerName,
      countryCode: country,
      carrier: carrierName,
      lineType: type,
      location: locationStr,
      isValid: valid ?? true,  // Twilio validates by default
      isPorted: null,  // Not included in basic Twilio response
      fraudScore: null,  // Available with SMS Pumping Risk package
      riskLevel: null,   // Available with SMS Pumping Risk package
      rawData: json,
    );
  }

  /// Create PhoneSearchResult from Sent.dm API response (DEPRECATED)
  factory PhoneSearchResult.fromSentdmResponse(
    Map<String, dynamic> json,
    String searchedPhone,
  ) {
    // Extract data from Sent.dm response format
    final String? callerName = json['caller_name']?.toString();
    final String? nationalFmt = json['national_format']?.toString();
    final String? country = json['country_code']?.toString();
    final String? carrierName = json['carrier']?.toString();
    final String? type = json['line_type']?.toString();
    final bool? valid = json['valid'] as bool?;
    final bool? ported = json['ported'] as bool?;

    // Extract location if available
    String? locationStr;
    if (json['location'] != null) {
      final loc = json['location'];
      if (loc is Map) {
        final city = loc['city']?.toString();
        final state = loc['state']?.toString();
        if (city != null && state != null) {
          locationStr = '$city, $state';
        } else if (state != null) {
          locationStr = state;
        }
      } else if (loc is String) {
        locationStr = loc;
      }
    }

    // Extract fraud indicators
    double? fraudScore;
    String? risk;
    if (json['fraud_score'] != null) {
      fraudScore = _parseDouble(json['fraud_score']);
      // Calculate risk level based on score
      if (fraudScore != null) {
        if (fraudScore >= 0.7) {
          risk = 'high';
        } else if (fraudScore >= 0.4) {
          risk = 'medium';
        } else {
          risk = 'low';
        }
      }
    } else if (json['risk_level'] != null) {
      risk = json['risk_level'].toString().toLowerCase();
    }

    return PhoneSearchResult(
      phoneNumber: searchedPhone,
      nationalFormat: nationalFmt,
      callerName: callerName,
      countryCode: country,
      carrier: carrierName,
      lineType: type,
      location: locationStr,
      isValid: valid,
      isPorted: ported,
      fraudScore: fraudScore,
      riskLevel: risk,
      rawData: json,
    );
  }

  /// Parse double from dynamic value
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Check if caller name is available
  bool get hasCallerName => callerName != null && callerName!.isNotEmpty;

  /// Check if this is a mobile number
  bool get isMobile =>
      lineType?.toLowerCase() == 'mobile' ||
      lineType?.toLowerCase() == 'wireless';

  /// Check if this is a landline
  bool get isLandline => lineType?.toLowerCase() == 'landline';

  /// Check if this is VOIP
  bool get isVoip =>
      lineType?.toLowerCase() == 'voip' ||
      lineType?.toLowerCase() == 'internet';

  /// Check if number is high risk
  bool get isHighRisk =>
      riskLevel == 'high' || (fraudScore != null && fraudScore! >= 0.7);

  /// Check if number is safe
  bool get isSafe =>
      riskLevel == 'low' || (fraudScore != null && fraudScore! < 0.4);

  /// Get display text for line type with icon
  String get lineTypeDisplay {
    if (isMobile) return 'Mobile';
    if (isLandline) return 'Landline';
    if (isVoip) return 'VOIP';
    return lineType ?? 'Unknown';
  }

  /// Get risk level display text
  String get riskLevelDisplay {
    if (riskLevel == null && fraudScore == null) return 'Unknown';
    if (isHighRisk) return 'High Risk';
    if (riskLevel == 'medium') return 'Medium Risk';
    if (isSafe) return 'Safe';
    return 'Unknown';
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'national_format': nationalFormat,
      'caller_name': callerName,
      'country_code': countryCode,
      'carrier': carrier,
      'line_type': lineType,
      'location': location,
      'is_valid': isValid,
      'is_ported': isPorted,
      'fraud_score': fraudScore,
      'risk_level': riskLevel,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PhoneSearchResult('
        'phone: $phoneNumber, '
        'name: $callerName, '
        'carrier: $carrier, '
        'type: $lineType, '
        'valid: $isValid'
        ')';
  }
}

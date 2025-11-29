/// Model representing a credit transaction record from Supabase.
class CreditTransaction {
  final String id;
  final String transactionType;
  final int credits;
  final String? provider;
  final String? providerTransactionId;
  final double? amount;
  final String? status;
  final DateTime createdAt;

  CreditTransaction({
    required this.id,
    required this.transactionType,
    required this.credits,
    required this.createdAt,
    this.provider,
    this.providerTransactionId,
    this.amount,
    this.status,
  });

  factory CreditTransaction.fromMap(Map<String, dynamic> map) {
    final created = map['created_at'];
    return CreditTransaction(
      id: map['id']?.toString() ?? '',
      transactionType: map['transaction_type']?.toString() ?? 'unknown',
      credits: _parseInt(map['credits']),
      provider: map['provider']?.toString(),
      providerTransactionId: map['provider_transaction_id']?.toString(),
      amount: _parseDouble(map['amount']),
      status: map['status']?.toString(),
      createdAt: created is DateTime
          ? created
          : DateTime.tryParse(created?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  /// Check if this is a refund transaction
  bool get isRefund => transactionType == 'refund';

  /// Check if this is a purchase transaction
  bool get isPurchase => transactionType == 'purchase';

  /// Check if this is a search transaction (credit deduction)
  bool get isSearch => transactionType == 'search';

  /// Get icon for transaction type (for UI display)
  String get icon {
    if (isRefund) return '🔄';
    if (isPurchase) return '💳';
    if (isSearch) return '🔍';
    return '📝';
  }

  /// Get human-readable refund reason (from provider field for refunds)
  String? get refundReason {
    if (!isRefund || provider == null) return null;

    return switch (provider) {
      'api_maintenance_503' => 'API Maintenance',
      'server_error_500' => 'Server Error',
      'bad_gateway_502' => 'Service Unavailable',
      'gateway_timeout_504' => 'Gateway Timeout',
      'rate_limit_429' => 'Rate Limit Exceeded',
      'request_timeout' => 'Request Timeout',
      'network_error' => 'Network Error',
      'timeout' => 'Connection Timeout',
      'api_auth_error' => 'API Authentication Error',
      'unknown_error' => 'Service Error',
      _ => 'Service Error',
    };
  }

  /// Get human-readable transaction type
  String get displayType {
    if (isRefund) return 'Credit Refunded';
    if (isPurchase) return 'Credits Purchased';
    if (isSearch) return 'Search Performed';
    return 'Transaction';
  }

  /// Get credits with sign for display (+1 or -1)
  String get displayCredits {
    if (isRefund || isPurchase) {
      return '+$credits credit${credits == 1 ? '' : 's'}';
    } else if (isSearch) {
      return '-$credits credit${credits == 1 ? '' : 's'}';
    }
    return '$credits credit${credits == 1 ? '' : 's'}';
  }
}

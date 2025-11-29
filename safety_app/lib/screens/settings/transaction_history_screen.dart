import 'package:flutter/material.dart';
import '../../models/credit_transaction.dart';
import '../../services/history_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_widgets.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _historyService = HistoryService();
  bool _isLoading = true;
  String? _error;
  List<CreditTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _historyService.fetchTransactions();
      if (mounted) {
        setState(() => _transactions = results);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to load transactions');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

  Color _pillColor(CreditTransaction tx) {
    if (tx.credits > 0) return AppColors.primaryPink.withValues(alpha: 0.14);
    return Colors.red.withValues(alpha: 0.1);
  }

  Color _pillTextColor(CreditTransaction tx) {
    if (tx.credits > 0) return AppColors.primaryPink;
    return Colors.red;
  }

  Widget _buildTransactionTile(CreditTransaction tx) {
    // Use model helpers for consistent display
    final label = tx.displayType;
    final creditText = tx.displayCredits;

    // Build subtitle with refund reason if applicable
    final subtitleParts = <String>[];

    if (tx.isRefund) {
      // For refunds, show the reason
      if (tx.refundReason != null) {
        subtitleParts.add(tx.refundReason!);
      }
    } else if (tx.isPurchase) {
      // For purchases, show provider and amount
      final providerLabel = tx.provider ?? 'App Store';
      subtitleParts.add(providerLabel);
      if (tx.amount != null) {
        subtitleParts.add('\$${tx.amount!.toStringAsFixed(2)}');
      }
    }

    final statusLabel = tx.status ?? 'Completed';
    if (!tx.isRefund) {
      subtitleParts.add(statusLabel);
    }

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show emoji icon for refunds, regular icon for others
            tx.isRefund
                ? Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      tx.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.softPink.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tx.credits > 0 ? Icons.add_card : Icons.remove_circle_outline,
                      color: AppColors.primaryPink,
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _pillColor(tx),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          creditText,
                          style: TextStyle(
                            color: _pillTextColor(tx),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitleParts.join(' • '),
                      style: TextStyle(
                        color: tx.isRefund ? Colors.green[700] : Colors.grey[700],
                        fontSize: 13,
                        fontWeight: tx.isRefund ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _timeLabel(tx.createdAt),
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
                    onPressed: _loadTransactions,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          )
        : _transactions.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 52,
                    color: AppColors.primaryPink,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No transactions yet',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Purchases and searches will appear here.',
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
        title: const Text('Transaction History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        color: AppColors.primaryPink,
        child: body,
      ),
    );
  }

  List<Widget> _buildGroupedList() {
    final List<Widget> children = [];
    String? lastLabel;

    for (final tx in _transactions) {
      final label = _dateLabel(tx.createdAt);
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
      children.add(_buildTransactionTile(tx));
    }

    return children;
  }
}

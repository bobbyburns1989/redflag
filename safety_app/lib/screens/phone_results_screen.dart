import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/phone_search_result.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Screen displaying phone number lookup results
///
/// Shows:
/// - Caller name (CNAM) if available
/// - Carrier and line type information
/// - Location data
/// - Fraud/spam risk assessment
/// - Validation status
class PhoneResultsScreen extends StatelessWidget {
  final PhoneSearchResult result;

  const PhoneResultsScreen({
    super.key,
    required this.result,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: AppColors.primaryPink,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.palePink,
      appBar: AppBar(
        title: Text(
          'Phone Lookup',
          style: TextStyle(
            color: AppColors.primaryPink,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.darkText,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.softPink.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Phone number card with caller name
            _buildPhoneNumberCard(context),
            const SizedBox(height: 16),

            // Carrier & Line Type card
            if (result.carrier != null || result.lineType != null)
              ...[
                _buildCarrierCard(),
                const SizedBox(height: 16),
              ],

            // Location card
            if (result.location != null)
              ...[
                _buildLocationCard(),
                const SizedBox(height: 16),
              ],

            // Risk assessment card
            _buildRiskCard(),
            const SizedBox(height: 16),

            // Additional info card
            _buildAdditionalInfoCard(),
            const SizedBox(height: 16),

            // Disclaimer
            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberCard(BuildContext context) {
    final displayNumber = result.nationalFormat ?? result.phoneNumber;
    final hasName = result.hasCallerName;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Phone icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.palePink,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.phone,
              size: 32,
              color: AppColors.primaryPink,
            ),
          ),
          const SizedBox(height: 16),

          // Phone number
          GestureDetector(
            onTap: () => _copyToClipboard(context, result.phoneNumber, 'Phone number'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayNumber,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.content_copy,
                  size: 16,
                  color: AppColors.mediumText,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Caller name or "Unknown"
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: hasName
                  ? AppColors.lightPink
                  : AppColors.palePink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasName ? Icons.person : Icons.person_off_outlined,
                  size: 18,
                  color: hasName
                      ? AppColors.primaryPink
                      : AppColors.mediumText,
                ),
                const SizedBox(width: 8),
                Text(
                  result.callerName ?? 'Name Not Available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: hasName
                        ? AppColors.primaryPink
                        : AppColors.mediumText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarrierCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Carrier Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),

          // Carrier
          if (result.carrier != null)
            _buildInfoRow(
              Icons.wifi_calling_3,
              'Carrier',
              result.carrier!,
            ),

          if (result.carrier != null && result.lineType != null)
            const SizedBox(height: 12),

          // Line Type
          if (result.lineType != null)
            _buildInfoRow(
              _getLineTypeIcon(),
              'Line Type',
              result.lineTypeDisplay,
            ),

          // Ported status
          if (result.isPorted != null)
            ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.swap_horiz,
                'Ported',
                result.isPorted! ? 'Yes' : 'No',
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Region',
            result.location!,
          ),
          if (result.countryCode != null)
            ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.public,
                'Country',
                result.countryCode!,
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildRiskCard() {
    final isHighRisk = result.isHighRisk;
    final isSafe = result.isSafe;

    Color riskColor;
    IconData riskIcon;
    if (isHighRisk) {
      riskColor = AppColors.deepPink;
      riskIcon = Icons.warning_rounded;
    } else if (isSafe) {
      riskColor = Colors.green;
      riskIcon = Icons.check_circle_rounded;
    } else {
      riskColor = Colors.orange;
      riskIcon = Icons.info_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk Assessment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),

          // Risk level indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: riskColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  riskIcon,
                  color: riskColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.riskLevelDisplay,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: riskColor,
                        ),
                      ),
                      if (result.fraudScore != null)
                        Text(
                          'Score: ${(result.fraudScore! * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mediumText,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Risk explanation
          _buildExplanationItem(
            Icons.info_outline,
            isHighRisk
                ? 'This number shows signs of potential spam/fraud activity'
                : isSafe
                    ? 'This number appears to be safe with low risk indicators'
                    : 'Risk level could not be determined or is moderate',
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),

          _buildInfoRow(
            Icons.check_circle_outline,
            'Valid Number',
            (result.isValid ?? false) ? 'Yes' : 'Unknown',
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            Icons.access_time,
            'Lookup Date',
            _formatDate(result.timestamp),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.palePink,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primaryPink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExplanationItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primaryPink,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.mediumText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.palePink,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.primaryPink,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Phone lookup data is provided by Sent.dm API. Information may not always be current or complete. Use as one verification tool among many.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mediumText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLineTypeIcon() {
    if (result.isMobile) return Icons.smartphone;
    if (result.isLandline) return Icons.phone;
    if (result.isVoip) return Icons.wifi_calling;
    return Icons.phone_in_talk;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

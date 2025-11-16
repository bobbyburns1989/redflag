import 'package:flutter/material.dart';
import '../models/offender.dart';
import '../theme/app_colors.dart';

class OffenderCard extends StatelessWidget {
  final Offender offender;

  const OffenderCard({super.key, required this.offender});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      color: AppColors.softWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.softPink, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.pinkGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPink.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offender.fullName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (offender.age != null)
                        Text(
                          'Age: ${offender.age}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Location
            if (offender.address != null ||
                offender.city != null ||
                offender.state != null) ...[
              _buildInfoRow(Icons.location_on, 'Location', _buildFullAddress()),
              const SizedBox(height: 8),
            ],

            // Offense description
            if (offender.offenseDescription != null) ...[
              _buildInfoRow(
                Icons.warning_amber,
                'Offense',
                offender.offenseDescription!,
              ),
              const SizedBox(height: 8),
            ],

            // Registration date
            if (offender.registrationDate != null) ...[
              _buildInfoRow(
                Icons.calendar_today,
                'Registered',
                offender.registrationDate!,
              ),
              const SizedBox(height: 8),
            ],

            // Distance (if available)
            if (offender.distance != null) ...[
              _buildInfoRow(
                Icons.near_me,
                'Distance',
                '${offender.distance!.toStringAsFixed(1)} miles',
              ),
            ],

            // Disclaimer
            const Divider(height: 28, thickness: 1, color: AppColors.softPink),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightPink,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.rose, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.deepPink),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Verify this information through official channels',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.deepPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildFullAddress() {
    final parts = <String>[];

    // Add street address if available
    if (offender.address != null && offender.address!.isNotEmpty) {
      parts.add(offender.address!);
    }

    // Build city, state line
    final cityStateParts = <String>[];
    if (offender.city != null && offender.city!.isNotEmpty) {
      cityStateParts.add(offender.city!);
    }
    if (offender.state != null && offender.state!.isNotEmpty) {
      cityStateParts.add(offender.state!);
    }

    if (cityStateParts.isNotEmpty) {
      parts.add(cityStateParts.join(', '));
    }

    return parts.join('\n');
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primaryPink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

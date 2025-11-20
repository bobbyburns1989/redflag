import 'package:flutter/material.dart';
import '../models/offender.dart';
import '../theme/app_colors.dart';

class OffenderCard extends StatelessWidget {
  final Offender offender;

  const OffenderCard({super.key, required this.offender});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.lightPink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primaryPink,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offender.fullName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (offender.age != null)
                        Text(
                          'Age: ${offender.age}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mediumText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Location
            if (offender.address != null ||
                offender.city != null ||
                offender.state != null) ...[
              _buildInfoRow(Icons.location_on_outlined, 'Location', _buildFullAddress()),
              const SizedBox(height: 6),
            ],

            // Offense description
            if (offender.offenseDescription != null) ...[
              _buildInfoRow(
                Icons.warning_amber_rounded,
                'Offense',
                offender.offenseDescription!,
              ),
              const SizedBox(height: 6),
            ],

            // Registration date
            if (offender.registrationDate != null) ...[
              _buildInfoRow(
                Icons.calendar_today_outlined,
                'Registered',
                offender.registrationDate!,
              ),
              const SizedBox(height: 6),
            ],

            // Distance (if available)
            if (offender.distance != null) ...[
              _buildInfoRow(
                Icons.near_me_outlined,
                'Distance',
                '${offender.distance!.toStringAsFixed(1)} miles',
              ),
            ],

            // Disclaimer - softer styling
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.palePink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primaryPink),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Verify this information through official channels',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumText,
                        fontWeight: FontWeight.w500,
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

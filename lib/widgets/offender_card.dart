import 'package:flutter/material.dart';
import '../models/offender.dart';

class OffenderCard extends StatelessWidget {
  final Offender offender;

  const OffenderCard({
    super.key,
    required this.offender,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.red.shade700,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (offender.age != null)
                        Text(
                          'Age: ${offender.age}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            if (offender.address != null) ...[
              _buildInfoRow(
                Icons.location_on,
                'Location',
                offender.address!,
              ),
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
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Verify this information through official channels',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

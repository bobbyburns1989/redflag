import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not launch phone dialer'),
              backgroundColor: AppColors.deepPink,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.deepPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Resources'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.appBarGradient,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Emergency banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.pinkGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.pinkGlow,
            ),
            child: const Row(
              children: [
                Icon(Icons.emergency, color: Colors.white, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'If you are in immediate danger, call 911',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Emergency services
          _buildResourceCard(
            context: context,
            icon: Icons.local_police,
            title: 'Emergency Services',
            subtitle: 'Immediate danger or crime in progress',
            phoneNumber: '911',
            color: AppColors.deepPink,
          ),
          const SizedBox(height: 16),

          // National Domestic Violence Hotline
          _buildResourceCard(
            context: context,
            icon: Icons.support_agent,
            title: 'National Domestic Violence Hotline',
            subtitle: '24/7 confidential support for domestic violence',
            phoneNumber: '1-800-799-7233',
            color: AppColors.primaryPink,
            additionalInfo: 'Text START to 88788',
          ),
          const SizedBox(height: 16),

          // National Sexual Assault Hotline
          _buildResourceCard(
            context: context,
            icon: Icons.healing,
            title: 'National Sexual Assault Hotline (RAINN)',
            subtitle: '24/7 confidential crisis support',
            phoneNumber: '1-800-656-4673',
            color: AppColors.rose,
            additionalInfo: 'Free and confidential',
          ),
          const SizedBox(height: 16),

          // National Suicide Prevention Lifeline
          _buildResourceCard(
            context: context,
            icon: Icons.favorite,
            title: 'National Suicide Prevention Lifeline',
            subtitle: '24/7 crisis support and suicide prevention',
            phoneNumber: '988',
            color: AppColors.primaryPink,
          ),
          const SizedBox(height: 16),

          // Crisis Text Line
          _buildResourceCard(
            context: context,
            icon: Icons.message,
            title: 'Crisis Text Line',
            subtitle: 'Text-based crisis support',
            phoneNumber: null,
            color: AppColors.deepPink,
            additionalInfo: 'Text HOME to 741741',
          ),
          const SizedBox(height: 24),

          // Additional resources section
          Card(
            color: AppColors.softWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.softPink, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primaryPink),
                      const SizedBox(width: 8),
                      const Text(
                        'Additional Resources',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    'National Center for Missing & Exploited Children',
                    '1-800-843-5678',
                  ),
                  const Divider(height: 24),
                  _buildInfoItem(
                    'Childhelp National Child Abuse Hotline',
                    '1-800-422-4453',
                  ),
                  const Divider(height: 24),
                  _buildInfoItem(
                    'National Human Trafficking Hotline',
                    '1-888-373-7888 or text 233733',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Safety tips
          Card(
            color: AppColors.lightPink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.softPink, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppColors.deepPink),
                      const SizedBox(width: 8),
                      const Text(
                        'Safety Tips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSafetyTip('Trust your instincts'),
                  _buildSafetyTip('Share your location with trusted contacts'),
                  _buildSafetyTip('Meet new people in public places'),
                  _buildSafetyTip('Keep your phone charged'),
                  _buildSafetyTip('Know your exits and surroundings'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String? phoneNumber,
    required Color color,
    String? additionalInfo,
  }) {
    return Card(
      elevation: 2,
      color: AppColors.softWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: phoneNumber != null
            ? () => _makePhoneCall(phoneNumber, context)
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (phoneNumber != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        phoneNumber,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                    if (additionalInfo != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        additionalInfo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (phoneNumber != null)
                Icon(Icons.phone, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String contact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          contact,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.primaryPink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

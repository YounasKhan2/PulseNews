import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Updated: April 2025',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Privacy Policy for Pulse News',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'At Pulse News, we take your privacy seriously. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('1. Information We Collect'),
            _buildBulletPoint('Usage data and analytics'),
            _buildBulletPoint('News preferences and reading history'),

            const SizedBox(height: 24),
            _buildSectionTitle('2. How We Use Your Information'),
            _buildBulletPoint('To provide and personalize our services'),
            _buildBulletPoint('To improve app performance and features'),
            _buildBulletPoint('To communicate with you about updates'),
            _buildBulletPoint('For security and fraud prevention'),

            const SizedBox(height: 24),
            _buildSectionTitle('3. Data Sharing and Disclosure'),
            const Text(
              'We do not sell your personal information. We may share data with:',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            _buildBulletPoint('Service providers who assist our operations'),
            _buildBulletPoint('Legal authorities when required by law'),

            const SizedBox(height: 24),
            _buildSectionTitle('4. Your Rights and Choices'),
            _buildBulletPoint('Access, update, or delete your information'),
            _buildBulletPoint('Opt-out of data collection'),
            _buildBulletPoint('Disable location services'),

            const SizedBox(height: 24),
            _buildSectionTitle('5. Data Security'),
            const Text(
              'We implement industry-standard security measures to protect your data, including encryption and secure servers.',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('6. Changes to This Policy'),
            const Text(
              'We may update this policy periodically. We will notify you of significant changes through the app or via email.',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),

            const SizedBox(height: 24),
            const Text(
              'If you have any questions about this Privacy Policy, please contact us at:',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 8),
            const Text(
              'privacy@pulsenews.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

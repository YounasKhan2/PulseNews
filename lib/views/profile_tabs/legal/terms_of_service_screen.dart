import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
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
              'Terms of Service for Pulse News',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Pulse News! These Terms of Service ("Terms") govern your use of our mobile application and services. By accessing or using Pulse News, you agree to be bound by these Terms.',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('1. Acceptance of Terms'),
            const Text(
              'By using Pulse News, you confirm that you accept these Terms and agree to comply with them. If you do not agree, you must not use our app.',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('2. Changes to Terms'),
            const Text(
              'We may revise these Terms at any time by amending this page. Please check this page regularly to take notice of any changes.',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('3. Account Registration'),
            const Text(
              'To access certain features, you may need to register an account. You must:',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            _buildBulletPoint('Provide accurate and complete information'),
            _buildBulletPoint('Maintain the security of your credentials'),
            _buildBulletPoint('Not share your account with others'),

            const SizedBox(height: 24),
            _buildSectionTitle('4. Acceptable Use'),
            const Text(
              'You agree not to:',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            _buildBulletPoint('Use the app for any unlawful purpose'),
            _buildBulletPoint(
              'Attempt to gain unauthorized access to our systems',
            ),
            _buildBulletPoint('Reverse engineer or decompile the app'),
            _buildBulletPoint('Post harmful or offensive content'),
            _buildBulletPoint('Engage in any activity that disrupts services'),

            const SizedBox(height: 24),
            _buildSectionTitle('5. Intellectual Property'),
            const Text(
              'All content, features, and functionality of Pulse News are our exclusive property or licensed to us. You may not:',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            _buildBulletPoint('Reproduce, duplicate, or copy any content'),
            _buildBulletPoint('Use our trademarks without permission'),
            _buildBulletPoint('Create derivative works based on our content'),

            const SizedBox(height: 24),
            _buildSectionTitle('6. Disclaimers'),
            const Text(
              'Pulse News is provided "as is" without warranties of any kind. We do not guarantee that:',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            _buildBulletPoint(
              'The app will always be available or uninterrupted',
            ),
            _buildBulletPoint('Content will be accurate or complete'),
            _buildBulletPoint('News sources are endorsed by us'),

            const SizedBox(height: 24),
            _buildSectionTitle('7. Limitation of Liability'),
            const Text(
              'To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, or consequential damages arising from your use of Pulse News.',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('8. Termination'),
            const Text(
              'We may terminate or suspend your access to Pulse News immediately, without prior notice, for any violation of these Terms.',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('9. Governing Law'),
            const Text(
              'These Terms shall be governed by and construed in accordance with the laws of [Your Country/State], without regard to its conflict of law provisions.',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('10. Contact Us'),
            const Text(
              'For questions about these Terms, please contact us at:',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 8),
            const Text(
              'legal@pulsenews.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'By continuing to use Pulse News, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                height: 1.6,
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

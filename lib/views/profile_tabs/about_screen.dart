import 'package:flutter/material.dart';
import 'legal/privacy_policy_screen.dart';
import 'legal/terms_of_service_screen.dart';
import 'legal/open_source_licenses_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple.withOpacity(0.1),
                child: const Icon(
                  Icons.article_rounded,
                  size: 50,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App Name and Version
            const Text(
              'Pulse News',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0 (Build 1)',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // About Description
            const Text(
              'Pulse News brings you the latest headlines, breaking news updates, '
              'and in-depth coverage from around the world. Stay informed with '
              'personalized news feed, save articles for later, and customize '
              'your reading experience.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Additional Information
            const Divider(),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.deepPurple),
              title: const Text('Developed by'),
              subtitle: const Text('Pulse News Team'),
            ),
            ListTile(
              leading: const Icon(Icons.api, color: Colors.deepPurple),
              title: const Text('Powered by'),
              subtitle: const Text('News API'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.deepPurple),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.deepPurple),
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TermsOfServiceScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.deepPurple),
              title: const Text('Open Source Licenses'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OpenSourceLicensesScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            const Center(
              child: Text(
                '© 2025 Pulse News. All rights reserved.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

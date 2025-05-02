import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _sendIssueReport(String issue, BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'younaskk120@gmail.com',
      query: 'subject=Issue Report&body=$issue',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email client found on this device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController issueController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('How do I save articles?'),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'To save an article, click on the bookmark icon in the article details screen.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Can I read articles offline?'),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Currently, offline reading is not supported. Stay tuned for updates!',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('How do I change app theme?'),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Go to Profile > App Appearance to toggle between light and dark themes.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Contact Support Section
            const Text(
              'Contact Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email, color: Colors.deepPurple),
                title: const Text('Email Support'),
                subtitle: const Text('We typically respond within 24 hours.'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to Email Support
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.help, color: Colors.deepPurple),
                title: const Text('Help Center'),
                subtitle: const Text('Browse our knowledge base for guides.'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to Help Center
                },
              ),
            ),
            const SizedBox(height: 24),

            // Report an Issue Section
            const Text(
              'Report an Issue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: issueController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the issue you\'re experiencing...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final issue = issueController.text.trim();
                if (issue.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please describe the issue.')),
                  );
                  return;
                }

                await _sendIssueReport(issue, context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

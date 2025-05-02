import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenSourceLicensesScreen extends StatefulWidget {
  const OpenSourceLicensesScreen({super.key});

  @override
  State<OpenSourceLicensesScreen> createState() =>
      _OpenSourceLicensesScreenState();
}

class _OpenSourceLicensesScreenState extends State<OpenSourceLicensesScreen> {
  String appVersion = '';
  String appName = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = '${info.version} (${info.buildNumber})';
      appName = info.appName;
    });
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Open Source Licenses',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (appName.isNotEmpty) ...[
              Text(
                appName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version: $appVersion',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Third-Party Libraries',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Firebase Packages
            _LicenseItem(
              name: 'Firebase Core',
              license: 'Apache 2.0',
              description: 'Flutter plugin for Firebase Core',
              onTap: () => _launchUrl('https://pub.dev/packages/firebase_core'),
            ),
            _LicenseItem(
              name: 'Firebase Auth',
              license: 'Apache 2.0',
              description: 'Flutter plugin for Firebase Authentication',
              onTap: () => _launchUrl('https://pub.dev/packages/firebase_auth'),
            ),
            _LicenseItem(
              name: 'Cloud Firestore',
              license: 'Apache 2.0',
              description: 'Flutter plugin for Cloud Firestore',
              onTap:
                  () => _launchUrl('https://pub.dev/packages/cloud_firestore'),
            ),

            // Animation & UI
            _LicenseItem(
              name: 'Flutter Animate',
              license: 'MIT',
              description: 'Add beautiful animations with minimal code',
              onTap:
                  () => _launchUrl('https://pub.dev/packages/flutter_animate'),
            ),
            _LicenseItem(
              name: 'Country Picker',
              license: 'MIT',
              description: 'Country code picker for Flutter',
              onTap:
                  () => _launchUrl('https://pub.dev/packages/country_picker'),
            ),

            // Utility
            _LicenseItem(
              name: 'HTTP',
              license: 'BSD-3-Clause',
              description:
                  'A composable, Future-based library for making HTTP requests',
              onTap: () => _launchUrl('https://pub.dev/packages/http'),
            ),
            _LicenseItem(
              name: 'URL Launcher',
              license: 'BSD-3-Clause',
              description: 'Flutter plugin for launching a URL',
              onTap: () => _launchUrl('https://pub.dev/packages/url_launcher'),
            ),
            _LicenseItem(
              name: 'Flutter Toast',
              license: 'MIT',
              description: 'Toast notification library for Flutter',
              onTap: () => _launchUrl('https://pub.dev/packages/fluttertoast'),
            ),
            _LicenseItem(
              name: 'Package Info Plus',
              license: 'Apache 2.0',
              description:
                  'Flutter plugin for querying information about an application package',
              onTap:
                  () =>
                      _launchUrl('https://pub.dev/packages/package_info_plus'),
            ),
            _LicenseItem(
              name: 'Cupertino Icons',
              license: 'MIT',
              description: 'Default set of Cupertino icons for Flutter',
              onTap:
                  () => _launchUrl('https://pub.dev/packages/cupertino_icons'),
            ),

            const SizedBox(height: 32),
            Text(
              'This application uses open-source libraries to provide the best experience. '
              'We are grateful to the developers of these libraries for their contributions to the Flutter community.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LicenseItem extends StatelessWidget {
  final String name;
  final String license;
  final String description;
  final VoidCallback onTap;

  const _LicenseItem({
    required this.name,
    required this.license,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(license),
                    backgroundColor: Colors.grey[100],
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//app_appearence_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../main.dart'; // Import themeNotifier from main.dart

class AppAppearanceScreen extends StatefulWidget {
  const AppAppearanceScreen({super.key});

  @override
  State<AppAppearanceScreen> createState() => _AppAppearanceScreenState();
}

class _AppAppearanceScreenState extends State<AppAppearanceScreen> {
  String _currentTheme = 'System default';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAppearance();
  }

  Future<void> _loadUserAppearance() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc =
        await _firestore.collection('userAppearance').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _currentTheme = doc['theme'] ?? 'System default';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user appearance: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserAppearance(String theme) async {
    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('userAppearance').doc(user.uid).set({
          'theme': theme,
        });
        debugPrint('User appearance saved successfully: $theme');

        // Update the themeNotifier to dynamically change the app's appearance
        if (theme == 'Light') {
          themeNotifier.updateTheme(ThemeMode.light);
        } else if (theme == 'Dark') {
          themeNotifier.updateTheme(ThemeMode.dark);
        } else {
          themeNotifier.updateTheme(ThemeMode.system);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme changed to $theme'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        debugPrint('Error saving user appearance: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save appearance. Please try again.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      debugPrint('No authenticated user found.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to save appearance settings.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.onSurface.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Theme',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      themeOption(
                        'System default',
                        'Follow your device settings',
                        Icons.settings_suggest_rounded,
                      ),
                      const Divider(height: 8),
                      themeOption(
                        'Light',
                        'Bright theme for daytime use',
                        Icons.wb_sunny_rounded,
                      ),
                      const Divider(height: 8),
                      themeOption(
                        'Dark',
                        'Easy on the eyes in low light',
                        Icons.nightlight_round,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _currentTheme == 'Dark'
                            ? Icons.nightlight_round
                            : _currentTheme == 'Light'
                            ? Icons.wb_sunny_rounded
                            : Icons.settings_suggest_rounded,
                        size: 28,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$_currentTheme theme active',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget themeOption(String title, String subtitle, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _currentTheme == title;

    return InkWell(
      onTap: () {
        if (_currentTheme != title) {
          setState(() {
            _currentTheme = title;
          });
          _saveUserAppearance(title);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

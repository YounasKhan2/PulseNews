import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import '../profile_tabs/edit_profile_screen.dart';
import '../profile_tabs/app_appearance_screen.dart';
import '../profile_tabs/help_support_screen.dart';
import '../profile_tabs/about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Global method to update reading history count
void updateReadingHistoryCount(BuildContext context) {
  final state = context.findAncestorStateOfType<_ProfileScreenState>();
  state?._incrementReadingHistoryCount();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _username;
  String? _email;
  int _bookmarksCount = 0;
  int _readingHistoryCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([
      _fetchUserData(),
      _fetchStats(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (mounted) {
          setState(() {
            _username = userDoc['username'];
            _email = user.email;
          });
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
      }
    }
  }

  Future<void> _fetchStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final bookmarksSnapshot =
        await FirebaseFirestore.instance
            .collection('bookmarks')
            .doc(user.uid)
            .collection('userBookmarks')
            .get();

        final readingHistorySnapshot =
        await FirebaseFirestore.instance
            .collection('readingHistory')
            .doc(user.uid)
            .collection('userHistory')
            .get();

        if (mounted) {
          setState(() {
            _bookmarksCount = bookmarksSnapshot.docs.length;
            _readingHistoryCount = readingHistorySnapshot.docs.length;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _bookmarksCount = 0;
            _readingHistoryCount = 0;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching stats: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _resetReadingHistory() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final historyCollection = _firestore
            .collection('readingHistory')
            .doc(user.uid)
            .collection('userHistory');

        final snapshot = await historyCollection.get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        if (mounted) {
          setState(() {
            _readingHistoryCount = 0;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reading history cleared successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting reading history: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    debugPrint('User initiated sign-out.');
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _incrementReadingHistoryCount() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final historyCollection = _firestore
            .collection('readingHistory')
            .doc(user.uid)
            .collection('userHistory');

        final snapshot = await historyCollection.get();
        if (mounted) {
          setState(() {
            _readingHistoryCount = snapshot.docs.length;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating reading history count: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: _buildProfileContent(),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),

        // Profile Avatar
        _buildProfileHeader(),

        const SizedBox(height: 24),

        // Stats Cards
        _buildStatsSection(),

        const SizedBox(height: 16),
        const Divider(thickness: 1),

        // Settings Options
        _buildSettingsOptions(),

        const SizedBox(height: 24),

        // Sign Out Button
        _buildSignOutButton(),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Hero(
          tag: 'profile-avatar',
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Theme.of(context).colorScheme.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Text(
                _username != null && _username!.isNotEmpty
                    ? _username![0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _username ?? 'Guest',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _email ?? 'No email available',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('Bookmarks', _bookmarksCount, Icons.bookmark),
        _buildStatCard('History', _readingHistoryCount, Icons.history),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOptions() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
          title: const Text('Edit Profile'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.color_lens, color: Theme.of(context).colorScheme.primary),
          title: const Text('Appearance'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AppAppearanceScreen()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.help, color: Theme.of(context).colorScheme.primary),
          title: const Text('Help & Support'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
          title: const Text('About'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.delete, color: Colors.red),
          title: const Text('Clear Reading History'),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Clear Reading History'),
                content: const Text('Are you sure you want to clear your reading history?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await _resetReadingHistory();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      icon: const Icon(Icons.logout),
      label: const Text('Sign Out'),
      onPressed: _signOut,
    );
  }
}

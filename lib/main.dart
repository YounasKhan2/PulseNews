import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulsenews/views/home/home_page.dart';
import 'package:pulsenews/views/auth/login_screen.dart';
import 'firebase_options.dart';
import 'package:pulsenews/views/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure plugin initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AppInitializer());
}

// Define themeNotifier as a global variable
final themeNotifier = ThemeNotifier(
  ThemeMode.light,
); // Set default to light mode

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier(ThemeMode value) : super(value);

  void updateTheme(ThemeMode themeMode) {
    value = themeMode;
    notifyListeners();
  }
}

Future<void> _loadUserPreferredTheme() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('userAppearance')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        final theme = doc['theme'] ?? 'System default';
        if (theme == 'Light') {
          themeNotifier.updateTheme(ThemeMode.light);
        } else if (theme == 'Dark') {
          themeNotifier.updateTheme(ThemeMode.dark);
        } else {
          themeNotifier.updateTheme(ThemeMode.system);
        }
      }
    } catch (e) {
      debugPrint('Error loading user preferred theme: $e');
    }
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pulse News',
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: themeMode, // Use the current theme mode
          home: const SplashScreen(),
        );
      },
    );
  }
}

class AuthStateHandler extends StatefulWidget {
  const AuthStateHandler({super.key});

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        debugPrint('User signed in: ${user.email}');
        await _loadUserPreferredTheme(); // Load theme after login
      } else {
        debugPrint('User signed out');
        themeNotifier.updateTheme(
          ThemeMode.light,
        ); // Reset to light mode on logout
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

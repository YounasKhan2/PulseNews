import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart'; // Add for PlatformException
import 'dart:io'; // Add for SocketException
import 'dart:async'; // Add for TimeoutException
import 'signup_screen.dart';
import '../home/home_page.dart';
import 'forgot_password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Helper function to show toast messages - moved outside of _login method
  void _showToast({
    required String message,
    required bool isError,
    required BuildContext context,
    String? debugDetails,
  }) {
    // Log the error details for debugging
    if (debugDetails != null) {
      print('Error details: $debugDetails');
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.primary,
      textColor: isError
          ? Theme.of(context).colorScheme.onError
          : Theme.of(context).colorScheme.onPrimary,
    );
  }

  Future<void> _googleSignInHandler() async {
    try {
      debugPrint('Attempting Google Sign-In...');
      final GoogleSignInAccount? googleUser =
      await _googleSignIn.signInSilently();
      if (googleUser != null) {
        await _googleSignIn
            .disconnect(); // Disconnect the previously signed-in account
      }
      final GoogleSignInAccount? newGoogleUser = await _googleSignIn.signIn();
      if (newGoogleUser == null) {
        debugPrint('Google Sign-In canceled by user.');
        return;
      }
      // Use the newGoogleUser for authentication
      final GoogleSignInAuthentication googleAuth =
      await newGoogleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        debugPrint('Google Sign-In successful for user: ${user.email}');

        // Check if user already exists in Firestore
        final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // If user doesn't exist, create a new document
        if (!userDoc.exists) {
          try {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'username': user.displayName ?? 'Google User',
              'email': user.email ?? '',
              'country':
              'Not specified', // Default value since Google doesn't provide country
              'createdAt': FieldValue.serverTimestamp(),
              'isGoogleUser': true, // Flag to identify Google sign-in users
              'profilePicture': user.photoURL ?? '', // Optional profile picture
            });
            debugPrint('Google user document created successfully.');
          } catch (e) {
            debugPrint('Error creating Google user document: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save user data: $e')),
            );
          }
        }

        // Show success toast before navigation
        _showToast(
          message: "Google Sign-In successful!",
          isError: false,
          context: context,
        );

        // Navigate to HomePage after successful login
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      _showToast(
        message: "Google Sign-In failed: ${e.toString()}",
        isError: true,
        context: context,
      );
    }
  }

  Future<void> _login() async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Please fill in all fields.');
      }

      if (!email.contains('@')) {
        throw Exception('Please enter a valid email address.');
      }

      // Login with email
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Show success toast before navigation
      _showToast(
        message: "Login successful!",
        isError: false,
        context: context,
      );

      // Navigate to HomePage after successful login
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with a different sign-in method.';
          break;
        case 'invalid-credential':
          errorMessage = 'The provided credential is invalid.';
          break;
        default:
          errorMessage = 'Authentication failed: ${e.message ?? e.code}';
      }
      _showToast(
        message: errorMessage,
        isError: true,
        context: context,
      );
    } on SocketException catch (_) {
      _showToast(
        message: 'Network error. Please check your internet connection.',
        isError: true,
        context: context,
      );
    } on TimeoutException catch (_) {
      _showToast(
        message: 'Connection timed out. Please try again.',
        isError: true,
        context: context,
      );
    } on PlatformException catch (e) {
      _showToast(
        message: 'Platform error: ${e.message}',
        isError: true,
        context: context,
      );
    } catch (e) {
      _showToast(
        message: 'An unexpected error occurred. Please try again.',
        isError: true,
        context: context,
        debugDetails: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(
                Icons.article_rounded,
                size: 100, // Increased size
                color: Colors.white,
              ),
              const SizedBox(height: 16),

              // App Name
              Text(
                'Pulse News',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28, // Increased size
                ),
              ),
              const SizedBox(height: 24),

              // Login Form
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login Button
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Theme.of(
                            context,
                          ).primaryColor, // Background color
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ElevatedButton.icon(
                      //   onPressed: _googleSignInHandler,
                      //   icon: const FaIcon(FontAwesomeIcons.google, size: 20, color: Colors.white), // FontAwesome Google icon
                      //   label: const Text(
                      //     'Continue with Google',
                      //     style: TextStyle(color: Colors.white),
                      //   ),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Theme.of(context).primaryColor, // Google button color
                      //     padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      //   ),
                      // ),
                      // const SizedBox(height: 16),


                      //Google Sign-In Button
                      ElevatedButton.icon(
                        onPressed: _googleSignInHandler,

                        icon: Image.network(
                          'http://pngimg.com/uploads/google/google_PNG19635.png',
                          fit: BoxFit.cover,
                          height: 28,
                          width: 28,
                        ),
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Theme.of(
                            context,
                          ).primaryColor, // Google button color
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Don't have an account? Sign Up",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
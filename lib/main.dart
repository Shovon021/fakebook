import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'theme/app_theme.dart';
import 'screens/nav_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'providers/current_user_provider.dart';

// Track Firebase initialization status
bool _firebaseInitialized = false;
String? _firebaseError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase with proper error tracking
  try {
    await Firebase.initializeApp();
    
    // Activate App Check
    await FirebaseAppCheck.instance.activate(
      // standard android provider
      androidProvider: AndroidProvider.playIntegrity,
      // For IOS: appleProvider: AppleProvider.appAttest,
    );
    
    _firebaseInitialized = true;
    
    // ONLY initialize provider AFTER Firebase is confirmed working
    currentUserProvider.init();
    
    debugPrint("✅ Firebase initialized successfully");
  } catch (e, stackTrace) {
    _firebaseError = e.toString();
    debugPrint("❌ Firebase initialization FAILED: $e");
    debugPrint("Stack: $stackTrace");
  }

  // Add global error handling
  FlutterError.onError = (details) {
    debugPrint("Flutter Error: ${details.exception}");
  };

  runApp(const FakebookApp());
}

class FakebookApp extends StatefulWidget {
  const FakebookApp({super.key});

  @override
  State<FakebookApp> createState() => _FakebookAppState();
}

class _FakebookAppState extends State<FakebookApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light 
          ? ThemeMode.dark 
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facebook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: _firebaseInitialized 
          ? SplashScreen(nextScreen: AuthWrapper(onThemeToggle: _toggleTheme))
          : FirebaseErrorScreen(error: _firebaseError),
    );
  }
}

// Show error if Firebase failed
class FirebaseErrorScreen extends StatelessWidget {
  final String? error;
  const FirebaseErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Firebase Connection Failed',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please ensure:\n'
                  '• You have an internet connection\n'
                  '• Firebase project is properly configured\n'
                  '• google-services.json is valid',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      'Error: $error',
                      style: TextStyle(fontSize: 12, color: Colors.red[900]),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Auth state wrapper
class AuthWrapper extends StatelessWidget {
  final VoidCallback onThemeToggle;
  const AuthWrapper({super.key, required this.onThemeToggle});

  Future<bool> _checkEmailVerified() async {
    final user = AuthService().currentUser;
    if (user == null) return false;
    
    await user.reload();
    final freshUser = AuthService().currentUser;
    return freshUser?.emailVerified ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1877F2),
              ),
            ),
          );
        }

        // If we have a user, check if email is verified
        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: _checkEmailVerified(),
            builder: (context, verifiedSnapshot) {
              if (verifiedSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1877F2),
                    ),
                  ),
                );
              }
              
              final isVerified = verifiedSnapshot.data ?? false;
              
              if (!isVerified) {
                // Sign out unverified user and show login
                AuthService().signOut();
                return const LoginScreen();
              }
              
              return NavScreen(onThemeToggle: onThemeToggle);
            },
          );
        }
        
        // No user -> Login
        return const LoginScreen();
      },
    );
  }
}

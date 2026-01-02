import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'screens/nav_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'providers/current_user_provider.dart';
// import 'firebase_options.dart'; // Uncomment after running flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase (Requires google-services.json or firebase_options.dart)
  try {
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp(); 
  } catch (e) {
    print("⚠️ INITIALIZATION WARNING: Firebase init failed. Did you add google-services.json? \nError: $e");
  }

  // Initialize current user provider
  currentUserProvider.init();

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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // If we have a user, show the App
        if (snapshot.hasData) {
           // We need to pass the toggleTheme callback. 
           // Since AuthWrapper is inside FakebookApp, we can't easily pass the callback from _FakebookAppState unless passed down.
           // For now, let's find the ancestor or use a State management solution.
           // TRICK: We can use context.findAncestorStateOfType or just pass a dummy for now/refactor.
           // Better: FakebookApp passes the callback to AuthWrapper? use a Provider?
           // Simplest: Just use `context.findAncestorStateOfType<_FakebookAppState>()?._toggleTheme` if accessible, or make _toggleTheme static/global? No.
           // Let's pass it down.
           
           return NavScreen(
             onThemeToggle: context.findAncestorStateOfType<_FakebookAppState>()?._toggleTheme ?? () {},
           );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
           return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        // No user -> Login
        return const LoginScreen();
      },
    );
  }
}

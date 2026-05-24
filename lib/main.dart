import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // We provide explicit options to ensure initialization works across all platforms
    // and to resolve the "FirebaseOptions cannot be null" error.
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDEwtjSk-RCWXtylaeacQSUBWH_cLxwIWA",
        appId: "1:520492755023:android:5bd5222d5e8164630a223a",
        messagingSenderId: "520492755023",
        projectId: "spendwise-aac0f",
        storageBucket: "spendwise-aac0f.firebasestorage.app",
      ),
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  
  runApp(const SpendWiseApp());
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>(
          create: (_) => AuthService().user,
          initialData: null,
          catchError: (_, __) => null,
        ),
        ProxyProvider<User?, DatabaseService?>(
          update: (_, user, __) => user == null ? null : DatabaseService(uid: user.uid),
        ),
      ],
      child: MaterialApp(
        title: 'SpendWise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppLoader(),
      ),
    );
  }
}

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  void _loadApp() async {
    // Keep splash screen for a realistic amount of time
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }
    return const AuthWrapper();
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    
    if (user == null) {
      return const LoginScreen();
    } else {
      return const HomeScreen();
    }
  }
}

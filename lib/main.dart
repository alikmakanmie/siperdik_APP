import 'package:flutter/material.dart';
import 'package:sipandik_app/core/constants/app_colors.dart';
import 'package:sipandik_app/core/services/auth_service.dart';
import 'package:sipandik_app/features/auth/screens/welcome_screen.dart';
import 'package:sipandik_app/features/home/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIPANDIK',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.background,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
  await Future.delayed(const Duration(seconds: 1));
  
  print('🔍 Checking login status...');
  final isLoggedIn = await _authService.isLoggedIn();
  print('📱 Is logged in: $isLoggedIn');
  
  if (isLoggedIn) {
    final userData = await _authService.getUserData();
    print('👤 Stored user data: $userData');
    
    if (userData != null && mounted) {
      // ✅ FIX: Akses userData['user']['id'], bukan userData['id']
      final userObject = userData['user'] as Map<String, dynamic>?;
      
      if (userObject == null) {
        print('⚠️ No user object found');
        _navigateToWelcome();
        return;
      }

      final dynamic userIdRaw = userObject['id'];
      final int userId = userIdRaw is int 
          ? userIdRaw 
          : int.tryParse(userIdRaw.toString()) ?? 0;

      print('👤 User ID: $userId');
      print('👤 User ID Type: ${userId.runtimeType}');

      if (userId <= 0) {
        print('⚠️ Invalid user ID ($userId), logging out...');
        await _authService.logout();
        _navigateToWelcome();
        return;
      }

      // Navigate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userName: userObject['name'] ?? 'User',
            userEmail: userObject['email'] ?? '',
            userId: userId,  // ✅ BENAR
          ),
        ),
      );
    } else {
      _navigateToWelcome();
    }
  } else {
    _navigateToWelcome();
  }
}


  void _navigateToWelcome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'SIPANDIK',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

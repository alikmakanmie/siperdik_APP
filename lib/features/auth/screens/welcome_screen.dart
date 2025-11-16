import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import 'sign_up_screen.dart';
import '../../home/screens/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 Logging in with email: ${_emailController.text}');
      
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('📡 Login Response: $result');

      if (mounted) {
  if (result['success'] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login successful!'),
        backgroundColor: Colors.green,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    // ✅ Extract dari result['data']['user']
    final responseData = result['data'] as Map<String, dynamic>;
    final userData = responseData['user'] as Map<String, dynamic>;  // ✅ AMBIL USER OBJECT
    
    final String userName = userData['name'] ?? 'User';
    final String userEmail = userData['email'] ?? '';
    
    // ✅ Pastikan ID di-parse dengan benar
    final dynamic userIdRaw = userData['id'];  // ✅ DARI userData['id']
    final int userId = userIdRaw is int 
        ? userIdRaw 
        : int.tryParse(userIdRaw.toString()) ?? 0;

    if (userId == 0) {
      throw Exception('Invalid user ID received from server');
    }

    print('✅ User logged in: $userName ($userEmail) - ID: $userId');
    print('📋 User ID Type: ${userId.runtimeType}');

    // Navigate ke HomeScreen dengan data dari API
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userName: userName,
            userEmail: userEmail,
            userId: userId,
          ),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Login failed'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

    } catch (e) {
      print('❌ Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: AppLogo()),
              const SizedBox(height: 48),
              
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 32),
              
              CustomTextField(
                placeholder: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                placeholder: 'Password',
                controller: _passwordController,
                isPassword: true,
                obscureText: _obscurePassword,
                onTogglePassword: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 8),
              
              CheckboxListTile(
                title: const Text(
                  'Remember me',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.foreground,
                  ),
                ),
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? true;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to forgot password
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Not a member? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                      children: [
                        TextSpan(
                          text: 'Register now',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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

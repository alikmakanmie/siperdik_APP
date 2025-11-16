import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import 'confirmation_code_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validasi input
  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your name');
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return false;
    }

    // Validasi format email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _showError('Please enter a valid email address');
      return false;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Please enter your password');
      return false;
    }

    if (_passwordController.text.length < 8) {
      _showError('Password must be at least 8 characters');
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }

    if (!_agreedToTerms) {
      _showError('Please agree to Terms and Conditions');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

 Future<void> _handleRegister() async {
  // Validasi input
  if (!_validateInputs()) {
    return;
  }

  // Tampilkan loading
  setState(() {
    _isLoading = true;
  });

  print('Starting registration...');
  print('Name: ${_nameController.text.trim()}');
  print('Email: ${_emailController.text.trim()}');

  try {
    final result = await _authService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    print('Registration result: $result');

    if (!mounted) return;

    // Periksa apakah result adalah Map
    if (result is Map<String, dynamic>) {
      if (result['success'] == true) {
        _showSuccess(result['message'] ?? 'Registration successful!');
        
        // Delay sedikit agar user bisa membaca success message
        await Future.delayed(const Duration(seconds: 1));

        // Navigate ke confirmation code screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmationCodeScreen(
                email: _emailController.text.trim(),
              ),
            ),
          );
        }
      } else {
        // Tampilkan error dari server
        String errorMessage = 'Registration failed';
        
        // Cek berbagai format error dari Laravel
        if (result['message'] != null) {
          errorMessage = result['message'];
        } else if (result['error'] != null) {
          errorMessage = result['error'];
        } else if (result['errors'] != null) {
          // Handle validation errors dari Laravel
          final errors = result['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first[0]; // Ambil error pertama
        }
        
        _showError(errorMessage);
      }
    } else {
      _showError('Invalid response format from server');
    }
  } catch (e) {
    print('Exception during registration: $e');
    if (mounted) {
      String errorMessage = 'An error occurred';
      
      // Parse error message yang lebih user-friendly
      if (e.toString().contains('SocketException')) {
        errorMessage = 'Cannot connect to server. Please check your internet connection.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid response from server.';
      } else {
        errorMessage = 'An error occurred: ${e.toString()}';
      }
      
      _showError(errorMessage);
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
              // Logo
              const Center(child: AppLogo()),
              const SizedBox(height: 48),
              
              // Title
              const Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create an account to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 32),
              
              // Name Field
              CustomTextField(
                label: 'Name',
                placeholder: 'Luci',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              
              // Email Field
              CustomTextField(
                label: 'Email Address',
                placeholder: 'name@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Password Field
              CustomTextField(
                label: 'Password',
                placeholder: 'Create a password',
                controller: _passwordController,
                isPassword: true,
                obscureText: _obscurePassword,
                onTogglePassword: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Confirm Password Field
              CustomTextField(
                label: 'Confirm password',
                placeholder: 'Confirm password',
                controller: _confirmPasswordController,
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onTogglePassword: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Terms and Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: const TextSpan(
                          text: "I've read and agree with the ",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(text: ' and the '),
                            TextSpan(
                              text: 'Privacy Policy',
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
              const SizedBox(height: 32),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Continue'),
                ),
              ),
              const SizedBox(height: 16),
              
              // Login Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign in',
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/services/auth_service.dart';
import '../../home/screens/home_screen.dart';

class ConfirmationCodeScreen extends StatefulWidget {
  final String email;
  
  const ConfirmationCodeScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<ConfirmationCodeScreen> createState() => _ConfirmationCodeScreenState();
}

class _ConfirmationCodeScreenState extends State<ConfirmationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getCode() {
    return _controllers.map((c) => c.text).join();
  }

  bool _isCodeComplete() {
    return _getCode().length == 6;
  }

  Future<void> _handleVerify() async {
  if (!_isCodeComplete()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter 6-digit code'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final code = _getCode();
    print('🔍 Verifying code: $code for email: ${widget.email}');
    
    // ✅ Call API verify email via AuthService
    final result = await _authService.verifyEmail(code, widget.email);
    
    print('📡 API Response: $result');
    
    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        // ✅ Extract user data dari response API
        Map<String, dynamic>? userData;
        
        // Coba ambil dari key 'user' atau 'data'
        if (result.containsKey('user') && result['user'] != null) {
          userData = result['user'] as Map<String, dynamic>;
        } else if (result.containsKey('data') && result['data'] != null) {
          userData = result['data'] as Map<String, dynamic>;
        }

        if (userData != null && mounted) {
          // ✅ Simpan user data ke storage (optional)
          await _authService.saveUserData(userData);
          
          // Navigate dengan data REAL dari API
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userName: userData!['name'] ?? 'User',
                userEmail: userData['email'] ?? '',
                userId: userData['id'] ?? 1,
              ),
            ),
          );
        } else {
          // Fallback jika tidak ada user data di response
          print('⚠️ No user data in response, using defaults');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(
                  userName: 'User',
                  userEmail: '',
                  userId: 1,
                ),
              ),
            );
          }
        }
      } else {
        // Verifikasi gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Verification failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    print('❌ Error during verification: $e');
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              const AppLogo(),
              const SizedBox(height: 48),
              
              // Title
              const Text(
                'Enter confirmation code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'A 6-digit code has been sent to\n${widget.email}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // PIN Code Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    margin: EdgeInsets.only(
                      right: index < 5 ? 12 : 0,
                    ),
                    child: _buildCodeBox(index),
                  );
                }),
              ),
              const SizedBox(height: 32),
              
              // Resend Code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive code? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement resend code
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code resent!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerify,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Verify'),
                ),
              ),
              const SizedBox(height: 16),
              
              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
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

  Widget _buildCodeBox(int index) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? AppColors.primary
              : AppColors.border,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to next box
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Last box - unfocus keyboard
              _focusNodes[index].unfocus();
              
              // Auto verify if all 6 digits entered
              if (_isCodeComplete()) {
                _handleVerify();
              }
            }
          } else {
            // Move to previous box on backspace
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
          
          setState(() {}); // Update border color
        },
        onTap: () {
          // Select all text when tapped
          if (_controllers[index].text.isNotEmpty) {
            _controllers[index].selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controllers[index].text.length,
            );
          }
        },
      ),
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  // Login & Save User Data
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Simpan token
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        
        // Simpan user data
        await saveUserData(data['data'] ?? data);
        
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      print('Sending request to: ${ApiConfig.register}');
      print('Request body: name=$name, email=$email');
      
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // TAMBAHAN: Simpan token jika backend mengembalikannya
        if (data['token'] != null) {
          await saveToken(data['token']);
          print('✅ Token saved from response: ${data['token']}');
        } else if (data['data'] != null && data['data']['token'] != null) {
          await saveToken(data['data']['token']);
          print('✅ Token saved from data: ${data['data']['token']}');
        } else {
          print('⚠️ Warning: No token received from register endpoint');
        }
        
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      print('Register error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Verify Email - FIXED VERSION
  Future<Map<String, dynamic>> verifyEmail(String code, String email) async {
    try {
      print('=== VERIFY EMAIL DEBUG ===');
      print('Email: $email');
      print('Code: $code');
      print('URL: ${ApiConfig.verifyEmail}');
      
      final response = await http.post(
        Uri.parse(ApiConfig.verifyEmail),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'verification_code': code,
        }),
      );

      print('Verify response status: ${response.statusCode}');
      print('Verify response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Verification SUCCESS');
        
        if (data['token'] != null) {
          await saveToken(data['token']);
          print('Token saved: ${data['token']}');
        }
        
        return {
          'success': true,
          'message': data['message'] ?? 'Email verified successfully',
          'data': data,
        };
      } else {
        print('❌ Verification FAILED');
        return {
          'success': false,
          'message': data['message'] ?? 'Verification failed',
          'error': data,
        };
      }
    } catch (e, stackTrace) {
      print('❌ Verify error: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  // ===== SAMPAI SINI =====

  // Save Token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Get Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Save User Data (untuk auto login)
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Simpan sebagai JSON string
    String userJson = jsonEncode(userData);
    await prefs.setString('user_data', userJson);
    
    // Simpan status login
    await prefs.setBool('is_logged_in', true);
  }

  // Get User Data
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user_data');
    
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  // Check if User is Logged In
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Logout - Clear All Data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.setBool('is_logged_in', false);
  }

  // Tambahkan di bagian bawah class AuthService

// Get User ID saja
Future<int?> getUserId() async {
  final userData = await getUserData();
  if (userData != null) {
    return userData['id'] as int?;
  }
  return null;
}

// Get User Name
Future<String?> getUserName() async {
  final userData = await getUserData();
  if (userData != null) {
    return userData['name'] as String?;
  }
  return null;
}

}

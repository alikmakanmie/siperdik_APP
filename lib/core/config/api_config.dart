class ApiConfig {
  // Ganti dengan URL backend Laravel Anda
  // Untuk development local: http://192.168.1.x:8000
  // Untuk production: https://your-domain.com
  static const String baseUrl = 'http://192.168.1.40:8000/api';
  
  // API Endpoints
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String verifyEmail = '$baseUrl/verify-email';
  static const String logout = '$baseUrl/logout';
  static const String profile = '$baseUrl/profile';
  
  // PPID Endpoints
  static const String ppidList = '$baseUrl/ppid';
  static const String ppidCreate = '$baseUrl/ppid';
  static const String ppidUpload = '$baseUrl/ppid/upload';
}

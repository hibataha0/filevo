import 'package:flutter/material.dart';
import 'package:filevo/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login({
    required String emailOrUsername,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    print('AuthController: Attempting login...');
    final result = await _authService.login(
      email: emailOrUsername,
      password: password,
    );
    _setLoading(false);

    print('AuthController: Login result: $result');
    
    if (result['success'] == true) {
      return true;
    } else {
      final errorMsg = result['error'] as String? ?? 'حدث خطأ غير معروف';
      print('AuthController: Login failed: $errorMsg');
      print('AuthController: Error details: ${result['details']}');
      _setError(errorMsg);
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
     required String confirmPassword, 
  }) async {
    _setLoading(true);
    _setError(null);
    print('AuthController: Attempting register...');
    final result = await _authService.register(
      name: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword, // ✅ أرسله هنا
    );
    _setLoading(false);

    print('AuthController: Register result: $result');
    
    if (result['success'] == true) {
      return true;
    } else {
      final errorMsg = result['error'] as String? ?? 'حدث خطأ غير معروف';
      print('AuthController: Register failed: $errorMsg');
      print('AuthController: Error details: ${result['details']}');
      _setError(errorMsg);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_hydroponic/data/services/auth_service.dart';

final authProvider =
    ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(AuthService());
});

enum AuthStatus {
  idle,
  loading,
  success,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  AuthProvider(this.authService);

  AuthStatus status = AuthStatus.idle;
  String? errorMessage;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage = "Email dan password tidak boleh kosong";
      status = AuthStatus.error;
      notifyListeners();
      return;
    }

    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      await authService.login(email: email, password: password);
      status = AuthStatus.success;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
    }

    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String username,
  }) async {
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        username.isEmpty) {
      errorMessage = "Semua field wajib diisi";
      status = AuthStatus.error;
      notifyListeners();
      return;
    }

    if (password != confirmPassword) {
      errorMessage = "Password tidak sama";
      status = AuthStatus.error;
      notifyListeners();
      return;
    }

    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      await authService.register(
        email: email,
        password: password,
        username: username,
      );
      status = AuthStatus.success;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    status = AuthStatus.idle;
    errorMessage = null;
    notifyListeners();
  }
}

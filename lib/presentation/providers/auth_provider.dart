import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_hydroponic/data/services/auth_service.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(AuthService());
});

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  late final Stream<User?> _authStream;

  User? _user;

  AuthProvider(this._authService) {
    _user = _authService.currentUser;

    _authStream = _authService.authStateChanges;
    _authStream.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  // ===== SESSION =====
  User? get currentUser => _user;
  String? get uid => _user?.uid;

  // ===== LOGIN =====
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.login(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // ===== REGISTER =====
  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      await _authService.register(
        email: email,
        password: password,
        username: username,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // ===== LOGOUT =====
  Future<void> logout() {
    return _authService.logout();
  }
}

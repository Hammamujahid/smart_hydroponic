import 'package:firebase_auth/firebase_auth.dart';

class AuthSession {
  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  User? get currentUser =>
      FirebaseAuth.instance.currentUser;

  bool get isLoggedIn =>
      FirebaseAuth.instance.currentUser != null;

  String? get uid =>
      FirebaseAuth.instance.currentUser?.uid;
}
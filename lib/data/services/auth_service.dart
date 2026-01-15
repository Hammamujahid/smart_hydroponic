import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _users = FirebaseFirestore.instance.collection('users');

  Future<void> register(
      {required String email,
      required String password,
      required String username}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _users.doc(credential.user!.uid).set({
      'username': username,
      'email': email,
      'activeDeviceId': '',
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> login({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() => _auth.signOut();

  // ========== SESSION ==========
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  String? get uid => _auth.currentUser?.uid;
}

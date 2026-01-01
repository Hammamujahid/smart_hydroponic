import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  Future<void> register(
      {required String email,
      required String password,
      required String username}) async {
    // Registration logic here
    try {
      debugPrint('AUTH START');

      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('AUTH OK uid=${credential.user!.uid}');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updateAt': FieldValue.serverTimestamp(),
      });

      debugPrint('FIRESTORE OK');
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

  Future<void> login({required String email, required String password}) async {
    // Login logic here
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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

  Future<void> logout() async {
    // Logout logic here
    await FirebaseAuth.instance.signOut();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final users = FirebaseFirestore.instance.collection('users');

  Future<void> updateUserById(String userId, Map<String, dynamic> data) async {
    await users.doc(userId).update(data);
  }
}
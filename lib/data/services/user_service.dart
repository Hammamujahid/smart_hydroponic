import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection('users');

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserById(String uid) {
    return _users.doc(uid).get();
  }

  Future<void> updateUserById(String userId, Map<String, dynamic> data) {
    return _users.doc(userId).update(data);
  }
}

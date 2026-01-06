import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_hydroponic/services/auth_session.dart';

class UserService {
  Future<void> pairing({required String deviceId}) async {
    // Pairing logic here
    try {
      final userUid = AuthSession().uid;
      if (userUid == null) {
        throw Exception('User not logged in');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .update({
        'deviceId': deviceId,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Pairing failed: $e');
    }
  }
}
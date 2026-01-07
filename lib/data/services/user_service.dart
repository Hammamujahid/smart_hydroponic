import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_hydroponic/data/services/auth_service.dart';

class UserService {
  Future<void> pairing({required String deviceId}) async {
    // Pairing logic here
    try {
      final userUid = AuthService().uid;
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
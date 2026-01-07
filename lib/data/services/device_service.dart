import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceService {
  final devices = FirebaseFirestore.instance.collection('devices');

  // ========== READ ==========
  Future<List<QueryDocumentSnapshot>> getDevices() async {
    final snapshot = await devices.get();
    return snapshot.docs;
  }

  Future<DocumentSnapshot> getDeviceById(String deviceId) async {
    return await devices.doc(deviceId).get();
  }

  // // ========== WRITE ==========
  // Future<void> updateDeviceById(
  //     String deviceId, String? userId, bool? claimed, DateTime updatedAt) async {
  //   try {
  //     await devices.doc(deviceId).update({
  //       if (userId != null) 'userUid': userId,
  //       if (claimed != null) 'claimed': claimed,
  //       'updatedAt': Timestamp.fromDate(updatedAt),
  //     });
  //   } catch (e) {
  //     throw Exception('Failed to update device by id $deviceId: $e');
  //   }
  // }
}

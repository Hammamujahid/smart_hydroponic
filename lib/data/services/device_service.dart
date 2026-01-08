import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceService {
  final devices = FirebaseFirestore.instance.collection('devices');

  // ========== READ ==========
  Future<List<QueryDocumentSnapshot>> getDevices() async {
    final snapshot = await devices.get();
    return snapshot.docs;
  }

  Future<DocumentSnapshot<Map<String,dynamic>>> getDeviceById(String deviceId) async {
    return await devices.doc(deviceId).get();
  }

  Future<void> updateDeviceById(String deviceId, Map<String, dynamic> data) async{
    await devices.doc(deviceId).update(data);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceService {
  final _devices = FirebaseFirestore.instance.collection('devices');

  Future<DocumentSnapshot<Map<String, dynamic>>> getDeviceById(
      String deviceId) {
    return _devices.doc(deviceId).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDevices() {
    return _devices.get();
  }

  Future<void> updateDeviceById(String deviceId, Map<String, dynamic> data) {
    return _devices.doc(deviceId).update(data);
  }
}

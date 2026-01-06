// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_hydroponic/models/device.dart';

class DeviceService {
  final devices = FirebaseFirestore.instance.collection('devices');

  // ========== READ ==========
  Future<List<Device>> getDevices() async {
    try {
      final snapshot = await devices.get();

      return snapshot.docs
          .map((doc) => Device.fromFirestore(doc, null))
          .toList();
    } catch (e) {
      throw Exception('Failed to get devices: $e');
    }
  }

  Future<Device> getDeviceById(String deviceId) async {
    try {
      final snapshot = await devices.doc(deviceId).get();
      if (!snapshot.exists) {
        throw Exception('Device not found');
      }
      return Device.fromFirestore(snapshot, null);
    } catch (e) {
      throw Exception('Failed to get device by id $deviceId: $e');
    }
  }

  // ========== WRITE ==========
  Future<void> updateDeviceById(
      String deviceId, String? userId, bool? claimed, DateTime updatedAt) async {
    try {
      await devices.doc(deviceId).update({
        if (userId != null) 'userUid': userId,
        if (claimed != null) 'claimed': claimed,
        'updatedAt': Timestamp.fromDate(updatedAt),
      });
    } catch (e) {
      throw Exception('Failed to update device by id $deviceId: $e');
    }
  }
}

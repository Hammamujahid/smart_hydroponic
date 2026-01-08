import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_hydroponic/data/models/device_model.dart';
import 'package:smart_hydroponic/data/services/device_service.dart';

class DeviceRepository {
  final DeviceService service;

  DeviceRepository(this.service);

  Future<List<DeviceModel>> getDevices() async {
    final docs = await service.getDevices();
    return docs
        .map((doc) => DeviceModel.fromFirestore(
            doc.data() as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  Future<DeviceModel?> getDeviceById(String deviceId) async {
    final doc = await service.getDeviceById(deviceId);
    if (!doc.exists) return null;

    return DeviceModel.fromFirestore(doc);
  }

  Future<void> updateDeviceById(DeviceModel device) async {
    await service.updateDeviceById(device.deviceId, device.toFirestore());
  }
}

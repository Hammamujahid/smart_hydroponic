import 'package:smart_hydroponic/data/models/device_model.dart';
import 'package:smart_hydroponic/data/services/device_service.dart';

class DeviceRepository {
  final DeviceService _service;

  DeviceRepository(this._service);

  Future<DeviceModel?> getDeviceById(String deviceId) async {
    final doc = await _service.getDeviceById(deviceId);
    if (!doc.exists) {
      return null;
    }
    return DeviceModel.fromFirestore(doc);
  }

  Future<List<DeviceModel>> getDevices() async {
    final snapshot = await _service.getDevices();
    return snapshot.docs.map(DeviceModel.fromFirestore).toList();
  }

  Future<void> updateDeviceById(DeviceModel device) {
    return _service.updateDeviceById(
        device.deviceId, device.toUpdateFirestore());
  }
}

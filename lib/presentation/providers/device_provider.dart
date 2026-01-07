import 'package:flutter/material.dart';
import 'package:smart_hydroponic/data/models/device_model.dart';
import 'package:smart_hydroponic/data/repositories/device_repository.dart';
import 'package:smart_hydroponic/data/services/device_service.dart';
import 'package:flutter_riverpod/legacy.dart';

final deviceProvider = ChangeNotifierProvider<DeviceProvider>((ref) {
  return DeviceProvider(
    DeviceRepository(DeviceService()),
  );
});

class DeviceProvider extends ChangeNotifier {
  final DeviceRepository repository;

  DeviceProvider(this.repository);

  List<DeviceModel> devices = [];
  DeviceModel? selectedDevice;
  bool isLoading = false;

  Future<List<DeviceModel>> getDevices() async {
    isLoading = true;
    notifyListeners();

    devices = await repository.getDevices();

    isLoading = false;
    notifyListeners();

    return devices.toList();
  }

  Future<DeviceModel?> getDeviceById(String id,
      {bool showLoading = true}) async {
    if (showLoading) {
      isLoading = true;
      notifyListeners();
    }

    selectedDevice = await repository.getDeviceById(id);

    if (showLoading) {
      isLoading = false;
      notifyListeners();
    }

    return selectedDevice;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_hydroponic/data/models/device_model.dart';
import 'package:smart_hydroponic/data/repositories/device_repository.dart';
import 'package:smart_hydroponic/data/services/device_service.dart';

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

  // ===== READ ALL =====
  Future<void> fetchDevices() async {
    isLoading = true;
    notifyListeners();

    devices = await repository.getDevices();

    isLoading = false;
    notifyListeners();
  }

  // ===== READ ONE =====
  Future<void> getDeviceById(String deviceId) async {
    if (deviceId.isEmpty) return;
    debugPrint("Fetching device with ID: $deviceId");

    isLoading = true;
    notifyListeners();

    try {
      selectedDevice = await repository.getDeviceById(deviceId);
    } catch (e) {
      selectedDevice = null;
    }

    isLoading = false;
    notifyListeners();
  }

  // ===== UPDATE (NON-PAIRING) =====
  Future<void> updateDeviceById({
    String? userId,
    String? title,
  }) async {
    if (selectedDevice == null) return;

    final updated = selectedDevice!.copyWith(
      userId: userId ?? selectedDevice!.userId,
      title: title ?? selectedDevice!.title,
      updatedAt: DateTime.now(),
    );

    await repository.updateDeviceById(updated);
    selectedDevice = updated;
    notifyListeners();
  }

  void reset() {
    devices = [];
    selectedDevice = null;
    isLoading = false;
    notifyListeners();
  }
}

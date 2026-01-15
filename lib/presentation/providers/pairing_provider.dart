import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_hydroponic/data/repositories/device_repository.dart';
import 'package:smart_hydroponic/data/repositories/user_repository.dart';
import 'package:smart_hydroponic/data/services/device_service.dart';
import 'package:smart_hydroponic/data/services/user_service.dart';
import 'package:smart_hydroponic/presentation/providers/auth_provider.dart';

final pairingProvider = ChangeNotifierProvider<PairingProvider>((ref) {
  final auth = ref.watch(authProvider);

  return PairingProvider(
    DeviceRepository(DeviceService()),
    UserRepository(UserService()),
    auth,
  );
});

enum PairingStatus {
  idle,
  loading,
  success,
  error,
}

class PairingProvider extends ChangeNotifier {
  final DeviceRepository deviceRepo;
  final UserRepository userRepo;
  final AuthProvider auth;

  PairingProvider(this.deviceRepo, this.userRepo, this.auth);

  PairingStatus status = PairingStatus.idle;
  String? errorMessage;

  Future<void> pair(String deviceId) async {
    final uid = auth.uid;
    if (uid == null) {
      status = PairingStatus.error;
      errorMessage = "User belum login";
      notifyListeners();
      return;
    }

    status = PairingStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final device = await deviceRepo.getDeviceById(deviceId);
      if (device == null) {
        throw Exception("Device tidak ditemukan");
      }

      if (device.userId != null) {
        throw Exception("Device sudah dipair");
      }

      final user = await userRepo.getUserById(uid);
      if (user == null) {
        throw Exception("User tidak ditemukan");
      }

      // === PAIRING (LOGIC ATOMIC DI LEVEL APLIKASI) ===
      await deviceRepo.updateDeviceById(
        device.copyWith(
          userId: uid,
          updatedAt: DateTime.now(),
        ),
      );

      await userRepo.updateUserById(
        user.copyWith(
          activeDeviceId: deviceId,
          updatedAt: DateTime.now(),
        ),
      );

      status = PairingStatus.success;
    } catch (e) {
      status = PairingStatus.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }
}

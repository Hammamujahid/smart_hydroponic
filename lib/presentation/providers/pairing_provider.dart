import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_hydroponic/data/repositories/device_repository.dart';
import 'package:smart_hydroponic/data/repositories/user_repository.dart';
import 'package:smart_hydroponic/data/services/auth_service.dart';
import 'package:smart_hydroponic/data/services/device_service.dart';
import 'package:smart_hydroponic/data/services/user_service.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';

final pairingProvider = ChangeNotifierProvider<PairingProvider>((ref) {
  return PairingProvider(
    ref,
    DeviceRepository(DeviceService()),
    UserRepository(UserService()),
    AuthService(),
  );
});

enum PairingStatus {
  idle,
  loading,
  success,
  error,
}

class PairingProvider extends ChangeNotifier {
  final Ref ref;
  final DeviceRepository deviceRepo;
  final UserRepository userRepo;
  final AuthService auth;

  PairingProvider(this.ref, this.deviceRepo, this.userRepo, this.auth);

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
    notifyListeners();

    try {
      debugPrint('DEVICE ID:  $deviceId');
      final device = await deviceRepo.getDeviceById(deviceId);
      if (device == null) {
        throw Exception("Device tidak ditemukan");
      }

      if (device.userId != null && device.userId!.isNotEmpty) {
        throw Exception("Device sudah dipair");
      }

      final user = await userRepo.getUserById(uid);
      if (user == null) {
        throw Exception("User tidak ditemukan");
      }

      debugPrint('MULAIII PAIRINGGGG DEVICE DENGAN USERID $uid');
      // === PAIRING (LOGIC ATOMIC DI LEVEL APLIKASI) ===
      await deviceRepo.updateDeviceById(
        device.copyWith(
          userId: uid,
          updatedAt: DateTime.now(),
        ),
      );

      debugPrint('update Device berhasillll');

      final updatedUser = user.copyWith(
        activeDeviceId: deviceId,
        updatedAt: DateTime.now(),
      );

      await userRepo.updateUserById(updatedUser);
      debugPrint('Updatee User BERHAISLLLLL');

// 🔥 SOURCE OF TRUTH UI
      ref.read(userProvider).setSelectedUser(updatedUser);
      debugPrint(' BERHAISLLLLL');

      status = PairingStatus.success;
    } catch (e) {
      status = PairingStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
    return;
  }
}

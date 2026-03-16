import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_hydroponic/data/models/device_model.dart';
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

//   Future<void> pair(String deviceId) async {
//     final uid = auth.uid;
//     if (uid == null) {
//       status = PairingStatus.error;
//       errorMessage = "User belum login";
//       notifyListeners();
//       return;
//     }

//     status = PairingStatus.loading;
//     notifyListeners();

//     try {

//       final device = await deviceRepo.getDeviceById(deviceId);
//       if (device == null) {
//         throw Exception("Device tidak ditemukan");
//       }

//       if (device.userId != null && device.userId!.isNotEmpty) {
//         throw Exception("Device sudah dipair");
//       }

//       final user = await userRepo.getUserById(uid);
//       if (user == null) {
//         throw Exception("User tidak ditemukan");
//       }

//       // === PAIRING (LOGIC ATOMIC DI LEVEL APLIKASI) ===
//       await deviceRepo.updateDeviceById(
//         device.copyWith(
//           userId: uid,
//           updatedAt: DateTime.now(),
//         ),
//       );

//       final updatedUser = user.copyWith(
//         activeDeviceId: deviceId,
//         updatedAt: DateTime.now(),
//       );

//       await userRepo.updateUserById(updatedUser);
//       debugPrint('Updatee User BERHAISLLLLL');

// // 🔥 SOURCE OF TRUTH UI
//       ref.read(userProvider).setSelectedUser(updatedUser);

//       status = PairingStatus.success;
//     } catch (e) {
//       status = PairingStatus.error;
//       errorMessage = e.toString();
//     }
//     notifyListeners();
//     return;
//   }

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

    /// 1️⃣ cek device di RTDB
    final existsInRTDB = await deviceRepo.deviceExistsInRTDB(deviceId);

    if (!existsInRTDB) {
      throw Exception("Device tidak ditemukan");
    }

    /// 2️⃣ cek device di Firestore
    final device = await deviceRepo.getDeviceById(deviceId);

    if (device == null) {

      /// 3️⃣ create device jika belum ada
      final newDevice = DeviceModel(
        deviceId: deviceId,
        userId: uid,
        title: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await deviceRepo.createDevice(newDevice);

    } else {

      /// 4️⃣ cek apakah sudah dipair
      if (device.userId != null && device.userId!.isNotEmpty) {
        throw Exception("Device sudah dipair");
      }

      /// update userId
      await deviceRepo.updateDeviceById(
        device.copyWith(
          userId: uid,
          updatedAt: DateTime.now(),
        ),
      );
    }

    /// update active device user
    final user = await userRepo.getUserById(uid);

    if (user == null) {
      throw Exception("User tidak ditemukan");
    }

    final updatedUser = user.copyWith(
      activeDeviceId: deviceId,
      updatedAt: DateTime.now(),
    );

    await userRepo.updateUserById(updatedUser);

    ref.read(userProvider).setSelectedUser(updatedUser);

    status = PairingStatus.success;

  } catch (e) {
    status = PairingStatus.error;
    errorMessage = e.toString();
  }

  notifyListeners();
}
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_hydroponic/data/models/user_model.dart';
import 'package:smart_hydroponic/data/repositories/user_repository.dart';
import 'package:smart_hydroponic/data/services/user_service.dart';

final userProvider = ChangeNotifierProvider<UserProvider>((ref) {
  return UserProvider(
    UserRepository(UserService()),
  );
});

class UserProvider extends ChangeNotifier {
  final UserRepository repository;

  UserProvider(this.repository);

  UserModel? selectedUser;
  bool isLoading = false;

  // ===== READ =====
Future<void> getUserById(String uid) async {
  if (uid.isEmpty) return;

  isLoading = true;
  notifyListeners();

  try {
    selectedUser = await repository.getUserById(uid);
  } catch (e) {
    selectedUser = null;
  }

  isLoading = false;
  notifyListeners();
}


  // ===== UPDATE PROFILE =====
  Future<void> updateUseById({
    String? username,
    String? activeDeviceId,
  }) async {
    if (selectedUser == null) return;

    final updated = selectedUser!.copyWith(
      username: username ?? selectedUser!.username,
      activeDeviceId: activeDeviceId ?? selectedUser!.activeDeviceId,
      updatedAt: DateTime.now(),
    );

    await repository.updateUserById(updated);

    selectedUser = updated;
    notifyListeners();
  }

  void reset() {
    selectedUser = null;
    isLoading = false;
    notifyListeners();
  }
}

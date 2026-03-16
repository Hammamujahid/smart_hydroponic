import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/auth_provider.dart';
import 'package:smart_hydroponic/presentation/providers/device_provider.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';
import 'package:smart_hydroponic/presentation/screens/auth/login.dart';
import 'package:smart_hydroponic/presentation/widgets/bottom_bar.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final userProv = ref.watch(userProvider);

    /// BOOTSTRAP USER
    if (auth.uid != null &&
        userProv.selectedUser == null &&
        !userProv.isLoading) {
      Future.microtask(() {
        ref.read(userProvider).getUserById(auth.uid!);
      });
    }

    /// BOOTSTRAP DEVICE
    final activeDeviceId = userProv.selectedUser?.activeDeviceId;
    if (activeDeviceId != null) {
      Future.microtask(() {
        ref.read(deviceProvider).getDeviceById(activeDeviceId);
      });
    }

    /// UI FLOW
    if (auth.uid == null) {
      return const LoginPage();
    }

    if (userProv.selectedUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return const BottomBar();
  }
}
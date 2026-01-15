import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/auth_provider.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';
import 'package:smart_hydroponic/presentation/screens/auth/login.dart';
import 'package:smart_hydroponic/presentation/screens/pairing.dart';
import 'package:smart_hydroponic/presentation/widgets/bottom_bar.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _fetched = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final userProv = ref.watch(userProvider);

    // ⛔ TUNGGU SAMPAI UID ADA
    if (auth.uid == null) {
      _fetched = false;
      return const LoginPage();
    }

    // FETCH USER SEKALI
    if (!_fetched) {
      _fetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userProvider).getUserById(auth.uid!);
      });
    }

    if (userProv.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userProv.selectedUser == null) {
      return const Scaffold(
        body: Center(child: Text("User data not found")),
      );
    }

    final deviceId = userProv.selectedUser!.activeDeviceId;
    if (deviceId == null || deviceId.isEmpty) {
      return const PairingScreen();
    }

    return const BottomBar();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/auth_provider.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';
import 'package:smart_hydroponic/presentation/screens/auth/login.dart';
import 'package:smart_hydroponic/presentation/widgets/bottom_bar.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final userProv = ref.watch(userProvider);

    // ===== BOOTSTRAP USER (ONLY IF AUTH VALID) =====
    if (auth.uid != null &&
        userProv.selectedUser == null &&
        !userProv.isLoading) {
      Future.microtask(() {
        // DOUBLE GUARD
        final currentUid = ref.read(authProvider).uid;
        if (currentUid != null) {
          ref.read(userProvider).getUserById(currentUid);
        }
      });
    }

    // ===== UI FLOW =====
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

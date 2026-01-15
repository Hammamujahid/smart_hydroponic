import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/auth_provider.dart';
import 'package:smart_hydroponic/presentation/providers/dashboard_provider.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';
import 'package:smart_hydroponic/presentation/screens/auth/login.dart';
import 'package:smart_hydroponic/presentation/widgets/control_card.dart';
import 'package:smart_hydroponic/presentation/widgets/sensor_card.dart';

class Dashboard extends ConsumerStatefulWidget {
  final NotchBottomBarController? controller;
  const Dashboard({super.key, this.controller});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final dashboard = ref.watch(dashboardProvider);

    if (userState.isLoading || userState.selectedUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final activeDeviceId = userState.selectedUser!.activeDeviceId;

    return Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          toolbarHeight: 80,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "WELCOME BACK!",
                style: TextStyle(
                    color: Color(0XFF64748B),
                    fontSize: 12,
                    fontFamily: "PlusJakartaSans",
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                "Smart Hydroponic",
                style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 20,
                    fontFamily: "PlusJakartaSans",
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: const Color(0xFFE2E8F0),
              )),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () async {
                    await ref.read(authProvider).logout();
                    ref.read(userProvider).reset();

                    Navigator.pushAndRemoveUntil(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2FE),
                    child: Icon(Icons.menu, color: Color(0xFF0284C7)),
                  ),
                ))
          ],
        ),
        body: (activeDeviceId == null || activeDeviceId.isEmpty)
            ? const Center(
                child: Text(
                  "Pairing First",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : CustomScrollView(
                slivers: [
                  _buildLiveStatusTitle(dashboard),
                  _buildLiveStatus(dashboard),
                  _buildDeviceControlTitle(),
                  _buildDeviceControl(ref, dashboard),
                ],
              ));
  }

  SliverToBoxAdapter _buildLiveStatusTitle(DashboardProvider d) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Live Status",
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontFamily: "PlusJakartaSans",
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  d.isOnline == true
                      ? const Icon(
                          Icons.circle,
                          color: Color(0xFF059669),
                          size: 12,
                        )
                      : const Icon(
                          Icons.circle,
                          color: Color(0xFFE2E8F0),
                          size: 12,
                        ),
                  const SizedBox(
                    width: 5,
                  ),
                  d.isOnline == true
                      ? const Text(
                          "System Online",
                          style: TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 14,
                              fontFamily: "PlusJakartaSans",
                              fontWeight: FontWeight.w500),
                        )
                      : const Text(
                          "System Offline",
                          style: TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 14,
                              fontFamily: "PlusJakartaSans",
                              fontWeight: FontWeight.w500),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  SliverPadding _buildLiveStatus(DashboardProvider d) {
    return SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
        sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            delegate: SliverChildListDelegate.fixed(
              [
                SensorCard(
                  title: 'Nutrient Level',
                  value: d.nutrientLevel.toString(),
                  unit: 'ppm',
                  status: 'Normal',
                  bgStatusColor: const Color(0xFFF4DCFC),
                  iconPath: 'assets/images/nutrient.png',
                  bgIconColor: const Color.fromARGB(20, 78, 13, 84),
                  statusColor: const Color(0xFFA6009B),
                ),
                SensorCard(
                  title: 'pH Level',
                  value: d.phLevel.toString(),
                  unit: 'pH',
                  status: 'Normal',
                  bgStatusColor: const Color(0xFFFEF3C6),
                  iconPath: 'assets/images/ph.png',
                  bgIconColor: const Color.fromARGB(20, 123, 51, 6),
                  statusColor: const Color(0xFFBB4D00),
                ),
                SensorCard(
                  title: 'Water Level',
                  value: d.waterLevel.toString(),
                  unit: '%',
                  status: 'Low',
                  bgStatusColor: const Color(0xFFE2EBFF),
                  iconPath: 'assets/images/water.png',
                  bgIconColor: const Color.fromARGB(20, 2, 73, 112),
                  statusColor: const Color(0xFF155DFC),
                ),
              ],
            )));
  }

  SliverToBoxAdapter _buildDeviceControlTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsetsGeometry.fromLTRB(20, 35, 20, 0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Device Control",
                style: TextStyle(
                    fontFamily: "PlusJakartaSans",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A)),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "Manage All",
                  style: TextStyle(
                      fontFamily: "PlusJakartaSans",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF059669)),
                ),
              )
            ]),
      ),
    );
  }

  SliverToBoxAdapter _buildDeviceControl(WidgetRef ref, DashboardProvider d) {
    return SliverToBoxAdapter(
        child: Padding(
      padding: const EdgeInsetsGeometry.fromLTRB(20, 15, 20, 120),
      child: LayoutBuilder(builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedToggleSwitch<String>.size(
              current: d.controllerMode.value,
              values: const ["manual", "auto"],
              iconOpacity: 0.2,
              indicatorSize: Size(fullWidth / 2, 42),
              customIconBuilder: (context, local, global) => Text(
                local.value == "auto" ? "Auto" : "Manual",
                style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontFamily: "PlusJakartaSans",
                    fontWeight: FontWeight.w600),
              ),
              borderWidth: 5.0,
              iconAnimationType: AnimationType.onHover,
              style: ToggleStyle(
                  backgroundColor: Colors.white,
                  indicatorColor: const Color(0xFF059669),
                  borderColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    const BoxShadow(
                      color: Color(0xFFE2E8F0),
                      spreadRadius: 0.5,
                      blurRadius: 1,
                      offset: Offset(0, 3),
                    )
                  ]),
              selectedIconScale: 1.0,
              onChanged: (value) {
                ref.read(dashboardProvider).setMode(value);
              },
            ),
            const SizedBox(
              height: 5,
            ),
            ValueListenableBuilder<String>(
                valueListenable: d.controllerMode,
                builder: (_, value, __) {
                  return value == "manual"
                      ? Column(children: [
                          ControlCard(
                            title: "Water Pump",
                            isActive: d.waterController.value,
                            uptime: "",
                            iconPath: "assets/images/water.png",
                            bgIconColor: const Color(0xFFEFF6FF),
                            onToggle: (value) {
                              ref.read(dashboardProvider).setWater(value);
                            },
                          ),
                          ControlCard(
                            title: "Nutrient Pump",
                            isActive: d.nutrientController.value,
                            uptime: "",
                            iconPath: "assets/images/nutrient.png",
                            bgIconColor: const Color(0xFFFBEFFF),
                            onToggle: (value) {
                              ref.read(dashboardProvider).setNutrient(value);
                            },
                          )
                        ])
                      : const Center(
                          child: Text("Auto"),
                        );
                })
          ],
        );
      }),
    ));
  }
}

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/rtdb_provider.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';
import 'package:smart_hydroponic/presentation/widgets/control_card.dart';
import 'package:smart_hydroponic/presentation/widgets/qr_scanner.dart';
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
    final userProv = ref.watch(userProvider);
    final rtdb = ref.watch(rtdbProvider);
    final deviceId = userProv.selectedUser?.activeDeviceId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (deviceId != null && deviceId.isNotEmpty) {
        ref.read(rtdbProvider).init(deviceId);
      } else {
        ref.read(rtdbProvider).disposeRTDB();
      }
      debugPrint("DASHBOARD INIT → $deviceId");
    });

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
            backgroundColor: Colors.transparent,
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
                      onTap: () {},
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.tap_and_play_rounded,
                            color: Color(0xFF059669)),
                      ),
                    ))
              ],
            ),
            body: (deviceId == null || deviceId.isEmpty)
                ? _buildPairingPlaceholder(context)
                : CustomScrollView(
                    slivers: [
                      _buildLiveStatusTitle(rtdb),
                      _buildLiveStatus(rtdb),
                      _buildDeviceControlTitle(rtdb),
                      _buildDeviceControl(ref, rtdb),
                    ],
                  )),
      ],
    );
  }

  Widget _buildPairingPlaceholder(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  const Text(
                    "Pair Your Controller",
                    style: TextStyle(
                        fontFamily: "PlusJakartaSans",
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF41877F),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/scanning_qr.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QrScanner(),
                          ));
                    },
                    child: Container(
                      width: screenWidth / 2,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF41877F),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFE2E8F0),
                            spreadRadius: 0.5,
                            blurRadius: 1,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Scan Now",
                          style: TextStyle(
                              fontFamily: "PlusJakartaSanz",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SliverToBoxAdapter _buildLiveStatusTitle(RTDBProvider rtdb) {
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
                child: ValueListenableBuilder<String>(
              valueListenable: rtdb.deviceStatus,
              builder: (context, value, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      color: value == "online"
                          ? const Color(0xFF059669)
                          : const Color(0xFF990003),
                      size: 12,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      value == "online" ? "System Online" : "System Offline",
                      style: TextStyle(
                          color: value == "online"
                              ? const Color(0xFF059669)
                              : const Color(0xFF990003),
                          fontSize: 14,
                          fontFamily: "PlusJakartaSans",
                          fontWeight: FontWeight.w500),
                    )
                  ],
                );
              },
            ))
          ],
        ),
      ),
    );
  }

  SliverPadding _buildLiveStatus(RTDBProvider rtdb) {
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
                ValueListenableBuilder<double>(
                  valueListenable: rtdb.nutrientLevel,
                  builder: (_, value, __) {
                    return SensorCard(
                      title: 'Nutrient Level',
                      value: value.toStringAsFixed(2),
                      unit: 'ppm',
                      status: 'Normal',
                      bgStatusColor: const Color(0xFFF4DCFC),
                      iconPath: 'assets/images/nutrient.png',
                      bgIconColor: const Color.fromARGB(20, 78, 13, 84),
                      statusColor: const Color(0xFFA6009B),
                    );
                  },
                ),
                ValueListenableBuilder<double>(
                  valueListenable: rtdb.phLevel,
                  builder: (_, value, __) {
                    return SensorCard(
                      title: 'pH Level',
                      value: value.toStringAsFixed(2),
                      unit: 'pH',
                      status: 'Normal',
                      bgStatusColor: const Color(0xFFFEF3C6),
                      iconPath: 'assets/images/ph.png',
                      bgIconColor: const Color.fromARGB(20, 123, 51, 6),
                      statusColor: const Color(0xFFBB4D00),
                    );
                  },
                ),
                ValueListenableBuilder<double>(
                  valueListenable: rtdb.waterLevel,
                  builder: (_, value, __) {
                    return SensorCard(
                      title: 'Water Level',
                      value: value.toStringAsFixed(0),
                      unit: '%',
                      status: value < 30 ? 'Low' : 'Normal',
                      bgStatusColor: const Color(0xFFE2EBFF),
                      iconPath: 'assets/images/water.png',
                      bgIconColor: const Color.fromARGB(20, 2, 73, 112),
                      statusColor: const Color(0xFF155DFC),
                    );
                  },
                ),
              ],
            )));
  }

  SliverToBoxAdapter _buildDeviceControlTitle(RTDBProvider rtdb) {
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
              ValueListenableBuilder<String>(
                  valueListenable: rtdb.controllerMode,
                  builder: (context, value, child) {
                    return Text(
                      value == "manual" ? "Manual" : "Auto",
                      style: TextStyle(
                          fontFamily: "PlusJakartaSans",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: value == "manual"
                              ? const Color(0xFF990003)
                              : const Color(0xFF059669)),
                    );
                  })
            ]),
      ),
    );
  }

  SliverToBoxAdapter _buildDeviceControl(WidgetRef ref, RTDBProvider rtdb) {
    return SliverToBoxAdapter(
        child: Padding(
      padding: const EdgeInsetsGeometry.fromLTRB(20, 5, 20, 120),
      child: LayoutBuilder(builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<String>(
                valueListenable: rtdb.controllerMode,
                builder: (_, value, __) {
                  return value == "manual"
                      ? Column(children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: rtdb.waterController,
                            builder: (_, isActive, __) {
                              return ControlCard(
                                title: "Water Pump",
                                isActive: isActive,
                                uptime: "",
                                iconPath: "assets/images/water.png",
                                bgIconColor: const Color(0xFFEFF6FF),
                                onToggle: (value) {
                                  ref.read(rtdbProvider).setWater(value);
                                },
                              );
                            },
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: rtdb.nutrientController,
                            builder: (_, isActive, __) {
                              return ControlCard(
                                title: "Nutrient Pump",
                                isActive: isActive,
                                uptime: "",
                                iconPath: "assets/images/nutrient.png",
                                bgIconColor: const Color(0xFFFBEFFF),
                                onToggle: (value) {
                                  ref.read(rtdbProvider).setNutrient(value);
                                },
                              );
                            },
                          ),
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

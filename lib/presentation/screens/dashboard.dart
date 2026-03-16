// ignore_for_file: use_build_context_synchronously

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/auth_provider.dart';
import 'package:smart_hydroponic/presentation/providers/device_provider.dart';
import 'package:smart_hydroponic/presentation/providers/rtdb_provider.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';
import 'package:smart_hydroponic/presentation/widgets/control_card.dart';
import 'package:smart_hydroponic/presentation/widgets/qr_scanner.dart';
import 'package:smart_hydroponic/presentation/widgets/sensor_card.dart';
import 'package:toastification/toastification.dart';

class Dashboard extends ConsumerStatefulWidget {
  final NotchBottomBarController? controller;
  const Dashboard({super.key, this.controller});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard>
    with AutomaticKeepAliveClientMixin {
  String? _deviceInitialized;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final auth = ref.read(authProvider);
      final uid = auth.uid;

      if (uid != null) {
        ref.read(deviceProvider).getDevicesByUserId(uid);
      }

      final deviceId = ref.read(userProvider).selectedUser?.activeDeviceId;

      if (deviceId != null && deviceId.isNotEmpty) {
        ref.read(rtdbProvider).init(deviceId);
        _deviceInitialized = deviceId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final userProv = ref.watch(userProvider);
    final deviceId = userProv.selectedUser?.activeDeviceId;

    /// jika device berubah
    if (deviceId != _deviceInitialized && deviceId != null) {
      Future.microtask(() {
        ref.read(rtdbProvider).init(deviceId);
        _deviceInitialized = deviceId;
      });
    }

    final rtdb = ref.watch(rtdbProvider);

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
            ),
            endDrawer: Drawer(
              backgroundColor: const Color(0xFFF1F5F9),
              child: Consumer(
                builder: (context, ref, child) {
                  final userProv = ref.watch(userProvider);
                  final deviceProv = ref.watch(deviceProvider);

                  final activeId = userProv.selectedUser?.activeDeviceId;

                  if (deviceProv.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allDevices = deviceProv.otherDevices;

                  final activeDevice = allDevices
                      .where((d) => d.deviceId == activeId)
                      .cast()
                      .toList();

                  final otherDevices =
                      allDevices.where((d) => d.deviceId != activeId).toList();

                  return ListView(
                    children: [
                      /// ACTIVE DEVICE
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Active Device",
                          style: TextStyle(
                              fontFamily: "PlusJakartaSans",
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),

                      if (activeDevice.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF41877F), // background tile
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(255, 57, 118, 111),
                                spreadRadius: 0.5,
                                blurRadius: 1,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.devices,
                              color: Color(0xFFE2E8F0),
                            ),
                            title: Text(
                              (activeDevice.first.title?.isNotEmpty ?? false)
                                  ? activeDevice.first.title!
                                  : "No Title",
                              style: const TextStyle(
                                  fontFamily: "PlusJakartaSans",
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFE2E8F0)),
                            ),
                            subtitle: Text(
                              activeDevice.first.deviceId,
                              style: const TextStyle(
                                  fontFamily: "PlusJakartaSans",
                                  color: Color(0xFFE2E8F0)),
                            ),
                          ),
                        ),

                      /// OTHER DEVICES
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Other Devices",
                          style: TextStyle(
                              fontFamily: "PlusJakartaSans",
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),

                      ...otherDevices.map((device) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white, // background tile
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFE2E8F0),
                                spreadRadius: 0.5,
                                blurRadius: 1,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.devices_outlined),
                            title: Text(
                              (device.title?.isNotEmpty ?? false)
                                  ? device.title!
                                  : "No Title",
                              style: const TextStyle(
                                  fontFamily: "PlusJakartaSans",
                                  fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              device.deviceId,
                              style: const TextStyle(
                                  fontFamily: "PlusJakartaSans"),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Color(0xFF990003)),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    title: const Text(
                                      "Confirm Device Removal",
                                      style: TextStyle(
                                          fontFamily: "PlusJakartaSans",
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: const Text(
                                      "Are you sure you want to remove this device?",
                                      style: TextStyle(
                                        fontFamily: "PlusJakartaSans",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "PlusJakartaSans")),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF990003)),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Remove",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "PlusJakartaSans")),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await ref
                                      .read(deviceProvider)
                                      .removeUserIdByDeviceId(device.deviceId);

                                  if (!mounted) return;

                                  toastification.show(
                                    type: ToastificationType.success,
                                    context: context,
                                    title: const Text(
                                      'Device removed successfully',
                                      style: TextStyle(
                                          fontFamily: 'PlusJakartaSans'),
                                    ),
                                    autoCloseDuration:
                                        const Duration(seconds: 3),
                                  );

                                  final userId = ref.read(authProvider).uid;
                                  if (userId != null) {
                                    await ref
                                        .read(deviceProvider)
                                        .getDevicesByUserId(userId);
                                  }
                                }
                              },
                            ),
                            onTap: () {
                              final auth = ref.read(authProvider);

                              ref.read(userProvider).updateActiveDeviceId(
                                    (auth.uid).toString(),
                                    device.deviceId,
                                  );

                              Navigator.pop(context);
                            },
                          ),
                        );
                      }),

                      SizedBox(height: 16,),
                      const Divider(),

                      /// ADD DEVICE
                      ListTile(
                        leading: const Icon(Icons.qr_code_scanner),
                        title: const Text(
                          "Add Device",
                          style: TextStyle(
                              fontFamily: "PlusJakartaSans",
                              fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QrScanner(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
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
                child: ValueListenableBuilder<int>(
              valueListenable: rtdb.deviceStatus,
              builder: (context, value, child) {
                // waktu sekarang
                int nowMillis = DateTime.now().millisecondsSinceEpoch;

                // selisih dalam millisecond
                int diffMillis = nowMillis - value;

                // jika selisih > 5 menit → offline
                bool isOnline = diffMillis < 5 * 60 * 1000;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      color: isOnline
                          ? const Color(0xFF059669)
                          : const Color(0xFF990003),
                      size: 12,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(isOnline ? "System Online" : "System Offline",
                        style: TextStyle(
                          color: isOnline
                              ? const Color(0xFF059669)
                              : const Color(0xFF990003),
                          fontSize: 14,
                          fontFamily: "PlusJakartaSans",
                          fontWeight: FontWeight.w500,
                        ))
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
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "Tooltip",
                  style: TextStyle(
                      fontFamily: "PlusJakartaSans",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A)),
                ),
              )
            ]),
      ),
    );
  }

  SliverToBoxAdapter _buildDeviceControl(WidgetRef ref, RTDBProvider rtdb) {
    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ValueListenableBuilder<String>(
            valueListenable: rtdb.waterMode,
            builder: (_, waterValue, __) {
              return ValueListenableBuilder<String>(
                valueListenable: rtdb.nutrientMode,
                builder: (_, nutrientValue, __) {
                  if (waterValue == "auto" && nutrientValue == "auto") {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 20,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/control_auto.png',
                          width: double.infinity,
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (waterValue == "manual")
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                          child: ValueListenableBuilder<bool>(
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
                        ),
                      if (nutrientValue == "manual")
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                          child: ValueListenableBuilder<bool>(
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
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

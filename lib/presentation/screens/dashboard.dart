import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:smart_hydroponic/presentation/screens/auth/login.dart';
import 'package:smart_hydroponic/data/services/auth_service.dart';
import 'package:smart_hydroponic/data/services/rtdb_service.dart';
import 'package:smart_hydroponic/presentation/widgets/control_card.dart';
import 'package:smart_hydroponic/presentation/widgets/sensor_card.dart';

class Dashboard extends StatefulWidget {
  final NotchBottomBarController? controller;

  const Dashboard({super.key, this.controller});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isOnline = true;
  final ValueNotifier<String> controllerMode = ValueNotifier<String>("manual");
  final ValueNotifier<bool> waterController = ValueNotifier<bool>(false);
  final ValueNotifier<bool> nutrientController = ValueNotifier<bool>(false);
  final ValueNotifier<double> nutrientLevel = ValueNotifier<double>(0.0);

  @override
  void dispose() {
    controllerMode.dispose();
    waterController.dispose();
    nutrientController.dispose();
    nutrientLevel.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    RTDBService.getAutoModeStream().listen((value) {
      controllerMode.value = value;
    });
    RTDBService.getWaterControllerStream().listen((value) {
      waterController.value = value;
    });
    RTDBService.getNutrientControllerStream().listen((value) {
      nutrientController.value = value;
    });
    RTDBService.getNutrientSensorStream().listen((value) {
      nutrientLevel.value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    try {
                      AuthService().logout();
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2FE),
                    child: Icon(Icons.menu, color: Color(0xFF0284C7)),
                  ),
                ))
          ],
        ),
        body: CustomScrollView(
          slivers: [
            _buildLiveStatusTitle(),
            _buildLiveStatus(),
            _buildDeviceControlTitle(),
            _buildDeviceControl(),
          ],
        ));
  }

  SliverToBoxAdapter _buildLiveStatusTitle() {
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
                  isOnline == true
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
                  isOnline == true
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

  SliverPadding _buildLiveStatus() {
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
                  value: nutrientLevel.value.toString(),
                  unit: 'ppm',
                  status: 'Normal',
                  bgStatusColor: const Color(0xFFF4DCFC),
                  iconPath: 'assets/images/nutrient.png',
                  bgIconColor: const Color.fromARGB(20, 78, 13, 84),
                  statusColor: const Color(0xFFA6009B),
                ),
                const SensorCard(
                  title: 'pH Level',
                  value: "",
                  unit: 'pH',
                  status: 'Normal',
                  bgStatusColor: Color(0xFFFEF3C6),
                  iconPath: 'assets/images/ph.png',
                  bgIconColor: Color.fromARGB(20, 123, 51, 6),
                  statusColor: Color(0xFFBB4D00),
                ),
                const SensorCard(
                  title: 'Water Level',
                  value: "",
                  unit: '%',
                  status: 'Low',
                  bgStatusColor: Color(0xFFE2EBFF),
                  iconPath: 'assets/images/water.png',
                  bgIconColor: Color.fromARGB(20, 2, 73, 112),
                  statusColor: Color(0xFF155DFC),
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

  SliverToBoxAdapter _buildDeviceControl() {
    return SliverToBoxAdapter(
        child: Padding(
      padding: const EdgeInsetsGeometry.fromLTRB(20, 15, 20, 120),
      child: LayoutBuilder(builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedToggleSwitch<String>.size(
              current: controllerMode.value,
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
              onChanged: (value) => setState(() {
                controllerMode.value = value;
                RTDBService.setAutoMode(value);
                if (value == "auto") {
                  RTDBService.setWaterController(false);
                  RTDBService.setNutrientController(false);
                }
              }),
            ),
            const SizedBox(
              height: 5,
            ),
            ValueListenableBuilder<String>(
                valueListenable: controllerMode,
                builder: (_, value, __) {
                  return value == "manual"
                      ? Column(children: [
                          ControlCard(
                              title: "Water Pump",
                              isActive: waterController.value,
                              uptime: "",
                              iconPath: "assets/images/water.png",
                              bgIconColor: const Color(0xFFEFF6FF),
                              onToggle: (value) {
                                setState(() {
                                  waterController.value = value;
                                  RTDBService.setWaterController(value);
                                });
                              }),
                          ControlCard(
                              title: "Nutrient Pump",
                              isActive: nutrientController.value,
                              uptime: "",
                              iconPath: "assets/images/nutrient.png",
                              bgIconColor: const Color(0xFFFBEFFF),
                              onToggle: (value) {
                                setState(() {
                                  nutrientController.value = value;
                                  RTDBService.setNutrientController(value);
                                });
                              })
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

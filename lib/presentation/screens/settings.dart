import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/data/models/device_model.dart';
import 'package:smart_hydroponic/data/models/user_model.dart';
import 'package:smart_hydroponic/presentation/providers/auth_provider.dart';
import 'package:smart_hydroponic/presentation/providers/device_provider.dart';
import 'package:smart_hydroponic/presentation/providers/rtdb_provider.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';
import 'package:smart_hydroponic/presentation/widgets/edit_dialog.dart';

class Settings extends ConsumerStatefulWidget {
  final NotchBottomBarController? controller;

  const Settings({super.key, this.controller});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings>
    with AutomaticKeepAliveClientMixin {
  final _usernameController = TextEditingController();
  final _plantController = TextEditingController();
  final _waterMaxController = TextEditingController();
  final _waterDurationController = TextEditingController();
  final _waterIntervalController = TextEditingController();
  final _nutrientThresholdMinController = TextEditingController();
  final _nutrientThresholdMaxController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _usernameController.dispose();
    _plantController.dispose();
    _waterMaxController.dispose();
    _waterDurationController.dispose();
    _waterIntervalController.dispose();
    _nutrientThresholdMinController.dispose();
    _nutrientThresholdMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenWidth = MediaQuery.of(context).size.width;
    final rtdb = ref.watch(rtdbProvider);
    final user = ref.watch(userProvider).selectedUser;
    final device = ref.watch(deviceProvider).selectedDevice;

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
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              title: const Text(
                "Settings",
                style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 20,
                    fontFamily: "PlusJakartaSans",
                    fontWeight: FontWeight.w700),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userProvider);
                ref.invalidate(deviceProvider);
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildAccountInfoTile(user),
                    (user?.activeDeviceId == null || user?.activeDeviceId == "")
                        ? const SizedBox()
                        : _buildDevicePreferences(rtdb, device),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: screenWidth,
                        height: 58,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            ref.read(rtdbProvider).disposeRTDB();
                            ref.read(userProvider).reset();
                            ref.read(deviceProvider).reset();
                            await ref.read(authProvider).logout();
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: "PlusJakartaSans",
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF990003),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    )
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildAccountInfoTile(UserModel? user) {
    return ExpansionTile(
      childrenPadding: const EdgeInsets.fromLTRB(17, 0, 17, 0),
      title: const Text("Account Info",
          style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: "PlusJakartaSans")),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 25),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFE2E8F0),
                spreadRadius: 0.5,
                blurRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Email",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: "PlusJakartaSans",
                    fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                user?.email ?? "",
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: "PlusJakartaSans",
                    fontSize: 14),
              )
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 25),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFE2E8F0),
                spreadRadius: 0.5,
                blurRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Username",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: "PlusJakartaSans",
                        fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user?.username ?? "",
                    style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: "PlusJakartaSans",
                        fontSize: 14),
                  )
                ],
              ),
              IconButton(
                onPressed: () async {
                  _usernameController.text = user?.username ?? "";

                  final result = await showDialog(
                    context: context,
                    builder: (_) => EditDialogPopup(
                      title: "Edit Username",
                      isTwoFields: false,
                      label1: "Username",
                      controller1: _usernameController,
                      notification: "Username",
                    ),
                  );

                  if (result == null) return;

                  final newUsername = (result["value1"] as String).trim();

                  if (newUsername.isEmpty || newUsername == user?.username) {
                    return;
                  }

                  await ref
                      .read(userProvider)
                      .updateUserById(username: newUsername);
                },
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDevicePreferences(RTDBProvider rtdb, DeviceModel? device) {
    return ExpansionTile(
      childrenPadding: const EdgeInsets.fromLTRB(17, 0, 17, 0),
      title: const Text("Device Preferences",
          style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: "PlusJakartaSans")),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 25),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFE2E8F0),
                spreadRadius: 0.5,
                blurRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Plant",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: "PlusJakartaSans",
                        fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                (device?.title?.isNotEmpty ?? false) ? device!.title! : "No Title",
                    style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: "PlusJakartaSans",
                        fontSize: 14),
                  )
                ],
              ),
              IconButton(
                onPressed: () async {
                  _plantController.text = device?.title ?? "";

                  final result = await showDialog(
                    context: context,
                    builder: (_) => EditDialogPopup(
                      title: "Edit Plant",
                      isTwoFields: false,
                      label1: "Plant",
                      controller1: _plantController,
                      notification: "Plant",
                    ),
                  );

                  if (result == null) return;

                  final newPlant = result["value1"];

                  if (newPlant == device?.title) return;

                  await ref
                      .read(deviceProvider)
                      .updateDeviceById(title: newPlant);
                },
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xFF64748B),
                ),
              )
            ],
          ),
        ),
        Container(
            margin: const EdgeInsets.only(bottom: 25),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFE2E8F0),
                  spreadRadius: 0.5,
                  blurRadius: 1,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Water Max",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: "PlusJakartaSans",
                          fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    ValueListenableBuilder<double>(
                      valueListenable: rtdb.waterMax,
                      builder: (_, value, __) {
                        return Text(
                          "${value.toStringAsFixed(0)} cm",
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: "PlusJakartaSans",
                              fontSize: 14),
                        );
                      },
                    )
                  ],
                ),
                IconButton(
                  onPressed: () async {
                    _waterMaxController.text =
                        rtdb.waterMax.value.toStringAsFixed(0);

                    final result = await showDialog(
                      context: context,
                      builder: (_) => EditDialogPopup(
                        title: "Edit Water Max",
                        isTwoFields: false,
                        label1: "Water Max",
                        controller1: _waterMaxController,
                        keyboardType1: TextInputType.number,
                        notification: "Water Max",
                      ),
                    );

                    if (result == null) return;

                    final value = double.tryParse(result["value1"]);

                    if (value == null) return;
                    if (value == rtdb.waterMax.value) return;

                    ref.read(rtdbProvider).setWaterMax(value);
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF64748B),
                  ),
                )
              ],
            )),
        Container(
          margin: const EdgeInsets.only(bottom: 25),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFE2E8F0),
                spreadRadius: 0.5,
                blurRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Water Control",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: "PlusJakartaSans",
                    fontSize: 16),
              ),
              const SizedBox(height: 5),
              ValueListenableBuilder<String>(
                  valueListenable: rtdb.waterMode,
                  builder: (context, value, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioMenuButton(
                            value: "manual",
                            groupValue: value,
                            onChanged: (selected) {
                              if (selected == null) return;
                              if (selected == value) {
                                return; // guard penting
                              }
                              ref.read(rtdbProvider).setWaterMode(selected);
                            },
                            child: const Text("Manual")),
                        RadioMenuButton(
                            value: "auto",
                            groupValue: value,
                            onChanged: (selected) {
                              if (selected == null) return;
                              if (selected == value) return;
                              ref.read(rtdbProvider).setWaterMode(selected);
                            },
                            child: const Text("Auto")),
                        const SizedBox(
                          height: 10,
                        ),
                        value == "auto"
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        spacing: 5,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Set Duration :",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "PlusJakartaSans",
                                                fontSize: 14),
                                          ),
                                          const SizedBox(height: 5),
                                          ValueListenableBuilder<double>(
                                            valueListenable: rtdb.waterDuration,
                                            builder: (_, value, __) {
                                              return Text(
                                                "${value.toStringAsFixed(0)} seconds",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        "PlusJakartaSans",
                                                    fontSize: 14),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          _waterDurationController.text = rtdb
                                              .waterDuration.value
                                              .toStringAsFixed(0);
                                          final result = await showDialog(
                                            context: context,
                                            builder: (_) => EditDialogPopup(
                                              title: "Edit Water Duration",
                                              isTwoFields: false,
                                              label1: "Water Duration",
                                              controller1:
                                                  _waterDurationController,
                                              keyboardType1:
                                                  TextInputType.number,
                                              notification: "Water Duration",
                                            ),
                                          );

                                          if (result == null) {
                                            return;
                                          }

                                          final duration =
                                              double.tryParse(result["value1"]);

                                          if (duration == null) {
                                            return;
                                          }
                                          if (duration ==
                                              rtdb.waterDuration.value) return;

                                          ref
                                              .read(rtdbProvider)
                                              .setWaterDuration(duration);
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Color(0xFF64748B),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        spacing: 5,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Set Interval :",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "PlusJakartaSans",
                                                fontSize: 14),
                                          ),
                                          const SizedBox(height: 5),
                                          ValueListenableBuilder<double>(
                                            valueListenable: rtdb.waterInterval,
                                            builder: (_, value, __) {
                                              return Text(
                                                "${value.toStringAsFixed(0)} seconds",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        "PlusJakartaSans",
                                                    fontSize: 14),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          _waterIntervalController.text = rtdb
                                              .waterInterval.value
                                              .toStringAsFixed(0);
                                          final result = await showDialog(
                                            context: context,
                                            builder: (_) => EditDialogPopup(
                                              title: "Edit Water Interval",
                                              isTwoFields: false,
                                              label1: "Water Interval",
                                              controller1:
                                                  _waterIntervalController,
                                              keyboardType1:
                                                  TextInputType.number,
                                              notification: "Water Interval",
                                            ),
                                          );

                                          if (result == null) {
                                            return;
                                          }

                                          final interval =
                                              double.tryParse(result["value1"]);

                                          if (interval == null) {
                                            return;
                                          }
                                          if (interval ==
                                              rtdb.waterInterval.value) return;

                                          ref
                                              .read(rtdbProvider)
                                              .setWaterInterval(interval);
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Color(0xFF64748B),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  })
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 25),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFE2E8F0),
                spreadRadius: 0.5,
                blurRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nutrient Control",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: "PlusJakartaSans",
                    fontSize: 16),
              ),
              const SizedBox(height: 5),
              ValueListenableBuilder<String>(
                  valueListenable: rtdb.nutrientMode,
                  builder: (context, value, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioMenuButton(
                            value: "manual",
                            groupValue: value,
                            onChanged: (selected) {
                              if (selected == null) return;
                              if (selected == value) {
                                return; // guard penting
                              }
                              ref.read(rtdbProvider).setNutrientMode(selected);
                            },
                            child: const Text("Manual")),
                        RadioMenuButton(
                            value: "auto",
                            groupValue: value,
                            onChanged: (selected) {
                              if (selected == null) return;
                              if (selected == value) return;
                              ref.read(rtdbProvider).setNutrientMode(selected);
                            },
                            child: const Text("Auto")),
                        const SizedBox(
                          height: 10,
                        ),
                        value == "auto"
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Set TDS Level :",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "PlusJakartaSans",
                                            fontSize: 14),
                                      ),
                                      Row(
                                        children: [
                                          ValueListenableBuilder<double>(
                                            valueListenable:
                                                rtdb.nutrientThresholdMin,
                                            builder: (_, value, __) {
                                              return Text(
                                                "${value.toStringAsFixed(0)} ppm",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        "PlusJakartaSans",
                                                    fontSize: 14),
                                              );
                                            },
                                          ),
                                          const Text(
                                            " - ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "PlusJakartaSans",
                                                fontSize: 14),
                                          ),
                                          ValueListenableBuilder<double>(
                                            valueListenable:
                                                rtdb.nutrientThresholdMax,
                                            builder: (_, value, __) {
                                              return Text(
                                                "${value.toStringAsFixed(0)} ppm",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        "PlusJakartaSans",
                                                    fontSize: 14),
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      _nutrientThresholdMinController.text =
                                          rtdb.nutrientThresholdMin.value
                                              .toStringAsFixed(0);
                                      _nutrientThresholdMaxController.text =
                                          rtdb.nutrientThresholdMax.value
                                              .toStringAsFixed(0);

                                      final result = await showDialog(
                                        context: context,
                                        builder: (_) => EditDialogPopup(
                                          title: "Edit Nutrient Threshold",
                                          isTwoFields: true,
                                          label1: "Min Threshold",
                                          label2: "Max Threshold",
                                          controller1:
                                              _nutrientThresholdMinController,
                                          controller2:
                                              _nutrientThresholdMaxController,
                                          keyboardType1: TextInputType.number,
                                          keyboardType2: TextInputType.number,
                                          notification: "Nutrient Threshold",
                                        ),
                                      );

                                      if (result == null) {
                                        return;
                                      }

                                      final min =
                                          double.tryParse(result["value1"]);
                                      final max =
                                          double.tryParse(result["value2"]);

                                      if (min == null ||
                                          max == null ||
                                          min >= max) {
                                        return;
                                      }
                                      if (min ==
                                              rtdb.nutrientThresholdMin.value &&
                                          max ==
                                              rtdb.nutrientThresholdMax.value) {
                                        return;
                                      }

                                      ref
                                          .read(rtdbProvider)
                                          .setThresholdMinNutrient(min);

                                      ref
                                          .read(rtdbProvider)
                                          .setThresholdMaxNutrient(max);
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Color(0xFF64748B),
                                    ),
                                  )
                                ],
                              )
                            : const SizedBox(),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  })
            ],
          ),
        ),
      ],
    );
  }
}

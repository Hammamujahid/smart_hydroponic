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
                      onSave: (value1, _) {
                        final newUsername = value1.trim();

                        if (newUsername.isEmpty) {
                          return const SaveResult.failed(
                              "Username tidak boleh kosong.");
                        }
                        if (newUsername.length < 3) {
                          return const SaveResult.failed(
                              "Username minimal 3 karakter.");
                        }
                        if (newUsername == user?.username) {
                          return const SaveResult.failed(
                              "Username sama dengan sebelumnya.");
                        }

                        return const SaveResult.success(
                            "Username berhasil diperbarui.");
                      },
                    ),
                  );

                  if (result == null) return;

                  final newUsername = (result["value1"] as String).trim();

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
                    (device?.title?.isNotEmpty ?? false)
                        ? device!.title!
                        : "No Title",
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
                      onSave: (value1, _) {
                        final newPlant = value1.trim();

                        if (newPlant == device?.title) {
                          return const SaveResult.failed(
                              "Jenis tanaman sama dengan sebelumnya");
                        }

                        return const SaveResult.success(
                            "Jenis tanaman berhasil diperbarui");
                      },
                    ),
                  );

                  if (result == null) return;

                  final newPlant = result["value1"];

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
                        onSave: (value1, _) {
                          final newWaterMax = double.tryParse(value1.trim());

                          if (newWaterMax == null) {
                            return const SaveResult.failed(
                                "Input harus berupa angka");
                          }
                          if (newWaterMax == rtdb.waterMax.value) {
                            return const SaveResult.failed(
                                "Tinggi maksimal air sama dengan sebelumnya");
                          }

                          return const SaveResult.success(
                              "Tinggi maksimal air berhasil diperbarui");
                        },
                      ),
                    );
                    if (result == null) return;

                    final value = double.parse(result[
                        "value1"]);

                    ref.read(rtdbProvider).setWaterMax(value);
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF64748B),
                  ),
                )
              ],
            )),
      ],
    );
  }
}

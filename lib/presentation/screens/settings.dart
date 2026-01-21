import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/auth_provider.dart';
import 'package:smart_hydroponic/presentation/providers/rtdb_provider.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';

class Settings extends ConsumerStatefulWidget {
  final NotchBottomBarController? controller;

  const Settings({super.key, this.controller});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final rtdb = ref.watch(rtdbProvider);

    return Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
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
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                children: [
                  ExpansionTile(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
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
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Email",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "PlusJakartaSans",
                                  fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "....@gmail.com",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "PlusJakartaSans",
                                  fontSize: 14),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 25),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
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
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Username",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "PlusJakartaSans",
                                      fontSize: 16),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "blabla",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "PlusJakartaSans",
                                      fontSize: 14),
                                )
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                debugPrint("edit username");
                              },
                              child: const Icon(
                                Icons.edit,
                                color: Color(0xFF64748B),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
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
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Type",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "PlusJakartaSans",
                                  fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "ESP32",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "PlusJakartaSans",
                                  fontSize: 14),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 25),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
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
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Plant",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "PlusJakartaSans",
                                      fontSize: 16),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Selada",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "PlusJakartaSans",
                                      fontSize: 14),
                                )
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                debugPrint("edit plant");
                              },
                              child: const Icon(
                                Icons.edit,
                                color: Color(0xFF64748B),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 25),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
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
                              "Control Mode",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "PlusJakartaSans",
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            ValueListenableBuilder<String>(
                                valueListenable: rtdb.controllerMode,
                                builder: (context, value, _) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RadioMenuButton(
                                          value: "manual",
                                          groupValue: value,
                                          onChanged: (selected) {
                                            if (selected == null) return;
                                            if (selected == value)
                                              return; // guard penting
                                            ref
                                                .read(rtdbProvider)
                                                .setMode(selected);
                                          },
                                          child: const Text("Manual")),
                                      RadioMenuButton(
                                          value: "auto",
                                          groupValue: value,
                                          onChanged: (selected) {
                                            if (selected == null) return;
                                            if (selected == value)
                                              return; // guard penting
                                            ref
                                                .read(rtdbProvider)
                                                .setMode(selected);
                                          },
                                          child: const Text("Auto")),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      value == "auto"
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                    const Row(
                                                  spacing: 5,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Set TDS Level :",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily:
                                                              "PlusJakartaSans",
                                                          fontSize: 14),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      "0.8 ppm",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              "PlusJakartaSans",
                                                          fontSize: 14),
                                                    )
                                                  ],
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    debugPrint(
                                                        "edit TDS level");
                                                  },
                                                  child: const Icon(
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
                                      value == "auto"
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Row(
                                                  spacing: 5,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Set Water Level :",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily:
                                                              "PlusJakartaSans",
                                                          fontSize: 14),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      "5%",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              "PlusJakartaSans",
                                                          fontSize: 14),
                                                    )
                                                  ],
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    debugPrint(
                                                        "edit Water level");
                                                  },
                                                  child: const Icon(
                                                    Icons.edit,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                )
                                              ],
                                            )
                                          : const SizedBox(),
                                    ],
                                  );
                                })
                          ],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      ref.read(rtdbProvider).disposeRTDB();
                      ref.read(userProvider).reset();
                      await ref.read(authProvider).logout();
                    },
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(17, 0, 21, 0),
                        height: 58,
                        width: screenWidth,
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Logout",
                                style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "PlusJakartaSans")),
                            Icon(
                              Icons.logout,
                              color: Color.fromARGB(201, 15, 23, 42),
                            )
                          ],
                        )),
                  ),
                  const SizedBox(height: 120,)
                ],
              ),
            ),
          );
        }));
  }
}

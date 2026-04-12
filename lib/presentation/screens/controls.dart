import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/device_provider.dart';
import 'package:smart_hydroponic/presentation/providers/rtdb_provider.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';
import 'package:smart_hydroponic/presentation/widgets/edit_dialog.dart';

class Controls extends ConsumerStatefulWidget {
  final NotchBottomBarController? controller;

  const Controls({super.key, this.controller});

  @override
  ConsumerState<Controls> createState() => _ControlsState();
}

class _ControlsState extends ConsumerState<Controls>
    with AutomaticKeepAliveClientMixin {
  final _waterDurationController = TextEditingController();
  final _waterIntervalController = TextEditingController();
  final _nutrientThresholdMinController = TextEditingController();
  final _phThresholdMinController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final rtdb = ref.watch(rtdbProvider);
    final user = ref.watch(userProvider).selectedUser;

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
              "Controls",
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
                  (user?.activeDeviceId == null || user?.activeDeviceId == "")
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 17),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 25),
                                padding: const EdgeInsets.all(10),
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
                                    ValueListenableBuilder<String>(
                                      valueListenable: rtdb.waterMode,
                                      builder: (context, mode, _) => Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  20, 2, 73, 112),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Image.asset(
                                                "assets/images/water.png",
                                                width: 24,
                                                height: 24),
                                          ),
                                          const SizedBox(width: 10),
                                          const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Water Pump",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "PlusJakartaSans",
                                                ),
                                              ),
                                              Text(
                                                "Irrigation control",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                  fontFamily: "PlusJakartaSans",
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          // Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE2EBFF),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              mode == "auto"
                                                  ? "Auto"
                                                  : "Manual",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF155DFC),
                                                fontFamily: "PlusJakartaSans",
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ValueListenableBuilder<String>(
                                        valueListenable: rtdb.waterMode,
                                        builder: (context, value, _) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (value == "manual") {
                                                          return;
                                                        }
                                                        ref
                                                            .read(rtdbProvider)
                                                            .setWaterMode(
                                                                "manual");
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 11),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: value ==
                                                                  "manual"
                                                              ? const Color(
                                                                  0xFF059669) // aktif
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            color: value ==
                                                                    "manual"
                                                                ? const Color(
                                                                    0xFF059669)
                                                                : const Color(
                                                                    0xFFE2E8F0),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "Manual",
                                                            style: TextStyle(
                                                              color: value ==
                                                                      "manual"
                                                                  ? Colors.white
                                                                  : const Color(
                                                                      0xFF64748B),
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  "PlusJakartaSans",
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (value == "auto") {
                                                          return;
                                                        }
                                                        ref
                                                            .read(rtdbProvider)
                                                            .setWaterMode(
                                                                "auto");
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 11),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: value == "auto"
                                                              ? const Color(
                                                                  0xFF059669) // aktif
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            color: value ==
                                                                    "auto"
                                                                ? const Color(
                                                                    0xFF059669)
                                                                : const Color(
                                                                    0xFFE2E8F0),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "Auto",
                                                            style: TextStyle(
                                                                color: value ==
                                                                        "auto"
                                                                    ? Colors
                                                                        .white
                                                                    : const Color(
                                                                        0xFF64748B),
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    "PlusJakartaSans"),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              const Divider(
                                                  color: Color(0xFFE2E8F0),
                                                  thickness: 0.5),
                                              const SizedBox(height: 6),
                                              if (value == "auto") ...[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 14,
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFFE1F5EE),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .schedule,
                                                                    size: 14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: Color(
                                                                        0xFF0F6E56)),
                                                                SizedBox(
                                                                    width: 6),
                                                                Text(
                                                                  "Schedule preview",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: Color(
                                                                        0xFF085041),
                                                                    fontFamily:
                                                                        "PlusJakartaSans",
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Text(
                                                                  "ON ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Color(
                                                                        0xFF0F6E56),
                                                                    fontFamily:
                                                                        "PlusJakartaSans",
                                                                  ),
                                                                ),
                                                                ValueListenableBuilder<
                                                                        double>(
                                                                    valueListenable:
                                                                        rtdb
                                                                            .waterDuration,
                                                                    builder: (_,
                                                                        value,
                                                                        __) {
                                                                      return Text(
                                                                          "${value.toStringAsFixed(0)} sec",
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            color:
                                                                                Color(0xFF0F6E56),
                                                                            fontFamily:
                                                                                "PlusJakartaSans",
                                                                          ));
                                                                    }),
                                                                const Text(
                                                                  " · every ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Color(
                                                                        0xFF0F6E56),
                                                                    fontFamily:
                                                                        "PlusJakartaSans",
                                                                  ),
                                                                ),
                                                                ValueListenableBuilder<
                                                                    double>(
                                                                  valueListenable:
                                                                      rtdb.waterInterval,
                                                                  builder: (_,
                                                                      value,
                                                                      __) {
                                                                    return Text(
                                                                      "${value.toStringAsFixed(0)} sec",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color: Color(
                                                                            0xFF0F6E56),
                                                                        fontFamily:
                                                                            "PlusJakartaSans",
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              spacing: 5,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Text(
                                                                  "Set Duration :",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontFamily:
                                                                          "PlusJakartaSans",
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                ValueListenableBuilder<
                                                                    double>(
                                                                  valueListenable:
                                                                      rtdb.waterDuration,
                                                                  builder: (_,
                                                                      value,
                                                                      __) {
                                                                    return Text(
                                                                      "${value.toStringAsFixed(0)} seconds",
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          fontFamily:
                                                                              "PlusJakartaSans",
                                                                          fontSize:
                                                                              14),
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            IconButton(
                                                              onPressed:
                                                                  () async {
                                                                _waterDurationController
                                                                        .text =
                                                                    rtdb.waterDuration
                                                                        .value
                                                                        .toStringAsFixed(
                                                                            0);
                                                                final result =
                                                                    await showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (_) =>
                                                                      EditDialogPopup(
                                                                    title:
                                                                        "Edit Water Duration",
                                                                    isTwoFields:
                                                                        false,
                                                                    label1:
                                                                        "Water Duration",
                                                                    controller1:
                                                                        _waterDurationController,
                                                                    keyboardType1:
                                                                        TextInputType
                                                                            .number,
                                                                    onSave:
                                                                        (value1,
                                                                            _) {
                                                                      final newWaterDuration =
                                                                          double.tryParse(
                                                                              value1.trim());
                                                                      if (newWaterDuration ==
                                                                          null) {
                                                                        return const SaveResult
                                                                            .failed(
                                                                            "Input harus berupa angka");
                                                                      }
                                                                      if (newWaterDuration ==
                                                                          rtdb.waterDuration
                                                                              .value) {
                                                                        return const SaveResult
                                                                            .failed(
                                                                            "Durasi air sama dengan sebelumnya");
                                                                      }

                                                                      if (newWaterDuration >
                                                                          rtdb.waterInterval
                                                                              .value) {
                                                                        return const SaveResult.failed(
                                                                            "Durasi nyala air tidak boleh lebih dari durasi interval air");
                                                                      }

                                                                      return const SaveResult
                                                                          .success(
                                                                          "Durasi air berhasil diperbarui");
                                                                    },
                                                                  ),
                                                                );

                                                                if (result ==
                                                                    null) {
                                                                  return;
                                                                }

                                                                final duration =
                                                                    double.parse(
                                                                        result[
                                                                            "value1"]);

                                                                ref
                                                                    .read(
                                                                        rtdbProvider)
                                                                    .setWaterDuration(
                                                                        duration);
                                                              },
                                                              icon: const Icon(
                                                                Icons.edit,
                                                                color: Color(
                                                                    0xFF64748B),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              spacing: 5,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Text(
                                                                  "Set Interval :",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontFamily:
                                                                          "PlusJakartaSans",
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                ValueListenableBuilder<
                                                                    double>(
                                                                  valueListenable:
                                                                      rtdb.waterInterval,
                                                                  builder: (_,
                                                                      value,
                                                                      __) {
                                                                    return Text(
                                                                      "${value.toStringAsFixed(0)} seconds",
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          fontFamily:
                                                                              "PlusJakartaSans",
                                                                          fontSize:
                                                                              14),
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            IconButton(
                                                              onPressed:
                                                                  () async {
                                                                _waterIntervalController
                                                                        .text =
                                                                    rtdb.waterInterval
                                                                        .value
                                                                        .toStringAsFixed(
                                                                            0);
                                                                final result =
                                                                    await showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (_) =>
                                                                      EditDialogPopup(
                                                                    title:
                                                                        "Edit Water Interval",
                                                                    isTwoFields:
                                                                        false,
                                                                    label1:
                                                                        "Water Interval",
                                                                    controller1:
                                                                        _waterIntervalController,
                                                                    keyboardType1:
                                                                        TextInputType
                                                                            .number,
                                                                    onSave:
                                                                        (value1,
                                                                            _) {
                                                                      final newWaterInterval =
                                                                          double.tryParse(
                                                                              value1.trim());
                                                                      if (newWaterInterval ==
                                                                          null) {
                                                                        return const SaveResult
                                                                            .failed(
                                                                            "Input harus berupa angka");
                                                                      }
                                                                      if (newWaterInterval ==
                                                                          rtdb.waterInterval
                                                                              .value) {
                                                                        return const SaveResult
                                                                            .failed(
                                                                            "Interval air sama dengan sebelumnya");
                                                                      }

                                                                      if (newWaterInterval <
                                                                          rtdb.waterDuration
                                                                              .value) {
                                                                        return const SaveResult.failed(
                                                                            "Durasi interval air tidak boleh kurang dari durasi nyala air");
                                                                      }

                                                                      return const SaveResult
                                                                          .success(
                                                                          "Interval air berhasil diperbarui");
                                                                    },
                                                                  ),
                                                                );

                                                                if (result ==
                                                                    null) {
                                                                  return;
                                                                }

                                                                final interval =
                                                                    double.parse(
                                                                        result[
                                                                            "value1"]);

                                                                ref
                                                                    .read(
                                                                        rtdbProvider)
                                                                    .setWaterInterval(
                                                                        interval);
                                                              },
                                                              icon: const Icon(
                                                                Icons.edit,
                                                                color: Color(
                                                                    0xFF64748B),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ]
                                            ],
                                          );
                                        })
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 25),
                                padding: const EdgeInsets.all(10),
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
                                    ValueListenableBuilder<String>(
                                      valueListenable: rtdb.nutrientMode,
                                      builder: (context, mode, _) => Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  20, 78, 13, 84),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Image.asset(
                                                "assets/images/nutrient.png",
                                                width: 24,
                                                height: 24),
                                          ),
                                          const SizedBox(width: 10),
                                          const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Nutrient Pump",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "PlusJakartaSans",
                                                ),
                                              ),
                                              Text(
                                                "TDS Solution Dosing",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                  fontFamily: "PlusJakartaSans",
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          // Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF4DCFC),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              mode == "auto"
                                                  ? "Auto"
                                                  : "Manual",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFFA6009B),
                                                fontFamily: "PlusJakartaSans",
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ValueListenableBuilder<String>(
                                        valueListenable: rtdb.nutrientMode,
                                        builder: (context, value, _) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (value == "manual") {
                                                          return;
                                                        }
                                                        ref
                                                            .read(rtdbProvider)
                                                            .setNutrientMode(
                                                                "manual");
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 11),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: value ==
                                                                  "manual"
                                                              ? const Color(
                                                                  0xFF059669) // aktif
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            color: value ==
                                                                    "manual"
                                                                ? const Color(
                                                                    0xFF059669)
                                                                : const Color(
                                                                    0xFFE2E8F0),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "Manual",
                                                            style: TextStyle(
                                                              color: value ==
                                                                      "manual"
                                                                  ? Colors.white
                                                                  : const Color(
                                                                      0xFF64748B),
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  "PlusJakartaSans",
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (value == "auto") {
                                                          return;
                                                        }
                                                        ref
                                                            .read(rtdbProvider)
                                                            .setNutrientMode(
                                                                "auto");
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 11),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: value == "auto"
                                                              ? const Color(
                                                                  0xFF059669) // aktif
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            color: value ==
                                                                    "auto"
                                                                ? const Color(
                                                                    0xFF059669)
                                                                : const Color(
                                                                    0xFFE2E8F0),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "Auto",
                                                            style: TextStyle(
                                                                color: value ==
                                                                        "auto"
                                                                    ? Colors
                                                                        .white
                                                                    : const Color(
                                                                        0xFF64748B),
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    "PlusJakartaSans"),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              const Divider(
                                                  color: Color(0xFFE2E8F0),
                                                  thickness: 0.5),
                                              const SizedBox(height: 6),
                                              if (value == "auto") ...[
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 16.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            "Set Minimum Threshold:",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    "PlusJakartaSans",
                                                                fontSize: 14),
                                                          ),
                                                          ValueListenableBuilder<
                                                              double>(
                                                            valueListenable: rtdb
                                                                .nutrientThresholdMin,
                                                            builder:
                                                                (_, value, __) {
                                                              return Text(
                                                                "${value.toStringAsFixed(0)} ppm",
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontFamily:
                                                                        "PlusJakartaSans",
                                                                    fontSize:
                                                                        14),
                                                              );
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                      IconButton(
                                                        onPressed: () async {
                                                          _nutrientThresholdMinController
                                                                  .text =
                                                              rtdb.nutrientThresholdMin
                                                                  .value
                                                                  .toStringAsFixed(
                                                                      0);

                                                          final result =
                                                              await showDialog(
                                                            context: context,
                                                            builder: (_) =>
                                                                EditDialogPopup(
                                                              title:
                                                                  "Edit Nutrient Threshold",
                                                              isTwoFields:
                                                                  false,
                                                              label1:
                                                                  "Min Threshold",
                                                              controller1:
                                                                  _nutrientThresholdMinController,
                                                              keyboardType1:
                                                                  TextInputType
                                                                      .number,
                                                              onSave: (value1, _){
                                                                final newMin = double.tryParse(value1.trim());

                                                                if(newMin == null){
                                                                  return const SaveResult.failed("Input harus berupa angka");
                                                                }

                                                                if(newMin == rtdb.nutrientThresholdMin.value){
                                                                  return const SaveResult.failed("Threshold minimum nutrisi sama dengan sebelumnya");
                                                                }

                                                                return const SaveResult.success("Threshold minimum nutrisi berhasil diperbarui");
                                                              },
                                                            ),
                                                          );

                                                          if (result == null) {
                                                            return;
                                                          }

                                                          final min = double
                                                              .parse(result[
                                                                  "value1"]);

                                                          ref
                                                              .read(
                                                                  rtdbProvider)
                                                              .setThresholdMinNutrient(
                                                                  min);
                                                        },
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          color:
                                                              Color(0xFF64748B),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ]
                                            ],
                                          );
                                        })
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 25),
                                padding: const EdgeInsets.all(10),
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
                                    ValueListenableBuilder<String>(
                                      valueListenable: rtdb.phMode,
                                      builder: (context, mode, _) => Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  20, 123, 51, 6),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Image.asset(
                                                "assets/images/ph.png",
                                                width: 24,
                                                height: 24),
                                          ),
                                          const SizedBox(width: 10),
                                          const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "pH Pump",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "PlusJakartaSans",
                                                ),
                                              ),
                                              Text(
                                                "pH Solution Dosing",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                  fontFamily: "PlusJakartaSans",
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          // Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEF3C6),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              mode == "auto"
                                                  ? "Auto"
                                                  : "Manual",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFFBB4D00),
                                                fontFamily: "PlusJakartaSans",
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ValueListenableBuilder<String>(
                                        valueListenable: rtdb.phMode,
                                        builder: (context, value, _) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (value == "manual") {
                                                          return;
                                                        }
                                                        ref
                                                            .read(rtdbProvider)
                                                            .setPhMode(
                                                                "manual");
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 11),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: value ==
                                                                  "manual"
                                                              ? const Color(
                                                                  0xFF059669) // aktif
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            color: value ==
                                                                    "manual"
                                                                ? const Color(
                                                                    0xFF059669)
                                                                : const Color(
                                                                    0xFFE2E8F0),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "Manual",
                                                            style: TextStyle(
                                                              color: value ==
                                                                      "manual"
                                                                  ? Colors.white
                                                                  : const Color(
                                                                      0xFF64748B),
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  "PlusJakartaSans",
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (value == "auto") {
                                                          return;
                                                        }
                                                        ref
                                                            .read(rtdbProvider)
                                                            .setPhMode("auto");
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 11),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: value == "auto"
                                                              ? const Color(
                                                                  0xFF059669) // aktif
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            color: value ==
                                                                    "auto"
                                                                ? const Color(
                                                                    0xFF059669)
                                                                : const Color(
                                                                    0xFFE2E8F0),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "Auto",
                                                            style: TextStyle(
                                                                color: value ==
                                                                        "auto"
                                                                    ? Colors
                                                                        .white
                                                                    : const Color(
                                                                        0xFF64748B),
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    "PlusJakartaSans"),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              const Divider(
                                                  color: Color(0xFFE2E8F0),
                                                  thickness: 0.5),
                                              const SizedBox(height: 6),
                                              if (value == "auto") ...[
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 16.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            "Set Minimum Threshold:",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    "PlusJakartaSans",
                                                                fontSize: 14),
                                                          ),
                                                          ValueListenableBuilder<
                                                              double>(
                                                            valueListenable: rtdb
                                                                .phThresholdMin,
                                                            builder:
                                                                (_, value, __) {
                                                              return Text(
                                                                "${value.toStringAsFixed(2)} pH",
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontFamily:
                                                                        "PlusJakartaSans",
                                                                    fontSize:
                                                                        14),
                                                              );
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                      IconButton(
                                                        onPressed: () async {
                                                          _phThresholdMinController
                                                                  .text =
                                                              rtdb.phThresholdMin
                                                                  .value
                                                                  .toStringAsFixed(
                                                                      2);

                                                          final result =
                                                              await showDialog(
                                                            context: context,
                                                            builder: (_) =>
                                                                EditDialogPopup(
                                                              title:
                                                                  "Edit pH Threshold",
                                                              isTwoFields:
                                                                  false,
                                                              label1:
                                                                  "Min Threshold",
                                                              controller1:
                                                                  _phThresholdMinController,
                                                              keyboardType1:
                                                                  TextInputType
                                                                      .number,
                                                            onSave: (value1, _){
                                                                final newMin = double.tryParse(value1.trim());

                                                                if(newMin == null){
                                                                  return const SaveResult.failed("Input harus berupa angka");
                                                                }

                                                                if(newMin == rtdb.phThresholdMin.value){
                                                                  return const SaveResult.failed("Threshold minimum pH sama dengan sebelumnya");
                                                                }

                                                                return const SaveResult.success("Threshold minimum pH berhasil diperbarui");
                                                              },
                                                            ),
                                                          );

                                                          if (result == null) {
                                                            return;
                                                          }

                                                          final min = double
                                                              .parse(result[
                                                                  "value1"]);

                                                          ref
                                                              .read(
                                                                  rtdbProvider)
                                                              .setThresholdMinPh(
                                                                  min);
                                                        },
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          color:
                                                              Color(0xFF64748B),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ]
                                            ],
                                          );
                                        })
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(
                    height: 100,
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_hydroponic/data/services/rtdb_service.dart';

final dashboardProvider =
    ChangeNotifierProvider<DashboardProvider>((ref) {
  return DashboardProvider();
});

class DashboardProvider extends ChangeNotifier {
  RTDBService? _rtdb;

  // ===== RTDB Subscriptions =====
  StreamSubscription? _modeSub;
  StreamSubscription? _waterCtrlSub;
  StreamSubscription? _nutrientCtrlSub;
  StreamSubscription? _ecSub;
  StreamSubscription? _phSub;
  StreamSubscription? _waterLevelSub;

  // ===== UI STATES (SAMA SEPERTI DASHBOARD.dart) =====
  final ValueNotifier<String> controllerMode =
      ValueNotifier<String>("manual");
  final ValueNotifier<bool> waterController =
      ValueNotifier<bool>(false);
  final ValueNotifier<bool> nutrientController =
      ValueNotifier<bool>(false);

  final ValueNotifier<double> nutrientLevel =
      ValueNotifier<double>(0.0);
  final ValueNotifier<double> phLevel =
      ValueNotifier<double>(0.0);
  final ValueNotifier<double> waterLevel =
      ValueNotifier<double>(0.0);

  bool isOnline = false;

  // ===== INIT RTDB (PENGGANTI init()) =====
  void init(String deviceId) {
    disposeRTDB(); // 🔒 penting

    _rtdb = RTDBService(deviceId);
    isOnline = true;

    _modeSub = _rtdb!.getAutoModeStream().listen((v) {
      controllerMode.value = v;
    });

    _waterCtrlSub = _rtdb!.getWaterControllerStream().listen((v) {
      waterController.value = v;
    });

    _nutrientCtrlSub = _rtdb!.getNutrientControllerStream().listen((v) {
      nutrientController.value = v;
    });

    _ecSub = _rtdb!.getNutrientSensorStream().listen((v) {
      nutrientLevel.value = v;
    });

    _phSub = _rtdb!.getpHSensorStream().listen((v) {
      phLevel.value = v;
    });

    _waterLevelSub = _rtdb!.getWaterSensorStream().listen((v) {
      waterLevel.value = v;
    });
  }

  // ===== CONTROL ACTIONS (DIPAKAI UI) =====
  void setMode(String value) {
    controllerMode.value = value;
    _rtdb?.setAutoMode(value);
  }

  void setWater(bool value) {
    waterController.value = value;
    _rtdb?.setWaterController(value);
  }

  void setNutrient(bool value) {
    nutrientController.value = value;
    _rtdb?.setNutrientController(value);
  }

  // ===== DISPOSE RTDB (WAJIB DIPANGGIL SAAT LOGOUT) =====
  void disposeRTDB() {
    _modeSub?.cancel();
    _waterCtrlSub?.cancel();
    _nutrientCtrlSub?.cancel();
    _ecSub?.cancel();
    _phSub?.cancel();
    _waterLevelSub?.cancel();

    _modeSub = null;
    _waterCtrlSub = null;
    _nutrientCtrlSub = null;
    _ecSub = null;
    _phSub = null;
    _waterLevelSub = null;

    isOnline = false;
    _rtdb = null;
  }
}

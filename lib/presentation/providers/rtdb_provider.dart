import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_hydroponic/data/services/rtdb_service.dart';

final rtdbProvider = ChangeNotifierProvider<RTDBProvider>((ref) {
  return RTDBProvider();
});

class RTDBProvider extends ChangeNotifier {
  RTDBService? _rtdb;

  // ===== RTDB Subscriptions =====
  StreamSubscription? _deviceStat;
  StreamSubscription? _modeSub;
  StreamSubscription? _waterCtrlSub;
  StreamSubscription? _nutrientCtrlSub;
  StreamSubscription? _ecSub;
  StreamSubscription? _phSub;
  StreamSubscription? _waterLevelSub;
  StreamSubscription? _waterThresholdMinSub;
  StreamSubscription? _waterThresholdMaxSub;
  StreamSubscription? _nutrientThresholdMinSub;
  StreamSubscription? _nutrientThresholdMaxSub;

  // ===== UI STATES (SAMA SEPERTI DASHBOARD.dart) =====
  final ValueNotifier<String> controllerMode = ValueNotifier<String>("manual");

  final ValueNotifier<bool> waterController = ValueNotifier<bool>(false);
  final ValueNotifier<double> waterThresholdMin = ValueNotifier<double>(0.0);
  final ValueNotifier<double> waterThresholdMax = ValueNotifier<double>(0.0);

  final ValueNotifier<bool> nutrientController = ValueNotifier<bool>(false);
  final ValueNotifier<double> nutrientThresholdMin = ValueNotifier<double>(0.0);
  final ValueNotifier<double> nutrientThresholdMax = ValueNotifier<double>(0.0);

  final ValueNotifier<double> nutrientLevel = ValueNotifier<double>(0.0);
  final ValueNotifier<double> phLevel = ValueNotifier<double>(0.0);
  final ValueNotifier<double> waterLevel = ValueNotifier<double>(0.0);

  final ValueNotifier<String> deviceStatus = ValueNotifier<String>("offline");

  // ===== INIT RTDB (PENGGANTI init()) =====
  void init(String deviceId) {
    disposeRTDB(); // 🔒 penting

    _rtdb = RTDBService(deviceId);

    _deviceStat = _rtdb!.getDeviceStatusStream().listen((v) {
      deviceStatus.value = v;
    });

    _modeSub = _rtdb!.getAutoModeStream().listen((v) {
      controllerMode.value = v;
    });

    _waterCtrlSub = _rtdb!.getWaterControllerStream().listen((v) {
      waterController.value = v;
    });

    _waterThresholdMinSub = _rtdb!.getWaterThresholdMinStream().listen((v) {
      waterThresholdMin.value = v;
    });

    _waterThresholdMaxSub = _rtdb!.getWaterThresholdMaxStream().listen((v) {
      waterThresholdMax.value = v;
    });

    _nutrientCtrlSub = _rtdb!.getNutrientControllerStream().listen((v) {
      nutrientController.value = v;
    });

    _nutrientThresholdMinSub =
        _rtdb!.getNutrientThresholdMinStream().listen((v) {
      nutrientThresholdMin.value = v;
    });

    _nutrientThresholdMaxSub =
        _rtdb!.getNutrientThresholdMaxStream().listen((v) {
      nutrientThresholdMax.value = v;
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

  void setThresholdMinWater(double value) {
    waterThresholdMin.value = value;
    _rtdb?.setWaterThresholdMin(value);
  }

  void setThresholdMaxWater(double value) {
    waterThresholdMax.value = value;
    _rtdb?.setWaterThresholdMax(value);
  }

  void setNutrient(bool value) {
    nutrientController.value = value;
    _rtdb?.setNutrientController(value);
  }

  void setThresholdMinNutrient(double value) {
    nutrientThresholdMin.value = value;
    _rtdb?.setNutrientThresholdMin(value);
  }

  void setThresholdMaxNutrient(double value) {
    nutrientThresholdMax.value = value;
    _rtdb?.setNutrientThresholdMax(value);
  }

  // ===== DISPOSE RTDB (WAJIB DIPANGGIL SAAT LOGOUT) =====
  void disposeRTDB() {
    _deviceStat?.cancel();
    _modeSub?.cancel();
    _waterCtrlSub?.cancel();
    _waterThresholdMinSub?.cancel();
    _waterThresholdMaxSub?.cancel();
    _nutrientCtrlSub?.cancel();
    _nutrientThresholdMinSub?.cancel();
    _nutrientThresholdMaxSub?.cancel();
    _ecSub?.cancel();
    _phSub?.cancel();
    _waterLevelSub?.cancel();

    _deviceStat = null;
    _modeSub = null;
    _waterCtrlSub = null;
    _waterThresholdMinSub = null;
    _waterThresholdMaxSub = null;
    _nutrientCtrlSub = null;
    _nutrientThresholdMinSub = null;
    _nutrientThresholdMaxSub = null;
    _ecSub = null;
    _phSub = null;
    _waterLevelSub = null;

    _rtdb = null;
  }
}

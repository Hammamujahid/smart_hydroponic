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
  StreamSubscription? _waterMaxSub;
  StreamSubscription? _waterCtrlSub;
  StreamSubscription? _waterModeSub;
  StreamSubscription? _nutrientCtrlSub;
  StreamSubscription? _nutrientModeSub;
  StreamSubscription? _tdsSub;
  StreamSubscription? _phSub;
  StreamSubscription? _waterLevelSub;
  StreamSubscription? _nutrientThresholdMinSub;
  StreamSubscription? _nutrientThresholdMaxSub;
  StreamSubscription? _waterIntervalSub;
  StreamSubscription? _waterDurationSub;

  // ===== UI STATES (SAMA SEPERTI DASHBOARD.dart) =====
  final ValueNotifier<bool> waterController = ValueNotifier<bool>(false);
  final ValueNotifier<String> waterMode = ValueNotifier<String>("manual");
  final ValueNotifier<double> waterInterval = ValueNotifier<double>(0.0);
  final ValueNotifier<double> waterDuration = ValueNotifier<double>(0.0);

  final ValueNotifier<bool> nutrientController = ValueNotifier<bool>(false);
  final ValueNotifier<String> nutrientMode = ValueNotifier<String>("manual");
  final ValueNotifier<double> nutrientThresholdMin = ValueNotifier<double>(0.0);
  final ValueNotifier<double> nutrientThresholdMax = ValueNotifier<double>(0.0);

  final ValueNotifier<double> nutrientLevel = ValueNotifier<double>(0.0);
  final ValueNotifier<double> phLevel = ValueNotifier<double>(0.0);
  final ValueNotifier<double> waterLevel = ValueNotifier<double>(0.0);

  final ValueNotifier<int> deviceStatus = ValueNotifier<int>(0);
  final ValueNotifier<double> waterMax = ValueNotifier<double>(0.0);

  // ===== INIT RTDB (PENGGANTI init()) =====
  void init(String deviceId) {
    disposeRTDB(); // 🔒 penting

    _rtdb = RTDBService(deviceId);

    _deviceStat = _rtdb!.getDeviceStatusStream().listen((v) {
      deviceStatus.value = v;
    });

    _waterMaxSub = _rtdb!.getWaterMaxStream().listen((v) {
      waterMax.value = v;
    });

    _waterModeSub = _rtdb!.getWaterModeStream().listen((v) {
      waterMode.value = v;
    });

    _waterIntervalSub = _rtdb!.getWaterIntervalStream().listen((v) {
      waterInterval.value = v/1000;
    });

    _waterDurationSub = _rtdb!.getWaterDurationStream().listen((v) {
      waterDuration.value = v/1000;
    });

    _waterCtrlSub = _rtdb!.getWaterControllerStream().listen((v) {
      waterController.value = v;
    });

    _nutrientCtrlSub = _rtdb!.getNutrientControllerStream().listen((v) {
      nutrientController.value = v;
    });

    _nutrientModeSub = _rtdb!.getNutrientModeStream().listen((v) {
      nutrientMode.value = v;
    });

    _nutrientThresholdMinSub =
        _rtdb!.getNutrientThresholdMinStream().listen((v) {
      nutrientThresholdMin.value = v;
    });

    _nutrientThresholdMaxSub =
        _rtdb!.getNutrientThresholdMaxStream().listen((v) {
      nutrientThresholdMax.value = v;
    });

    _tdsSub = _rtdb!.getNutrientSensorStream().listen((v) {
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
  void setWaterMax(double value) {
    waterMax.value = value;
    _rtdb?.setWaterMax(value);
  }

  void setWaterMode(String value) {
    waterMode.value = value;
    _rtdb?.setWaterMode(value);

    if (value == "auto") {
      waterController.value = false;
      _rtdb?.setWaterController(false);
    }
  }

  void setWater(bool value) {
    waterController.value = value;
    _rtdb?.setWaterController(value);
  }

  void setWaterInterval(double value) {
    waterInterval.value = value;
    _rtdb?.setWaterInterval(value*1000);
  }

  void setWaterDuration(double value) {
    waterDuration.value = value;
    _rtdb?.setWaterDuration(value*1000);
  }

  void setNutrient(bool value) {
    nutrientController.value = value;
    _rtdb?.setNutrientController(value);
  }

  void setNutrientMode(String value) {
    nutrientMode.value = value;
    _rtdb?.setNutrientMode(value);

    if (value == "auto") {
      nutrientController.value = false;
      _rtdb?.setNutrientController(false);
    }
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
    _waterMaxSub?.cancel();
    _waterModeSub?.cancel();
    _waterIntervalSub?.cancel();
    _waterDurationSub?.cancel();
    _waterCtrlSub?.cancel();
    _nutrientCtrlSub?.cancel();
    _nutrientModeSub?.cancel();
    _nutrientThresholdMinSub?.cancel();
    _nutrientThresholdMaxSub?.cancel();
    _tdsSub?.cancel();
    _phSub?.cancel();
    _waterLevelSub?.cancel();

    _deviceStat = null;
    _waterMaxSub = null;
    _waterModeSub = null;
    _waterIntervalSub = null;
    _waterDurationSub = null;
    _waterCtrlSub = null;
    _nutrientCtrlSub = null;
    _nutrientModeSub = null;
    _nutrientThresholdMinSub = null;
    _nutrientThresholdMaxSub = null;
    _tdsSub = null;
    _phSub = null;
    _waterLevelSub = null;

    _rtdb = null;
  }
}

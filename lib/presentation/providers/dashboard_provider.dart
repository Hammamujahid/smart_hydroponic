import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_hydroponic/data/services/rtdb_service.dart';

final dashboardProvider =
    ChangeNotifierProvider<DashboardProvider>((ref) {
  return DashboardProvider();
});

class DashboardProvider extends ChangeNotifier {
  RTDBService? _rtdb;
  String? _deviceId;

  bool get isInitialized => _rtdb != null;

  // ===== STATE (PAKAI ValueNotifier SESUAI UI) =====
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

  bool isOnline = true;

  // ===== INIT RTDB =====
  void init(String deviceId) {
    if (_rtdb != null && _deviceId == deviceId) {
      debugPrint("RTDB already initialized for $deviceId");
      return;
    }

    debugPrint("RTDB INIT for $deviceId");

    _deviceId = deviceId;
    _rtdb = RTDBService(deviceId);

    _rtdb!.getAutoModeStream().listen((v) {
      controllerMode.value = v;
    });

    _rtdb!.getWaterControllerStream().listen((v) {
      waterController.value = v;
    });

    _rtdb!.getNutrientControllerStream().listen((v) {
      nutrientController.value = v;
    });

    _rtdb!.getNutrientSensorStream().listen((v) {
      nutrientLevel.value = v;
    });

    _rtdb!.getpHSensorStream().listen((v) {
      phLevel.value = v;
    });

    _rtdb!.getWaterSensorStream().listen((v) {
      waterLevel.value = v;
    });
  }

  // ===== ACTIONS =====
  void setMode(String mode) {
    controllerMode.value = mode;
    _rtdb?.setAutoMode(mode);

    if (mode == "auto") {
      setWater(false);
      setNutrient(false);
    }
  }

  void setWater(bool value) {
    waterController.value = value;
    _rtdb?.setWaterController(value);
  }

  void setNutrient(bool value) {
    nutrientController.value = value;
    _rtdb?.setNutrientController(value);
  }

  @override
  void dispose() {
    controllerMode.dispose();
    waterController.dispose();
    nutrientController.dispose();
    nutrientLevel.dispose();
    phLevel.dispose();
    waterLevel.dispose();
    super.dispose();
  }
}

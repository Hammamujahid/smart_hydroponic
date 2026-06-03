import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_hydroponic/data/services/rtdb_service.dart';

final calibrationProvider =
    ChangeNotifierProvider.autoDispose<CalibrationProvider>((ref) {
  final provider = CalibrationProvider();
  ref.onDispose(() => provider.disposeRTDB());
  return provider;
});

class CalibrationProvider extends ChangeNotifier {
  RTDBService? _rtdb;

  // ===== RTDB Subscriptions =====
  StreamSubscription? _tdsBufferAModeSub;
  StreamSubscription? _tdsBufferAVoltageSub;
  StreamSubscription? _tdsBufferAValueSub;
  StreamSubscription? _tdsBufferBModeSub;
  StreamSubscription? _tdsBufferBVoltageSub;
  StreamSubscription? _tdsBufferBValueSub;
  StreamSubscription? _tdsGradientSub;
  StreamSubscription? _tdsConstantaSub;
  StreamSubscription? _phBufferAModeSub;
  StreamSubscription? _phBufferAVoltageSub;
  StreamSubscription? _phBufferAValueSub;
  StreamSubscription? _phBufferBModeSub;
  StreamSubscription? _phBufferBVoltageSub;
  StreamSubscription? _phBufferBValueSub;
  StreamSubscription? _phGradientSub;
  StreamSubscription? _phConstantaSub;

  // ===== UI STATES (SAMA SEPERTI DASHBOARD.dart) =====
  final ValueNotifier<bool> tdsBufferAMode = ValueNotifier<bool>(false);
  final ValueNotifier<double> tdsBufferAVoltage = ValueNotifier<double>(0.0);
  final ValueNotifier<double> tdsBufferAValue = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> tdsBufferBMode = ValueNotifier<bool>(false);
  final ValueNotifier<double> tdsBufferBVoltage = ValueNotifier<double>(0.0);
  final ValueNotifier<double> tdsBufferBValue = ValueNotifier<double>(0.0);
  final ValueNotifier<double> tdsGradient = ValueNotifier<double>(0.0);
  final ValueNotifier<double> tdsConstanta = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> phBufferAMode = ValueNotifier<bool>(false);
  final ValueNotifier<double> phBufferAVoltage = ValueNotifier<double>(0.0);
  final ValueNotifier<double> phBufferAValue = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> phBufferBMode = ValueNotifier<bool>(false);
  final ValueNotifier<double> phBufferBVoltage = ValueNotifier<double>(0.0);
  final ValueNotifier<double> phBufferBValue = ValueNotifier<double>(0.0);
  final ValueNotifier<double> phGradient = ValueNotifier<double>(0.0);
  final ValueNotifier<double> phConstanta = ValueNotifier<double>(0.0);

  // ===== INIT RTDB (PENGGANTI init()) =====
  void init(String deviceId) {
    disposeRTDB(); // 🔒 penting

    _rtdb = RTDBService(deviceId);

    _tdsBufferAModeSub = _rtdb!.getTdsBufferAModeStream().listen((v) {
      tdsBufferAMode.value = v;
    });

    _tdsBufferAVoltageSub = _rtdb!.getTdsBufferAVoltageStream().listen((v) {
      tdsBufferAVoltage.value = v;
    });

    _tdsBufferAValueSub = _rtdb!.getTdsBufferAValueStream().listen((v) {
      tdsBufferAValue.value = v;
    });

    _tdsBufferBModeSub = _rtdb!.getTdsBufferBModeStream().listen((v) {
      tdsBufferBMode.value = v;
    });

    _tdsBufferBVoltageSub = _rtdb!.getTdsBufferBVoltageStream().listen((v) {
      tdsBufferBVoltage.value = v;
    });

    _tdsBufferBValueSub = _rtdb!.getTdsBufferBValueStream().listen((v) {
      tdsBufferBValue.value = v;
    });

    _tdsGradientSub = _rtdb!.getTdsGradientStream().listen((v) {
      tdsGradient.value = v;
    });

    _tdsConstantaSub = _rtdb!.getTdsConstantaStream().listen((v) {
      tdsConstanta.value = v;
    });

    _phBufferAModeSub = _rtdb!.getPhBufferAModeStream().listen((v) {
      phBufferAMode.value = v;
    });

    _phBufferAVoltageSub = _rtdb!.getPhBufferAVoltageStream().listen((v) {
      phBufferAVoltage.value = v;
    });

    _phBufferAValueSub = _rtdb!.getPhBufferAValueStream().listen((v) {
      phBufferAValue.value = v;
    });

    _phBufferBModeSub = _rtdb!.getPhBufferBModeStream().listen((v) {
      phBufferBMode.value = v;
    });

    _phBufferBVoltageSub = _rtdb!.getPhBufferBVoltageStream().listen((v) {
      phBufferBVoltage.value = v;
    });

    _phBufferBValueSub = _rtdb!.getPhBufferBValueStream().listen((v) {
      phBufferBValue.value = v;
    });

    _phGradientSub = _rtdb!.getPhGradientStream().listen((v) {
      phGradient.value = v;
    });

    _phConstantaSub = _rtdb!.getPhConstantaStream().listen((v) {
      phConstanta.value = v;
    });
  }

  // ===== CONTROL ACTIONS (DIPAKAI UI) =====
  void setTdsBufferAMode(bool value) {
    tdsBufferAMode.value = value;
    _rtdb?.setTdsBufferAMode(value);
  }

  void setTdsBufferAValue(double value) {
    tdsBufferAValue.value = value;
    _rtdb?.setTdsBufferAValue(value);
  }

  void setTdsBufferBMode(bool value) {
    tdsBufferBMode.value = value;
    _rtdb?.setTdsBufferBMode(value);
  }

  void setTdsBufferBValue(double value) {
    tdsBufferBValue.value = value;
    _rtdb?.setTdsBufferBValue(value);
  }

  void setTdsGradient(double value) {
    tdsGradient.value = value;
    _rtdb?.setTdsGradient(value);
  }

  void setTdsConstanta(double value) {
    tdsConstanta.value = value;
    _rtdb?.setTdsConstanta(value);
  }

  void setPhBufferAMode(bool value) {
    phBufferAMode.value = value;
    _rtdb?.setPhBufferAMode(value);
  }

  void setPhBufferAValue(double value) {
    phBufferAValue.value = value;
    _rtdb?.setPhBufferAValue(value);
  }

  void setPhBufferBMode(bool value) {
    phBufferBMode.value = value;
    _rtdb?.setPhBufferBMode(value);
  }

  void setPhBufferBValue(double value) {
    phBufferBValue.value = value;
    _rtdb?.setPhBufferBValue(value);
  }

  void setPhGradient(double value) {
    phGradient.value = value;
    _rtdb?.setPhGradient(value);
  }

  void setPhConstanta(double value) {
    phConstanta.value = value;
    _rtdb?.setPhConstanta(value);
  }

  // ===== DISPOSE RTDB (WAJIB DIPANGGIL SAAT LOGOUT) =====
  void disposeRTDB() {
    _tdsBufferAModeSub?.cancel();
    _tdsBufferAVoltageSub?.cancel();
    _tdsBufferAValueSub?.cancel();
    _tdsBufferBModeSub?.cancel();
    _tdsBufferBVoltageSub?.cancel();
    _tdsBufferBValueSub?.cancel();
    _tdsGradientSub?.cancel();
    _tdsConstantaSub?.cancel();
    _phBufferAModeSub?.cancel();
    _phBufferAVoltageSub?.cancel();
    _phBufferAValueSub?.cancel();
    _phBufferBModeSub?.cancel();
    _phBufferBVoltageSub?.cancel();
    _phBufferBValueSub?.cancel();
    _phGradientSub?.cancel();
    _phConstantaSub?.cancel();

    _tdsBufferAModeSub = null;
    _tdsBufferAVoltageSub = null;
    _tdsBufferAValueSub = null;
    _tdsBufferBModeSub = null;
    _tdsBufferBVoltageSub = null;
    _tdsBufferBValueSub = null;
    _tdsGradientSub = null;
    _tdsConstantaSub = null;
    _phBufferAModeSub = null;
    _phBufferAVoltageSub = null;
    _phBufferAValueSub = null;
    _phBufferBModeSub = null;
    _phBufferBVoltageSub = null;
    _phBufferBValueSub = null;
    _phGradientSub = null;
    _phConstantaSub = null;
    _rtdb = null;
  }
}

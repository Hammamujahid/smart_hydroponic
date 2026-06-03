import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/calibration_provider.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';
import 'package:smart_hydroponic/presentation/widgets/rotating_icon_button.dart';

class Calibration extends ConsumerStatefulWidget {
  const Calibration({super.key});

  @override
  ConsumerState<Calibration> createState() => _CalibrationState();
}

class _CalibrationState extends ConsumerState<Calibration> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ambil deviceId dari userProvider
      final deviceId = ref.read(userProvider).selectedUser?.activeDeviceId;
      if (deviceId != null && deviceId.isNotEmpty) {
        ref.read(calibrationProvider).init(deviceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calibration"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    child: Row(
                  children: [
                    ValueListenableBuilder<double>(
                      valueListenable:
                          ref.watch(calibrationProvider).tdsBufferAValue,
                      builder: (context, value, child) {
                        return Text(value.toStringAsFixed(2)); //Value Buffer A
                      },
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable:
                          ref.watch(calibrationProvider).tdsBufferAVoltage,
                      builder: (context, value, child) {
                        return Text(
                            value.toStringAsFixed(2)); //Value Tegangan Buffer A
                      },
                    ),
                  ],
                )),
                ValueListenableBuilder<bool>(
                  valueListenable:
                      ref.watch(calibrationProvider).tdsBufferAMode,
                  builder: (context, value, child) {
                    return RotatingIconButton(
                      isLoading: value,
                      onPressed: () {
                        ref.read(calibrationProvider).setTdsBufferAMode(true);
                      },
                    );
                  },
                )
              ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    child: Row(
                  children: [
                    ValueListenableBuilder<double>(
                      valueListenable:
                          ref.watch(calibrationProvider).tdsBufferBValue,
                      builder: (context, value, child) {
                        return Text(value.toStringAsFixed(2)); //Value Buffer B
                      },
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable:
                          ref.watch(calibrationProvider).tdsBufferBVoltage,
                      builder: (context, value, child) {
                        return Text(
                            value.toStringAsFixed(2)); //Value Tegangan Buffer B
                      },
                    )
                  ],
                )),
                ValueListenableBuilder<bool>(
                  valueListenable:
                      ref.watch(calibrationProvider).tdsBufferBMode,
                  builder: (context, value, child) {
                    return RotatingIconButton(
                      isLoading: value,
                      onPressed: () {
                        ref.read(calibrationProvider).setTdsBufferBMode(true);
                      },
                    );
                  },
                )
              ]),
          ElevatedButton(
            onPressed: () {
              final provider = ref.read(calibrationProvider);

              final bufferAValue = provider.tdsBufferAValue.value;
              final bufferBValue = provider.tdsBufferBValue.value;

              final bufferAVoltage = provider.tdsBufferAVoltage.value;
              final bufferBVoltage = provider.tdsBufferBVoltage.value;

              // Hindari pembagian dengan nol
              if (bufferBVoltage == bufferAVoltage) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Kalibrasi gagal: Tegangan A dan B tidak boleh sama"),
                  ),
                );
                return;
              }

              final gradient = (bufferBValue - bufferAValue) /
                  (bufferBVoltage - bufferAVoltage);

              final constanta = bufferAValue - (gradient * bufferAVoltage);

              provider.setTdsGradient(gradient);
              provider.setTdsConstanta(constanta);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Kalibrasi berhasil"),
                ),
              );
            },
            child: const Text("Calibrate"),
          ),
          ValueListenableBuilder<double>(
            valueListenable: ref.watch(calibrationProvider).tdsGradient,
            builder: (context, value, child) {
              return Text(value.toStringAsFixed(2)); //Value Gradien
            },
          ),
          ValueListenableBuilder<double>(
            valueListenable: ref.watch(calibrationProvider).tdsConstanta,
            builder: (context, value, child) {
              return Text(value.toStringAsFixed(2)); //Value Konstanta
            },
          ),
        ],
      ),
    );
  }
}

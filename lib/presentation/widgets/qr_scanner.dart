import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_hydroponic/data/services/auth_service.dart';
import 'package:smart_hydroponic/presentation/providers/device_provider.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';
import 'package:smart_hydroponic/presentation/widgets/bottom_bar.dart';

class QrScanner extends ConsumerStatefulWidget {
  /// Constructor for simple Mobile Scanner example
  const QrScanner({super.key});

  @override
  ConsumerState<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends ConsumerState<QrScanner> {
  Barcode? _barcode;

  Widget _barcodePreview(Barcode? value) {
    if (value == null) {
      return const Text(
        'Scan something!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Column(
      spacing: 10,
      children: [
        Text(
          'Device Id: ${value.displayValue}',
          overflow: TextOverflow.fade,
          style: const TextStyle(color: Colors.white),
        ),
        ElevatedButton(
          onPressed: () async {
            final deviceId = value.displayValue;
            if (deviceId == null) return;

            final userId = AuthService().uid;
            if (userId == null) return;

            final deviceProv = ref.read(deviceProvider);
            final userProv = ref.read(userProvider);

            final device = await deviceProv.getDeviceById(deviceId);

            if (device == null) {
              debugPrint("Device tidak ditemukan");
              return;
            }

            if (device.userId != null && device.userId!.isNotEmpty) {
              debugPrint("Device sudah dipair");
              return;
            }

            await deviceProv.updateDeviceById(userId);

            await userProv.updateUserById(
              null,
              deviceId,
            );

            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const BottomBar()),
              (_) => false,
            );
          },
          child: const Text("Next"),
        )
      ],
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Mobile Scanner')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleBarcode),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 100,
              color: const Color.fromRGBO(0, 0, 0, 0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Center(child: _barcodePreview(_barcode))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

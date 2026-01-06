import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_hydroponic/bottom_bar.dart';
import 'package:smart_hydroponic/services/device_service.dart';

class QrScanner extends StatefulWidget {
  /// Constructor for simple Mobile Scanner example
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
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
            onPressed: () {
              final isDeviceAvailable =
                  DeviceService().getDeviceById(value.displayValue!);
              if (isDeviceAvailable['claimed'] == false) {
                DeviceService().updateDeviceById(
                  value.displayValue!,
                  null,
                  true,
                  DateTime.now(),
                );
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => BottomBar()), (_) => false);
              }
            },
            child: const Text("Next")),
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

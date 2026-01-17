import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_hydroponic/presentation/providers/pairing_provider.dart';
import 'package:smart_hydroponic/presentation/screens/auth/authgate.dart';

class QrScanner extends ConsumerStatefulWidget {
  const QrScanner({super.key});

  @override
  ConsumerState<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends ConsumerState<QrScanner> {
  Barcode? _barcode;
  bool _listened = false;
  bool _hasPaired = false;

  void _handleBarcode(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.displayValue == null) return;

    setState(() {
      _barcode = barcode;
    });
  }

  Widget _barcodePreview(Barcode? barcode) {
    if (barcode == null) {
      return const Text(
        "Scan QR Device",
        style: TextStyle(color: Colors.white),
      );
    }

    return Column(
      spacing: 10,
      children: [
        Text(
          'Device Id: ${barcode.displayValue}',
          overflow: TextOverflow.fade,
          style: const TextStyle(color: Colors.white),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(pairingProvider).pair(barcode.displayValue!);
          },
          child: const Text("Next"),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_listened) {
      _listened = true;
      ref.listen<PairingProvider>(pairingProvider, (prev, next) {
        if (next.status == PairingStatus.success && !_hasPaired) {
          _hasPaired = true;
          Navigator.pop(context);
        }

        if (next.status == PairingStatus.error && next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage!)),
          );
        }
      });
    }
    ref.listen<PairingProvider>(pairingProvider, (prev, next) {
      if (next.status == PairingStatus.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      }

      if (next.status == PairingStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Pairing gagal')),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Device')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleBarcode),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              color: Colors.black54,
              child: Center(
                child: _barcodePreview(_barcode),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

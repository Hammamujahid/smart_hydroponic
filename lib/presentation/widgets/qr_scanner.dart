import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_hydroponic/presentation/providers/pairing_provider.dart';
import 'package:smart_hydroponic/presentation/screens/auth/authgate.dart';
import 'package:toastification/toastification.dart';

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
      return const Center(
        child: Text(
          "Scanning...",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: "PlusJakartaSans",
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10,
      children: [
        Text(
          'Device Id: ${barcode.displayValue}',
          overflow: TextOverflow.fade,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: "PlusJakartaSans",
          ),
        ),
        GestureDetector(
          onTap: () {
            ref.read(pairingProvider).pair(barcode.displayValue!);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            child: const Text(
              "Next",
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: "PlusJakartaSans"),
            ),
          ),
        ),
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
          toastification.show(
            type: ToastificationType.error,
            context: context,
            title: Text(
              next.errorMessage!,
              style: const TextStyle(fontFamily: 'PlusJakartaSans'),
            ),
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      });
    }
    ref.listen<PairingProvider>(pairingProvider, (prev, next) {
      if (next.status == PairingStatus.success) {
        toastification.show(
          type: ToastificationType.success,
          context: context,
          title: const Text(
            "Device paired successfully",
            style: TextStyle(fontFamily: 'PlusJakartaSans'),
          ),
          autoCloseDuration: const Duration(seconds: 3),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      }

      if (next.status == PairingStatus.error) {
        toastification.show(
          type: ToastificationType.error,
          context: context,
          title: Text(
            next.errorMessage!,
            style: const TextStyle(fontFamily: 'PlusJakartaSans'),
          ),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFFE2E8F0),
          title: const Text(
            'Scan QR Device',
            style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: "PlusJakartaSans"),
          )),
      backgroundColor: const Color(0xFFE2E8F0),
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleBarcode),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              color: const Color(0xFFE2E8F0),
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

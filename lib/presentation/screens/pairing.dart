import 'package:flutter/material.dart';
import 'package:smart_hydroponic/presentation/widgets/bottom_bar.dart';
import 'package:smart_hydroponic/presentation/widgets/qr_scanner.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Pairing"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QrScanner(),
                      ));
                },
                child: const Text("Scan Now!")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const BottomBar()));
                },
                child: const Text("Skip")),
          ],
        ),
      ),
    );
  }
}

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
      double screenWidth = MediaQuery.of(context).size.width;

      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Scan QR Code",
            style: TextStyle(
                fontFamily: "PlusJakartaSans",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A)),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              const Text(
                "Pair Your Controller",
                style: TextStyle(
                    fontFamily: "PlusJakartaSans",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A)),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF41877F),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/scanning_qr.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QrScanner(),
                      ));
                },
                child: Container(
                  width: screenWidth / 2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF41877F),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFE2E8F0),
                        spreadRadius: 0.5,
                        blurRadius: 1,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Scan Now",
                      style: TextStyle(
                          fontFamily: "PlusJakartaSanz",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const BottomBar()));
                },
                child: Container(
                  width: screenWidth / 2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF41877F),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFE2E8F0),
                        spreadRadius: 0.5,
                        blurRadius: 1,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Skip",
                      style: TextStyle(
                          fontFamily: "PlusJakartaSanz",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

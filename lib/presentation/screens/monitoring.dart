import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';

class Monitoring extends StatefulWidget {
  final NotchBottomBarController? controller;
  const Monitoring({super.key, this.controller});

  @override
  State<Monitoring> createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Monitoring",
          style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontFamily: "PlusJakartaSans",
              fontWeight: FontWeight.w700),
        ),
      ),
      body: const SingleChildScrollView(
        child: Center()
      ),
    );
  }
}
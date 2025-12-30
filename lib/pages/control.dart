import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';

class Control extends StatefulWidget {
      final NotchBottomBarController? controller;

  const Control({super.key, this.controller});

  @override
  State<Control> createState() => _ControlState();
}

class _ControlState extends State<Control> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Control Page'),
    );
  }
}
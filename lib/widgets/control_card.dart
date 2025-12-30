import 'package:flutter/material.dart';

class ControlCard extends StatelessWidget {
  final String title;
  final bool isActive;
  final String uptime;
  final String iconPath;
  final Color bgIconColor;
  final ValueChanged<bool> onToggle;

  const ControlCard(
      {super.key,
      required this.title,
      required this.isActive,
      required this.uptime,
      required this.iconPath,
      required this.bgIconColor,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(top: 15),
      width: screenWidth,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgIconColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(iconPath, width: 24, height: 24),
              ),
              const SizedBox(
                width: 12,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontFamily: "PlusJakartaSans",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A))),
                  isActive == true
                      ? Text("Running • $uptime",
                          style: const TextStyle(
                              fontFamily: "PlusJakartaSans",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF009966)))
                      : const Text("Off",
                          style: TextStyle(
                              fontFamily: "PlusJakartaSans",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B))),
                ],
              )
            ],
          ),
          Switch(
              activeTrackColor: const Color(0xFF059669),
              inactiveTrackColor: const Color(0xFFE2E8F0),
              inactiveThumbColor: Colors.white,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              value: isActive,
              onChanged: onToggle)
        ],
      ),
    );
  }
}

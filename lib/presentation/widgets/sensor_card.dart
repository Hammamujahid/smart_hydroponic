import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String status;
  final Color statusColor;
  final Color bgStatusColor;
  final String iconPath;
  final Color bgIconColor;

  const SensorCard(
      {super.key,
      required this.title,
      required this.value,
      required this.unit,
      required this.status,
      required this.bgStatusColor,
      required this.iconPath,
      required this.bgIconColor,
      required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: bgIconColor,
                    borderRadius: BorderRadius.circular(16)),
                child: Image.asset(iconPath, width: 24, height: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: bgStatusColor,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                      fontFamily: "PlusJakartaSans",
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: statusColor),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 18,
          ),
          Text(
            title,
            style: const TextStyle(
                fontFamily: "PlusJakartaSans",
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF64748B)),
          ),
          const SizedBox(
            height: 6,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                    fontFamily: "PlusJakartaSans",
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    height: 1.1,
                    color: Color(0xFF0F172A)),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                unit,
                style: const TextStyle(
                    fontFamily: "PlusJakartaSans",
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF64748B)),
              )
            ],
          ),
        ],
      ),
    );
  }
}

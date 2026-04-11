import 'package:flutter/material.dart';

/// Model untuk setiap tombol mode (Manual, Auto, dsb.)
class DeviceMode {
  final String key;
  final String label;

  const DeviceMode({required this.key, required this.label});
}

/// Widget reusable untuk kartu kontrol perangkat (Water Pump, Fan, dll.)
class DeviceControlCard extends StatelessWidget {
  // --- Header ---
  final Widget icon;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;

  // --- Badge ---
  final Color badgeBackgroundColor;
  final Color badgeTextColor;

  // --- Tombol Mode ---
  final List<DeviceMode> modes;
  final String selectedMode;
  final Color activeModeColor;
  final Color activeModeTextColor;
  final Color inactiveModeTextColor;
  final Color inactiveBorderColor;
  final void Function(String modeKey) onModeChanged;

  // --- Konten bawah ---
  /// Builder dipanggil dengan modeKey yang sedang aktif,
  /// kembalikan widget konten sesuai mode.
  final Widget Function(BuildContext context, String modeKey) contentBuilder;

  const DeviceControlCard({
    super.key,

    // Header
    required this.icon,
    this.iconBackgroundColor = const Color(0xFFEFF6FF),
    required this.title,
    required this.subtitle,

    // Badge
    this.badgeBackgroundColor = const Color(0xFFEFF6FF),
    this.badgeTextColor = const Color(0xFF155DFC),

    // Tombol mode
    this.modes = const [
      DeviceMode(key: 'manual', label: 'Manual'),
      DeviceMode(key: 'auto', label: 'Auto'),
    ],
    required this.selectedMode,
    this.activeModeColor = const Color(0xFF059669),
    this.activeModeTextColor = Colors.white,
    this.inactiveModeTextColor = const Color(0xFF64748B),
    this.inactiveBorderColor = const Color(0xFFE2E8F0),
    required this.onModeChanged,

    // Konten
    required this.contentBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final activeMode = modes.firstWhere(
      (m) => m.key == selectedMode,
      orElse: () => modes.first,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: icon,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Badge mode aktif
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  activeMode.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: badgeTextColor,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Tombol mode ──
          Row(
            children: modes.map((mode) {
              final isActive = mode.key == selectedMode;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: modes.indexOf(mode) == 0 ? 0 : 4,
                    right: modes.indexOf(mode) == modes.length - 1 ? 0 : 4,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (!isActive) onModeChanged(mode.key);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: isActive ? activeModeColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              isActive ? activeModeColor : inactiveBorderColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          mode.label,
                          style: TextStyle(
                            color: isActive
                                ? activeModeTextColor
                                : inactiveModeTextColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE2E8F0), thickness: 0.5),
          const SizedBox(height: 14),

          // ── Konten dinamis ──
          contentBuilder(context, selectedMode),
        ],
      ),
    );
  }
}
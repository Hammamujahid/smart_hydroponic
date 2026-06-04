import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/calibration_provider.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';
import 'package:smart_hydroponic/presentation/widgets/rotating_icon_button.dart';
import 'package:toastification/toastification.dart';

class Calibration extends ConsumerStatefulWidget {
  final int initialTab; // 0 = TDS, 1 = pH
  const Calibration({super.key, this.initialTab = 0});

  @override
  ConsumerState<Calibration> createState() => _CalibrationState();
}

class _CalibrationState extends ConsumerState<Calibration>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.initialTab);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceId = ref.read(userProvider).selectedUser?.activeDeviceId;
      if (deviceId != null && deviceId.isNotEmpty) {
        ref.read(calibrationProvider).init(deviceId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Calibration",
          style: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF0F172A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: const Color(0xFF0F172A),
              unselectedLabelColor: const Color(0xFF94A3B8),
              labelStyle: const TextStyle(
                fontFamily: "PlusJakartaSans",
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: "PlusJakartaSans",
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("🧪 "),
                      Text("Nutrient (TDS)"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("🔬 "),
                      Text("pH"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TDSCalibrationTab(),
          _PHCalibrationTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TDS TAB
// ─────────────────────────────────────────────
class _TDSCalibrationTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cal = ref.watch(calibrationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(
            label: "Buffer Solutions",
            color: Color(0xFFA6009B),
          ),
          const SizedBox(height: 12),
          _BufferCard(
            title: "TDS Buffer Solutions",
            label: "Buffer A",
            accentColor: const Color(0xFFA6009B),
            bgColor: const Color(0xFFF4DCFC),
            valueListenable: cal.tdsBufferAValue,
            modeListenable: cal.tdsBufferAMode,
            onCapture: () =>
                ref.read(calibrationProvider).setTdsBufferAMode(true),
            onValueChanged: (value) =>
                ref.read(calibrationProvider).setTdsBufferAValue(value),
          ),
          const SizedBox(height: 12),
          _BufferCard(
            title: "TDS Buffer Solutions",
            label: "Buffer B",
            accentColor: const Color(0xFF7C3AED),
            bgColor: const Color(0xFFEDE9FE),
            valueListenable: cal.tdsBufferBValue,
            modeListenable: cal.tdsBufferBMode,
            onCapture: () =>
                ref.read(calibrationProvider).setTdsBufferBMode(true),
            onValueChanged: (value) =>
                ref.read(calibrationProvider).setTdsBufferBValue(value),
          ),
          const SizedBox(height: 24),
          const _SectionLabel(
            label: "Calibration Result",
            color: Color(0xFF0F172A),
          ),
          const SizedBox(height: 12),
          _ResultCard(
            gradientListenable: cal.tdsGradient,
            constantaListenable: cal.tdsConstanta,
            accentColor: const Color(0xFFA6009B),
          ),
          const SizedBox(height: 24),
          _CalibrateButton(
            color: const Color(0xFFA6009B),
            label: "Calibrate TDS",
            onPressed: () {
              final provider = ref.read(calibrationProvider);
              final bufferAValue = provider.tdsBufferAValue.value;
              final bufferBValue = provider.tdsBufferBValue.value;
              final bufferAVoltage = provider.tdsBufferAVoltage.value;
              final bufferBVoltage = provider.tdsBufferBVoltage.value;

              if (bufferBVoltage == bufferAVoltage) {
                ScaffoldMessenger.of(context).showSnackBar(
                  _errorSnackBar("Tegangan A dan B tidak boleh sama"),
                );
                return;
              }

              final gradient = (bufferBValue - bufferAValue) /
                  (bufferBVoltage - bufferAVoltage);
              final constanta = bufferAValue - (gradient * bufferAVoltage);

              provider.setTdsGradient(gradient);
              provider.setTdsConstanta(constanta);

              ScaffoldMessenger.of(context).showSnackBar(
                _successSnackBar("Kalibrasi TDS berhasil"),
              );
            },
          ),
          const _CalibrationNotes(title: "TDS"),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// pH TAB
// ─────────────────────────────────────────────
class _PHCalibrationTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cal = ref.watch(calibrationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(
            label: "Buffer Solutions",
            color: Color(0xFFBB4D00),
          ),
          const SizedBox(height: 12),
          _BufferCard(
            title: "pH Buffer Solutions",
            label: "Buffer A",
            accentColor: const Color(0xFFBB4D00),
            bgColor: const Color(0xFFFEF3C6),
            valueListenable: cal.phBufferAValue,
            modeListenable: cal.phBufferAMode,
            onCapture: () =>
                ref.read(calibrationProvider).setPhBufferAMode(true),
            onValueChanged: (value) =>
                ref.read(calibrationProvider).setPhBufferAValue(value),
          ),
          const SizedBox(height: 12),
          _BufferCard(
            title: "pH Buffer Solutions",
            label: "Buffer B",
            accentColor: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFF7ED),
            valueListenable: cal.phBufferBValue,
            modeListenable: cal.phBufferBMode,
            onCapture: () =>
                ref.read(calibrationProvider).setPhBufferBMode(true),
            onValueChanged: (value) =>
                ref.read(calibrationProvider).setPhBufferBValue(value),
          ),
          const SizedBox(height: 24),
          const _SectionLabel(
            label: "Calibration Result",
            color: Color(0xFF0F172A),
          ),
          const SizedBox(height: 12),
          _ResultCard(
            gradientListenable: cal.phGradient,
            constantaListenable: cal.phConstanta,
            accentColor: const Color(0xFFBB4D00),
          ),
          const SizedBox(height: 24),
          _CalibrateButton(
            color: const Color(0xFFBB4D00),
            label: "Calibrate pH",
            onPressed: () {
              final provider = ref.read(calibrationProvider);
              final bufferAValue = provider.phBufferAValue.value;
              final bufferBValue = provider.phBufferBValue.value;
              final bufferAVoltage = provider.phBufferAVoltage.value;
              final bufferBVoltage = provider.phBufferBVoltage.value;

              if (bufferBVoltage == bufferAVoltage) {
                ScaffoldMessenger.of(context).showSnackBar(
                  _errorSnackBar("Tegangan A dan B tidak boleh sama"),
                );
                return;
              }

              final gradient = (bufferBValue - bufferAValue) /
                  (bufferBVoltage - bufferAVoltage);
              final constanta = bufferAValue - (gradient * bufferAVoltage);

              provider.setPhGradient(gradient);
              provider.setPhConstanta(constanta);

              ScaffoldMessenger.of(context).showSnackBar(
                _successSnackBar("Kalibrasi pH berhasil"),
              );
            },
          ),
          const _CalibrationNotes(title: "pH"),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _BufferCard extends StatelessWidget {
  final String title;
  final String label;
  final Color accentColor;
  final Color bgColor;
  final Function(double value)? onValueChanged;
  final ValueNotifier<double> valueListenable;
  final ValueNotifier<bool> modeListenable;
  final VoidCallback onCapture;

  const _BufferCard({
    required this.title,
    required this.label,
    required this.accentColor,
    required this.bgColor,
    this.onValueChanged,
    required this.valueListenable,
    required this.modeListenable,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label.split(" ").last, // "A" or "B"
                style: TextStyle(
                  fontFamily: "PlusJakartaSans",
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Values
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: "PlusJakartaSans",
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(children: [
                  _ValueChip(
                    title: title,
                    icon: Icons.science_outlined,
                    label: "Value",
                    listenable: valueListenable,
                    color: accentColor,
                    onTap: onValueChanged,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title == "TDS Buffer Solutions" ? "ppm" : "pH",
                    style: const TextStyle(
                      fontFamily: "PlusJakartaSans",
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Capture button
          ValueListenableBuilder<bool>(
            valueListenable: modeListenable,
            builder: (context, isLoading, _) {
              return RotatingIconButton(
                isLoading: isLoading,
                onPressed: onCapture,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String label;
  final ValueNotifier<double> listenable;
  final Color color;
  final Function(double value)? onTap;

  const _ValueChip({
    required this.icon,
    required this.title,
    required this.label,
    required this.listenable,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: listenable,
      builder: (_, value, __) {
        return InkWell(
          onTap: onTap == null
              ? null
              : () async {
                  final controller = TextEditingController(
                    text: title == "TDS Buffer Solutions"
                        ? value.toStringAsFixed(0)
                        : value.toStringAsFixed(2),
                  );

                  final result = await showDialog<double>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text("Set $label"),
                        content: TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Masukkan nilai",
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Batal"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white),
                            onPressed: () {
                              final value =
                                  double.tryParse(controller.text.trim());

                              if (title == "TDS Buffer Solutions" &&
                                  value != null) {
                                if (value < 0 || value > 2000) {
                                  toastification.show(
                                    context: context,
                                    title: const Text(
                                      "Value TDS harus antara 0 - 2000 ppm",
                                      style: TextStyle(
                                          fontFamily: 'PlusJakartaSans'),
                                    ),
                                    type: ToastificationType.error,
                                    autoCloseDuration:
                                        const Duration(seconds: 3),
                                  );
                                  return;
                                }
                              } else {
                                if (value != null &&
                                    (value < 0 || value > 14)) {
                                  toastification.show(
                                    context: context,
                                    title: const Text(
                                      "Value pH harus antara 0 - 14",
                                      style: TextStyle(
                                          fontFamily: 'PlusJakartaSans'),
                                    ),
                                    type: ToastificationType.error,
                                    autoCloseDuration:
                                        const Duration(seconds: 3),
                                  );
                                  return;
                                }
                              }

                              if (value != null) {
                                Navigator.pop(context, value);
                              }
                            },
                            child: const Text("Simpan"),
                          ),
                        ],
                      );
                    },
                  );

                  if (result != null) {
                    onTap!(result);
                  }
                },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(
                    fontFamily: "PlusJakartaSans",
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  final ValueNotifier<double> gradientListenable;
  final ValueNotifier<double> constantaListenable;
  final Color accentColor;

  const _ResultCard({
    required this.gradientListenable,
    required this.constantaListenable,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ResultItem(
              icon: Icons.trending_up_rounded,
              label: "Gradient",
              listenable: gradientListenable,
              color: accentColor,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: const Color(0xFFE2E8F0),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: _ResultItem(
              icon: Icons.calculate_outlined,
              label: "Konstanta",
              listenable: constantaListenable,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final ValueNotifier<double> listenable;
  final Color color;

  const _ResultItem({
    required this.icon,
    required this.label,
    required this.listenable,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: listenable,
      builder: (_, value, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: "PlusJakartaSans",
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toStringAsFixed(4),
              style: const TextStyle(
                fontFamily: "PlusJakartaSans",
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CalibrateButton extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onPressed;

  const _CalibrateButton({
    required this.color,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

SnackBar _successSnackBar(String message) {
  return SnackBar(
    content: Row(
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(
          message,
          style: const TextStyle(fontFamily: "PlusJakartaSans"),
        ),
      ],
    ),
    backgroundColor: const Color(0xFF059669),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  );
}

SnackBar _errorSnackBar(String message) {
  return SnackBar(
    content: Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontFamily: "PlusJakartaSans"),
          ),
        ),
      ],
    ),
    backgroundColor: const Color(0xFF990003),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  );
}

class _CalibrationNotes extends StatelessWidget {
  final String title;
  const _CalibrationNotes({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFCD34D),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📌 Petunjuk Kalibrasi ${title}",
            style: TextStyle(
              fontFamily: "PlusJakartaSans",
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "• Tentukan nilai Buffer A dan Buffer B sesuai larutan standar yang digunakan (Rekomendasi ${title == "TDS" ? "350 ppm dan 1000 ppm " : "pH 4 dan pH 7"}).\n"
            "• Celupkan sensor ${title} ke dalam larutan buffer, lalu tekan tombol capture (↻).\n"
            "• Tunggu hingga tombol kembali berwarna abu-abu.\n"
            "• Lakukan langkah yang sama untuk buffer berikutnya.\n"
            "• Setelah kedua buffer berhasil direkam, tekan tombol Calibrate ${title}.\n"
            "• Tunggu sekitar 5–10 menit hingga pembacaan sensor ${title} stabil.\n"
            "• Jika hasil masih kurang sesuai, ulangi proses kalibrasi ${title} dari awal.",
            style: TextStyle(
              fontFamily: "PlusJakartaSans",
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class SaveResult {
  /// Apakah simpan berhasil.
  final bool success;

  /// Pesan toast yang ditampilkan.
  final String message;

  const SaveResult.success(this.message) : success = true;
  const SaveResult.failed(this.message) : success = false;
}

class EditDialogPopup extends StatelessWidget {
  final String title;
  final bool isTwoFields;

  final String label1;
  final String? label2;

  final TextEditingController controller1;
  final TextEditingController? controller2;

  final TextInputType keyboardType1;
  final TextInputType keyboardType2;

  final SaveResult Function(String value1, String? value2) onSave;

  const EditDialogPopup({
    super.key,
    required this.title,
    required this.isTwoFields,
    required this.label1,
    this.label2,
    required this.controller1,
    this.controller2,
    this.keyboardType1 = TextInputType.text,
    this.keyboardType2 = TextInputType.text,
    required this.onSave,
  });

  void _handleSave(BuildContext context) {
    final value1 = controller1.text.trim();
    final value2 = controller2?.text.trim();

    final result = onSave(value1, value2);

    toastification.show(
      context: context,
      title: Text(result.message,
          style: const TextStyle(fontFamily: 'PlusJakartaSans')),
      type: result.success
          ? ToastificationType.success
          : ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 3),
    );

    if (result.success) {
      Navigator.pop(context, {"value1": value1, "value2": value2});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontFamily: "PlusJakartaSans",
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildField(
            controller: controller1,
            label: label1,
            keyboardType: keyboardType1,
          ),
          if (isTwoFields) ...[
            const SizedBox(height: 14),
            _buildField(
              controller: controller2!,
              label: label2 ?? "",
              keyboardType: keyboardType2,
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontFamily: "PlusJakartaSans",
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () => _handleSave(context),
              child: const Text(
                "Save",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontFamily: "PlusJakartaSans",
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: "PlusJakartaSans"),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

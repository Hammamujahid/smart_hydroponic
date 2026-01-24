import 'package:flutter/material.dart';

class EditDialogPopup extends StatelessWidget {
  final String title;
  final bool isTwoFields;

  final String label1;
  final String? label2;

  final TextEditingController controller1;
  final TextEditingController? controller2;

  final TextInputType keyboardType1;
  final TextInputType keyboardType2;

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
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "value1": controller1.text.trim(),
                  "value2": controller2?.text.trim(),
                });
              },
              child: const Text("Save"),
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

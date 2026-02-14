import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/fonts.dart';

class AppEditableFeild extends StatelessWidget {
  const AppEditableFeild({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.isReadOnly,
    required this.onEditTap,
    required this.colors,
    this.isEmail = false,
    this.inputType = TextInputType.text,
  });
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isReadOnly;
  final VoidCallback onEditTap;
  final dynamic colors;
  final TextInputType inputType;
  final bool isEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: inputType,
          style: TextStyle(color: colors.text),
          decoration: InputDecoration(
            suffixIcon: isEmail
                ? null
                : IconButton(
                    icon: Icon(
                      isReadOnly ? Icons.edit : Icons.edit_off,
                      size: 20,
                      color: isReadOnly ? colors.secText : colors.primary,
                    ),
                    onPressed: onEditTap,
                  ),
            hintText: label,
            filled: true,
            fillColor: colors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.secondary, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.info_outline, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(hint, style: AppTextStyles.size12weight4(colors.secText)),
          ],
        ),
      ],
    );
  }
}

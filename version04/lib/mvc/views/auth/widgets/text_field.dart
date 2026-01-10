import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
  final colors = AppColors.light;

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.textInside});
  final String textInside;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: textInside,
        hintStyle: AppTextStyles.size12weight4(colors.secText),
        filled: true,
        fillColor: colors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 1.3),
        ),
        
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

final colors = AppColors.light;

// ignore: must_be_immutable
class AppTextField2 extends StatelessWidget {
  AppTextField2({
    super.key,
    required this.textInside,
    this.obscure = false,
    required this.controller,
    this.validator,
  });
  FormFieldValidator<String>? validator;
  final String textInside;
  final TextEditingController controller;
  final bool obscure;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: textInside,
        hintStyle: AppTextStyles.size12weight4(colors.secText),
        filled: true,
        fillColor: colors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.secondary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 1.3),
        ),
      ),
    );
  }
}

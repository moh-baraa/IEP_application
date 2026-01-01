import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

final colors = AppColors.light;

class AppFormButton extends StatelessWidget {
  const AppFormButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.isSecondary = false,
    this.isloading = false,
  });
  final String buttonText;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isloading;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? colors.secondary : colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 5,
        ),
        onPressed: onPressed,
        child: isloading
            ? CircularProgressIndicator()
            : Text(
                buttonText,
                style: AppTextStyles.size14weight4(
                  isSecondary ? colors.text : colors.background,
                ),
              ),
      ),
    );
  }
}

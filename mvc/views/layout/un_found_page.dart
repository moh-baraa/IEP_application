import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

final colors = AppColors.light;

class AppUnFoundPage extends StatelessWidget {
  const AppUnFoundPage({
    super.key,
    this.icon,
    required this.text,
    this.subText,
    this.tryAgain,
  });
  final IconData? icon;
  final String text;
  final String? subText;
  final VoidCallback? tryAgain;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon == null
              ? SizedBox()
              : Icon(icon, size: 60, color: colors.secTextShapes),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.size16weight5(colors.secText),
          ),
          const SizedBox(height: 8),
          subText == null
              ? SizedBox()
              : Text(
                  subText!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.size12weight4(colors.secText),
                ),
          const SizedBox(height: 8),
          tryAgain == null
              ? SizedBox()
              : TextButton(
                  onPressed: tryAgain!,
                  child: const Text('Try Again'),
                ),
        ],
      ),
    );
  }
}

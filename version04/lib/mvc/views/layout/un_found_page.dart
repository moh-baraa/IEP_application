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
    this.buttonText = 'Try Again', // to customize the button
  });
  final IconData? icon;
  final String text;
  final String? subText;
  final VoidCallback? tryAgain;
  final String buttonText;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
              style: AppTextStyles.size18weight5(colors.secText),
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
                : SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.bg,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colors.primary),
                        ),
                      ),
                      onPressed: tryAgain!,
                      child: Text(
                        buttonText,
                        style: AppTextStyles.size14weight5(colors.primary),
                      ),
                    ),
                  ),

            // : TextButton(onPressed: tryAgain!, child: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}

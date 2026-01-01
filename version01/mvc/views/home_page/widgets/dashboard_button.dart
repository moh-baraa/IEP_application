import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

AppColorScheme colors = AppColors.light;

class AppDashboardButton extends StatelessWidget {
  const AppDashboardButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon = Icons.home_filled,
  });
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // side: BorderSide(color: colors.secText.withOpacity(0.5)),
        backgroundColor: colors.secondary,
        elevation: 2,
        shadowColor: colors.text.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -1,
            top: -2,
            child: Icon(
              icon,
              size: 26,
              color: colors.background.withOpacity(0.8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 2, bottom: 2),
            child: Text(text, style: AppTextStyles.size14weight4(colors.text)),
          ),
        ],
      ),
    );
  }
}

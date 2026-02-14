import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/views/home_page/widgets/dashboard_button.dart';

AppColorScheme colors = AppColors.light;

class AppDashboardContainer extends StatelessWidget {
  const AppDashboardContainer({super.key, required this.buttons});
  final List<AppDashboardButton> buttons;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.text.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Wrap(spacing: 10, runSpacing: 10, children: buttons),
    );
  }
}

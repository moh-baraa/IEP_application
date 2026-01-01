import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

AppColorScheme colors = AppColors.light;

class AppSnapshotCard extends StatelessWidget {
  final String title;
  final String number;
  const AppSnapshotCard({super.key, required this.title, required this.number});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: colors.secText.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              Text(
                number,
                style: AppTextStyles.size16weight5(colors.text),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 90,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.size12weight4(colors.secText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

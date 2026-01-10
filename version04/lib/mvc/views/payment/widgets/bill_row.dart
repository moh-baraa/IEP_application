import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

class AppBillRow extends StatelessWidget {
  const AppBillRow({super.key, required this.label, required this.value,  this.isBold=false});
  final String label;
  final String value;
  final bool isBold;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.size14weight4(colors.secText)),
        Text(
          value,
          style: isBold
              ? AppTextStyles.size18weight5(colors.text)
              : AppTextStyles.size14weight5(colors.text),
        ),
      ],
    );
  }
}

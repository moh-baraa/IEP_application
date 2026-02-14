import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

class ProjectRatingBar extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double iconSize;
  final bool showText;

  const ProjectRatingBar({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.iconSize = 18,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;

    return Row(
      mainAxisSize: MainAxisSize.min, // least size avaliable
      children: [
        // === starts ====
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating.round() ? Icons.star : Icons.star_border,
              color: colors.orange,
              size: iconSize,
            );
          }),
        ),

        // === Collection If & Spread Operator ===
        if (showText) ...[
          const SizedBox(width: 6),
          // === rating number ===
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.size14weight5(
              colors.text,
            ).copyWith(fontSize: iconSize * 0.8),
          ),

          const SizedBox(width: 4),

          // === numbers of reviews ===
          Text(
            '($reviewCount reviews)',
            style: AppTextStyles.size12weight4(colors.secText).copyWith(
              fontSize: iconSize * 0.6, // تصغير الخط قليلاً
            ),
          ),
        ],
      ],
    );
  }
}

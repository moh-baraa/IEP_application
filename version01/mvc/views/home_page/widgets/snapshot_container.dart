import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/views/home_page/widgets/snapshot_card.dart';

final colors = AppColors.light;

class AppSnapshotContainer extends StatelessWidget {
  const AppSnapshotContainer({
    super.key,
    required this.cards,

  });
  final List<AppSnapshotCard> cards;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dashboard Snapshot',
              style: AppTextStyles.size18weight5(colors.text),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.text.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(// make height all the elements equal to  the tallest elemtent
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: cards.map((e) => Expanded(child: e)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

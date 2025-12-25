import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

AppColorScheme colors = AppColors.light;

class SavedProjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final String imageUrl;
  final VoidCallback? onUnsaveTap; // delete button
  final VoidCallback? onCardTap; // to go to project details
  final bool showBookmarkIcon; // controllling if we want to show delete icon

  const SavedProjectCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.imageUrl,
    this.onUnsaveTap,
    this.onCardTap,
    this.showBookmarkIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        // to work the toch colors when click by inkwell
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onCardTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 1. الصورة
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (imageUrl.startsWith('http'))//to check the image come from network or not
                      ? Image.network(//if the image exist
                          imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _placeholder(),//what show if error occur
                        )
                      : Image.asset(// if its not exist
                          imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _placeholder(),//what show if error occur
                        ),
                ),

                const SizedBox(width: 14),

                // ======================== save project content ========================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.size16weight5(colors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.size12weight4(colors.secText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: colors.secTextShapes,
                                color: colors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: AppTextStyles.size10weight4(colors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

// === delete icon, show if its allow ===
                if (showBookmarkIcon && onUnsaveTap != null)
                  IconButton(
                    onPressed: onUnsaveTap,
                    icon: Icon(
                      Icons.close, 
                      color: colors.secText.withOpacity(0.6),
                    ),
                    style: IconButton.styleFrom(
                      // === circular backgreound ===
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      padding: const EdgeInsets.all(4),
                      minimumSize: const Size(30, 30), //ake it smaller a little
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {// show only if error occur
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}

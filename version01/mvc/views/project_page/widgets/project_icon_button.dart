import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';

AppColorScheme colors = AppColors.light;

class ProjectIconButton extends StatelessWidget {
  const ProjectIconButton({super.key, this.label, required this.icon, required this.onTap, required Color color});
  final String? label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: [
            Icon(icon, color: colors.secText),
            label == null ? SizedBox.shrink() : const SizedBox(height: 4),
            label == null
                ? SizedBox.shrink()
                : Text(label!, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

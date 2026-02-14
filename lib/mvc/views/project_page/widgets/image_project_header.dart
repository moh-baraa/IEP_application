import 'package:flutter/material.dart';
import 'package:iep_app/mvc/views/project_page/widgets/project_image_slider.dart';

class ProjectImageHeader extends StatelessWidget {
  final List<String> images;

  const ProjectImageHeader({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    // === same widget used on project card ===
    return ProjectImageSlider(
      images: images,
      height: 220, // more bigger
      borderRadius: BorderRadius.circular(12), // diffrent raduis
    );
  }
}

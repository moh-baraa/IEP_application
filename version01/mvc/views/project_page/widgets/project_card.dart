import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/views/project_page/projectsDetails_page.dart';
import 'package:iep_app/mvc/views/project_page/widgets/project_button.dart';
import 'package:iep_app/mvc/views/project_page/widgets/project_image_slider.dart';
import 'package:iep_app/mvc/views/project_page/widgets/project_rating_bar.dart';

AppColorScheme colors = AppColors.light;

class ProjectCard extends StatefulWidget {
  const ProjectCard({super.key, required this.project});
  final ProjectModel project;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  late double currentInvestment;
  late double goalInvestment;
  late String title;
  late String description;
  late List<String> images;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    currentInvestment = project.totalFunds;
    goalInvestment = project.targetFunds;
    title = project.title;
    description = project.description;
    images = project.images;
    bool isActive = project.isApproved && !project.isFrozen;

    return Card(
      // === white background if ia active, diffrent bg if unpproved or frozen ===
      color: isActive ? colors.background : Colors.red.shade50,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === Image Section with Status Badge ===
          Stack(
            children: [
              // === image widget for dealing with the images ===
              ProjectImageSlider(
                images: project.images,
                height: 180,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),

              // === state indicator, show only if not active ===
              if (!isActive)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_filled,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          project.isApproved
                              ? "Project Frozen"
                              : "Pending Review",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // === Progress bar ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currentInvestment.toInt()}\$',
                      style: AppTextStyles.size14weight5(colors.primary),
                    ),
                    Text(
                      '${goalInvestment.toInt()}\$',
                      style: AppTextStyles.size14weight5(colors.secText),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: goalInvestment > 0
                        ? (currentInvestment / goalInvestment).clamp(0.0, 1.0)
                        : 0,
                    minHeight: 6,
                    backgroundColor: colors.secTextShapes,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                ),
              ],
            ),
          ),

          // === Rating ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ProjectRatingBar(
              rating: project.rating ?? 0.0,
              reviewCount: project.numOfReviews ?? 0,
              iconSize: 18,
            ),
          ),

          // === Title & Description ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: AppTextStyles.size16weight5(colors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              description,
              style: AppTextStyles.size12weight4(AppColors.light.secText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // === Buttons ===
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ProjectButton(
                  text: 'View Details',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectDetailsPage(project: project),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:iep_app/mvc/views/home_page/saved_projects_page.dart';
import 'package:iep_app/mvc/views/home_page/widgets/saved_projects_cards.dart';
import 'package:provider/provider.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/home_page/saved_projects_controller.dart';

AppColorScheme colors = AppColors.light;

class SavedProjectsContainer extends StatelessWidget {
  const SavedProjectsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // to get save projects information
    return ChangeNotifierProvider(
      create: (_) => SavedProjectsController(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Projects',
                  style: AppTextStyles.size18weight5(colors.text),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: colors.text),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedProjectsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // to refresh the list when there is new saved project
          Consumer<SavedProjectsController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.savedProjects.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: Text(
                    "No saved projects yet",
                    style: TextStyle(color: colors.secText),
                  ),
                );
              }

              // === only first 3 elements will shown ===
              final displayedProjects = controller.savedProjects
                  .take(3)
                  .toList();

              return Column(
                children: displayedProjects.map((project) {
                  // ======================== project save card ========================
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: SavedProjectCard(
                      title: project.title,
                      subtitle: project.description,
                      imageUrl: project.images.isNotEmpty
                          ? project.images.first
                          : 'assets/images/logo.png', //default image
                      progress: (project.targetFunds > 0)
                          ? (project.totalFunds / project.targetFunds)
                          : 0.0,
                      onCardTap: () =>
                          controller.onProjectTap(context, project),

                      // on tapping delete button
                      onUnsaveTap: () {
                        controller.removeProject(project.id!);
                      },
                    ),
                  );
                  // ======================== project save card ========================
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

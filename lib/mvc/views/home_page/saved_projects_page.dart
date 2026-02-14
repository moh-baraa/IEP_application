import 'package:flutter/material.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';
import 'package:iep_app/mvc/controllers/home_page/saved_projects_controller.dart';
import 'package:iep_app/mvc/views/home_page/widgets/saved_projects_cards.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

final AppColorScheme colors = AppColors.light;

class SavedProjectsPage extends StatelessWidget {
  const SavedProjectsPage({super.key, required this.controller});
  final SavedProjectsController controller;

  @override
  Widget build(BuildContext context) {
    // === using the provider/controller ===
    return Scaffold(
      backgroundColor: AppColors.light.bg,
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: colors.secText)),
        backgroundColor: AppColors.light.background,
        elevation: 0,
        title: Text(
          'Saved Projects',
          style: AppTextStyles.size18weight5(colors.text),
        ),
        centerTitle: true,
      ),

      // === listening to the data ===
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            // === is loading phase ===
            if (controller.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: colors.primary),
              );
            }
            // === is empty phase ===
            if (controller.savedProjects.isEmpty) {
              return AppUnFoundPage(
                icon: Icons.bookmark_border,
                text: "No saved projects yet",
              );
            }
            // === data show phase ===
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.savedProjects.length,
              itemBuilder: (context, index) {
                // === take the project object from saved projects in controller ===
                final project = controller.savedProjects[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ), // adding space btw items
                  child: SavedProjectCard(
                    title: project.title,
                    subtitle: project.description,
                    imageUrl: project.images.isNotEmpty
                        ? project.images.first
                        : 'assets/images.logo.png',
                    progress: (project.targetFunds > 0)
                        ? (project.totalFunds / project.targetFunds)
                        : 0.0,
                    // === route to project details page ===
                    onCardTap: () {
                      controller.onCardTap(context, project: project);
                    },

                    // === on saved project delete ===
                    onUnsaveTap: () {
                      controller.removeProject(project.id!);

                      AppSnackBarState.show(
                        context,
                        color: colors.secText,
                        content: "Removed from saved",
                      );
                    },
                    // showBookmarkIcon: true,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

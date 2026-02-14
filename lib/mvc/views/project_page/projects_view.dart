import 'package:flutter/material.dart';
import 'package:iep_app/mvc/controllers/home_page/home_controller.dart';
import 'package:iep_app/mvc/views/project_page/widgets/catagories_list.dart';
import 'package:iep_app/mvc/views/project_page/widgets/project_card.dart';
import 'package:iep_app/mvc/views/project_page/widgets/search_bar.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/controllers/project_page/project_controller.dart';

final colors = AppColors.light;

class ProjectsView extends StatefulWidget {
  const ProjectsView({super.key});

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  final HomeController homeController = HomeController();
  late final ProjectsController controller;

  @override
  initState() {
    super.initState();
    controller = ProjectsController();
    controller.fetchProjects('All');
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  // === for building the list ===
  Widget _buildList(ProjectsController provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // === error occur page ===
    if (provider.errorMessage != null) {
      return AppUnFoundPage(
        icon: Icons.folder_open,
        text: "Error loading projects",
        tryAgain: () => provider.fetchProjects(provider.selectedFilter),
      );
    }
    // === empty projects page ===
    if (provider.displayedProjects.isEmpty) {
      return AppUnFoundPage(
        text: provider.selectedFilter == 'All'
            ? "No projects found"
            : "No projects found for ${provider.selectedFilter}.",
        tryAgain: () => provider.fetchProjects(provider.selectedFilter),
      );
    }
    // === build the project in the page ===
    return RefreshIndicator(// to refresh when pull the page
      onRefresh: () async => provider.fetchProjects(provider.selectedFilter),

      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),// important to refresh indicator
        itemCount: provider.displayedProjects.length,
        itemBuilder: (context, index) {
          return ProjectCard(
            project: provider.displayedProjects[index],
          ); // pass the project
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          // === listening to the data in the controller ===
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === search bar ===
                  Row(
                    children: [
                      Expanded(
                        child: AppSearchBar(
                          onChanged: (value) {
                            controller.filterProjects(value);
                          },
                        ),
                      ),
                      SizedBox(width: 4),
                      IconButton(
                        onPressed: () =>
                            homeController.navigateToAddProject(context),
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: colors.primary,
                          size: 35,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // === page catagories ===
                  AppCatagoriesList(
                    categories: const [
                      'All',
                      'Lowest Goal',
                      'Highest Goal',
                      'Latest',
                      'Oldest',
                    ],
                    onSelected: (selectedCategory) {
                      controller.fetchProjects(selectedCategory);
                    },
                  ),

                  const SizedBox(height: 12),

                  // === actual data list ===
                  Expanded(child: _buildList(controller)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

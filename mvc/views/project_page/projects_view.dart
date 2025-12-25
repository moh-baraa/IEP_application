import 'package:flutter/material.dart';
import 'package:iep_app/mvc/controllers/home_page/home_controller.dart';
import 'package:iep_app/mvc/views/project_page/widgets/catagories_list.dart';
import 'package:iep_app/mvc/views/project_page/widgets/project_card.dart';
import 'package:iep_app/mvc/views/project_page/widgets/search_bar.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';
import 'package:provider/provider.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/controllers/project_page/project_controller.dart';

final colors = AppColors.light;

class ProjectsView extends StatelessWidget {
  const ProjectsView({super.key});

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
      );
    }
    // === build the project in the page ===
    return ListView.builder(
      itemCount: provider.displayedProjects.length,
      itemBuilder: (context, index) {
        return ProjectCard(
          project: provider.displayedProjects[index],
        ); // pass the project
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = HomeController();
    return ChangeNotifierProvider(
      create: (context) => ProjectsController()..fetchProjects('All'), //?
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            // === listening to the data in the controller ===
            child: Consumer<ProjectsController>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === search bar ===
                    Row(
                      children: [
                        Expanded(
                          child: AppSearchBar(
                            onChanged: (value) {
                              provider.filterProjects(value);
                            },
                          ),
                        ),
                        SizedBox(width: 4),
                        IconButton(
                          onPressed: () =>
                              controller.navigateToAddProject(context),
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
                        provider.fetchProjects(selectedCategory);
                      },
                    ),

                    const SizedBox(height: 12),

                    // 3. القائمة
                    Expanded(child: _buildList(provider)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

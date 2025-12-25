import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/mvc/views/admin/widgets/admin_project_card.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';
import 'package:iep_app/mvc/views/project_page/widgets/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/controllers/project_page/project_controller.dart';
import 'package:iep_app/mvc/controllers/admin/projects_manager_controller.dart';

final colors = AppColors.light;

class ProjectsManagerView extends StatelessWidget {
  const ProjectsManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProjectsController()
            ..fetchProjects(
              'All',
              includeFrozen: true,
            ), // create controller, excute fetchProjects, return the controller
        ),
        ChangeNotifierProvider(create: (_) => ProjectsManagerController()),
      ],
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Consumer2<ProjectsController, ProjectsManagerController>(
              // using two consumer
              builder: (context, projectProvider, adminController, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === search bar ===
                    AppSearchBar(
                      onChanged: (value) {
                        projectProvider.filterProjects(value);
                      },
                    ),

                    const SizedBox(height: 12),

                    // === project list ===
                    Expanded(
                      child: _buildList(
                        context,
                        projectProvider,
                        adminController,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ProjectsController projectProvider,
    ProjectsManagerController adminController,
  ) {
    // === is loading phase ===
    if (projectProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // === error phase ===
    if (projectProvider.errorMessage != null) {
      return AppUnFoundPage(
        text: "Error loading projects",
        tryAgain: () => projectProvider.fetchProjects('All'),
      );
    }
    // === empty phase ===
    if (projectProvider.allProjects.isEmpty) {
      return AppUnFoundPage(text: "No projects found");
    }
    // === actual data ===
    return ListView.builder(
      itemCount: projectProvider.displayedProjects.length,
      itemBuilder: (context, index) {
        final project = projectProvider.displayedProjects[index];

        // === project card ===
        return StreamBuilder<DocumentSnapshot>(
          // listen to the users
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(project.ownerId)
              .snapshots(),
          builder: (context, snapshot) {
            bool isUserBlocked = false;

            // === check about the data ===
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              isUserBlocked =
                  data?['isBlocked'] ?? false; // if non exist, will be false
            }

            // === project card ===
            return AdminProjectCard(
              project: project,
              controller: adminController,
              isProjectFrozen: project.isFrozen,
              isOwnerFrozen: isUserBlocked,
            );
          },
        );
      },
    );
  }
}

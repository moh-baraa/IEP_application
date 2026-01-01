import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/mvc/views/admin/widgets/admin_project_card.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';
import 'package:iep_app/mvc/views/project_page/widgets/search_bar.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/controllers/project_page/project_controller.dart';
import 'package:iep_app/mvc/controllers/admin/projects_manager_controller.dart';

final colors = AppColors.light;

class ProjectsManagerView extends StatefulWidget {
  const ProjectsManagerView({super.key});

  @override
  State<ProjectsManagerView> createState() => _ProjectsManagerViewState();
}

class _ProjectsManagerViewState extends State<ProjectsManagerView> {
  late final ProjectsController projectController; // user projects controller
  late final ProjectsManagerController
  adminController; // admin manager controller
  @override
  void initState() {
    super.initState();
    projectController = ProjectsController();
    adminController = ProjectsManagerController();
    // === create controller, excute fetchProjects, return the controller ===
    projectController.fetchProjects('All', includeFrozen: true);
  }

  @override
  void dispose() {
    projectController.dispose();
    adminController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListenableBuilder(
            // === use to listenable, to update the interface when: ===
            // === 1. the project is freezed ===
            // === 2. the user is blocked ===
            listenable: Listenable.merge([projectController, adminController]),
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === search bar ===
                  AppSearchBar(
                    onChanged: (value) {
                      projectController.filterProjects(value);
                    },
                  ),

                  const SizedBox(height: 12),

                  // === project list ===
                  Expanded(
                    child: _buildList(
                      context,
                      projectController,
                      adminController,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ProjectsController projectController,
    ProjectsManagerController adminController,
  ) {
    // === is loading phase ===
    if (projectController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // === error phase ===
    if (projectController.errorMessage != null) {
      return AppUnFoundPage(
        text: "Error loading projects",
        tryAgain: () =>
            projectController.fetchProjects('All', includeFrozen: true),
      );
    }
    // === empty phase ===
    if (projectController.allProjects.isEmpty) {
      return AppUnFoundPage(text: "No projects found");
    }
    // === actual data ===
    return ListView.builder(
      itemCount: projectController.displayedProjects.length,
      itemBuilder: (context, index) {
        final project = projectController.displayedProjects[index];

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
              projController: projectController,
              isProjectFrozen: project.isFrozen,
              isOwnerFrozen: isUserBlocked,
            );
          },
        );
      },
    );
  }
}

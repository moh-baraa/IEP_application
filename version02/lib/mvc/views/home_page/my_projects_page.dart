import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/repositories/project_repository.dart';
import 'package:iep_app/mvc/views/project_page/projectsDetails_page.dart';
import 'package:iep_app/mvc/views/project_page/widgets/project_card.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';

final colors = AppColors.light;

class MyProjectsPage extends StatelessWidget {
  const MyProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = UserProvider.instance;
    final String currentUserId = provider.currentUserId!;
    final repo = ProjectsRepository();

    return Scaffold(
      backgroundColor: AppColors.light.bg,
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: colors.secText)),
        title: Text(
          "My Projects",
          style: AppTextStyles.size18weight5(colors.text),
        ),
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: repo.getUserProjects(currentUserId: currentUserId),
          builder: (context, snapshot) {
            // === is loading phase ===
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // === wrong fetch ===
            if (snapshot.hasError) {
              // === there no projects page for user ===
              return AppUnFoundPage(
                icon: Icons.folder_open,
                text: "Error loading projects",
                subText: snapshot.error.toString()
              );
            }

            // === no projects ===
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return AppUnFoundPage(
                icon: Icons.folder_open,
                text: "No projects found.",
              );
            }

            // === data exist ===
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];

                try {
                  ProjectModel project = ProjectModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProjectDetailsPage(project: project),
                        ),
                      );
                    },
                    child: ProjectCard(project: project),
                  );
                } catch (e) {
                  // === if there error with one project, hide it ===
                  return const SizedBox.shrink();
                }
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/admin/projects_manager_controller.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/views/admin/widgets/request_card.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';

class ProjectRequestsPage extends StatefulWidget {
  const ProjectRequestsPage({super.key});

  @override
  State<ProjectRequestsPage> createState() => _ProjectRequestsPageState();
}

class _ProjectRequestsPageState extends State<ProjectRequestsPage> {
  final ProjectsManagerController controller = ProjectsManagerController();
  final colors = AppColors.light;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: colors.secText)),
        title: Text(
          'Project Requests',
          style: AppTextStyles.size18weight5(colors.text),
        ),
        backgroundColor: colors.background,
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: controller.getProjectRequestsStream(),
          builder: (context, snapshot) {
            // === is loading phase ===
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // === no data phase ===
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return AppUnFoundPage(
                text: 'No Pending Requests',
                icon: Icons.checklist_outlined,
              );
            }
            // === actual data ===
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final project = ProjectModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                );

                return AppRequestCard(
                  project: project,
                  onApprove: () async {
                    await controller.approveProject(
                      projectId: project.id!,
                      ownerId: project.ownerId!,
                      projectTitle: project.title,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Project Approved & User Notified"),
                        ),
                      );
                    }
                  },
                  onReject: () async {
                    await controller.rejectProject(
                      projectId: project.id!,
                      ownerId: project.ownerId!,
                      projectTitle: project.title,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Project Rejected & User Notified"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

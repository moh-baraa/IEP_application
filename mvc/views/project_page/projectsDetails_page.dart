import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/mvc/controllers/project_page/project_action_buttons.dart';
import 'package:iep_app/mvc/views/home_page/add_new_project_page.dart';
import 'package:iep_app/mvc/views/project_page/widgets/add_comment_section.dart';
import 'package:iep_app/mvc/views/project_page/widgets/image_project_header.dart';
import 'package:iep_app/mvc/views/project_page/widgets/investment_bar.dart';
import 'package:iep_app/mvc/views/project_page/widgets/project_comments_list.dart';
import 'package:iep_app/mvc/views/project_page/widgets/project_rating_bar.dart';
import 'package:iep_app/core/widgets/app_input_dialog.dart';
import 'package:provider/provider.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/controllers/project_page/projects_datails_controllre.dart';

final colors = AppColors.light;

class ProjectDetailsPage extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailsPage({super.key, required this.project});

  // === delete confirmtion ===
  void _showDeleteConfirmation(
    BuildContext context,
    ProjectDetailsController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Delete Project",
          style: AppTextStyles.size16weight5(colors.text),
        ),
        content: Text(
          "Are you sure you want to delete this project? This action cannot be undone.",
          style: AppTextStyles.size14weight4(colors.secText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: colors.secText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteProject(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectDetailsController(project: project),
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          centerTitle: true,
          title: Text(
            project.title,
            style: AppTextStyles.size18weight5(colors.text),
            overflow: TextOverflow.ellipsis,
          ),
          // === buttons section ===
          actions: [
            // === if the user is the owner, will add the button ===
            if (FirebaseAuth.instance.currentUser?.uid == project.ownerId)
              // === delete button ===
              Row(
                children: [
                  Consumer<ProjectDetailsController>(
                    builder: (context, controller, _) {
                      return IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: colors.red,
                        ),
                        tooltip: "Delete Project",
                        onPressed: () =>
                            _showDeleteConfirmation(context, controller),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_note_rounded, color: colors.primary),
                    //=== edit icon ===
                    tooltip: "Edit Project",
                    onPressed: () {
                      // === pass the project to edit page ===
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddProjectPage(projectToEdit: project),
                        ),
                      );
                    },
                  ),
                ],
              ),

            const SizedBox(width: 8),
          ],
        ),
        bottomNavigationBar:
            // === bottom investment bar ===
            SafeArea(
              child: Consumer<ProjectDetailsController>(
                builder: (context, controller, _) {
                  return InvestmentBar(
                    current: controller.liveTotalFunds,

                    goal: controller.project.targetFunds,

                    investors: controller.liveInvestorsCount,

                    project: controller.project
                  );
                },
              ),
            ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<ProjectDetailsController>(
              builder: (context, controller, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === project images  section ===
                    ProjectImageHeader(images: project.images),
                    const SizedBox(height: 16),

                    // === owner section ===
                    _buildOwnerSection(context, controller),

                    const SizedBox(height: 16),

                    // === project rating section ===
                    ProjectRatingBar(
                      rating: project.rating ?? 0.0,
                      reviewCount: project.numOfReviews ?? 0,
                      iconSize: 20,
                    ),

                    const SizedBox(height: 16),

                    // === project description section ===
                    Text(
                      'Description',
                      style: AppTextStyles.size16weight5(colors.text),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.description,
                      style: AppTextStyles.size13weight4(
                        colors.secText,
                      ).copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 20),

                    // === interaction buttons section ===
                    ProjectActionButtons(controller: controller),

                    const Divider(height: 40),
                    Text(
                      'Comments & Reviews',
                      style: AppTextStyles.size16weight5(colors.text),
                    ),
                    const SizedBox(height: 10),

                    // === comments list section ===
                    ProjectCommentsList(projectId: project.id!),

                    const SizedBox(height: 20),

                    //  === adding comment & ratings section ===
                    AddCommentSection(controller: controller),

                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // === report dialog ===
  void _showUserReportDialog(
    BuildContext context,
    ProjectDetailsController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AppInputDialog(
        title: "Report User",
        subtitle: "Why are you reporting ${controller.ownerName}?",
        hintText: "Reason (e.g. Fake profile, harassment...)",
        actionText: "Report User",
        actionColor: AppColors.light.red,
        onSubmit: (reason) {
          controller.sendUserReport(context, reason);
        },
      ),
    );
  }

  // === owner widget ===
  Widget _buildOwnerSection(
    BuildContext context,
    ProjectDetailsController controller,
  ) {
    if (controller.isOwnerLoading) {
      return const SizedBox(
        height: 50,
        child: Center(child: LinearProgressIndicator(minHeight: 2)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: (controller.ownerImage.isNotEmpty)
                ? NetworkImage(controller.ownerImage)
                : null,
            backgroundColor: colors.primary.withOpacity(0.2),
            child: (controller.ownerImage.isEmpty)
                ? Icon(Icons.person, color: colors.primary)
                : null,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.ownerName,
                  style: AppTextStyles.size14weight5(colors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Project Owner",
                  style: AppTextStyles.size12weight4(colors.secText),
                ),
              ],
            ),
          ),

          // === buttons ===
          Row(
            children: [
              IconButton(
                onPressed: () => controller.contactOwner(context),
                style: IconButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                ),
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 18,
                ),
                tooltip: "Chat",
              ),

              const SizedBox(width: 8),

              IconButton(
                onPressed: () => _showUserReportDialog(context, controller),
                style: IconButton.styleFrom(
                  backgroundColor: colors.red.withOpacity(0.1),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                ),
                icon: Icon(Icons.flag_outlined, color: colors.red, size: 18),
                tooltip: "Report User",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

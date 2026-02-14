import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/controllers/admin/projects_manager_controller.dart';
import 'package:iep_app/mvc/controllers/project_page/project_controller.dart';
import 'package:iep_app/mvc/views/home_page/widgets/saved_projects_cards.dart';
import 'package:iep_app/mvc/views/project_page/projectsDetails_page.dart';

class AdminProjectCard extends StatelessWidget {
  final ProjectModel project;
  final ProjectsManagerController controller;
  final ProjectsController projController;
  final bool isProjectFrozen;

  const AdminProjectCard({
    super.key,
    required this.project,
    required this.controller,
    required this.projController,
    this.isProjectFrozen = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;

    double progress = (project.targetFunds > 0)
        ? (project.totalFunds / project.targetFunds).clamp(0.0, 1.0)
        : 0.0;

    // === null safty protection ===
    if (project.ownerId == null || project.ownerId!.isEmpty) {
      // === the user not found, then show empty container ===
      return Container(
        height: 100,
        margin: const EdgeInsets.all(8),
        color: Colors.red.withOpacity(0.1),
        child: const Center(child: Text("Project has no owner info!")),
      );
    }

    // === for user information and state ===
    return StreamBuilder<DocumentSnapshot>(
      stream: controller.getUserInfo(userId: project.ownerId!),
      builder: (context, snapshot) {
        String ownerName = "Loading...";
        String ownerImage = "";
        bool isUserBlocked = false;

        // === extract the data when arrive ===
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          ownerName = "${data['first_name']} ${data['last_name']}";
          ownerImage = data['avatar_url'] ?? "";
          isUserBlocked = data['isBlocked'] ?? false;
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isProjectFrozen
                  ? colors.red.withOpacity(0.5)
                  : colors.button,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // === project card ===
                SavedProjectCard(
                  title: project.title,
                  subtitle: project.description,
                  progress: progress,
                  imageUrl: project.images.isNotEmpty
                      ? project.images.first
                      : '',
                  showBookmarkIcon: false,
                  onCardTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectDetailsPage(project: project),
                      ),
                    );
                  },
                ),

                // === owner info section ===
                _buildOwnerInfoRow(context, colors, ownerName, ownerImage),

                Divider(height: 1.5, color: colors.button),

                // === Action Buttons ===
                _buildActionButtons(context, colors, isUserBlocked),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOwnerInfoRow(
    BuildContext context,
    AppColorScheme colors,
    String name,
    String image,
  ) {
    if (project.ownerId == null || project.ownerId!.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: (image.isNotEmpty) ? NetworkImage(image) : null,
            backgroundColor: colors.primary.withOpacity(0.1),
            child: (image.isEmpty)
                ? Icon(Icons.person, size: 16, color: colors.primary)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.size14weight5(colors.text),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline,
              color: colors.primary,
              size: 20,
            ),
            onPressed: () {
              controller.contactOwner(
                context,
                project: project,
                ownerName: name,
                ownerImage: image,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppColorScheme colors,
    bool isOwnerBlocked,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // === Freeze Project ===
          _AdminActionButton(
            icon: isProjectFrozen ? Icons.lock_open : Icons.lock_outline,
            label: isProjectFrozen ? "Unfreeze" : "Freeze",
            color: isProjectFrozen ? Colors.green : Colors.orange,
            onTap: () {
              controller.toggleProjectFreeze(context, project, projController);
            },
          ),

          // === Info ===
          _AdminActionButton(
            icon: Icons.info_outline,
            label: "Info",
            color: colors.primary,
            onTap: () => controller.showOwnerInfo(context, project),
          ),

          // === Block User ===
          _AdminActionButton(
            icon: isOwnerBlocked
                ? Icons.person_add_alt_1
                : Icons.person_off_outlined,
            label: isOwnerBlocked ? "Unblock" : "Block Usr",
            color: isOwnerBlocked ? Colors.green : Colors.red,
            onTap: () {
              controller.toggleOwnerBlock(context, project);
            },
          ),
        ],
      ),
    );
  }
}

class _AdminActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

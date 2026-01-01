import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/controllers/admin/projects_manager_controller.dart';
import 'package:iep_app/mvc/controllers/project_page/project_controller.dart';
import 'package:iep_app/mvc/views/home_page/widgets/saved_projects_cards.dart';

class AdminProjectCard extends StatelessWidget {
  final ProjectModel project;
  final ProjectsManagerController controller;
  final ProjectsController projController;

  final bool isProjectFrozen;
  final bool isOwnerFrozen;

  const AdminProjectCard({
    super.key,
    required this.project,
    required this.controller,
    this.isProjectFrozen = false,
    this.isOwnerFrozen = false,
    required this.projController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;
    final borderclr = colors.button;

    double progress = (project.targetFunds > 0)
        ? (project.totalFunds! / project.targetFunds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isProjectFrozen ? colors.red.withOpacity(0.5) : borderclr,
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
              imageUrl: project.images.isNotEmpty ? project.images.first : '',
              showBookmarkIcon: false,
            ),

            // === owner information with chat button ===
            _buildOwnerSection(context, colors, controller),

            Divider(height: 1.5, color: borderclr),

            // === controls buuton ===
            _buildActionButtons(context, colors, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerSection(
    BuildContext context,
    AppColorScheme colors,
    ProjectsManagerController controller,
  ) {
    if (project.ownerId == null || project.ownerId!.isEmpty) {
      return const SizedBox();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(project.ownerId)
          .get(),
      builder: (context, snapshot) {
        String ownerName = "Loading...";
        String ownerImage = "";

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          ownerName =
              data['name'] ?? "${data['first_name']} ${data['last_name']}";
          ownerImage = data['avatar_url'] ?? "";
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: (ownerImage.isNotEmpty)
                    ? NetworkImage(ownerImage)
                    : null,
                backgroundColor: colors.primary.withOpacity(0.1),
                child: (ownerImage.isEmpty)
                    ? Icon(Icons.person, size: 16, color: colors.primary)
                    : null,
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  ownerName,
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
                    ownerName: ownerName,
                    ownerImage: ownerImage,
                  );
                },
                tooltip: 'Chat with Owner',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppColorScheme colors,
    ProjectsManagerController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // === project freez button ===
          _AdminActionButton(
            icon: isProjectFrozen ? Icons.lock_open : Icons.lock_outline,
            label: isProjectFrozen ? "Unfreeze" : "Freeze",
            color: isProjectFrozen ? Colors.green : Colors.orange,
            onTap: () {
              controller.toggleProjectFreeze(context, project, projController);
            },
          ),

          // === owner info button ===
          _AdminActionButton(
            icon: Icons.info_outline,
            label: "Info",
            color: colors.primary,
            onTap: () {
              controller.showOwnerInfo(context, project);
            },
          ),

          // === block user button ===
          _AdminActionButton(
            icon: isOwnerFrozen
                ? Icons.person_add_alt_1
                : Icons.person_off_outlined,
            label: isOwnerFrozen ? "Unblock" : "Block Usr",
            color: isOwnerFrozen ? Colors.green : Colors.red,
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

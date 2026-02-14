import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';
import 'package:iep_app/mvc/controllers/project_page/projects_datails_controllre.dart';
import 'package:iep_app/mvc/views/project_page/widgets/project_icon_button.dart';
import 'package:iep_app/core/widgets/app_input_dialog.dart';

class ProjectActionButtons extends StatelessWidget {
  final ProjectDetailsController controller;

  const ProjectActionButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // === Upvote button ===
        ProjectIconButton(
          icon: controller.isUpVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
          color: colors.secText,
          label: 'Upvote (${controller.upvoteCount})',
          onTap: () => controller.toggleUpvote(),
        ),

        // === Save button ====
        ProjectIconButton(
          icon: controller.isSaved ? Icons.bookmark : Icons.bookmark_border,
          color:  colors.secText,
          label: controller.isSaved ? 'Saved' : 'Save',
          onTap: () async {
            String msg = await controller.toggleSave();
            if (context.mounted) {
              AppSnackBarState.show(
                context,
                color: colors.secText,
                content: msg,
              );
            }
          },
        ),

        // === Report button ===
        ProjectIconButton(
          icon: Icons.flag_outlined,
          label: 'Report',
          color: colors.secText,
          onTap: () => AppInputDialog.show(
            context: context,
            title: "Report Project",
            subtitle: "Please describe the issue with this project:",
            hintText: "Reason for reporting...",
            actionText: "Submit Report",
            actionColor: AppColors.light.red,
            onSubmit: (reason) {
              controller.sendReport(context, reason);
            },
          ),
        ),
      ],
    );
  }
}

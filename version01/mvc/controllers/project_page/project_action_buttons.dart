import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/controllers/project_page/projects_datails_controllre.dart';
import 'package:iep_app/mvc/views/project_page/widgets/project_icon_button.dart';
import 'package:iep_app/core/widgets/app_input_dialog.dart';

class ProjectActionButtons extends StatelessWidget {
  final ProjectDetailsController controller;

  const ProjectActionButtons({super.key, required this.controller});

 void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AppInputDialog(
        title: "Report Project",
        subtitle: "Please describe the issue with this project:",
        hintText: "Reason for reporting...",
        actionText: "Submit Report",
        actionColor: AppColors.light.red,
        onSubmit: (reason) {

          controller.sendReport(context, reason);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // زر Upvote
        ProjectIconButton(
          icon: controller.isUpVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
          color: controller.isUpVoted ? colors.primary : colors.secText,
          label: 'Upvote (${controller.upvoteCount})', 
          onTap: () => controller.toggleUpvote(),
        ),

        // زر Save
        ProjectIconButton(
          icon: controller.isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: controller.isSaved ? colors.primary : colors.secText,
          label: controller.isSaved ? 'Saved' : 'Save',
          onTap: () async {
            String msg = await controller.toggleSave();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg)),
              );
            }
          },
        ),

        // زر Report
        ProjectIconButton(
          icon: Icons.flag_outlined,
          label: 'Report',
          color: colors.secText,
          onTap: () => _showReportDialog(context), 
        ),
      ],
    );
  }
}
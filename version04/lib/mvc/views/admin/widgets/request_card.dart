import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/views/project_page/projectsDetails_page.dart';

class AppRequestCard extends StatelessWidget {
  const AppRequestCard({
    super.key,
    required this.project,
    required this.onApprove,
    required this.onReject,
  });
  final ProjectModel project;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: project.images.isNotEmpty
                  ? Image.network(
                      project.images.first,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    ),
            ),
            title: Text(
              project.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: colors.secText),
            ),
            onTap: () {
              // === opening details before the acceptance ===
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectDetailsPage(project: project),
                ),
              );
            },
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text(
                    "Reject",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                child: TextButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, color: Colors.green),
                  label: const Text(
                    "Approve",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

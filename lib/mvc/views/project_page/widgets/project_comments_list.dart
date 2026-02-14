import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/project_page/projects_datails_controllre.dart';
import 'package:iep_app/mvc/models/user_model.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';

class ProjectCommentsList extends StatelessWidget {
  final String projectId;
  final ProjectDetailsController controller;

  const ProjectCommentsList({
    super.key,
    required this.projectId,
    required this.controller,
  });

  // === confirms comment delete ===

  Future<void> _confirmDelete(
    BuildContext context,
    String commentId,
    double rating, {
    String? commentOwner,
  }) async {
    bool? confirm = await showDialog(
      context: context,

      builder: (ctx) => AlertDialog(
        title: const Text("Delete Review"),

        content: const Text("Are you sure? This action cannot be undone."),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),

            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () => Navigator.pop(ctx, true),

            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.deleteComment(commentId, rating, commentOwner);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserProvider.instance;
    final String currentUserId = currentUser.currentUserId ?? '';
    final bool isAdmin = currentUser.currentUser?.role == UserRole.admin;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        return ListView.separated(
          // same as builder but with sperated item
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (c, i) => const Divider(), //the sperated item
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;

            double rating =
                double.tryParse(data['userRating']?.toString() ?? '0') ?? 0.0;

            // === is the user account aowner or admin ===
            String commentUserId = data['userId'] ?? '';
            bool canDelete = (commentUserId == currentUserId) || isAdmin;

            return _CommentTile(
              name: data['name'] ?? 'User',
              rating: rating,
              text: data['text'] ?? '',
              // === give the permisson, and delete function ===
              canDelete: canDelete,
              onDelete: () => _confirmDelete(context, doc.id, rating),
            );
          },
        );
      },
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String name;
  final double rating;
  final String text;
  final bool canDelete;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.name,
    required this.rating,
    required this.text,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: colors.primary.withOpacity(0.1),
        child: Icon(Icons.person, color: colors.primary),
      ),
      title: Row(
        children: [
          Text(name, style: AppTextStyles.size14weight5(colors.text)),
          const SizedBox(width: 8),
          // === Collection If & Spread Operator ===
          if (rating > 0) ...[
            //list because there more than one element, ... to transfer the list to element element
            Icon(Icons.star, size: 14, color: colors.orange),
            const SizedBox(width: 2),
            Text(
              rating.toStringAsFixed(1), // with one place after comma
              style: AppTextStyles.size12weight4(colors.text),
            ),
          ] else ...[
            Text(
              "• Investor",
              style: AppTextStyles.size12weight4(colors.secText),
            ),
          ],
        ],
      ),
      subtitle: Text(text, style: AppTextStyles.size13weight4(colors.text)),
      // === delete button ===
      trailing: canDelete
          ? IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: colors.secText),
              onPressed: onDelete,
              tooltip: "Delete Comment",
            )
          : null, // if he dont have permission to delete
    );
  }
}

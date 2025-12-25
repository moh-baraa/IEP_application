import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

class ProjectCommentsList extends StatelessWidget {
  final String projectId;

  const ProjectCommentsList({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
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

            return _CommentTile(
              name: data['name'] ?? 'User',
              rating: rating,
              text: data['text'] ?? '',
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

  const _CommentTile({
    required this.name,
    required this.rating,
    required this.text,
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
          if (rating > 0) ...[ //list because there more than one element, ... to transfer the list to element element
            Icon(Icons.star, size: 14, color: colors.orange),
            const SizedBox(width: 2),
            Text(
              rating.toStringAsFixed(1),// with one place after comma
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
    );
  }
}

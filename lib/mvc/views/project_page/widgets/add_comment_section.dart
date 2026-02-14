import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/project_page/projects_datails_controllre.dart';

class AddCommentSection extends StatelessWidget {
  final ProjectDetailsController controller;

  const AddCommentSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.secondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add your review",
            style: AppTextStyles.size14weight5(colors.text),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return InkWell(
                onTap: () => controller.updateUserRating(index + 1.0),
                child: Icon(
                  index < controller.userRating ? Icons.star : Icons.star_border,
                  color: colors.orange,
                  size: 30,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.commentController,
                  decoration: InputDecoration(
                    hintText: 'Write your opinion...',
                    filled: true,
                    fillColor: colors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: colors.primary,
                child: controller.isCommentLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: () {
                          controller.addComment();
                          FocusScope.of(context).unfocus();
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/repositories/user_repository.dart';
import 'package:intl/intl.dart';

class ReportCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String reportId;
  final VoidCallback onResolve;

  const ReportCard({
    super.key,
    required this.data,
    required this.reportId,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;
    final bool isUserReport = data['type'] == 'user_report';

    // === date format ===
    String dateStr = 'Just now';
    if (data['reportedAt'] != null) {
      DateTime date = (data['reportedAt'] as Timestamp).toDate();
      dateStr = DateFormat('MMM d, y • h:mm a').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        // adding bottom(for undisplayed content) a raduis
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ), // same the theme, but with transpernet border
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            childrenPadding: EdgeInsets.zero,

            // === top container - start icon ===
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUserReport
                    ? colors.orange.withOpacity(0.1)
                    : colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUserReport
                    ? Icons.person_off_outlined
                    : Icons.report_problem_outlined,
                color: isUserReport ? colors.orange : colors.red,
                size: 22,
              ),
            ),

            // === top container - title ===
            title: _buildTitleWidget(colors),

            // === top container - sub title(Date&time) ===
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                dateStr,
                style: TextStyle(fontSize: 11, color: colors.secText),
              ),
            ),

            // === undisplayed content ===
            children: [
              Container(
                width: double.infinity,
                color: colors.container,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "REPORT REASON",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // === user reason ===
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        data['reason'] ?? 'No detail provided.',
                        style: TextStyle(color: colors.text, height: 1.4),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // === the button to resolve ===
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text(
                          "Resolve & Notify Reporter",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: onResolve,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === title (user reported / project reported) ===
  Widget _buildTitleWidget(AppColorScheme colors) {
    final userRepo = UserRepository();
    if (data['type'] == 'user_report' && data['reportedUserId'] != null) {
      return FutureBuilder<String>(
        future: userRepo.getUserName(userId: data['reportedUserId']),
        builder: (context, snapshot) {
          String name = "Loading...";
          if (snapshot.connectionState == ConnectionState.waiting) {
            name = "Loading...";
          } else if (snapshot.hasError) {
            name = "Error loading name";
          } else if (snapshot.hasData) {
            name = snapshot.data!;
          }
          return Text(
            name,
            style: AppTextStyles.size16weight5(colors.text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      );
    } else {
      return Text(
        data['projectTitle'] ?? 'Unknown Project',
        style: AppTextStyles.size16weight5(colors.text),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}

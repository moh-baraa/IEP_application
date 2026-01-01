import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/admin/admin_reports_controller.dart';
import 'package:iep_app/mvc/views/admin/widgets/report_card.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AdminReportsController();
    final colors = AppColors.light;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reports', style: AppTextStyles.size18weight5(colors.text)),
        backgroundColor: colors.background,
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: colors.secText)),
      ),
      backgroundColor: colors.bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: controller.getReportsStream(),
          builder: (context, snapshot) {
            // === is loading phase ===
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // === no data phase ===
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return AppUnFoundPage(
                text: "No Pending Reports.",
                icon: Icons.check_circle_outline,
              );
            }
            // === acual data ===
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var report = snapshot.data!.docs[index];
                var data = report.data() as Map<String, dynamic>;

                return ReportCard(
                  data: data,
                  reportId: report.id,
                  onResolve: () {
                    // === open response/resolve dialog ===
                    controller.showResolveDialog(
                      context,
                      report.id,
                      data['reporterId'] ?? '', // for sending the notification
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/notification/notification_controller.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';
import 'package:intl/intl.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final NotificationController controller = NotificationController();
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: colors.secText)),
        title: Text(
          'Admin Alerts',
          style: AppTextStyles.size18weight5(colors.text),
        ),
        backgroundColor: colors.background,
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          // === read from admin notification ===
          stream: controller.getAdminNotifications(),
          builder: (context, snapshot) {
            // === is loading phase ===
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // === no data phase ===
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return AppUnFoundPage(
                text: "No notifications",
                icon: Icons.notifications_off_outlined,
              );
            }
            // === actual list ===
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;

                // === identify icon depending on notification type ===
                IconData icon = Icons.notifications;
                Color iconColor = colors.primary;
                if (data['type'] == 'report') {
                  icon = Icons.report_problem;
                  iconColor = colors.orange;
                } else if (data['type'] == 'user_report') {
                  icon = Icons.person_off;
                  iconColor = colors.red;
                }

                // === time format ===
                String timeStr = '';
                if (data['timestamp'] != null) {
                  timeStr = DateFormat(
                    'MMM d, h:mm a',
                  ).format((data['timestamp'] as Timestamp).toDate());
                }

                return Card(
                  color: data['isRead']
                      ? colors.background
                      : Colors.red.shade50,

                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: iconColor.withOpacity(0.1),
                      child: Icon(icon, color: iconColor),
                    ),
                    title: Text(
                      data['title'] ?? 'Notification',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(data['body'] ?? ''),
                        const SizedBox(height: 6),
                        Text(
                          timeStr,
                          style: TextStyle(fontSize: 11, color: colors.secText),
                        ),
                      ],
                    ),
                    // === if admin click on it, become it read ===
                    onTap: () {
                      if (data['isRead'] == false) {
                        controller.markAdminNotiAsRead(doc.id);
                      }
                    },
                    // === red circle if it's unread ===
                    trailing: (data['isRead'] == false)
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/notification/notification_controller.dart';
import 'package:iep_app/mvc/models/notification_model.dart';
import 'package:iep_app/mvc/views/layout/widgets/notification_tile.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';
import 'package:intl/intl.dart';

AppColorScheme colors = AppColors.light;

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final controller = NotificationController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: colors.secText)),
        title: Text(
          'Notifications',
          style: AppTextStyles.size18weight5(colors.text),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: controller.getUserNotifications(),
          builder: (context, snapshot) {
            // === error phase ===
            if (snapshot.hasError) {
              return AppUnFoundPage(
                icon: Icons.folder_open,
                text:
                    'Something went wrong '
                    "Error: ${snapshot.error}",
              );
            }

            // === is loading phase ===
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // === no data phase ===
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return AppUnFoundPage(
                text: "No notifications yet",
                icon: Icons.notifications_off_outlined,
              );
            }

            // === actual data phase ===
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;
                var notification = NotificationModel.fromMap(data, doc.id);

                String formattedTime = '';
                try {
                  DateTime date = notification.time.toDate();
                  final now = DateTime.now();
                  if (now.difference(date).inDays == 0) {
                    formattedTime = DateFormat.jm().format(date);
                  } else {
                    formattedTime = DateFormat.MMMd().format(date);
                  }
                } catch (e) {
                  formattedTime = 'Now';
                }

                return GestureDetector(
                  onTap: () {
                    controller.markUserNotiAsRead(notification.id!);
                  },
                  child: AppNotificationTile(
                    title: notification.title,
                    subtitle: notification.subtitle,
                    time: formattedTime,
                    unread: notification.unread,
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

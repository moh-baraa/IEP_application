import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/controllers/notification/notification_controller.dart';
import 'package:iep_app/mvc/views/layout/notification_page.dart';

AppColorScheme colors = AppColors.light;

class NotificationButton extends StatefulWidget {
  const NotificationButton({super.key});

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  final controller = NotificationController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );
          },
        ),
        // listen to the unRead notifications number
        StreamBuilder<QuerySnapshot>(
          stream: controller.getUnreadCount(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const SizedBox(); // show nothing(there nothing new)
            }

            int count = snapshot.data!.docs.length;

            return Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 9 ? '+9' : '$count',
                  style: TextStyle(
                    color: colors.background,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';

class AppMessageItem extends StatelessWidget {
  const AppMessageItem({
    super.key,
    required this.document,
    required this.maxWidth,
  });
  final DocumentSnapshot document;
  final double maxWidth;
  @override
  Widget build(BuildContext context) {
    final provider = UserProvider.instance;
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    Timestamp? timestamp = data['timestamp'] as Timestamp?;
    bool isMe = (data['senderId'] == provider.currentUserId!);
    final colors = AppColors.light;
    String formattedTime = '';
    if (timestamp != null) {
      // === 12 hour mode time ===
      formattedTime = TimeOfDay.fromDateTime(
        timestamp!.toDate(),
      ).format(context);
    }
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isMe ? colors.primary : Colors.grey.shade300,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe
                  ? const Radius.circular(16)
                  : const Radius.circular(4),
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // === the message text ===
              Text(
                data['message'],
                style: TextStyle(
                  color: isMe ? colors.background : colors.text,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              // === the message time ===
              Text(
                formattedTime,
                style: AppTextStyles.size10weight4(
                  isMe ? colors.background : colors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

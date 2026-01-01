import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/controllers/chat_page/chat_controller.dart';

class AppMessageTextInput extends StatelessWidget {
  const AppMessageTextInput({super.key, required this.controller, required this.receiverId});
  final TextEditingController controller;
  final String receiverId;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;
    final chatController = ChatController();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              minLines: 1,
              maxLines: 4,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: colors.primary),
            onPressed: () async => await chatController.sendMessage(
              receiverId,
              controller.text.trim(),
              controller,
            ),
          ),
        ],
      ),
    );
  }
}

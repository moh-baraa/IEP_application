import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/mvc/controllers/chat_page/chat_controller.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/views/chat_page/widgets/chat_room_item.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key});

  final ChatController _chatController = ChatController();

  @override
  Widget build(BuildContext context) {
    final provider = UserProvider.instance;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<QuerySnapshot>(
        // === get all the chat rooms ===
        stream: _chatController.getChatRooms(provider.currentUserId!),
        builder: (context, snapshot) {
          // === error phase ===
          if (snapshot.hasError) {
            return AppUnFoundPage(text: 'Something went wrong ');
          }
          // === is loading phase ===
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // === is empty phase ===
          if (snapshot.data!.docs.isEmpty) {
            return const AppUnFoundPage(text: "No chats yet");
          }
          // === data list ===
          final docs = snapshot.data!.docs;
          // === actual data ===
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return AppChatRoomItem(
                document: docs[index],
                context: context,
                provider: provider,
              );
            },
          );
        },
      ),
    );
  }
}

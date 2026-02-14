import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/mvc/controllers/chat_page/chat_controller.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/views/chat_page/widgets/chat_item.dart';

class AppChatRoomItem extends StatelessWidget {
  const AppChatRoomItem({
    super.key,
    required this.document,
    required this.context,
    required this.provider,
  });
  final DocumentSnapshot document;
  final BuildContext context;
  final UserProvider provider;

  @override
  Widget build(BuildContext context) {
    final chatController = ChatController();

    Map<String, dynamic> data =
        document.data()!
            as Map<String, dynamic>; // content chatRoom document data

    // === get user array ===
    List<dynamic> users = data['users'];
    String otherUserId = users.firstWhere(
      (id) => id != provider.currentUserId!,
      orElse: () => '', // more protection
    ); // second person id
    // === if the other user not exist ===
    if (otherUserId.isEmpty) return const SizedBox.shrink();
    String lastMessage = data['last_message'] ?? '';

    // === unread messages number ===
    int unreadCount = 0;
    if (data['unread_counts'] != null &&
        data['unread_counts'][provider.currentUserId!] != null) {
      unreadCount = data['unread_counts'][provider.currentUserId!];
    }

    return
    // === get the other person name and image ===
    StreamBuilder<DocumentSnapshot>(
      stream: chatController.getUserStream(otherUserId),
      builder: (context, userSnapshot) {
        // === if still connect to server ===
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        // === if there no data or user ===
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const SizedBox.shrink();
        }
        // === actual data ===
        var userData = userSnapshot.data!.data() as Map<String, dynamic>;

        String displayName =
            "${userData['first_name']} ${userData['last_name']}";

        String avatarUrl = userData['avatarUrl'] ?? '';

        Timestamp? timestamp = data['last_updated'] as Timestamp?;

        String formattedTime = '';

        if (timestamp != null) {
          DateTime date = timestamp.toDate();
          formattedTime = TimeOfDay.fromDateTime(
            date,
          ).format(context); // time like 8:45
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ChatListItem(
            name: displayName,
            avatarUrl: avatarUrl,
            subtitle: lastMessage, //
            time: formattedTime,
            unreadCount: unreadCount,
            onTap: () {
              chatController.onChatListTap(
                context,
                receiverId: otherUserId,
                displayName: displayName,
                avatarUrl: avatarUrl,
              );
            },
          ),
        );
      },
    );
  }
}

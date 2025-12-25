import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/mvc/controllers/chat_page/chat_controller.dart';
import 'package:iep_app/mvc/views/chat_page/chatDetails_page.dart';
import 'package:iep_app/mvc/views/chat_page/widgets/chat_item.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatController _chatController = ChatController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<QuerySnapshot>(
        // === get all the chat rooms ===
        stream: FirebaseFirestore.instance
            .collection('chat_rooms')
            .where(
              'users',
              arrayContains: _auth.currentUser!.uid, // personal room chats
            )
            .orderBy('last_updated', descending: true) // new first
            .snapshots(),
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
          // === actual data ===
          return ListView(
            children: snapshot.data!.docs.map<Widget>((doc) {
              return _buildChatRoomItem(doc, context);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildChatRoomItem(DocumentSnapshot document, BuildContext context) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // === get user array ===
    List<dynamic> users = data['users'];
    String otherUserId = users.firstWhere(
      (id) => id != _auth.currentUser!.uid,
    ); // second person id
    String lastMessage = data['last_message'] ?? '';

    // === unread messages number ===
    int unreadCount = 0;
    if (data['unread_counts'] != null &&
        data['unread_counts'][_auth.currentUser!.uid] != null) {
      unreadCount = data['unread_counts'][_auth.currentUser!.uid];
    }

    // === get the other person name and image ===
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        var userData = userSnapshot.data!.data() as Map<String, dynamic>;

        String displayName =
            userData['name'] ??
            "${userData['first_name']} ${userData['last_name']}";
        String avatarUrl = userData['avatarUrl'] ?? '';
        Timestamp? timestamp = data['last_updated'] as Timestamp?;
        String formattedTime = '';
        if (timestamp != null) {
          DateTime date = timestamp.toDate();
          formattedTime = TimeOfDay.fromDateTime(date).format(context);
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
              _chatController.markMessageAsRead(otherUserId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailsPage(
                    chatName: displayName,
                    avatarUrl: avatarUrl,
                    receiverId: otherUserId,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

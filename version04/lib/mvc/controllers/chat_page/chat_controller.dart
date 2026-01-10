import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/services/notification_service.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';
import 'package:iep_app/mvc/repositories/project_details.repositories.dart';
import 'package:iep_app/mvc/views/chat_page/chatDetails_page.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // === sending a message ===
  Future<void> sendMessage(
    String receiverId,
    String? message,
    TextEditingController controller,
  ) async {
    if (message == null || message.trim().isEmpty) return;
    controller.clear();
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email ?? "User";
    final Timestamp timestamp = Timestamp.now();

    Map<String, dynamic> newMessage = {
      'senderId': currentUserId,
      'senderEmail': currentUserEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'isRead': false,
    };

    // === creating chat room id ===
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage);

    // === sending the notification ===
    await NotificationService.sendNotification(
      receiverId: receiverId,
      title: "New Message",
      body: "You have a new message from $currentUserEmail",
    );

    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'users': ids,
      'last_message': message,
      'last_updated': timestamp,
      'unread_counts': {receiverId: FieldValue.increment(1)},
    }, SetOptions(merge: true));
  }

  Future<void> onChatListTap(
    context, {
    required String receiverId,
    required String displayName,
    required String avatarUrl,
  }) async {
    final String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    try {
      await _firestore.collection('chat_rooms').doc(chatRoomId).update({
        'unread_counts.$currentUserId': 0,
      });
    } catch (e) {
      print("Error marking as read: $e");
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          chatName: displayName,
          avatarUrl: avatarUrl,
          receiverId: receiverId,
        ),
      ),
    );
  }

  Stream<DocumentSnapshot> getUserStream(String userId) {
  return _firestore.collection('users').doc(userId).snapshots();
}

  // === get all user chatrooms ===
  Stream<QuerySnapshot> getChatRooms(String userId) {
    return _firestore
        .collection('chat_rooms')
        .where(
          'users',
          arrayContains: userId, // personal room chats
        )
        .orderBy('last_updated', descending: true) // newest msg first
        .snapshots();
  }

  Future<void> onReportTap(
    BuildContext context, {
    required String reason,
    required String receiverId,
  }) async {
    if (reason.trim().isEmpty) return;

    try {
      final repo = ProjectDetailsRepository();

      await repo.submitUserReport(
        reportedUserId: receiverId,
        reporterId: _auth.currentUser!.uid,
        reason: reason,
      );

      if (context.mounted) {
        AppSnackBarState.show(
          context,
          color: colors.green,
          content: 'User reported successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBarState.show(context, color: colors.red, content: 'Error: $e');
      }
    }
  }

  // === get the messages ===
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

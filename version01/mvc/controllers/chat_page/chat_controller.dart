import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iep_app/core/services/notification_service.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // === sending a message ===
  Future<void> sendMessage(String receiverId, String message) async {
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
      'unread_counts': {
        receiverId: FieldValue.increment(
          1,
        ),
      },
    }, SetOptions(merge: true));
  }

  Future<void> markMessageAsRead(String receiverId) async {
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

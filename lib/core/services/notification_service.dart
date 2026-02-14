import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iep_app/mvc/models/notification_model.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // === used to send a notification ===
  static Future<void> sendNotification({
    required String receiverId,
    required String title,
    required String body,
  }) async {
    try {
      final newNotification = NotificationModel(
        title: title,
        subtitle: body,
        time: Timestamp.now(),
        receiverId: receiverId,
        unread: true,
      );

      await _firestore.collection('notifications').add(newNotification.toMap());
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  static Future<void> sendAdminNotification({
    required String relatedId,
    required String title,
    required String body,
    required String type,
    String relatedIdKey = 'relatedId',
  }) async {
    try {
      final newNotification = NotificationModel.admin(
        title: title,
        body: body,
        timestamp: Timestamp.now(),
        relatedId: relatedId,
        isRead: false,
        type: type,
      );

      await _firestore
          .collection('admin_notifications')
          .add(newNotification.adminToMap(relatedIdKey: relatedIdKey));
    } catch (e) {
      print("Error sending admin notification: $e");
    }
  }

  // === to get user notification ===
  static Stream<QuerySnapshot> getUserNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: uid)
        .orderBy('time', descending: true)
        .snapshots();
  }

  // === to get admin notification ===
  static Stream<QuerySnapshot> getAdminNotifications() {
    return _firestore
        .collection('admin_notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // === to calc unread messages ===
  static Stream<QuerySnapshot> getUnreadCount() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: uid)
        .where('unread', isEqualTo: true)
        .snapshots();
  }

  // === to calc unread messages ===
  static Stream<QuerySnapshot> getAdminUnreadCount() {
    return FirebaseFirestore.instance
        .collection('admin_notifications')
        .where('isRead', isEqualTo: false) // only unread notifications
        .snapshots();
  }

  // === update to become read ===
  static Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'unread': false,
    });
  }

  // === update to become read ===
  static Future<void> markItAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('admin_notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}

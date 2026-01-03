import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iep_app/core/services/notification_service.dart';

class NotificationController {
  // ==================== admin notification section ====================
  Future<void> markAdminNotiAsRead(String docId) {
    return NotificationService.markItAsRead(docId);
  }

  Stream<QuerySnapshot> getAdminNotifications() {
    return NotificationService.getAdminNotifications();
  }

  Stream<QuerySnapshot> getAdminUnreadCount() {
    return NotificationService.getAdminUnreadCount();
  }

  // ==================== user notification section ====================

  Stream<QuerySnapshot> getUserNotifications() {
    return NotificationService.getUserNotifications();
  }

  Future<void> markUserNotiAsRead(String docId) {
    return NotificationService.markAsRead(docId);
  }

  Stream<QuerySnapshot> getUnreadCount() {
    return NotificationService.getUnreadCount();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? id;
  final String title;
  final String subtitle;
  final Timestamp time;
  final bool unread;
  final String receiverId;
  final String? type;

  NotificationModel({
    this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    this.unread = true,
    required this.receiverId,
    this.type,
  });

  NotificationModel.admin({
    this.id,
    required this.title,
    required String body,
    required Timestamp timestamp,
    bool isRead = false,
    this.type,
    required String relatedId,
  }) : receiverId = relatedId,
      subtitle = body,
      time = timestamp,
      unread = !isRead;

  factory NotificationModel.adminFromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return NotificationModel.admin(
      id: docId,
      title: map['title'],
      body: map['body'],
      timestamp: map['timestamp'],
      relatedId: map['relatedId'],
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'Unkown',
    );
  }

  Map<String, dynamic> adminToMap({String relatedIdKey = 'relatedId'}) {
    return {
      'title': title,
      'body': subtitle,
      'timestamp': time,
      'isRead': !unread,
      relatedIdKey: receiverId, // to be more specifi about what id is this
      'type': type,
    };
  }

  // === transfer the data into objects ===
  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      time: map['time'] ?? Timestamp.now(),
      unread: map['unread'] ?? true,
      receiverId: map['receiverId'] ?? '',
    );
  }

  // === transfer from objects to map ===
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'unread': unread,
      'receiverId': receiverId,
    };
  }
}

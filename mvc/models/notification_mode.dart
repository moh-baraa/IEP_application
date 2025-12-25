import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? id;
  final String title;
  final String subtitle;
  final Timestamp time; 
  final bool unread;
  final String receiverId; 

  NotificationModel({
    this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    this.unread = true,
    required this.receiverId,
  });

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
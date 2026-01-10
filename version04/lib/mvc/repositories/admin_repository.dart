import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iep_app/core/services/notification_service.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === get all the user ===
  Future<List<QueryDocumentSnapshot>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs;
  }

  // === block & unblock the user ===
  Future<void> toggleUserBlockState(String uid, bool currentStatus) async {
    await _firestore.collection('users').doc(uid).update({
      'isBlocked': !currentStatus,
    });
  }

  // === resolve the reports & send notifications to user ===
  Future<void> resolveReport({
    required String reportId,
    required String reporterId,
    required String replyMessage,
  }) async {
    // === delete the report from the firestore ===
    await _firestore.collection('reports').doc(reportId).delete();

    // === send a notification ===
    await NotificationService.sendNotification(
      receiverId: reporterId,
      title: 'Report Update',
      body: replyMessage,
    );
  }

  // === get un accepted projects(project requests) ===
  Stream<QuerySnapshot> getProjectRequestsStream() {
    return _firestore
        .collection('projects')
        .where(
          'isApproved',
          isEqualTo: false,
        ) // === main condition-> un accepted yet ===
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  // === accept an project & notify the user ===
  Future<void> approveProject({
    required String projectId,
    required String ownerId,
    required String projectTitle,
  }) async {
    // === update the project state ===
    await _firestore.collection('projects').doc(projectId).update({
      'isApproved': true,
    });

    // === send a notification ===
    await NotificationService.sendNotification(
      receiverId: ownerId,
      title: "Project Approved.",
      body:
          "Congratulations! Your project '$projectTitle' has been approved and is now live.",
    );
  }

    // === get the reports ===
  Stream<QuerySnapshot> getReportsStream() {
    return FirebaseFirestore.instance
        .collection('reports')
        .orderBy('reportedAt', descending: true)
        .snapshots();
  }

  // === reject the project and inform the user ===
  Future<void> rejectProject({
    required String projectId,
    required String ownerId,
    required String projectTitle,
  }) async {
    // === notify the user ===
    await NotificationService.sendNotification(
      receiverId: ownerId,
      title: "Project Rejected.",
      body: "Unfortunately, your project '$projectTitle' has been rejected.",
    );

    // === delete the project from the database ===
    await _firestore.collection('projects').doc(projectId).delete();
  }

  // === get all the projects for the admin ===
  Future<List<QueryDocumentSnapshot>> getAllProjects() async {
    final snapshot = await _firestore
        .collection('projects')
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs;
  }
}

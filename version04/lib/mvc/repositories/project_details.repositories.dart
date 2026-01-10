import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectDetailsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === add comment & update the project rating ===
  Future<void> addComment(
    String projectId,
    Map<String, dynamic> commentData,
  ) async {
    commentData['timestamp'] = FieldValue.serverTimestamp();
    _firestore
        .collection('projects')
        .doc(projectId)
        .collection('comments')
        .add(commentData);
  }

  // === update the rating ===
  Future<void> updateRating(
    String projectId,
    double newRating,
    int newCount,
  ) async {
    await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .update({'rating': newRating, 'reviews_count': newCount});
  }

  // === delete comment ===
  Future<void> deleteComment(String projectId, String commentId) async {
    await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  // === update the upvote ===
  Future<void> updateUpvote(String projectId, int value) async {
    await _firestore.collection('projects').doc(projectId).update({
      'up_votes': FieldValue.increment(value),
    });
  }

  Future<DocumentSnapshot> getUserData(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  // === check if the user upvoted before ===
  Future<bool> hasUserUpvoted(String projectId, String userId) async {
    final doc = await _firestore.collection('projects').doc(projectId).get();
    if (!doc.exists) return false;
    List upvoters = doc.data()?['upvoters'] ?? [];
    return upvoters.contains(userId);
  }

  // === cancel/ add the upvote ===
  Future<void> toggleUpvote(
    String projectId,
    String userId,
    bool shouldUpvote,
  ) async {
    if (shouldUpvote) {
      // === add the user to the array and increase the number ===
      await _firestore.collection('projects').doc(projectId).update({
        'upvoters': FieldValue.arrayUnion([userId]),
        'up_votes': FieldValue.increment(1),
      });
    } else {
      // === remove the user from the array and decrease the number ===
      await _firestore.collection('projects').doc(projectId).update({
        'upvoters': FieldValue.arrayRemove([userId]),
        'up_votes': FieldValue.increment(-1),
      });
    }
  }

  // === Save project ===
  Future<void> saveProject(
    String userId,
    String projectId,
    Map<String, dynamic> projectData,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_projects')
        .doc(projectId)
        .set(projectData);
  }

  // === remove project from saved list ===
  Future<void> removeSavedProject(String userId, String projectId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_projects')
        .doc(projectId)
        .delete();
  }

  // === check if the user saved the project before ===
  Future<bool> isProjectSaved(String userId, String projectId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_projects')
        .doc(projectId)
        .get();
    return doc.exists;
  }

  // === delete a project ===
  Future<void> deleteProject(String projectId) async {
    await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .delete();
  }

  // === add report to the project ===
  Future<void> submitReport({
    required String projectId,
    required String projectTitle,
    required String reporterId,
    required String reason,
  }) async {
    // === add the report to the firestore ===
    await _firestore.collection('reports').add({
      'projectId': projectId,
      'projectTitle': projectTitle,
      'reporterId': reporterId,
      'reason': reason,
      'reportedAt': FieldValue.serverTimestamp(),
      'status': 'pending', // report state
    });

    // === send notification to the admin ===
    await _firestore.collection('admin_notifications').add({
      'title': 'New Project Report',
      'body': 'User reported project: $projectTitle',
      'type': 'report',
      'relatedId': projectId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  // === add report to a user ===
  Future<void> submitUserReport({
    required String reportedUserId,
    required String reporterId,
    required String reason,
  }) async {
    // === add the report to the firestore ===
    await _firestore.collection('reports').add({
      'type': 'user_report',
      'reportedUserId': reportedUserId,
      'reporterId': reporterId,
      'reason': reason,
      'reportedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });

    // === send notification to the admin ===
    await _firestore.collection('admin_notifications').add({
      'title': 'New User Report',
      'body': 'A user has been reported for: $reason',
      'type': 'user_report',
      'relatedId': reportedUserId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  // === update project date(edit page) ===
  Future<void> updateProjectData(
    String projectId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('projects').doc(projectId).update(data);
  }

  // === listen to the live updates on the project ===
  Stream<DocumentSnapshot> getProjectStream(String projectId) {
    return _firestore.collection('projects').doc(projectId).snapshots();
  }
}

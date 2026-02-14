import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iep_app/mvc/models/project_model.dart';

class SavedProjectsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // === get user saved projects ===
  Future<List<ProjectModel>> getSavedProjects() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    try {
      // === get projects id, sorted by save time ===
      final savedSnaps = await _firestore
          .collection('users')
          .doc(uid)
          .collection('saved_projects')
          .get();

      if (savedSnaps.docs.isEmpty) return [];

      // === using the id's, get the actual projects ===
      final fetchFutures = savedSnaps.docs.map((doc) {
        String projectId = doc.id;
        return _firestore.collection('projects').doc(projectId).get();
      }).toList();

      // === waiting for all the projects ===
      final projectSnapshots = await Future.wait(fetchFutures);

      List<ProjectModel> liveProjects = [];

      // === transfer the data into projects ===
      for (var snapshot in projectSnapshots) {
        // === ensure the project didn't deleted yet ===
        if (snapshot.exists && snapshot.data() != null) {
          ProjectModel project = ProjectModel.fromMap(
            snapshot.data() as Map<String, dynamic>,
            snapshot.id,
          );

          // === ensure the project is not frozen or unapproved ===
          if (project.isApproved && !project.isFrozen) {
            liveProjects.add(project);
          }
        }
      }

      return liveProjects;
    } catch (e) {
      print("Error fetching saved projects: $e");
      return [];
    }
  }

  Future<void> deleteSavedProject({required String projectId}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_projects')
        .doc(projectId)
        .delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/repositories/saved_projects_repository.dart';
import 'package:iep_app/mvc/views/project_page/projectsDetails_page.dart';

class SavedProjectsController extends ChangeNotifier {
  final SavedProjectsRepository _repository = SavedProjectsRepository();

  bool isLoading = true;
  List<ProjectModel> savedProjects = [];

  bool _isDisposed = false;

  SavedProjectsController() {
    fetchSavedProjects();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> fetchSavedProjects() async {
    isLoading = true;
    notifyListeners();

    try {
      savedProjects = await _repository.getSavedProjects();
    } catch (e) {
      debugPrint("Error in controller: $e");
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void onProjectTap(BuildContext context, ProjectModel project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsPage(project: project),
      ),
    );
    // === updating the list, if the user delete an element ===
    fetchSavedProjects();
  }

  void removeProjectLocally(String projectId) {
    savedProjects.removeWhere((p) => p.id == projectId);
    if (!_isDisposed) notifyListeners(); 
  }

  Future<void> removeProject(String projectId) async {
    savedProjects.removeWhere((p) => p.id == projectId);
    if (!_isDisposed) notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('saved_projects')
            .doc(projectId)
            .delete();
      }
    } catch (e) {
      print("Error deleting project: $e");
      if (!_isDisposed) {
        fetchSavedProjects();
      }
    }
  }

  void onSavedProjectTab(BuildContext context, {project}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsPage(project: project),
      ),
    ).then((_) {
      fetchSavedProjects();
    });
  }
}

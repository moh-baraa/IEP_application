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

  Future<void> removeProject(String projectId) async {
    savedProjects.removeWhere((p) => p.id == projectId);
    if (!_isDisposed) notifyListeners();

    try {
     await _repository.deleteSavedProject(projectId: projectId);
    } catch (e) {
      print("Error deleting project: $e");
      if (!_isDisposed) {
        fetchSavedProjects();
      }
    }
  }

  void onCardTap(BuildContext context, {project}) {
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

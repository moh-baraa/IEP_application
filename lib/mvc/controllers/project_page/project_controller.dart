import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/repositories/project_repository.dart';
import 'package:iep_app/mvc/views/project_page/projectsDetails_page.dart';

class ProjectsController extends ChangeNotifier {
  final ProjectsRepository _repository = ProjectsRepository();

  bool isLoading = false;
  List<ProjectModel> allProjects = [];
  List<ProjectModel> displayedProjects = [];
  String? errorMessage;
  String selectedFilter = 'All';

  // === for storing current search text ===
  String _currentSearchQuery = '';

  StreamSubscription? _projectsSubscription;

  bool _isDisposed = false;

  void fetchProjects(String category, {bool includeFrozen = false}) {
    if (_isDisposed) return;

    isLoading = true;
    selectedFilter = category;
    errorMessage = null;
    notifyListeners();

    _projectsSubscription?.cancel();

    _projectsSubscription = _repository
        .getProjectsStream(category, includeFrozen: includeFrozen)
        .listen(
          (projects) {
            if (_isDisposed) return;

            allProjects = projects;

            if (_currentSearchQuery.isNotEmpty) {
              filterProjects(
                _currentSearchQuery,
              ); 
            } else {
              displayedProjects = List.from(allProjects);
              isLoading = false;
              notifyListeners();
            }
          },
          onError: (error) {
            if (_isDisposed) return; 
            errorMessage = error.toString();
            isLoading = false;
            notifyListeners();
          },
        );
  }

  void filterProjects(String query) {
    if (_isDisposed) return;

    _currentSearchQuery = query;

    if (query.isEmpty) {
      displayedProjects = List.from(allProjects);
    } else {
      displayedProjects = allProjects
          .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAndNavigateToProject(
    BuildContext context,
    String projectId,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    ProjectModel? project = await _repository.getProjectById(projectId);
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }


    if (context.mounted) {
      if (project != null) {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsPage(project: project),
          ),
        );
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Project not found or has been deleted"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _projectsSubscription?.cancel();
    super.dispose();
  }
}

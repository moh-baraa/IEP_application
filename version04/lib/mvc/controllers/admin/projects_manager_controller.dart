import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/controllers/project_page/project_controller.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/repositories/admin_repository.dart';
import 'package:iep_app/mvc/repositories/project_repository.dart';
import 'package:iep_app/mvc/views/chat_page/chatDetails_page.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';

class ProjectsManagerController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final repository = AdminRepository();
  final projRepository = ProjectsRepository();
  final String currentUserId = UserProvider.instance.currentUserId ?? '';

  List<ProjectModel> allProjects = [];
  List<ProjectModel> displayedProjects = [];
  bool isLoading = false;


  StreamSubscription<List<ProjectModel>>? _projectsSubscription;

  void fetchProjects() {
    isLoading = true;
    notifyListeners();

    _projectsSubscription?.cancel();

    _projectsSubscription = projRepository
        .getProjectsStream('All', includeFrozen: true)
        .listen(
          (projectsData) {
          
            allProjects = projectsData;
            displayedProjects = List.from(allProjects);

            isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            debugPrint("Error fetching projects: $e");
            isLoading = false;
            notifyListeners();
          },
        );
  }

  void filterProjects(String query) {
    if (query.isEmpty) {
      displayedProjects = List.from(allProjects);
    } else {
      displayedProjects = allProjects
          .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // === contact with the project owner ===
  void contactOwner(
    BuildContext context, {
    required ProjectModel project,
    required String ownerName,
    required String ownerImage,
  }) {
    if (project.ownerId == currentUserId) {
      AppSnackBarState.show(
        context,
        color: AppColors.light.red,
        content: "You cannot chat with yourself!",
      );
      return;
    }

    if (project.ownerId == null || project.ownerId!.isEmpty) {
      AppSnackBarState.show(
        context,
        color: AppColors.light.red,
        content: "Owner information is missing.",
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          chatName: ownerName,
          avatarUrl: ownerImage,
          receiverId: project.ownerId!,
        ),
      ),
    );
  }

  // === froze & unfroze the projects ===
  Future<void> toggleProjectFreeze(
    BuildContext context,
    ProjectModel project,
    ProjectsController projectsDataController,
  ) async {
    bool newStatus = !project.isFrozen;

    try {
      await _firestore.collection('projects').doc(project.id).update({
        'isFrozen': newStatus,
      });

      final index = projectsDataController.displayedProjects.indexWhere(
        (p) => p.id == project.id,
      );

      if (index != -1) {
        projectsDataController.displayedProjects[index] = project.copyWith(
          isFrozen: newStatus,
        );

        final allIndex = projectsDataController.allProjects.indexWhere(
          (p) => p.id == project.id,
        );
        if (allIndex != -1) {
          projectsDataController.allProjects[allIndex] = project.copyWith(
            isFrozen: newStatus,
          );
        }

        projectsDataController.notifyListeners();
      }

      if (context.mounted) {
        AppSnackBarState.show(
          context,
          color: newStatus ? AppColors.light.red : AppColors.light.green,
          content: newStatus ? "Project Frozen" : "Project Unfrozen",
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBarState.show(
          context,
          color: AppColors.light.red,
          content: "Error: $e",
        );
      }
    }
  }

  void showOwnerInfo(BuildContext context, ProjectModel project) async {
    if (project.ownerId == null) return;

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(project.ownerId)
          .get();

      if (userDoc.exists && context.mounted) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        String name =
            data['name'] ?? "${data['first_name']} ${data['last_name']}";
        String email = data['email'] ?? "No Email";
        String phone = data['mobile_num'] ?? "No Phone";

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Owner Info"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: $name"),
                const SizedBox(height: 8),
                Text("Email: $email"),
                const SizedBox(height: 8),
                Text("Phone: $phone"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBarState.show(
          context,
          color: AppColors.light.red,
          content: "Error fetching user info",
        );
      }
    }
  }

  // === block & unblock the user ===
  Future<void> toggleOwnerBlock(
    BuildContext context,
    ProjectModel project,
  ) async {
    if (project.ownerId == null) return;

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(project.ownerId)
          .get();

      bool isBlocked = false;
      if (userDoc.data() != null &&
          (userDoc.data() as Map).containsKey('isBlocked')) {
        isBlocked = userDoc.get('isBlocked') ?? false;
      }

      await _firestore.collection('users').doc(project.ownerId).update({
        'isBlocked': !isBlocked,
      });
      notifyListeners();
      if (context.mounted) {
        AppSnackBarState.show(
          context,
          color: isBlocked ? AppColors.light.green : AppColors.light.red,
          content: isBlocked ? "Owner Unblocked" : "Owner Blocked Successfully",
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBarState.show(
          context,
          color: AppColors.light.red,
          content: "Error updating owner status: $e",
        );
      }
    }
  }

  // === get user data ===
  Stream<DocumentSnapshot> getUserInfo({required String userId}) {
    try {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots();
    } catch (e) {
      rethrow;
    }
  }

  // ==================== project requests section ====================

  Stream<QuerySnapshot> getProjectRequestsStream() {
    return repository.getProjectRequestsStream();
  }

  Future<void> approveProject({
    required String projectId,
    required String ownerId,
    required String projectTitle,
  }) {
    return repository.approveProject(
      projectId: projectId,
      ownerId: ownerId,
      projectTitle: projectTitle,
    );
  }

  Future<void> rejectProject({
    required String projectId,
    required String ownerId,
    required String projectTitle,
  }) {
    return repository.rejectProject(
      projectId: projectId,
      ownerId: ownerId,
      projectTitle: projectTitle,
    );
  }
}

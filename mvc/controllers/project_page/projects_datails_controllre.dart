import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/services/notification_service.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/repositories/project_details.repositories.dart';
import 'package:iep_app/mvc/views/chat_page/chatDetails_page.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';

class ProjectDetailsController extends ChangeNotifier {
  final ProjectDetailsRepository _repository = ProjectDetailsRepository();

  final ProjectModel project;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  final TextEditingController commentController = TextEditingController();


  int upvoteCount = 0; 
  bool isUpVoted = false; 

  double liveTotalFunds = 0.0;
  int liveInvestorsCount = 0;
  StreamSubscription<DocumentSnapshot>? _projectSubscription;

  double currentRating = 0.0;
  double userRating = 0.0;
  bool isSaved = false;
  bool isCommentLoading = false;

  String ownerName = 'Loading...';
  String ownerImage = '';
  bool isOwnerLoading = true;

  ProjectDetailsController({required this.project}) {
    currentRating = project.rating ?? 0.0;

    upvoteCount = project.upVote ?? 0;

    liveTotalFunds = project.totalFunds;
    liveInvestorsCount = project.investors_count ?? 0;

    _checkIfSaved();
    _checkIfUpvoted();
    _fetchOwnerDetails();

    _listenToProjectUpdates();
  }

  void _listenToProjectUpdates() {
    _projectSubscription = _repository.getProjectStream(project.id!).listen((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        liveTotalFunds = (data['total_raised'] ?? 0).toDouble();
        liveInvestorsCount = (data['investors_count'] ?? 0);

        notifyListeners(); // 🔔 تحديث الواجهة
      }
    });

    _checkIfSaved();
    _checkIfUpvoted();
    _fetchOwnerDetails();
  }

  Future<void> _checkIfUpvoted() async {
    try {

      bool status = await _repository.hasUserUpvoted(project.id!, userId);
      isUpVoted = status;
      notifyListeners();
    } catch (e) {
      debugPrint("Error checking upvote: $e");
    }
  }

  Future<void> toggleUpvote() async {

    isUpVoted = !isUpVoted;
    if (isUpVoted) {
      upvoteCount++;
    } else {
      upvoteCount--;
    }
    notifyListeners();

    try {
      await _repository.toggleUpvote(project.id!, userId, isUpVoted);
    } catch (e) {
      isUpVoted = !isUpVoted;
      if (isUpVoted)
        upvoteCount++;
      else
        upvoteCount--;
      notifyListeners();
      debugPrint('Upvote Error: $e');
    }
  }

  
  Future<void> _checkIfSaved() async {
    try {
      isSaved = await _repository.isProjectSaved(userId, project.id!);
      notifyListeners();
    } catch (e) {
      debugPrint("Error checking saved status: $e");
    }
  }

  Future<String> toggleSave() async {
    isSaved = !isSaved;
    notifyListeners();

    try {
      if (isSaved) {
        await _repository.saveProject(userId, project.id!, project.toMap());
        return 'Project Saved';
      } else {
        await _repository.removeSavedProject(userId, project.id!);
        return 'Removed from saved list';
      }
    } catch (e) {
      isSaved = !isSaved; 
      notifyListeners();
      return 'Error saving project';
    }
  }

  Future<void> sendReport(BuildContext context, String reason) async {
    if (reason.trim().isEmpty) return;

    Navigator.pop(context);

    try {
      await _repository.submitReport(
        projectId: project.id!,
        projectTitle: project.title,
        reporterId: userId,
        reason: reason,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
      }
    } catch (e) {
      debugPrint("Report Error: $e");
    }
  }

  Future<void> _fetchOwnerDetails() async {
    if (project.ownerId == null || project.ownerId!.isEmpty) {
      ownerName = 'Unknown Owner';
      isOwnerLoading = false;
      notifyListeners();
      return;
    }

    try {
      DocumentSnapshot userDoc = await _repository.getUserData(
        project.ownerId!,
      );
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        if (data.containsKey('name')) {
          ownerName = data['name'];
        } else {
          ownerName = "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}";
        }

        ownerImage =
            data['avatar_url'] ?? '';
      }
    } catch (e) {
      debugPrint("Error fetching owner details: $e");
      ownerName = 'Project Owner';
    } finally {
      isOwnerLoading = false;
      notifyListeners();
    }
  }

  
  void contactOwner(BuildContext context) {
    if (project.ownerId == userId) {
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

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }


  void updateUserRating(double rating) {
    userRating = rating;
    notifyListeners();
  }

  Future<void> addComment() async {
    if (commentController.text.trim().isEmpty) return;

    isCommentLoading = true;
    notifyListeners();

    try {

      await _repository.addComment(project.id!, {
        'name': 'Current User',
        'job': 'Investor',
        'text': commentController.text.trim(),
        'userRating': userRating,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
      });

  
      if (userRating > 0) {
        int oldReviewCount = project.numOfReviews ?? 0;
        double oldRating = project.rating ?? 0.0;

        project.numOfReviews = oldReviewCount + 1;
        project.rating =
            ((oldRating * oldReviewCount) + userRating) / (oldReviewCount + 1);

        currentRating = project.rating!;
      }

      commentController.clear();
      userRating = 0.0;

      await NotificationService.sendNotification(
        receiverId: project.ownerId!,
        title: "New Comment",
        body: "Someone commented on your project: ${project.title}",
      );
    } catch (e) {
      debugPrint("Error adding comment: $e");
    } finally {
      isCommentLoading = false;
      notifyListeners();
    }
  }

  Future<void> rateProject(int stars) async {
    currentRating = stars.toDouble();
    notifyListeners();

    try {
      await _repository.updateRating(project.id!, stars);
    } catch (e) {
      debugPrint("Error updating rating: $e");
    }
  }

  Future<void> sendUserReport(BuildContext context, String reason) async {
    if (reason.trim().isEmpty) return;

    Navigator.pop(context); 

    if (project.ownerId == userId) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You cannot report yourself!'),
            backgroundColor: AppColors.light.red,
          ),
        );
      }
      return;
    }

    try {
      await _repository.submitUserReport(
        reportedUserId: project.ownerId!, 
        reporterId: userId,
        reason: reason,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User reported successfully')),
        );
      }
    } catch (e) {
      debugPrint("User Report Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to send report')));
      }
    }
  }

  Future<void> deleteProject(BuildContext context) async {
    try {

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(project.id)
          .delete();


      if (context.mounted) {
        AppSnackBarState.show(
          context,
          color: colors.green,
          content: 'Project deleted successfully',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBarState.show(
          context,
          content: 'Failed to delete project: $e',
          color: colors.red,
        );
      }
    }
  }
}

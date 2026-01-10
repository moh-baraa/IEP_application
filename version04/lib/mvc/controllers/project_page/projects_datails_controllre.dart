import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/services/notification_service.dart';
import 'package:iep_app/mvc/models/comment_model.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/models/user_model.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/repositories/project_details.repositories.dart';
import 'package:iep_app/mvc/views/chat_page/chatDetails_page.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';

class ProjectDetailsController extends ChangeNotifier {
  final ProjectDetailsRepository _repository = ProjectDetailsRepository();
  final ProjectModel project;
  final String userId = UserProvider.instance.currentUserId!;
  final String userProviderName = UserProvider.instance.fullName;

  final TextEditingController commentController = TextEditingController();

  int upvoteCount = 0;
  bool isUpVoted = false;

  double liveTotalFunds = 0.0;
  int liveInvestorsCount = 0;
  // ignore: unused_field
  StreamSubscription<DocumentSnapshot>? _projectSubscription;

  double currentRating = 0.0;
  double userRating = 0.0;
  bool isSaved = false;
  bool isCommentLoading = false;

  String ownerName = 'Loading...';
  String ownerImage = '';
  bool isOwnerLoading = true;
  int numOfReviews = 0;

  ProjectDetailsController({required this.project}) {
    // === fast initillizing for data from the project ===
    currentRating = project.rating;
    upvoteCount = project.upVote;
    liveTotalFunds = project.totalFunds;
    liveInvestorsCount = project.investors_count;
    numOfReviews = project.numOfReviews;

    // === get now data + check user interact + get owner info ===
    _initData();
  }

  void _initData() {
    // === start live stream about transaction and investors ===
    _startProjectStream();

    // === get rest of the data ===
    // === Future.wait - help with excute more than one async method in same time ===
    Future.wait([_checkIfSaved(), _checkIfUpvoted(), _fetchOwnerDetails()]);
  }

  // === listen to the changes in the project funds ===
  void _startProjectStream() {
    _projectSubscription = _repository.getProjectStream(project.id!).listen((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        //=================================================
        // ===edit ===
        //=================================================
        final projectData = ProjectModel.fromMap(data, project.id!);
        // === update the data that change immediately ===
        liveTotalFunds = projectData.totalFunds;
        //  (data['total_raised'] ?? 0.0).toDouble();
        liveInvestorsCount = projectData.investors_count;
        // (data['investors_count'] ?? 0);
        currentRating = projectData.rating;
        // (data['rating'] ?? 0.0).toDouble();
        numOfReviews = projectData.numOfReviews;
        // (data['reviews_count'] ?? 0);
        upvoteCount = projectData.upVote;
        // (data['up_votes'] ?? 0);

        notifyListeners();
      }
    });
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
      if (isUpVoted) {
        upvoteCount++;
      } else {
        upvoteCount--;
      }
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
        final data = userDoc.data() as Map<String, dynamic>;
        //=================================================
        // ===edit ===
        //=================================================
        final user = UserModel.fromMap(data, project.ownerId!);
        ownerName = "${user.firstName} ${user.lastName}".trim();
        // "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}"
        //     .trim();
        ownerImage = user.avatarUrl ?? '';
        //  data['avatar_url'] ?? '';
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

  void updateUserRating(double rating) {
    userRating = rating;
    notifyListeners();
  }

  Future<void> addComment() async {
    // === check the text ===
    if (commentController.text.trim().isEmpty) return;

    isCommentLoading = true;
    notifyListeners();

    try {
      CommentModel comment = CommentModel(
        ownerId: userId,
        ownerName: userProviderName,
        rate: userRating,
        text: commentController.text.trim(),
      );
      Map<String, dynamic> commentData = comment.toMap();
      // === add the comment to the firebase ===
      await _repository.addComment(project.id!, commentData);

      // === update the rating ===
      if (userRating > 0) {
        int currentCount = project.numOfReviews ?? 0;
        double currentAvg = project.rating ?? 0.0;

        // === calc new rating ===
        double newRating =
            ((currentAvg * currentCount) + userRating) / (currentCount + 1);

        int newCount = currentCount + 1;

        // === update the data in the database ===
        await _repository.updateRating(project.id!, newRating, newCount);

        // === local update for user ===
        project.numOfReviews = newCount;
        project.rating = newRating;
        currentRating = newRating;
        numOfReviews = newCount;
      }

      // === clean the text and send motification ===
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

  // === delete comment and calc the rating again ===
  Future<void> deleteComment(
    String commentId,
    double ratingToDelete,
    String? commentOwner,
  ) async {
    int currentCount = project.numOfReviews ?? 0;
    double currentAvg = project.rating ?? 0.0;

    double newRating = 0.0;
    int newCount = currentCount;

    if (ratingToDelete > 0 && currentCount > 0) {
      newCount = currentCount - 1;

      if (newCount > 0) {
        double totalScore = (currentAvg * currentCount) - ratingToDelete;
        newRating = totalScore / newCount;

        if (newRating < 0) newRating = 0.0;
      } else {
        newRating = 0.0;
      }
    } else if (ratingToDelete > 0 && currentCount == 0) {
      newRating = 0.0;
    }

    try {
      // === delete the comment from the firebase ===
      _repository.deleteComment(project.id!, commentId);

      // === update the numbers ===
      if (ratingToDelete > 0) {
        await _repository.updateRating(project.id!, newRating, newCount);
      }

      // === local update ===
      if (ratingToDelete > 0) {
        project.rating = newRating;
        project.numOfReviews = newCount;

        currentRating = newRating;
        numOfReviews = newCount;
      }

      // === if the comment deleted by admin, send notification ===
      if (commentOwner != null) {
        NotificationService.sendAdminNotification(
          relatedId: commentOwner,
          title: 'Your Comment Deleted!',
          body:
              'Iep admin deleted your comment on ${project.title} for violation of application terms',
          type: 'comment_deleted',
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting comment: $e");
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
      _repository.deleteProject(project.id!);

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

  @override
  void dispose() {
    commentController.dispose();
    _projectSubscription?.cancel();
    super.dispose();
  }
}

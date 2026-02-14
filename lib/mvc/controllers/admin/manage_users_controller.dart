import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/repositories/admin_repository.dart';
import 'package:iep_app/mvc/views/chat_page/chatDetails_page.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';

class ManageUsersController extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  bool isLoading = true;
  List<QueryDocumentSnapshot> _allUsers = []; // orginal list
  List<QueryDocumentSnapshot> displayedUsers = []; // displayed list
  String selectedCategory = 'All';

  // === get the data when the controller run ===
  ManageUsersController() {
    fetchUsers();
  }

  // === get the data ===
  Future<void> fetchUsers() async {
    isLoading = true;
    notifyListeners();

    try {
      _allUsers = await _repository.getAllUsers();
      filterUsers(selectedCategory); 
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // === filtering ===
  void filterUsers(String category) {
    selectedCategory = category;

    if (category == 'All') {
      displayedUsers = List.from(_allUsers);
    } else {
      displayedUsers = _allUsers.where((doc) {
        final data = doc.data() as Map<String, dynamic>;

        final role = (data['role']?.toString() ?? 'user').trim().toLowerCase();

        if (category == 'Admins') {
          return role == 'admin';
        } else if (category == 'Municipality') {
          return role == 'municipality';
        } else if (category == 'Users') {
          return role == 'user';
        }
        return true;
      }).toList();
    }
    notifyListeners();
  }

  // === block the user ===
  Future<void> toggleBlockUser(BuildContext context, String uid, bool isBlocked) async {
    try {
      await _repository.toggleUserBlockState(uid, isBlocked);
      
      // === locally updating the data ===
      final index = _allUsers.indexWhere((doc) => doc.id == uid);
      if (index != -1) {
        // === for updating the data ===
        await fetchUsers(); 
      }

      if (context.mounted) {
        AppSnackBarState.show(
          context,
          color: isBlocked ? AppColors.light.green : AppColors.light.red,
          content: isBlocked ? "User Unblocked" : "User Blocked Successfully",
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBarState.show(context, color: AppColors.light.red, content: "Error: $e");
      }
    }
  }

  // === chating ===
  void chatWithUser(BuildContext context, String uid, String name, String image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          chatName: name,
          avatarUrl: image,
          receiverId: uid,
        ),
      ),
    );
  }
}
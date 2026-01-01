import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';

class AccountController extends ChangeNotifier {
  // === for controlling the textfeilds ===
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // === for controlling the state of editablity to all the text feilds ===
  bool isNameReadOnly = true;
  bool isPhoneReadOnly = true;
  bool isEmailReadOnly = true;

  // === for controlling to display the save bar ===
  bool showSaveBar = false;
  bool isLoading = false;

  // === for locally chooden image before upload it ===
  File? localImageFile;
  final ImagePicker _picker = ImagePicker();

  // === for initiallize the data when the page open ===
  void initData(UserProvider userProvider) {
    nameController.text = userProvider.fullName;
    phoneController.text = userProvider.phone ?? '';
    emailController.text = userProvider.email ?? '';
  }

  // === enable editing when toggle the text feild pen ===
  void toggleEdit(String field) {
    switch (field) {
      case 'name':
        isNameReadOnly = !isNameReadOnly;
        break;
      case 'phone':
        isPhoneReadOnly = !isPhoneReadOnly;
        break;
      case 'email':
        isEmailReadOnly = !isEmailReadOnly;
        break;
    }
    // === with any change, save bar will show up ===
    showSaveBar = true;
    notifyListeners();
  }

  // === pick the images ===
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      localImageFile = File(image.path);
      showSaveBar = true;
      notifyListeners();
    }
  }

  // === cancel the changes ===
  void cancelChanges(UserProvider userProvider) {
    isNameReadOnly = true;
    isPhoneReadOnly = true;
    isEmailReadOnly = true;
    showSaveBar = false;
    localImageFile = null;
    initData(userProvider); // return the data to the orginal values
    notifyListeners();
  }

  // === save the changes into firebase ===
  Future<void> saveChanges(
    BuildContext context,
    String uid,
    UserProvider userProvider,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      String? newAvatarUrl;
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null &&
          emailController.text.trim() != currentUser.email) {
        try {
          // === sending verify email ===
          await currentUser.verifyBeforeUpdateEmail(
            emailController.text.trim(),
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Verification email sent. Please verify to update login email.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            // === security error - should re login ===
            throw 'For security, please sign out and sign in again to change your email.';
          }
          rethrow; // to catch the error in catch
        }
      }

      if (localImageFile != null) {
        // === determine the path in storing the image ===
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_avatars')
            .child('$uid.jpg');

        // === upload the file ===
        await storageRef.putFile(localImageFile!);

        // === get the new url ===
        newAvatarUrl = await storageRef.getDownloadURL();
      }

      // === decompose the name into first and last name ===
      List<String> names = nameController.text.trim().split(' ');
      String fName = names.isNotEmpty ? names.first : '';
      String lName = names.length > 1 ? names.sublist(1).join(' ') : '';

      // === update the data ===
      Map<String, dynamic> updates = {
        'first_name': fName,
        'last_name': lName,
        'mobile_num': phoneController.text,
        'email': emailController.text.trim(),
      };
      // === if there a new image, will add the url ===
      if (newAvatarUrl != null) {
        updates['avatar_url'] = newAvatarUrl;
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(updates, SetOptions(merge: true));

      // === update the data after the update ===
      userProvider.updateLocalData(
        firstName: fName,
        lastName: lName,
        phone: phoneController.text,
        email: emailController.text.trim(),
        avatarUrl: newAvatarUrl, // if image null, will still the old one
      );

      // === end and cleanning the state ===
      isLoading = false;
      showSaveBar = false;
      isNameReadOnly = true;
      isPhoneReadOnly = true;
      isEmailReadOnly = true;
      localImageFile = null;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Changes saved successfully!'),
            backgroundColor: AppColors.light.green,
          ),
        );
      }
    } catch (e) {
      // === dealing with error ===
      isLoading = false;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.light.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}

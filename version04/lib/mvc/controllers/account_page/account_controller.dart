import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';
import 'package:iep_app/mvc/models/user_model.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/repositories/auth_repository.dart';
import 'package:iep_app/mvc/repositories/user_repository.dart';
import 'package:iep_app/mvc/views/auth/login_page.dart';
import 'package:image_picker/image_picker.dart';

class AccountController extends ChangeNotifier {
  final _repo = AuthRepository();
  final _userRepo = UserRepository();

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
  bool isForgetPassLoading = false;

  // === for locally chooden image before upload it ===
  XFile? localImageFile;
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
      localImageFile = image;
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
    UserProvider userProvider,
    UserModel user,
  ) async {
    final uid = user.id;
    try {
      isLoading = true;
      notifyListeners();

      String? newAvatarUrl;

      if (localImageFile != null) {
        newAvatarUrl = await _userRepo.addAvatarUrlAndGetUrl(
          localImageFile: localImageFile,
          uid: uid,
        );
      }

      // === decompose the name into first and last name ===
      List<String> names = nameController.text.trim().split(' ');
      String fName = names.isNotEmpty ? names.first : '';
      String lName = names.length > 1 ? names.sublist(1).join(' ') : '';

      UserModel updatedUser = user.copyWith(
        email: emailController.text.trim(),
        firstName: fName,
        lastName: lName,
        mobile: phoneController.text,
        // === if there a new image, will add the url ===
        avatarUrl: newAvatarUrl ?? user.avatarUrl,
      );
      // === update the data ===
      _userRepo.updateUserData(uid, updatedUser.toMap());

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
        AppSnackBarState.show(
          context,
          color: AppColors.light.green,
          content: 'Changes saved successfully!',
        );
      }
    } catch (e) {
      // === dealing with error ===
      isLoading = false;
      notifyListeners();
      if (context.mounted) {
        AppSnackBarState.show(
          context,
          color: AppColors.light.red,
          content: 'Error: $e',
        );
      }
    }
  }

  forgetPassword(BuildContext context) async {
    isForgetPassLoading = true;
    notifyListeners();
    FocusScope.of(context).unfocus();

    try {
      await _repo.sendPasswordResetEmail(emailController.text.trim());
      if (!context.mounted) return; //check user not change the page
      AppSnackBarState.show(
        context,
        color: Colors.green,
        content: 'check your email box, and reset your email password.',
      );
    } catch (e) {
      if (!context.mounted) return; //check user not change the page
      AppSnackBarState.show(
        context,
        color: Colors.red,
        content: 'An error Occured: ${e.toString()}',
      );
    } finally {
      isForgetPassLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    await _repo.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
    AppSnackBarState.show(
      context,
      color: AppColors.light.secText,
      content: 'signed out, successfully',
    );
  }

  // === update the data in the feilds ===
  void updateControllersIfReadOnly(UserProvider userProvider) {
    // === update the name ===
    if (isNameReadOnly && nameController.text != userProvider.fullName) {
      nameController.text = userProvider.fullName;
    }

    // === update the mobile number ===
    if (isPhoneReadOnly && phoneController.text != (userProvider.phone ?? '')) {
      phoneController.text = userProvider.phone ?? '';
    }

    // === update the email ===
    if (isEmailReadOnly && emailController.text != (userProvider.email ?? '')) {
      emailController.text = userProvider.email ?? '';
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

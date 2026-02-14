import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/models/user_model.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/repositories/auth_repository.dart';
import 'package:iep_app/mvc/views/auth/email_verify.dart';
import 'package:iep_app/mvc/views/layout/blocked_user_screen.dart';
import 'package:iep_app/mvc/views/auth/sign_up_page.dart';
import 'package:iep_app/mvc/views/layout/layout.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';

final colors = AppColors.light;

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final provider = UserProvider.instance;
  final _repository = AuthRepository();
  bool isLoading = false;

  // ==================== Validation Section ====================
  String? validateEmail(String? value) {
    if (value!.isEmpty) return 'please enter your email';
    value = value.trim(); // delete extra spaces
    // === libary for validation ===
    final pattern = r'(^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$)'; // for email check
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) return 'please enter valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value!.isEmpty) return 'please enter your password';
    // no need for strong password validation(it's already done in signup)
    return null;
  }

  // ==================== login ====================
  Future<void> login(BuildContext context, GlobalKey<FormState> key) async {
    if (!key.currentState!.validate()) return; //ensure validation first
    isLoading = true; // change loading state
    notifyListeners(); // show that app is loading
    FocusScope.of(
      context,
    ).unfocus(); // unfocus the textfeild (down the keyboard)
    try {
      // === login using repositery ===
      UserCredential userCredential = await _repository.login(
        emailController.text.trim(),
        passwordController.text,
      );
      if (!context.mounted) return; //check user not change the page

      // ==================== check if user is blocked section ====================
      // === check from repository using user id ===
      if (await _repository.isBlocked(userCredential.user!.uid)) {
        if (!context.mounted) return; //check user not change the page
        // === go to block page not into the app ===
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BlockedUserScreen()),
          (route) => false,
        );
        return;
      }

      if (!provider.isEmailVerified &&
          provider.currentUser?.role == UserRole.user) {
        if (!context.mounted) return; //check user not change the page
        // === go to verify page not into the app ===
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AppVerifyEmailPage()),
          (route) => false,
        );
        return;
      }

      // ==================== not blocked & signed in successfully ====================
      if (!context.mounted) return; //check user not change the page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Layout()),
        (route) => false,
      );
      return AppSnackBarState.show(
        context,
        color: colors.green,
        content: 'Logged in successfully',
      );

      // ==================== error in firebase occure ====================
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        if (!context.mounted) return; //check user not change the page
        return AppSnackBarState.show(
          context,
          color: colors.red,
          content: 'invalid email or password.',
        );
      } else if (e.code == 'wrong-password') {
        if (!context.mounted) return; //check user not change the page
        return AppSnackBarState.show(
          context,
          color: colors.red,
          content: 'Wrong password provided for that user.',
        );
      } else {
        if (!context.mounted) return; //check user not change the page
        return AppSnackBarState.show(
          context,
          color: colors.red,
          content: 'An error occured: ${e.code}',
        );
      }
    }
    // ==================== system (not firebase) error ====================
    catch (e) {
      if (!context.mounted) return; //check user not change the page

      return AppSnackBarState.show(
        context,
        color: colors.red,
        content: 'System Error: ${e.toString()}',
      );
    }
    // ==================== in any case ,stop loading at UI ====================
    finally {
      isLoading = false;
      notifyListeners();
    }
  }

  forgetPassword(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    FocusScope.of(context).unfocus();

    if (emailController.text.isEmpty) {
      isLoading = false;
      return AppSnackBarState.show(
        context,
        color: colors.red,
        content: 'please insert your email first!',
      );
    }
    try {
      await _repository.sendPasswordResetEmail(emailController.text.trim());
      if (!context.mounted) return; //check user not change the page
      AppSnackBarState.show(
        context,
        color: colors.green,
        content: 'check your email box, and reset your email password.',
      );
    } catch (e) {
      if (!context.mounted) return; //check user not change the page
      AppSnackBarState.show(
        context,
        color: colors.red,
        content: 'An error Occured: ${e.toString()}',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==================== create new account tap - go to sign up page ====================
  void onCreateAccountEmailTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateAccountPage()),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

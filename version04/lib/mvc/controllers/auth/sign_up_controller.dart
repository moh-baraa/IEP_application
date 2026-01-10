import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/repositories/auth_repository.dart';
import 'package:iep_app/mvc/views/auth/login_page.dart';
import 'package:iep_app/mvc/views/auth/email_verify.dart';
import 'package:iep_app/mvc/views/layout/layout.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';
import 'package:provider/provider.dart';

class SignupController extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final UserProvider provider = UserProvider.instance;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final yearController = TextEditingController();
  final monthController = TextEditingController();
  final dayController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  bool isEmailSent = false;
  bool canResendEmail = true;

  // ==================== Validation Section ====================

  String? validateFirstName(String? value) {
    if (value!.isEmpty) return 'please enter your first name';
    return null;
  }

  String? validateLastName(String? value) {
    if (value!.isEmpty) return 'please enter your last name';
    return null;
  }

  String? validateEmail(String? value) {
    if (value!.isEmpty) return 'please enter your email';
    value = value.trim();
    final pattern = r'(^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$)';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) return 'please enter valid email';
    return null;
  }

  String? validateMobil(String? value) {
    if (value!.isEmpty) return 'please enter your mobile number';
    return null;
  }

  String? validateYear(String? value) {
    final currentYear = DateTime.now().year;
    if (value!.isEmpty) return 'please enter year';
    if (int.tryParse(value) == null) return 'please enter valid numbers';
    if (int.tryParse(value)! > currentYear - 17) {
      return 'Sorry ,your under the allowed age';
    }
    if (int.tryParse(value)! < 1900) return 'please enter valid date';
    return null;
  }

  String? validateMonth(String? value) {
    if (value!.isEmpty) return 'please enter month';
    if (int.tryParse(value) == null) return 'please enter valid numbers';
    if (int.tryParse(value)! > 12 || int.tryParse(value)! < 1) {
      return 'please enter valid month number';
    }
    return null;
  }

  String? validateDay(String? value) {
    if (value!.isEmpty) return 'please enter day';
    if (int.tryParse(value) == null) return 'please enter valid numbers';
    if (int.tryParse(value)! > 31 || int.tryParse(value)! < 1) {
      return 'please enter valid day number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value!.isEmpty) return 'please enter your password';
    final pattern = r'(^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$)';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) return 'please enter valid password';
    return null;
  }

  String? validateConfirmPassword(String? value, String? password) {
    if (password!.isEmpty) return 'please enter your password at first';
    if (value!.isEmpty) return 'please enter your password again';
    if (value != password) return "the password don't match";
    return null;
  }

  // ==================== Sign Up Logic ====================

  Future<void> signUp(BuildContext context, GlobalKey<FormState> key) async {
    if (!key.currentState!.validate()) return;
    isLoading = true;
    notifyListeners();
    FocusScope.of(context).unfocus();

    try {
      // === calling the repositery for creating new user in firebase authentication ===
      // === and create new user with his details in firestore ===
      await _repository.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        mobile: mobileController.text.trim(),
        birthDate:
            "${yearController.text}-${monthController.text}-${dayController.text}",
      );

      // ==================== created successfully ====================
      if (!context.mounted) return;

      AppSnackBarState.show(
        context,
        color: AppColors.light.green,
        content: 'Account created successfully',
      );

      // === go to the app + deleting all previous pages ===
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AppVerifyEmailPage()),//########3
        (route) => false,
      );

      // ==================== on error occure(in firebase) ====================
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred: ${e.code}';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      }

      if (context.mounted) {
        AppSnackBarState.show(
          context,
          color: AppColors.light.red,
          content: message,
        );
      }
    }
    // ==================== on error occure(in system) ====================
    catch (e) {
      if (context.mounted) {
        AppSnackBarState.show(
          context,
          color: AppColors.light.red,
          content: 'System Error: ${e.toString()}',
        );
      }
    } finally {
      // === end loading in UIin all cases ===
      isLoading = false;
      notifyListeners();
    }
  }

  // === on already have account tap(go to login page) ===
  void onHaveAccountTap(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> checkEmailVerified(BuildContext context) async {//###########
    // === using reload to update the data from the firebase ===
    await FirebaseAuth.instance.currentUser?.reload();

    // === get the updated data ===
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      // === verified successfully ===
      if (!context.mounted) return;

      // === updating the provider ===
      await context.read<UserProvider>().reloadUserData();

      if (!context.mounted) return;

      // === continue to the app ===
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Layout()),
      );
      AppSnackBarState.show(
        context,
        color: Colors.green,
        content: "Email Verified Successfully!",
      );
    } else {
      // === not verified ===
      if (!context.mounted) return;

      AppSnackBarState.show(
        context,
        color: AppColors.light.red,
        content: "Email not verified yet. Please check your inbox.",
      );
    }
  }

  //=== sending verification message ===
  Future<void> sendVerificationEmail(BuildContext context) async {//############
    try {
      final user = UserProvider.instance.user;
      await user?.sendEmailVerification();
      isEmailSent = true;

      // === avoid the repating of sending email verifiction ===
      canResendEmail = false;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 5));
      if (!context.mounted) return;
      canResendEmail = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error sending verification email: $e");
    }
  }

  // ==================== Dispose ====================

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    yearController.dispose();
    monthController.dispose();
    dayController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}

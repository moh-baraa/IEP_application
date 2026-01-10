import 'package:flutter/material.dart';
import 'package:iep_app/mvc/views/auth/login_page.dart';
import 'package:iep_app/mvc/views/auth/sign_up_page.dart';
import 'package:iep_app/mvc/views/on_boarding/second.dart';
import 'package:iep_app/mvc/views/on_boarding/third.dart';

class OnBoardingController {
  void onSkipTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void onGetStartedTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardPage2()),
    );
  }

  void onNextTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardPage3()),
    );
  }
  void onLoginTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

    void onSignUpTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateAccountPage()),
    );
  }
}

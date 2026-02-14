import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/on_boarding/on_boarding_controller.dart';
import 'package:iep_app/mvc/views/on_boarding/widgets/Indicator.dart';
import 'package:iep_app/mvc/views/on_boarding/widgets/on_boarding_button.dart';

class OnboardPage3 extends StatelessWidget {
  const OnboardPage3({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;
    final _controller = OnBoardingController();

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 25),

            Image.asset(
              height: 260,
              "assets/images/onboardThird.png",
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 30),

            Text(
              "Finally!",
              style: AppTextStyles.size26weight5(colors.primary),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Sign in or create an email, for better experience with us!",
                textAlign: TextAlign.center,
                style: AppTextStyles.size16weight5(colors.secText),
              ),
            ),

            const Spacer(),

            // Indicators
            Indicator(pageNumber: 3),

            const SizedBox(height: 25),

            // Sign In
            AppOnboardingButton(
              insideText: 'Login',
              onPressed: () {
                _controller.onLoginTap(context);
              },
            ),

            const SizedBox(height: 15),

            // Sign Up
            AppOnboardingButton(
              insideText: 'Sign Up',
              isSecondary: true,
              onPressed: () {
                _controller.onSignUpTap(context);
              },
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

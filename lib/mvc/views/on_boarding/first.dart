import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/on_boarding/on_boarding_controller.dart';
import 'package:iep_app/mvc/views/on_boarding/widgets/Indicator.dart';
import 'package:iep_app/mvc/views/on_boarding/widgets/on_boarding_button.dart';

class OnboardPage1 extends StatelessWidget {
  const OnboardPage1({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;
    final controller = OnBoardingController();

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Illustration
            Image.asset(
              height: 260,
              "assets/images/onboardFirst.png",
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 20),

            Text("Welcome to", style: AppTextStyles.size18weight5(colors.text)),

            Text("I  E  P", style: AppTextStyles.size26weight5(colors.primary)),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Discover, invest, and start your own business with a reliable and transparent platform.",
                textAlign: TextAlign.center,
                style: AppTextStyles.size16weight5(colors.secText),
              ),
            ),

            const Spacer(),

            // Indicators
            Indicator(pageNumber: 1),

            const SizedBox(height: 25),

            // Get Started Button
            AppOnboardingButton(
              insideText: 'Get Started 🚀',
              onPressed: () {
                controller.onGetStartedTap(context);
              },
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                controller.onSkipTap(context);
              },
              child: Text(
                "Skip",
                style: AppTextStyles.size14weight4(colors.secText),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

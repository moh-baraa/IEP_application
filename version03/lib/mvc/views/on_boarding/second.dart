import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/on_boarding/on_boarding_controller.dart';
import 'package:iep_app/mvc/views/on_boarding/widgets/Indicator.dart';
import 'package:iep_app/mvc/views/on_boarding/widgets/on_boarding_button.dart';

class OnboardPage2 extends StatelessWidget {
  const OnboardPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;
    final _controller = OnBoardingController();

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// ---------------------------
            /// TOP IMAGE + TEXT (IMAGE RIGHT)
            /// ---------------------------
            SizedBox(
              height: 220,
              child: Stack(
                clipBehavior: Clip.none, //??
                children: [
                  // Image aligned to RIGHT
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 220,
                      child: Image.asset(
                        "assets/images/onboardSecond.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // TEXT aligned left-mid, overlapping image a bit
                  Positioned(
                    left: 20,
                    top: 70,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.55,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.background.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colors.secText.withOpacity(.2),
                        ),
                      ),
                      child: Text(
                        "Invest and share your ideas with us with complete confidence.",
                        style: AppTextStyles.size16weight5(colors.text),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// ---------------------------
            /// BOTTOM IMAGE + TEXT (IMAGE LEFT)
            /// ---------------------------
            SizedBox(
              height: 200,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Image aligned LEFT
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 200,
                      child: Image.asset(
                        "assets/images/onboardSecond2.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Text aligned right-mid, top aligned with image top
                  Positioned(
                    right: 20,
                    top: 0, // aligns with image top
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.55,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.background.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colors.secText.withOpacity(.2),
                        ),
                      ),
                      child: Text(
                        "A secure platform with digital contracts and official documentation.",
                        style: AppTextStyles.size16weight5(colors.text),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// Indicators
            Indicator(pageNumber: 2),

            const SizedBox(height: 20),

            /// Next Button
            AppOnboardingButton(
              insideText: 'Next',
              onPressed: () {
                _controller.onNextTap(context);
              },
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => _controller.onSkipTap(context),
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

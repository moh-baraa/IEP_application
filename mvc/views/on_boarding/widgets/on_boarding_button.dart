import 'package:flutter/material.dart';
import 'package:iep_app/mvc/views/auth/widgets/form_button.dart';

class AppOnboardingButton extends StatelessWidget {
  const AppOnboardingButton({
    super.key,
    required this.insideText,
    required this.onPressed,
    this.isSecondary = false,
  });
  final String insideText;
  final VoidCallback? onPressed;
  final bool isSecondary;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: AppFormButton(
        buttonText: insideText,
        onPressed: onPressed,
        isSecondary: isSecondary,
      ),
    );
  }
}


            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 40),
            //   child: SizedBox(
            //     width: double.infinity,
            //     height: 54,
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: AppColors.light.primary,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(14),
            //         ),
            //         elevation: 5,
            //       ),
            //       onPressed: () {},
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Text(
            //             "Get Started",
            //             style: AppTextStyles.size14weight4(Colors.white),
            //           ),
            //           const SizedBox(width: 6),
            //           const Icon(
            //             Icons.rocket_launch_outlined,
            //             color: Colors.white,
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
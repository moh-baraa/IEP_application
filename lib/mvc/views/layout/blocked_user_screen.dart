import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/core/services/email_support.dart';
import 'package:iep_app/mvc/controllers/account_page/account_controller.dart';

class BlockedUserScreen extends StatelessWidget {
  BlockedUserScreen({super.key});
  // === for open email app, if the user want to contact with us ===
  final _emailService = EmailSupport();
  final controller = AccountController();
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_person_rounded, size: 100, color: colors.red),
              const SizedBox(height: 24),

              Text(
                "Account Suspended",
                style: AppTextStyles.size26weight5(colors.text),
              ),
              const SizedBox(height: 12),

              Text(
                "Your account has been suspended due to a violation of our terms. If you think this is a mistake, please contact support.",
                textAlign: TextAlign.center,
                style: AppTextStyles.size16weight4(colors.secText),
              ),
              const SizedBox(height: 40),

              // === contact button with the support ===
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _emailService.openEmailApp(context: context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.email_outlined, color: colors.background),
                  label: Text(
                    "Contact Support",
                    style: AppTextStyles.size16weight4(colors.background),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // === logout button ===
              TextButton(
                onPressed: () => controller.signOut(context),
                child: Text(
                  "Sign Out",
                  style: AppTextStyles.size14weight4(colors.secText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/account_page/account_controller.dart';
import 'package:iep_app/mvc/controllers/auth/sign_up_controller.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';

class AppVerifyEmailPage extends StatefulWidget {
  const AppVerifyEmailPage({super.key});

  @override
  State<AppVerifyEmailPage> createState() => _AppVerifyEmailPageState();
}

class _AppVerifyEmailPageState extends State<AppVerifyEmailPage> {
  late final SignupController _controller;
  final accController = AccountController();

  @override
  void initState() {
    super.initState();
    _controller = SignupController(); // intillize the controller

    final user = UserProvider.instance.user;
    // === if the email not verified,sent message ===
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.sendVerificationEmail(context);
    });
  }

  @override
  void dispose() {
    accController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // === display the email ===
    final email = UserProvider.instance.user?.email ?? "your email";

    return Scaffold(
      backgroundColor: AppColors.light.bg,
      appBar: AppBar(
        backgroundColor: AppColors.light.bg,
        actions: [
          // === signing out button ===
          TextButton.icon(
            onPressed: () async {
              await accController.signOut(context);
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text("Sign Out"),
            style: TextButton.styleFrom(foregroundColor: AppColors.light.red),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // === no rebuild needed ===
            Expanded(
              child: AppUnFoundPage(
                icon: Icons.mark_email_unread_outlined,
                text: "Verify your email address",
                subText:
                    "We have sent a verification link to:\n$email\n\nPlease check your inbox and click the link, then press the button below.",
                buttonText: "I have verified it",
                tryAgain: () => _controller.checkEmailVerified(context),
              ),
            ),

            // === need to rebuild section ===
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: ListenableBuilder(
                listenable: _controller, // listen to controller
                builder: (context, child) {
                  return TextButton(
                    onPressed: _controller.canResendEmail
                        ? () => _controller.sendVerificationEmail(context)
                        : null,
                    child: Text(
                      _controller.canResendEmail
                          ? "Resend Email"
                          : "Wait a few seconds...",
                      style: AppTextStyles.size14weight5(
                        _controller.canResendEmail
                            ? AppColors.light.primary
                            : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:url_launcher/url_launcher.dart';

AppColorScheme colors = AppColors.light;
class AppSupportDialog extends StatelessWidget {
  const AppSupportDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AppSupportDialog();
      },
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    const String emailAddress = 'support@iep-company.com';
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: Uri.encodeFull('subject=Support Request from App'),
    );

    try {
      if (await launchUrl(emailLaunchUri)) {
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Support',
        style: AppTextStyles.size14weight4(colors.primary),
      ),
      content: Text(
        'You will be redirected to your email app.\n'
        'Please write your full issue clearly and send it so our team can contact you.',
        style: AppTextStyles.size14weight4(colors.text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _launchEmail(context);
          },
          child: const Text('Go'),
        ),
      ],
    );
  }
}
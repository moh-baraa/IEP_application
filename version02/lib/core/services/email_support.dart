import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailSupport {
  final emailAddress = 'support@iep-company.com';

  Future<void> openEmailApp({required BuildContext context}) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: Uri.encodeFull('subject=Support Request from App'),
    );

    try {
      if (await launchUrl(emailLaunchUri)) {
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }
}

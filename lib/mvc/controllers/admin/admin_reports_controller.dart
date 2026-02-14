import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/repositories/admin_repository.dart';
import 'package:iep_app/core/widgets/app_input_dialog.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';

class AdminReportsController extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  // === get the reports ===
  Stream<QuerySnapshot> getReportsStream() {
    return _repository.getReportsStream();
  }

  // open resolve dialog ===
  void showResolveDialog(
    BuildContext context,
    String reportId,
    String reporterId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AppInputDialog(
        title: "Resolve Report",
        subtitle:
            "Write a message to the reporter explaining the action taken:",
        hintText: "E.g. We have reviewed your report and taken action...",
        actionText: "Mark as Done",
        actionColor: AppColors.light.green,
        onSubmit: (message) {
          _confirmResolve(context, reportId, reporterId, message);
        },
      ),
    );
  }

  // === exxcute the resolve ===
  Future<void> _confirmResolve(
    BuildContext context,
    String reportId,
    String reporterId,
    String message,
  ) async {
    if (message.trim().isEmpty) {
      AppSnackBarState.show(
        context,
        color: Colors.red,
        content: "Please write a message to the reporter first.",
      );
      return;
    }

    Navigator.pop(context); // close the window

    try {
      await _repository.resolveReport(
        reportId: reportId,
        reporterId: reporterId,
        replyMessage: message,
      );

      if (context.mounted) {
        AppSnackBarState.show(
          context,
          color: AppColors.light.green,
          content: "Report resolved and notification sent.",
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBarState.show(context, color: Colors.red, content: "Error: $e");
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:iep_app/core/services/mock_payment_service.dart';
import 'package:iep_app/core/services/notification_service.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/models/transaction_model.dart';
import 'package:iep_app/core/services/contract_generator_service.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/repositories/payment_repository.dart';
import 'package:iep_app/mvc/repositories/transaction_repository.dart';
import 'package:iep_app/mvc/repositories/user_repository.dart';
import 'package:iep_app/mvc/views/payment/payment_success_page.dart';
import 'package:provider/provider.dart';

class PaymentController extends ChangeNotifier {
  final MockPaymentService _paymentService = MockPaymentService();
  final TransactionRepository _transactionRepo = TransactionRepository();
  final _paymentRepo = PaymentRepository();
  ContractGeneratorService generator = ContractGeneratorService();
  bool isLoading = false;

  // === main payment method ===
  Future<void> processPayment({
    required BuildContext context,
    required ProjectModel project,
    required double amount,
    required String userId,
    required String userName,
    required String paymentMethodId,
    required TransactionType type, // investment or donation
  }) async {
    final userRepo = UserRepository();
    // === start loading ===
    isLoading = true;
    notifyListeners();

    try {
      // === payment simulation ===
      bool success = await _paymentService.makePayment(amount: amount);

      if (!success) {
        if (!context.mounted) return;

        AppSnackBarState.show(
          context,
          content: "Payment failed by bank.",
          color: Colors.red,
        );
        return;
      }

      // === do payment. and update total_raised & investors_count ===
      double? updatedTotalRaised = await _paymentRepo.runTransaction(
        projectId: project.id!,
        type: type,
        amount: amount,
      );

      // === record the transaction in the firebase ===
      final transactionRecord = TransactionModel(
        id: '',
        userId: userId,
        userName: userName,
        projectId: project.id!,
        amount: amount,
        type: type,
        timestamp: DateTime.now(),
        paymentMethodId: paymentMethodId,
        status: 'success',
        projectTitle: project.title,
      );

      await _transactionRepo.createTransaction(transactionRecord);
      int currentInvestors = project.investors_count ?? 0;
      if (updatedTotalRaised != null) {
        // === update the object we use ===
        project = project.copyWith(
          investors_count: type == TransactionType.investment
              ? currentInvestors + 1
              : currentInvestors, // if it donation, there no change
          totalFunds: updatedTotalRaised,
        );
        await Future.delayed(const Duration(seconds: 1));
        // === check if the project reach the target ===
        if (updatedTotalRaised >= project.targetFunds) {
          // === contract generation ===
          await generator.generateAndSaveContract(project);
        }
      }

      if (context.mounted) {
        Provider.of<UserProvider>(context, listen: false).refreshStats();
        isLoading = false;
        notifyListeners();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(
              amount: amount,
              projectName: project.title,
              date:
                  "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
            ),
          ),
        );
        AppSnackBarState.show(
          context,
          content: "Payment Successful! Thank you.",
          color: Colors.green,
        );
        final String? projOwnerId = await userRepo.getUserId(
          projectId: project.id!,
        );
        if (projOwnerId != null) {
          NotificationService.sendNotification(
            receiverId: projOwnerId,
            title: 'You got new ${type.toString()}.',
            body:
                'You got new ${type.toString()}, on your project, ${project.title}, the amount is: ${amount.toString()} JD.',
          );
        }
      }
    } catch (e) {
      print("Error processing payment: $e");
      if (context.mounted) {
        AppSnackBarState.show(
          context,
          content: "System Error: $e",
          color: Colors.red,
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

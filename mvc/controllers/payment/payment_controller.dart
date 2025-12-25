import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/services/mock_payment_service.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/models/transaction_model.dart';
import 'package:iep_app/mvc/controllers/contract/contract_generator_controller.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/repositories/transaction_repository.dart';
import 'package:iep_app/mvc/views/payment/payment_success_page.dart';
import 'package:provider/provider.dart';

class PaymentController extends ChangeNotifier {
  final MockPaymentService _paymentService = MockPaymentService();
  final TransactionRepository _transactionRepo = TransactionRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    // === start loading ===
    isLoading = true;
    notifyListeners();

    try {
      // === payment simulation ===
      bool success = await _paymentService.makePayment(amount: amount);

      if (!success) {
        if (!context.mounted) return;

        _showSnack(context, "Payment failed by bank.", Colors.red);
        isLoading = false;
        notifyListeners();
        return;
      }

// === if the payment sucess ,update the firebase ===
      await _firestore.runTransaction((transaction) async {
        DocumentReference projectRef = _firestore
            .collection('projects')
            .doc(project.id);

        DocumentSnapshot projectSnapshot = await transaction.get(projectRef);

        if (!projectSnapshot.exists) {
          throw Exception("Project does not exist!");
        }

        double currentRaised = (projectSnapshot.get('total_raised') ?? 0)
            .toDouble();
        double targetAmount = (projectSnapshot.get('target_amount') ?? 0)
            .toDouble();

        // ب) تحديث المبلغ
        double newRaised = currentRaised + amount;

        Map<String, dynamic> updates = {'total_raised': newRaised};

        if (type == TransactionType.investment) {
          updates['investors_count'] = FieldValue.increment(1);
        }

        transaction.update(projectRef, updates);
      });

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

      if (type == TransactionType.investment) {

        double newTotal = project.totalFunds + amount;

        if (newTotal >= project.targetFunds) {
          print("🚀 Project Target Reached! Initiating Contract Logic...");
          await _handleContractCreation(project.id!, userId, amount);
        }
      }

 
      if (context.mounted) {
        Provider.of<UserProvider>(context, listen: false).refreshStats();
        isLoading = false;
        notifyListeners();

        Navigator.push(
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
        _showSnack(context, "Payment Successful! Thank you.", Colors.green);
      }
    } catch (e) {
      print("Error processing payment: $e");
      if (context.mounted) {
        _showSnack(context, "System Error: $e", Colors.red);
        isLoading = false;
        notifyListeners();
      }
    }
  }


  Future<void> _handleContractCreation(
    String projectId,
    String investorId,
    double amount,
  ) async {
    DocumentSnapshot doc = await _firestore
        .collection('projects')
        .doc(projectId)
        .get();
    ProjectModel project = ProjectModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );

    ContractGeneratorController generator = ContractGeneratorController();
    await generator.generateAndSaveContract(project);

 
    // adding NotificationService.send...
  }

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}

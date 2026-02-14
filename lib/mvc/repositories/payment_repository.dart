import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iep_app/mvc/models/transaction_model.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double?> runTransaction({
    required String projectId,
    required TransactionType type,
    required double amount,
  }) async {
    double? updatedTotalRaised;
    // === if the payment sucess ,update the firebase ===
    await _firestore.runTransaction((transaction) async {
      //deny any tow transaction at same time/ transaction(object) from firebase for monotoring
      DocumentReference projectRef =
          _firestore // reading the project
              .collection('projects')
              .doc(projectId);

      DocumentSnapshot projectSnapshot = await transaction.get(
        projectRef,
      ); // save it/ check the changes by transaction(get)

      if (!projectSnapshot.exists) {
        throw Exception("Project does not exist!");
      }

      double currentRaised = (projectSnapshot.get('total_raised') ?? 0)
          .toDouble();

      double newRaised = currentRaised + amount;

      Map<String, dynamic> updates = {'total_raised': newRaised};

      if (type == TransactionType.investment) {
        updates['investors_count'] = FieldValue.increment(
          1,
        ); // without reading the value
      }
      double targetFunds = projectSnapshot.get(
        'target_amount',
      ); // if investment completed to this project
      if (targetFunds <= newRaised) {
        updates['isSatisfiesTarget'] = true;
      }

      transaction.update(
        projectRef,
        updates,
      ); // if there no changes during the opreation, the update will success/using transaction too

      updatedTotalRaised = newRaised;
    });
    return updatedTotalRaised;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iep_app/mvc/models/contract_model.dart';

class ContractRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  // === creating new contract ===
  Future<void> createContract(ContractModel contract) async {
    await _firestore.collection('contracts').add(contract.toMap());
  }

  // === get the contract that user partner with(investor, project owner) ===
  Stream<List<ContractModel>> getUserContracts(String userId) {
    return _firestore
        .collection('contracts')
        .where('participantsIds', arrayContains: userId) 
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ContractModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}

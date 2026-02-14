import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iep_app/mvc/models/credit_card_model.dart'; 

class CardsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === add new credit card  ===
  Future<void> addCard(CreditCardModel card) async {
    try {
      await _firestore
          .collection('users')
          .doc(card.userId)
          .collection('cards') // sub collection
          .add(card.toMap());
    } catch (e) {
      throw Exception('Failed to add card: $e');
    }
  }

  // === get all user card(using stream for live update) ===
  Stream<List<CreditCardModel>> getUserCards(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cards')
        .orderBy('createdAt', descending: true) //new first
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // === convert the data into objects ===
            return CreditCardModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // === delete card ===
  Future<void> deleteCard(String userId, String cardId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cards')
          .doc(cardId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete card: $e');
    }
  }
}

import 'package:iep_app/core/services/encryption_service.dart';

class CreditCardModel {
  final String id;
  final String userId;
  final String holderName;
  final String expiryDate; // Format: MM/YY
  final String cardType; // Visa, Mastercard, etc.
  final String last4Digits; // // for seccurity
  
  // === encription ===
  final String encryptedNumber; 
  final String encryptedCvv;

  CreditCardModel({
    required this.id,
    required this.userId,
    required this.holderName,
    required this.expiryDate,
    required this.cardType,
    required this.last4Digits,
    required this.encryptedNumber,
    required this.encryptedCvv,
  });

// === transfer the data into objects ===
  factory CreditCardModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CreditCardModel(
      id: documentId,
      userId: data['userId'] ?? '',
      holderName: data['holderName'] ?? '',
      expiryDate: data['expiryDate'] ?? '',
      cardType: data['cardType'] ?? 'Unknown',
      last4Digits: data['last4Digits'] ?? '',
      encryptedNumber: data['cardNumber'] ?? '', // enrypt data
      encryptedCvv: data['cvv'] ?? '',           //enrypt data
    );
  }

  // === transfer the object into map ===
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'holderName': holderName,
      'expiryDate': expiryDate,
      'cardType': cardType,
      'last4Digits': last4Digits,
      'cardNumber': encryptedNumber, // store the encrypt
      'cvv': encryptedCvv,           //store the encrypt
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // === to create an object with encrypt data ===
  static CreditCardModel createNew({
    required String userId,
    required String holderName,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardType,
  }) {
    return CreditCardModel(
      id: '', // choosed by firebase
      userId: userId,
      holderName: holderName,
      expiryDate: expiryDate,
      cardType: cardType,
      last4Digits: cardNumber.length >= 4 ? cardNumber.substring(cardNumber.length - 4) : cardNumber,
      // === encrypt all the data before the storing the object ===
      encryptedNumber: EncryptionService.encryptData(cardNumber),
      encryptedCvv: EncryptionService.encryptData(cvv),
    );
  }
}
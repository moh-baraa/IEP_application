import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';
import 'package:iep_app/mvc/models/credit_card_model.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/repositories/cards_repository.dart';

class AddCardController {
  final holderNameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  final CardsRepository _cardsRepo = CardsRepository();
  final AppColorScheme colors = AppColors.light;

  final provider = UserProvider.instance;

  Future<void> saveCard(
    BuildContext context, {
    required GlobalKey<FormState> key,
  }) async {
    if (!key.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final user = provider.user;
      if (user == null) return;

      // === create an object and encypt in same time ===
      final newCard = CreditCardModel.createNew(
        userId: user.uid,
        holderName: holderNameController.text,
        cardNumber: cardNumberController.text.replaceAll(' ', ''),
        expiryDate: expiryController.text,
        cvv: cvvController.text,
        cardType: detectCardType(cardNumberController.text),
      );

      // === save in firestore ===
      await _cardsRepo.addCard(newCard);

      if (context.mounted) {
        Navigator.pop(context); // back to choose card page
        AppSnackBarState.show(
          context,
          color: colors.green,
          content: 'Card Added Successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBarState.show(context, color: colors.red, content: 'Error: $e');
      }
    } finally {
      if (context.mounted) isLoading.value = false;
    }
  }

  // === to define card type from the card first number ===
  String detectCardType(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'Mastercard';
    return 'Credit Card';
  }

  // ==================== validators ====================
  String? cardNumberValidator(String? value) {
    if (value == null || value.length < 16) {
      return "Invalid card number";
    } else {
      return null;
    }
  }

  String? expiryValidator(String? value) {
    if (value == null || !value.contains('/')) {
      return "Invalid Date";
    } else {
      return null;
    }
  }

  String? ccvValidator(String? value) {
    if (value == null || value.length < 3) {
      return "Invalid CVV";
    } else {
      return null;
    }
  }

  String? holderNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Required";
    } else {
      return null;
    }
  }

  void dispose() {
    cardNumberController.dispose();
    cvvController.dispose();
    expiryController.dispose();
    holderNameController.dispose();
    isLoading.dispose();
  }
}

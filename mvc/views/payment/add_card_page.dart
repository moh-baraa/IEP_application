import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/models/credit_card_model.dart';
import 'package:iep_app/mvc/repositories/cards_repository.dart';
import 'package:iep_app/mvc/views/auth/widgets/form_button.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _holderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isLoading = false;
  final CardsRepository _cardsRepo = CardsRepository();
  final AppColorScheme colors = AppColors.light;

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. إنشاء المودل (سيقوم بالتشفير تلقائياً داخل الدالة createNew)
      final newCard = CreditCardModel.createNew(
        userId: user.uid,
        holderName: _holderNameController.text,
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expiryDate: _expiryController.text,
        cvv: _cvvController.text,
        cardType: _detectCardType(_cardNumberController.text),
      );

      // 2. الحفظ في الفايرستور
      await _cardsRepo.addCard(newCard);

      if (mounted) {
        Navigator.pop(context); // الرجوع لصفحة الاختيار
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Card Added Successfully'),
            backgroundColor: colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // دالة بسيطة لتحديد نوع البطاقة من الرقم
  String _detectCardType(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'Mastercard';
    return 'Credit Card';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          "Add New Card",
          style: AppTextStyles.size18weight5(colors.text),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.text),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Card Information",
                  style: AppTextStyles.size16weight5(colors.text),
                ),
                const SizedBox(height: 15),

                // Card Number
                _buildLabel("Card Number"),
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  decoration: _inputDecoration(
                    "0000 0000 0000 0000",
                    Icons.credit_card,
                  ),
                  validator: (v) => (v == null || v.length < 16)
                      ? "Invalid card number"
                      : null,
                ),
                const SizedBox(height: 15),

                // Row for Expiry & CVV
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Expiry Date"),
                          TextFormField(
                            controller: _expiryController,
                            keyboardType: TextInputType.datetime,
                            decoration: _inputDecoration(
                              "MM/YY",
                              Icons.date_range,
                            ),
                            validator: (v) => (v == null || !v.contains('/'))
                                ? "Invalid Date"
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("CVV"),
                          TextFormField(
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 3,
                            decoration: _inputDecoration(
                              "123",
                              Icons.lock_outline,
                            ),
                            validator: (v) => (v == null || v.length < 3)
                                ? "Invalid CVV"
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Card Holder
                _buildLabel("Card Holder Name"),
                TextFormField(
                  controller: _holderNameController,
                  decoration: _inputDecoration(
                    "Ex. John Doe",
                    Icons.person_outline,
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? "Required" : null,
                ),

                const SizedBox(height: 40),

                // Save Button
                AppFormButton(
                  buttonText: "Save Card",
                  isloading: _isLoading,
                  onPressed: _saveCard,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.size14weight5(colors.text)),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: colors.secText),
      filled: true,
      fillColor: colors.container, // لون رمادي فاتح للخلفية
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      counterText: "", // لإخفاء عداد الأحرف
    );
  }
}

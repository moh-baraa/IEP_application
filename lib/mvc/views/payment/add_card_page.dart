import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/payment/add_card_controller.dart';
import 'package:iep_app/mvc/views/auth/widgets/form_button.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();

  final _controller = AddCardController();

  final AppColorScheme colors = AppColors.light;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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

                // === Card Number ===
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Card Number",
                    style: AppTextStyles.size14weight5(colors.text),
                  ),
                ),

                TextFormField(
                  controller: _controller.cardNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  decoration: _inputDecoration(
                    "0000 0000 0000 0000",
                    Icons.credit_card,
                  ),
                  validator: (value) => _controller.cardNumberValidator(value),
                ),
                const SizedBox(height: 15),

                // === Row for Expiry & CVV ===
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              "Expiry Date",
                              style: AppTextStyles.size14weight5(colors.text),
                            ),
                          ),
                          TextFormField(
                            controller: _controller.expiryController,
                            keyboardType: TextInputType.datetime,
                            decoration: _inputDecoration(
                              "MM/YY",
                              Icons.date_range,
                            ),
                            validator: (value) =>
                                _controller.expiryValidator(value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              "CVV",
                              style: AppTextStyles.size14weight5(colors.text),
                            ),
                          ),
                          TextFormField(
                            controller: _controller.cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 3,
                            decoration: _inputDecoration(
                              "123",
                              Icons.lock_outline,
                            ),
                            validator: (value) =>
                                _controller.ccvValidator(value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // === Card Holder ===
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Card Holder Name",
                    style: AppTextStyles.size14weight5(colors.text),
                  ),
                ),
                TextFormField(
                  controller: _controller.holderNameController,
                  decoration: _inputDecoration(
                    "Ex. John Doe",
                    Icons.person_outline,
                  ),
                  validator: (value) => _controller.holderNameValidator(value),
                ),

                const SizedBox(height: 40),

                // === Save Button ===
                ValueListenableBuilder<bool>(
                  valueListenable: _controller.isLoading,
                  builder: (context, isLoading, child) {
                    return AppFormButton(
                      buttonText: "Save Card",
                      isloading: isLoading,
                      onPressed: () =>
                          _controller.saveCard(context, key: _formKey),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: colors.secText),
      filled: true,
      fillColor: colors.container,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      counterText: "", // to hide number of characters
    );
  }
}

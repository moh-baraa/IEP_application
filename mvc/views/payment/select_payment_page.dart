import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iep_app/mvc/views/auth/widgets/form_button.dart';
import 'package:iep_app/mvc/views/payment/add_card_page.dart';
import 'package:provider/provider.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/models/credit_card_model.dart';
import 'package:iep_app/mvc/models/transaction_model.dart'; // لاستخدام الـ Enum
import 'package:iep_app/mvc/repositories/cards_repository.dart';
import 'package:iep_app/mvc/controllers/payment/payment_controller.dart';

class SelectPaymentPage extends StatefulWidget {
  final ProjectModel project;
  final double amount;
  final TransactionType type; // investment or donation

  const SelectPaymentPage({
    super.key,
    required this.project,
    required this.amount,
    required this.type,
  });

  @override
  State<SelectPaymentPage> createState() => _SelectPaymentPageState();
}

class _SelectPaymentPageState extends State<SelectPaymentPage> {
  final CardsRepository _cardsRepo = CardsRepository();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  String? _selectedCardId; // ID البطاقة المختارة حالياً
  final AppColorScheme colors = AppColors.light;

  @override
  Widget build(BuildContext context) {
    // نستخدم الـ ChangeNotifierProvider هنا للوصول للكونترولر
    return ChangeNotifierProvider(
      create: (_) => PaymentController(),
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(
            "Select Payment",
            style: AppTextStyles.size18weight5(colors.text),
          ),
          centerTitle: true,
          backgroundColor: colors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: colors.text),
        ),
        body: SafeArea(
          child: Consumer<PaymentController>(
            builder: (context, controller, child) {
              return Column(
                children: [
                  // 1. ملخص المبلغ
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    color: colors.container.withOpacity(0.5),
                    child: Column(
                      children: [
                        Text(
                          "Total Amount",
                          style: AppTextStyles.size14weight4(colors.secText),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${widget.amount.toStringAsFixed(2)} JD",
                          style: AppTextStyles.size26weight5(colors.primary),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "For: ${widget.project.title}",
                          style: AppTextStyles.size14weight5(colors.text),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. قائمة البطاقات
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payment Methods",
                          style: AppTextStyles.size16weight5(colors.text),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddCardPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Add New"),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: StreamBuilder<List<CreditCardModel>>(
                      stream: _cardsRepo.getUserCards(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.credit_card_off,
                                  size: 50,
                                  color: colors.secText,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "No cards saved yet",
                                  style: TextStyle(color: colors.secText),
                                ),
                              ],
                            ),
                          );
                        }

                        var cards = snapshot.data!;
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            final card = cards[index];
                            final isSelected = _selectedCardId == card.id;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCardId = card.id;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.primary.withOpacity(0.1)
                                      : colors.background,
                                  border: Border.all(
                                    color: isSelected
                                        ? colors.primary
                                        : colors.container,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    // أيقونة الفيزا
                                    Icon(
                                      Icons.credit_card,
                                      color: isSelected
                                          ? colors.primary
                                          : colors.secText,
                                      size: 30,
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            card.cardType, // Visa / Mastercard
                                            style: AppTextStyles.size14weight5(
                                              colors.text,
                                            ),
                                          ),
                                          Text(
                                            "**** **** **** ${card.last4Digits}",
                                            style: AppTextStyles.size14weight4(
                                              colors.secText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: colors.primary,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // 3. زر الدفع
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.background,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: AppFormButton(
                      buttonText: "Pay ${widget.amount} JD",
                      isloading: controller.isLoading,
                      onPressed: () {
                        if (_selectedCardId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select a card first"),
                            ),
                          );
                          return;
                        }

                        controller.processPayment(
                          context: context,
                          project: widget.project,
                          amount: widget.amount,
                          userId: userId,
                          userName:
                              "Current User", // يمكنك جلبه من UserProvider
                          paymentMethodId: _selectedCardId!,
                          type: widget.type,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

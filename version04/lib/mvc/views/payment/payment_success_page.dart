import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/views/payment/widgets/bill_row.dart';

class PaymentSuccessPage extends StatelessWidget {
  final double amount;
  final String projectName;
  final String date;

  const PaymentSuccessPage({
    super.key,
    required this.amount,
    required this.projectName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // === success icon ===
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 60, color: colors.green),
              ),

              const SizedBox(height: 24),

              Text(
                "Thank you!",
                style: AppTextStyles.size26weight5(colors.text),
              ),
              const SizedBox(height: 8),
              Text(
                "Your transaction was successful",
                style: AppTextStyles.size14weight4(colors.secText),
              ),

              const SizedBox(height: 40),

              // === bill details ===
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.container,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    AppBillRow(label: "Date", value: date),
                    const Divider(height: 30),
                    AppBillRow(label: "To", value: projectName),
                    const Divider(height: 30),
                    AppBillRow(
                      label: "Total",
                      value: "$amount JD",
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // === back button ===
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    // === back to layout page ===
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    "Done",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

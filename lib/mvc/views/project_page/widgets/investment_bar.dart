import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/models/transaction_model.dart';
import 'package:iep_app/mvc/views/payment/select_payment_page.dart';

final colors = AppColors.light;

class InvestmentBar extends StatelessWidget {
  const InvestmentBar({
    super.key,
    required this.current,
    required this.goal,
    required this.investors,
    required this.project,
  });

  final double current;
  final double goal;
  final int investors;
  final ProjectModel project;

  // === to show the number(money ammount) input dialog ===
  void _showAmountDialog(BuildContext context, TransactionType type) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          type == TransactionType.investment
              ? "Invest Amount"
              : "Donate Amount",
          style: AppTextStyles.size16weight5(colors.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter amount (e.g. 50)",
                suffixText: "JD",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                AppSnackBarState.show(
                  context,
                  color: colors.red,
                  content: "please enter valid numbers",
                );
                return;
              }

              Navigator.pop(ctx);

              // === go to payment page ===
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectPaymentPage(
                    project: project,
                    amount: amount,
                    type: type,
                  ),
                ),
              );
            },
            child: Text("Next", style: TextStyle(color: colors.background)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSatsfiesTarget =
        project.isSatisfiesTarget ?? false; // chuck to disable payments actions

    // === calc the percentage + protect from divide on zero ===
    double progress = (goal > 0) ? (current / goal) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.secTextShapes)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // === bar title + percentage ===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Investment Progress",
                style: AppTextStyles.size16weight5(colors.text),
              ),
              Text(
                "${(progress * 100).toStringAsFixed(1)}%",
                style: AppTextStyles.size16weight5(colors.primary),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // === show the target & current investments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Raised: ${current.toInt()} JD",
                style: AppTextStyles.size14weight5(colors.text),
              ),
              Text(
                "Goal: ${goal.toInt()} JD",
                style: AppTextStyles.size14weight5(colors.secText),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // === progress bar ===
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.secTextShapes.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(10),
                value: progress,
                backgroundColor: colors.secTextShapes.withOpacity(0.5),
                color: colors.primary,
                minHeight: 12,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // === number of investors ===
          Row(
            children: [
              Icon(Icons.people_outline, size: 18, color: colors.secText),
              const SizedBox(width: 6),
              Text(
                "$investors Investors",
                style: AppTextStyles.size12weight4(colors.secText),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // === invest & donation buttons ===
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isSatsfiesTarget
                      ? null
                      : () => _showAmountDialog(
                          context,
                          TransactionType.investment,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Invest",
                    style: AppTextStyles.size14weight5(colors.background),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: isSatsfiesTarget
                      ? null
                      : () => _showAmountDialog(
                          context,
                          TransactionType.donation,
                        ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: colors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Donate",
                    style: AppTextStyles.size14weight5(colors.primary),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // === the note ===
          Center(
            child: Text(
              "Donation will not return a Profit",
              style: AppTextStyles.size12weight4(colors.secText),
            ),
          ),
        ],
      ),
    );
  }
}

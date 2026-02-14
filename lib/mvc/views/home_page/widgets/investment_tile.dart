import 'package:flutter/material.dart';
import 'package:iep_app/mvc/controllers/project_page/project_controller.dart';
import 'package:intl/intl.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/models/transaction_model.dart';

final colors = AppColors.light;

class InvestmentTile extends StatelessWidget {
  final TransactionModel transaction;

  const InvestmentTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    bool isInvestment = transaction.type == TransactionType.investment;

    String formattedDate = DateFormat(
      // the date & time formated
      'MMM d, yyyy • h:mm a',
    ).format(transaction.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ProjectsController().fetchAndNavigateToProject(
            context,
            transaction.projectId,
          ),
          child: Row(
            children: [
              // === project icon ===
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade100,
                  child: Icon(
                    isInvestment ? Icons.trending_up : Icons.favorite,
                    color: colors.primary,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // === details ===
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.projectTitle,
                      style: AppTextStyles.size16weight5(colors.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // === tansaction type icon ===
                        Icon(
                          isInvestment
                              ? Icons.monetization_on_outlined
                              : Icons.volunteer_activism_outlined,
                          size: 14,
                          color: isInvestment ? colors.blue : colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isInvestment ? "Investment" : "Donation",
                          style: AppTextStyles.size12weight4(
                            isInvestment ? colors.blue : colors.orange,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text("•", style: TextStyle(color: colors.secText)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: AppTextStyles.size12weight4(colors.secText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // === amount of money ===
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${transaction.amount.toStringAsFixed(0)} JD",
                    style: AppTextStyles.size16weight6(colors.green),
                  ),
                  if (transaction.status == 'success')
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

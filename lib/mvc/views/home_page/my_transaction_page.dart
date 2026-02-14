import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/models/transaction_model.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/repositories/transaction_repository.dart';
import 'package:iep_app/mvc/views/home_page/widgets/investment_tile.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';

final colors = AppColors.light;

class MyTransactionPage extends StatelessWidget {
  const MyTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = UserProvider.instance;
    final String currentUserId = provider.currentUserId!;
    final TransactionRepository repo = TransactionRepository();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: colors.secText)),
        title: Text(
          "My Funds",
          style: AppTextStyles.size18weight5(colors.text),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<List<TransactionModel>>(
          stream: repo.getUserTransactions(currentUserId),
          builder: (context, snapshot) {
            // === is loading phase ===
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: colors.primary),
              );
            }

            // === error phase ===
            if (snapshot.hasError) {
              return AppUnFoundPage(text: "Error loading data");
            }

            // === no data phase ===
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return AppUnFoundPage(
                icon: Icons.savings_outlined,
                text: "No investments yet",
              );
            }

            // === list the data phase ===
            final transactions = snapshot.data!;

            double totalInvested = 0;
            for (var t in transactions) {
              // go through the list,element elemnet
              if (t.type == TransactionType.investment) {
                totalInvested += t.amount; // sum all the transactions
              }
            }
            return Column(
              children: [
                // === investment summary ===
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Value Invested",
                        style: AppTextStyles.size14weight4(
                          colors.background.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$totalInvested JD",
                        style: AppTextStyles.size26weight5(colors.background),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            color: colors.background,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${transactions.length} Transactions",
                            style: AppTextStyles.size12weight4(
                              colors.background,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // === list title ===
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "History",
                      style: AppTextStyles.size18weight5(colors.text),
                    ),
                  ),
                ),

                // === actual transaction ===
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return InvestmentTile(transaction: transactions[index]);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

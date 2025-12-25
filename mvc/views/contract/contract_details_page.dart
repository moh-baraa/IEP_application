import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/models/contract_model.dart';
import 'package:intl/intl.dart';

class ContractDetailsPage extends StatelessWidget {
  final ContractModel contract;

  const ContractDetailsPage({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(        shape: Border(
          bottom: BorderSide(color: colors.secText),
        ),
        title: Text(
          "Investment Contract",
          style: AppTextStyles.size16weight5(colors.text),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === title ===
              Center(
                child: Text(
                  contract.projectTitle,
                  style: AppTextStyles.size20weight6(
                    colors.primary,
                  ).copyWith(decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Date: ${DateFormat('yyyy-MM-dd').format(contract.createdAt)}",
                  style: AppTextStyles.size14weight4(colors.text),
                ),
              ),
              const Divider(thickness: 2),

              // === fainancial details ===
              _buildInfoRow(
                "Total Investment",
                "${contract.totalInvestedAmount} JD",
              ),
              _buildInfoRow(
                "Total Donations",
                "${contract.totalDonatedAmount} JD",
              ),
              const SizedBox(height: 20),

              // === contract details ===
              Text(
                "Terms & Conditions:",
                style: AppTextStyles.size16weight6(colors.text),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: colors.background,
                ),
                child: Text(
                  contract.termsAndConditions,
                  style: AppTextStyles.size14weight4(
                    colors.text,
                  ).copyWith(height: 1.5),
                ),
              ),

              const SizedBox(height: 20),

              // === investors table ===
              Text(
                "Schedule A: Investors List",
                style: AppTextStyles.size16weight6(colors.text),
              ),
              const SizedBox(height: 10),
              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  // Header
                  TableRow(
                    decoration: BoxDecoration(color: colors.container),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Name",
                          style: AppTextStyles.size14weight5(colors.text),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Amount",
                          style: AppTextStyles.size14weight5(colors.text),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Equity %",
                          style: AppTextStyles.size14weight5(colors.text),
                        ),
                      ),
                    ],
                  ),
                  // Data
                  ...contract.investors.map((inv) {
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            inv.name,
                            style: AppTextStyles.size13weight4(colors.text),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "${inv.amount}",
                            style: AppTextStyles.size13weight4(colors.text),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "${inv.equityPercentage}%",
                            style: AppTextStyles.size13weight4(colors.text),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  "--- End of Document ---",
                  style: AppTextStyles.size14weight4(colors.secText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.size14weight5(AppColors.light.text)),
          Text(value, style: AppTextStyles.size14weight4(AppColors.light.text)),
        ],
      ),
    );
  }
}

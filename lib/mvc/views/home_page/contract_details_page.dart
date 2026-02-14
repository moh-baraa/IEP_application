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
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: colors.secText)),
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
                  style: AppTextStyles.size26weight5(colors.primary),
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

              const SizedBox(height: 25),
              // === math logic ===
              Builder(
                builder: (context) {
                  // === total amount ===
                  double totalRaised =
                      contract.totalInvestedAmount +
                      contract.totalDonatedAmount;

                  // === owner share from the project ===
                  // === 50% of investment + 100% of donation ===
                  double ownerShareValue =
                      contract.totalDonatedAmount +
                      (contract.totalInvestedAmount * 0.5);
                  double ownerSharePercent = (totalRaised > 0)
                      ? (ownerShareValue / totalRaised) * 100
                      : 0.0;

                  // === investors share ===
                  // === 50% of investment ===
                  double investorsShareValue =
                      contract.totalInvestedAmount * 0.5;
                  double investorsSharePercent = (totalRaised > 0)
                      ? (investorsShareValue / totalRaised) * 100
                      : 0.0;

                  return Column(
                    children: [
                      // === show the total ===
                      _buildInfoRow(
                        "Total Raised Capital",
                        "${totalRaised.toStringAsFixed(1)} JD",
                        isBold: true,
                      ),
                      const SizedBox(height: 20),

                      // === table show how much the share for every part ===
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // === table heads ===
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colors.container,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Party",
                                      style: AppTextStyles.size14weight5(
                                        colors.text,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Value (JD)",
                                      style: AppTextStyles.size14weight5(
                                        colors.text,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Equity %",
                                      style: AppTextStyles.size14weight5(
                                        colors.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // === owner row ===
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Project Owner",
                                          style: AppTextStyles.size13weight4(
                                            colors.text,
                                          ),
                                        ),
                                        Text(
                                          "(Donations + 50% Inv)",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: colors.secText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      ownerShareValue.toStringAsFixed(1),
                                      style: AppTextStyles.size13weight4(
                                        colors.primary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${ownerSharePercent.toStringAsFixed(1)}%",
                                      style: AppTextStyles.size14weight5(
                                        colors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Divider(height: 1),

                            // === investors row ===
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Investors Pool",
                                          style: AppTextStyles.size13weight4(
                                            colors.text,
                                          ),
                                        ),
                                        Text(
                                          "(50% Inv)",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: colors.secText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      investorsShareValue.toStringAsFixed(1),
                                      style: AppTextStyles.size13weight4(
                                        colors.blue,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${investorsSharePercent.toStringAsFixed(1)}%",
                                      style: AppTextStyles.size14weight5(
                                        colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 50),

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
                // === widget to manupulate the text style in the rules ===
                child: ContractTextRenderer(
                  text: contract.termsAndConditions,
                  baseStyle: AppTextStyles.size14weight4(
                    colors.text,
                  ).copyWith(height: 1.6),
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
                  // === Header ===
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
                  // === Data ===
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

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.size14weight5(AppColors.light.text)),
          Text(
            value,
            style: isBold
                ? AppTextStyles.size16weight6(AppColors.light.primary)
                : AppTextStyles.size14weight4(AppColors.light.text),
          ),
        ],
      ),
    );
  }
}

// === using ** to make the titles bold ===
class ContractTextRenderer extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;

  const ContractTextRenderer({super.key, required this.text, this.baseStyle});

  @override
  Widget build(BuildContext context) {
    List<String> parts = text.split('**'); // split the code to titles and text

    return RichText(
      text: TextSpan(
        style: baseStyle ?? const TextStyle(color: Colors.black, fontSize: 14),
        children: List.generate(parts.length, (index) {
          if (index % 2 == 0) {
            // always the even indeces are normal text
            return TextSpan(text: parts[index]);
          } else {
            // always the odd indeces are titles
            return TextSpan(
              text: parts[index],
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          }
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/models/contract_model.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/repositories/contract_repository.dart';
import 'package:iep_app/mvc/views/home_page/contract_details_page.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyContractsPage extends StatelessWidget {
  const MyContractsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().currentUserId;
    final ContractRepository repo = ContractRepository();
    final colors = AppColors.light;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: colors.secText)),
        title: Text(
          "My Contracts",
          style: AppTextStyles.size16weight5(colors.text),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
      ),
      body: StreamBuilder<List<ContractModel>>(
        stream: repo.getUserContracts(
          userId!,
        ), // get the contract from the firestore
        builder: (context, snapshot) {
          // === is loading phase ===
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // === no data phase ===
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return AppUnFoundPage(
              icon: Icons.description_outlined,
              text: "No contracts yet.",
              subText:
                  "Contracts are generated when a project\nreaches its funding goal.",
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final contract = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildContractCard(context, contract, colors),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContractCard(
    BuildContext context,
    ContractModel contract,
    dynamic colors,
  ) {
    return GestureDetector(
      onTap: () {
        // === open contract details page and pass the contract object ===
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContractDetailsPage(contract: contract),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.secondary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contract.projectTitle,
                    style: AppTextStyles.size16weight5(colors.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Signed on: ${DateFormat('yyyy-MM-dd').format(contract.createdAt)}",
                    style: TextStyle(fontSize: 12, color: colors.secText),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iep_app/mvc/models/contract_investor.dart';
import 'package:iep_app/mvc/models/contract_model.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/models/transaction_model.dart';
import 'package:iep_app/mvc/repositories/contract_repository.dart';
import 'package:iep_app/mvc/repositories/user_repository.dart';

class ContractGeneratorService {
  final ContractRepository _contractRepo = ContractRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _userRepo = UserRepository();

  // === invoke when the project get the target money ===
  Future<void> generateAndSaveContract(ProjectModel project) async {
    try {
      // === Security Check: Idempotency ===
      var existingContract = await _firestore
          .collection('contracts')
          .where('projectId', isEqualTo: project.id)
          .limit(1)
          .get();

      if (existingContract.docs.isNotEmpty) {
        print(
          "⚠️ Contract already exists for project ${project.title}. Skipping generation.",
        );
        return;
      }

      // === get all successfull transactions in this poject ===
      QuerySnapshot querySnapshot = await _firestore
          .collection('transactions')
          .where('projectId', isEqualTo: project.id)
          .where('status', isEqualTo: 'success')
          .get();

      List<TransactionModel> transactions = querySnapshot.docs
          .map(
            (doc) => TransactionModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      // === sperate the donation and investment ===
      double totalInvested = 0.0;
      double totalDonated = 0.0;
      Map<String, ContractInvestor> investorsMap =
          {}; // compose same user investment

      for (var tx in transactions) {
        if (tx.type == TransactionType.donation) {
          totalDonated += tx.amount;
        } else {
          totalInvested += tx.amount;

          if (investorsMap.containsKey(tx.userId)) {
            var existing = investorsMap[tx.userId]!;
            investorsMap[tx.userId] = ContractInvestor(
              userId: existing.userId,
              name: existing.name,
              amount: existing.amount + tx.amount,
              equityPercentage: 0,
            );
          } else {
            investorsMap[tx.userId] = ContractInvestor(
              userId: tx.userId,
              name: tx.userName,
              amount: tx.amount,
              equityPercentage: 0,
            );
          }
        }
      }

      List<ContractInvestor> finalInvestors = [];
      List<String> participants = [project.ownerId!];

      // === Calculate Equity  ===
      investorsMap.forEach((key, value) {
        double totalRaised = totalInvested + totalDonated;
        // === Safe Division ===
        double equity = (totalRaised > 0)
            ? (value.amount / totalRaised) *
                  50 // investors have 50%
            : 0.0;

        finalInvestors.add(
          ContractInvestor(
            userId: value.userId,
            name: value.name,
            amount: value.amount,
            equityPercentage: double.parse(equity.toStringAsFixed(2)),
          ),
        );
        participants.add(value.userId);
      });
      // === Generate Legal Text  ===
      String ownerRealName = await _userRepo.getUserName(
        userId: project.ownerId!,
      );
      String legalText = _generateLegalText(
        project.title,
        ownerRealName,
        totalInvested,
      );

      ContractModel contract = ContractModel(
        id: '',
        projectId: project.id!,
        projectTitle: project.title,
        ownerId: project.ownerId!,
        ownerName: ownerRealName,
        totalInvestedAmount: totalInvested,
        totalDonatedAmount: totalDonated,
        createdAt: DateTime.now(),
        investors: finalInvestors,
        participantsIds: participants,
        termsAndConditions: legalText,
      );

      await _contractRepo.createContract(contract);

      print("✅ Contract generated successfully for ${project.title}");
    } catch (e) {
      print("❌ Error generating contract: $e");
    }
  }

  String _generateLegalText(
    String title,
    String ownerName,
    double totalCapital,
  ) {
    String date = DateTime.now().toString().split(' ')[0]; // Today's date
    return """
    **INVESTMENT AND PARTNERSHIP AGREEMENT (ELECTRONIC)**
    
    Pursuant to the Jordanian Electronic Transactions Law No. (15) of 2015, this agreement is executed on **$date** regarding the project **"$title"**.

    **1. PARTIES:**
       - **First Party (Project Manager):** $ownerName, hereinafter referred to as the "Project Owner".
       - **Second Party (Investors):** The individuals listed with their respective equity shares in "Schedule A" of this agreement.

    **2. SUBJECT:**
       The parties acknowledge that the (IEP) platform is the approved technical and legal intermediary. This agreement aims to regulate the investment of a total capital of (**$totalCapital JOD**) for the development and operation of the aforementioned project.

    **3. EQUITY & PROFIT DISTRIBUTION:**
       - Net annual profits shall be distributed as follows: **Fifty percent (50%)** shall be allocated to the Project Owner (First Party), and the remaining **Fifty percent (50%)** shall be distributed to the Investors (Second Party) pro-rata based on each investor's shareholding (as detailed in Schedule A).
       - Investors are not entitled to claim capital repayment except in cases of liquidation or sale of shares in accordance with the platform's policies.

    **4. DONATIONS:**
       Any funds contributed under the classification of "Donation" are considered non-refundable support. **These funds are fully allocated to the Project Owner's equity and are not subject to the profit distribution mechanism described in Clause 3.** Such contributions grant no ownership rights, equity, or profit-sharing to the donor.

    **5. MANAGEMENT & OVERSIGHT:**
       - The "Project Owner" shall assume **full operational management** of the project.
       - The project is subject to regulatory oversight by the "Greater Amman Municipality" to ensure compliance with applicable laws and regulations.
       - The Project Owner commits to providing periodic progress updates to investors via the IEP application.

    **6. INTELLECTUAL PROPERTY:**
       In accordance with the regulations of the Department of the National Library (Copyright), the ownership of the project's idea, brand, and intellectual property remains solely with the Project Owner. Investors hold rights **strictly to the financial returns** of the commercial entity.

    **7. DISPUTE RESOLUTION & APPLICABLE LAW:**
       In the event of any dispute, the parties shall first resort to arbitration through the IEP platform administration. If a resolution cannot be reached, the courts of "Amman - Hashemite Kingdom of Jordan" shall have exclusive jurisdiction, and Jordanian law shall apply.
       
    * This agreement is considered electronically signed and legally binding once the funding goal is met via the application and requires no physical signature.
    """;
  }
}

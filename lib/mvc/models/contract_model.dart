import 'package:iep_app/mvc/models/contract_investor.dart';

class ContractModel {
  final String id;
  final String projectId;
  final String projectTitle;
  final String ownerId;
  final String ownerName;
  final double totalInvestedAmount;
  final double totalDonatedAmount; 
  final DateTime createdAt;
  
  // === investors list to show in the contract ===
  final List<ContractInvestor> investors;
  
  // to show the contract in all my contract particpicants(owner + investors)
  final List<String> participantsIds; 
  
  // === the terms in the contract (in law manner) ===
  final String termsAndConditions;

  ContractModel({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.ownerId,
    required this.ownerName,
    required this.totalInvestedAmount,
    required this.totalDonatedAmount,
    required this.createdAt,
    required this.investors,
    required this.participantsIds,
    required this.termsAndConditions,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'projectTitle': projectTitle,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'totalInvestedAmount': totalInvestedAmount,
      'totalDonatedAmount': totalDonatedAmount,
      'createdAt': createdAt.toIso8601String(),
      'investors': investors.map((x) => x.toMap()).toList(),
      'participantsIds': participantsIds,
      'termsAndConditions': termsAndConditions,
    };
  }

  factory ContractModel.fromMap(Map<String, dynamic> map, String id) {
    return ContractModel(
      id: id,
      projectId: map['projectId'] ?? '',
      projectTitle: map['projectTitle'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      totalInvestedAmount: (map['totalInvestedAmount'] ?? 0).toDouble(),
      totalDonatedAmount: (map['totalDonatedAmount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      investors: List<ContractInvestor>.from(
        (map['investors'] ?? []).map((x) => ContractInvestor.fromMap(x)),
      ),
      participantsIds: List<String>.from(map['participantsIds'] ?? []),
      termsAndConditions: map['termsAndConditions'] ?? '',
    );
  }
}

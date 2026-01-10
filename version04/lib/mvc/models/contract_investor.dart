class ContractInvestor {
  // class for help the investors & project owner in contract
  final String userId;
  final String name;
  final double amount;
  final double equityPercentage; // the percentage

  ContractInvestor({
    required this.userId,
    required this.name,
    required this.amount,
    required this.equityPercentage,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'amount': amount,
      'equityPercentage': equityPercentage,
    };
  }

  factory ContractInvestor.fromMap(Map<String, dynamic> map) {
    return ContractInvestor(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      equityPercentage: (map['equityPercentage'] ?? 0).toDouble(),
    );
  }
}

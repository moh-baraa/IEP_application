enum TransactionType { investment, donation }

class TransactionModel {
  final String id;
  final String userId;
  final String userName;
  final String projectId;
  final String projectTitle; 
  final double amount;
  final TransactionType type;
  final DateTime timestamp;
  final String paymentMethodId;
  final String status;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.projectId,
    required this.projectTitle,
    required this.amount,
    required this.type,
    required this.timestamp,
    required this.paymentMethodId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'projectId': projectId,
      'projectTitle': projectTitle, 
      'amount': amount,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'paymentMethodId': paymentMethodId,
      'status': status,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      projectId: map['projectId'] ?? '',
      projectTitle: map['projectTitle'] ?? 'Unknown Project', 
      amount: (map['amount'] ?? 0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.donation,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      paymentMethodId: map['paymentMethodId'] ?? '',
      status: map['status'] ?? 'unknown',
    );
  }
}
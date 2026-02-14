// ignore: constant_identifier_names
enum JobType { Investor, Donator }

class CommentModel {
  final String? id;
  final String ownerId;
  final String ownerName;
  final JobType ownerJob;
  final double rate;
  final String text;
  final DateTime? createdAt;
  CommentModel({
    this.id,
    required this.ownerId,
    required this.ownerName,
    this.ownerJob = JobType.Investor,
    required this.rate,
    required this.text,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': ownerId,
      'name': ownerName,
      'job': ownerJob.toString(),
      'text': text,
      'userRating': rate,
      'timestamp': createdAt,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> data, String docId) {
    return CommentModel(
      ownerId: data['userId'] ?? '',
      ownerName: data['name'] ?? '',
      rate: data['userRating'] ?? 0,
      text: data['text'] ?? '',
    );
  }
}

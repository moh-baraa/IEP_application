import 'package:iep_app/mvc/models/comment_model.dart';

class ProjectModel {
  String? id;
  String? ownerId;
  List<String> images;
  double targetFunds;
  double totalFunds;
  int numOfReviews;
  double rating;
  String title;
  String description;
  DateTime? date;
  List<CommentModel>? comments;
  String? bankAccount;
  int upVote;
  bool isApproved; // the admins approved or not
  bool isFrozen;
  // ignore: non_constant_identifier_names
  int investors_count; //how much people are invest in this project
  bool isSatisfiesTarget;

  ProjectModel({
    this.isApproved = false,
    this.isFrozen = false,
    this.id,
    required this.images,
    required this.targetFunds,
    required this.title,
    required this.description,
    this.totalFunds = 0.0,
    this.numOfReviews = 0,
    this.rating = 0.0,
    this.date,
    this.comments,
    this.bankAccount,
    this.upVote = 0,
    this.ownerId,
    // ignore: non_constant_identifier_names
    this.investors_count = 0,
    this.isSatisfiesTarget = false,
  });

  // === transfer objects to map ===
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'images': images,
      'target_amount': targetFunds,
      'total_raised': totalFunds,
      'rating': rating,
      'reviews_count': numOfReviews,
      'owner_id': ownerId,
      'up_votes': upVote,
      'investors_count': investors_count,
      'isApproved': isApproved, //
      'isFrozen': isFrozen,
      'isSatisfiesTarget': isSatisfiesTarget,
    };
  }

  // === to transfer the data into objects ===
  factory ProjectModel.fromMap(Map<String, dynamic> data, String docId) {
    return ProjectModel(
      id: docId,
      ownerId: data['owner_id']?.toString() ?? '',
      title: data['title']?.toString() ?? 'No Title',
      description: data['description']?.toString() ?? 'No Description',

      targetFunds:
          double.tryParse(
            data['target_amount'].toString().replaceAll(',', ''),
          ) ??
          0.0,
      totalFunds:
          double.tryParse(data['total_raised']?.toString() ?? '0') ?? 0.0,

      images: (data['images'] is List)
          ? (data['images'] as List).map((e) => e.toString()).toList()
          : [],

      rating: double.tryParse(data['rating'].toString()) ?? 0.0,
      numOfReviews: int.tryParse(data['reviews_count'].toString()) ?? 0,
      date: data['created_at'] != null ? (data['created_at']).toDate() : null,

      bankAccount: data['bank_account']??'', 
      upVote: int.tryParse(data['up_votes'].toString()) ?? 0,
      investors_count: int.tryParse(data['investors_count'].toString()) ?? 0,
      isApproved: data['isApproved'] ?? false,
      isFrozen: data['isFrozen'] ?? false,
      isSatisfiesTarget: data['isSatisfiesTarget'] ?? false,
    );
  }

  // === for updating the screen ===
  ProjectModel copyWith({
    String? id,
    String? ownerId,
    List<String>? images,
    double? targetFunds,
    double? totalFunds,
    int? numOfReviews,
    double? rating,
    String? title,
    String? description,
    DateTime? date,
    List<CommentModel>? comments,
    String? bankAccount,
    int? upVote,
    bool? isApproved,
    bool? isFrozen,
    // ignore: non_constant_identifier_names
    int? investors_count,
    bool? isSatisfiesTarget,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      images: images ?? this.images,
      targetFunds: targetFunds ?? this.targetFunds,
      totalFunds: totalFunds ?? this.totalFunds,
      numOfReviews: numOfReviews ?? this.numOfReviews,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      comments: comments ?? this.comments,
      bankAccount: bankAccount ?? this.bankAccount,
      upVote: upVote ?? this.upVote,
      isApproved: isApproved ?? this.isApproved,
      isFrozen: isFrozen ?? this.isFrozen,
      investors_count: investors_count ?? this.investors_count,
      isSatisfiesTarget: isSatisfiesTarget ?? this.isSatisfiesTarget,
    );
  }
}

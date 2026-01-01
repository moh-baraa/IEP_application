class CommentModel {
final String id;
  final String authorId; // غيرت author إلى authorId للدقة
  final String content;
  final DateTime createdAt;
  CommentModel({required this.authorId, required this.content, required this.id, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'content': content,
      'createdAt': createdAt.toIso8601String(), 
    };
  }
  // أضف factory fromMap هنا...
}

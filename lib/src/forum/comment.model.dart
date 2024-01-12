class CommentModel {
  final String id;
  final String content;
  final String uid;
  final String createdAt;

  CommentModel({
    required this.id,
    required this.content,
    required this.uid,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'],
      content: map['content'],
      uid: map['uid'],
      createdAt: map['createdAt'],
    );
  }
}
